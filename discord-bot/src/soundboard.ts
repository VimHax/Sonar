import { PassThrough, pipeline, Readable } from 'node:stream';
import axios, { HttpStatusCode } from 'axios';
import prism from 'prism-media';
import { RealtimeChannel, SupabaseClient } from '@supabase/supabase-js';
import { Sound } from './types';
import { assert, humanFileSize, nonNull } from './util';
import { performance } from 'perf_hooks';
import {
	AudioPlayer,
	createAudioPlayer,
	createAudioResource,
	joinVoiceChannel,
	NoSubscriberBehavior,
	StreamType
} from '@discordjs/voice';
import { z } from 'zod';
import { Client } from 'discord.js';

interface DecodedSound {
	id: string;
	name: string;
	buffer: Buffer;
}

interface PlayingSound extends DecodedSound {
	member: string;
	start: number | null;
}

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
	private readonly _sounds = new Map<string, DecodedSound>();
	private readonly _channel: RealtimeChannel;
	private _stream: PassThrough | null = null;
	private _player: AudioPlayer = createAudioPlayer({
		behaviors: { noSubscriber: NoSubscriberBehavior.Play }
	});
	private _playerPaused = true;
	private _playing: PlayingSound[] = [];
	private _start: number | null = null;
	private _cursor: number = 0;
	private _paused: number | null = null;

	public constructor(
		private readonly _guildID: string,
		private readonly _client: Client,
		private readonly _supabase: SupabaseClient
	) {
		this._tick();

		this._channel = _supabase.channel('soundboard');
		this._channel
			.on('broadcast', { event: 'play' }, async (payload) => {
				console.log('[Channel:soundboard] Play:', payload);
				const res = z.object({ member: z.string(), sound: z.string().uuid() }).safeParse(payload);
				if (!res.success) return;
				const willPlay = await this.play(res.data.sound, res.data.member);
				if (willPlay) {
					this._channel.send({
						type: 'broadcast',
						event: 'playing',
						payload: { member: res.data.member, sound: res.data.sound }
					});
				} else {
					this._channel.send({
						type: 'broadcast',
						event: 'error',
						payload: { member: res.data.member, sound: res.data.sound }
					});
				}
			})
			.subscribe((state) => {
				console.log('[Channel:soundboard] State:', state);
			});
	}

	public async addSound(sound: Sound): Promise<void> {
		assert(this._sounds.get(sound.id) === undefined);
		const url = this._getSoundURL(sound);
		const res = await axios.get(url, { responseType: 'arraybuffer' });
		assert(res.status === HttpStatusCode.Ok);
		assert(res.data instanceof Buffer);
		const buffer = await Soundboard._decodeS16LE(Readable.from(res.data));
		assert(buffer.byteLength > 0);
		this._sounds.set(sound.id, { id: sound.id, name: sound.name, buffer });
		console.log(
			`[Soundboard] Added Sound(${sound.id}) "${sound.name}" of raw size ${humanFileSize(buffer.byteLength, true)}`
		);
	}

	public removeSound(id: string): void {
		const sound = this._sounds.get(id);
		if (sound === undefined) return;
		this._sounds.delete(id);
		console.log(`[Soundboard] Removed Sound(${sound.id}) "${sound.name}"`);
	}

	public async play(id: string, memberID: string): Promise<boolean> {
		const sound = this._sounds.get(id);
		if (sound === undefined) return false;

		const guild = await this._client.guilds.fetch(this._guildID);
		const member = await guild.members.fetch(memberID);
		const channel = member.voice.channel;
		if (channel === null) return false;

		let connection = joinVoiceChannel({
			channelId: channel.id,
			guildId: guild.id,
			adapterCreator: guild.voiceAdapterCreator
		});

		connection.subscribe(this._player);

		this._playing.push({
			id: sound.id,
			member: member.id,
			name: sound.name,
			start: null,
			buffer: sound.buffer
		});
		console.log(
			`[Soundboard] Playing Sound(${sound.id}) "${sound.name}" from Member(${member.id})...`
		);
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
			console.log('[Soundboard] Stream unpaused!');
			this._cursor = currentChunks;
			this._paused = null;
		}

		while (this._cursor - currentChunks < WRITE_AHEAD) {
			this._playing = this._playing.filter((x) => {
				if (x.start === null) return true;
				const chunks = Math.ceil(x.buffer.byteLength / CHUNK_SIZE);
				const stillPlaying = this._cursor - x.start <= chunks;
				if (!stillPlaying) {
					console.log(
						`[Soundboard] Completed Sound(${x.id}) "${x.name}" from Member(${x.member})!`
					);
					this._channel.send({
						type: 'broadcast',
						event: 'completed',
						payload: { member: x.member, sound: x.id }
					});
				}
				return stillPlaying;
			});

			if (this._playing.length === 0) {
				if (!this._playerPaused) {
					console.log('[Soundboard] Stop player!');
					this._playerPaused = true;
					this._player.stop();
					this._stream = null;
				}
				this._cursor++;
				continue;
			} else {
				if (this._playerPaused) {
					this._playerPaused = false;
					console.log('[Soundboard] Unpause player!');
					this._stream = new PassThrough();
					this._stream.on('drain', () => this._tick());
					this._player.play(createAudioResource(this._stream, { inputType: StreamType.Raw }));
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

			const res = nonNull(this._stream).write(chunk);
			this._cursor++;
			if (!res) {
				console.log('[Soundboard] Stream paused!');
				this._paused = performance.now();
				return;
			}
		}

		setTimeout(this._tick.bind(this), CHUNK_DURATION);
	}
}
