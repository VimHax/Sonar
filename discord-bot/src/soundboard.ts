import { PassThrough, pipeline, Readable } from 'node:stream';
import axios, { HttpStatusCode } from 'axios';
import prism from 'prism-media';
import { SupabaseClient } from '@supabase/supabase-js';
import { Sound } from './types';
import { assert, humanFileSize } from './util';
import { performance } from 'perf_hooks';
import {
	createAudioPlayer,
	createAudioResource,
	StreamType,
	VoiceConnection
} from '@discordjs/voice';

const FFMPEG_PCM_ARGUMENTS = [
	'-analyzeduration',
	'0',
	'-loglevel',
	'0',
	'-f',
	's16le',
	'-ar',
	'48000',
	'-ac',
	'2'
];

/** Samples per second per channel. */
const FREQUENCY = 48_000;
/** Number of channels. */
const CHANNELS = 2;
/** Bytes per sample. */
const SAMPLE_SIZE = 2;
/** Samples per second. */
const SAMPLE_RATE = FREQUENCY * CHANNELS;
/** Bytes per chunk. */
const CHUNK_SIZE = 4096;
/** Amount of time a chunk plays for. */
const CHUNK_DURATION = (CHUNK_SIZE / (SAMPLE_RATE * SAMPLE_SIZE)) * 1_000;
/** Chunks to write ahead. */
const WRITE_AHEAD = 5;

export default class Soundboard {
	private readonly _sounds = new Map<string, { name: string; buffer: Buffer }>();
	private readonly _stream = new PassThrough();
	private readonly _player = createAudioPlayer();
	private _playerPaused = true;
	private _playing: { start: number | null; buffer: Buffer }[] = [];
	private _start: number | null = null;
	private _cursor: number = 0;
	private _paused: number | null = null;
	private _pausedTime: number = 0;

	public constructor(private readonly _supabase: SupabaseClient) {
		const resource = createAudioResource(this._stream, { inputType: StreamType.Raw });
		this._player.play(resource);

		this._tick();
		this._stream.on('drain', () => this._tick());
	}

	public subscribe(connection: VoiceConnection) {
		connection.subscribe(this._player);
	}

	public async addSound(sound: Sound): Promise<void> {
		assert(this._sounds.get(sound.id) === undefined);
		const url = this._getSoundURL(sound);
		const res = await axios.get(url, { responseType: 'arraybuffer' });
		assert(res.status === HttpStatusCode.Ok);
		assert(res.data instanceof Buffer);
		const buffer = await Soundboard._decodeS16LE(Readable.from(res.data));
		assert(buffer.byteLength > 0);
		this._sounds.set(sound.id, { name: sound.name, buffer });
		console.log(
			`[Soundboard] Added Sound(${sound.id}) "${sound.name}" of raw size ${humanFileSize(buffer.byteLength, true)}`
		);
	}

	public play(id: string): boolean {
		const sound = this._sounds.get(id);
		if (sound === undefined) return false;
		this._playing.push({ start: null, buffer: sound.buffer });
		return true;
	}

	private _getSoundURL(sound: Sound): string {
		return this._supabase.storage.from('audio').getPublicUrl(`${sound.author}/${sound.audio}`).data
			.publicUrl;
	}

	static async _decodeS16LE(input: Readable): Promise<Buffer> {
		const output = new PassThrough();
		const ffmpeg = new prism.FFmpeg({
			args: ['-i', '-', ...FFMPEG_PCM_ARGUMENTS]
		});
		pipeline(input, ffmpeg, output, (err) => {
			if (err) throw err;
		});
		const buffer: Buffer = Buffer.concat(await output.toArray());
		return buffer;
	}

	private _tick() {
		const currentTime = performance.now();
		if (this._start === null) this._start = currentTime;
		const currentChunks = Math.floor((currentTime - this._start) / CHUNK_DURATION);

		if (this._paused !== null) {
			this._cursor = currentChunks;
			this._paused = null;
		}

		while (this._cursor - currentChunks < WRITE_AHEAD) {
			this._playing = this._playing.filter((x) => {
				if (x.start === null) return true;
				const chunks = Math.ceil(x.buffer.byteLength / CHUNK_SIZE);
				return this._cursor - x.start <= chunks;
			});

			if (this._playing.length === 0) {
				if (!this._playerPaused) {
					console.log('Pause!');
					this._playerPaused = true;
					this._player.pause();
				}
				this._cursor++;
				continue;
			} else {
				if (this._playerPaused) {
					this._playerPaused = false;
					console.log('Play!');
					this._player.unpause();
				}
			}

			// This technically isn't correct as partial chunks are not properly considered
			const chunk = Buffer.alloc(CHUNK_SIZE);
			const factor = 1 / Math.sqrt(this._playing.length);
			for (const x of this._playing) {
				if (x.start === null) x.start = this._cursor;
				const startByte = (this._cursor - x.start) * CHUNK_SIZE;
				const sub = x.buffer.subarray(startByte, startByte + CHUNK_SIZE);
				for (let idx = 0; idx < sub.byteLength; idx += SAMPLE_SIZE) {
					const value = chunk.readInt16LE(idx) + Math.floor(sub.readInt16LE(idx) * factor);
					chunk.writeInt16LE(Math.max(Math.min(value, 32767), -32768), idx);
				}
			}

			const res = this._stream.write(chunk);
			this._cursor++;
			if (!res) {
				this._paused = performance.now();
				return;
			}
		}

		setTimeout(this._tick.bind(this), CHUNK_DURATION);
	}
}
