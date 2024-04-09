import * as dotenv from 'dotenv';
import { Client, GatewayIntentBits } from 'discord.js';
import { createClient } from '@supabase/supabase-js';
import { assert, transform } from './util';
import { Intro, Sound } from './types';
import { z } from 'zod';
import {
	StreamType,
	createAudioPlayer,
	createAudioResource,
	joinVoiceChannel
} from '@discordjs/voice';
import { createReadStream } from 'node:fs';
import { PassThrough } from 'node:stream';
import Soundboard from './soundboard';

dotenv.config();

function env(name: string): string {
	const value = process.env[name];
	if (!value) throw new Error(`${name} is missing`);
	return value;
}

const SUPABASE_URL = env('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = env('SUPABASE_SERVICE_ROLE_KEY');
const DISCORD_BOT_TOKEN = env('DISCORD_BOT_TOKEN');
const GUILD_ID = env('GUILD_ID');

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const client = new Client({
	intents: [
		GatewayIntentBits.Guilds,
		GatewayIntentBits.GuildMembers,
		GatewayIntentBits.GuildVoiceStates
	]
});

const soundboard = new Soundboard(supabase);
let sounds: Map<string, Sound> | null = null;
let intros: Map<string, Intro> | null = null;
const lastDisconnect = new Map<string, number>();

supabase
	.from('sounds')
	.select('*')
	.then(async (res) => {
		if (res.error) throw res.error;
		sounds = new Map(
			z
				.array(Sound)
				.parse(res.data)
				.map((x) => {
					soundboard.addSound(x);
					return [x.id, x];
				})
		);
		console.log('Received all sounds! Count:', sounds.size);
	});

supabase
	.from('intros')
	.select('*')
	.then((res) => {
		if (res.error) throw res.error;
		intros = new Map(
			z
				.array(Intro)
				.parse(res.data)
				.map((x) => [x.id, x])
		);
		console.log('Received all intros! Count:', intros.size);
	});

supabase
	.channel('table-db-changes')
	.on(
		'postgres_changes',
		{
			event: 'INSERT',
			schema: 'public',
			table: 'sounds'
		},
		(payload) => console.log(payload)
	)
	.subscribe();

supabase
	.channel('soundboard')
	.on('broadcast', { event: 'play' }, (payload) => {
		console.log('Play:', payload);
		assert(soundboard.play(payload.sound));
	})
	.subscribe((state) => {
		console.log('Channel[soundboard] state:', state);
	});

client.on('ready', async () => {
	console.log(`Logged in as ${client.user!.tag}!`);
	const guild = await client.guilds.fetch(GUILD_ID);
	const members = await guild.members.fetch();

	const data = await Promise.all(
		members
			.map((member) => member.user)
			.filter((user) => !user.bot)
			.map(async ({ id }) => {
				// Requires force fetch to get the accent color
				// https://discord.js.org/docs/packages/discord.js/14.14.1/User:Class#accentColor
				const user = await client.users.fetch(id, { force: true });
				return transform(user);
			})
	);

	await supabase.from('members').upsert(data);
	console.log('Updated DB!');

	const connection = joinVoiceChannel({
		channelId: '599177587884818443',
		guildId: guild.id,
		adapterCreator: guild.voiceAdapterCreator
	});

	// const buffer1 = await Soundboard._decodeS16LE(createReadStream('./audio1.mp3'));
	// const buffer2 = await Soundboard._decodeS16LE(createReadStream('./audio2.mp3'));

	// const streamOut = new PassThrough();

	// const frequency = 48_000;
	// const channels = 2;
	// const sampleSize = 2;
	// const sampleRate = frequency * channels;
	// const chunkSize = 4096;
	// const interval = (chunkSize / (sampleRate * sampleSize)) * 1_000;

	// let cursor = 0;
	// const timer = setInterval(() => {
	// 	if (cursor > buffer1.byteLength || cursor > buffer2.byteLength) {
	// 		clearInterval(timer);
	// 		streamOut.end();
	// 		return;
	// 	}
	// 	const chunk1 = buffer1.subarray(cursor, cursor + chunkSize);
	// 	const chunk2 = buffer2.subarray(cursor, cursor + chunkSize);
	// 	const combined = Buffer.alloc(chunkSize);
	// for (let idx = 0; idx < chunkSize / sampleSize; idx++) {
	// 	// if (idx % 2 == 0) continue;
	// 	combined.writeInt16LE(
	// 		Math.floor((chunk1.readInt16LE(idx * 2) + chunk2.readInt16LE(idx * 2)) / Math.sqrt(2)),
	// 		idx * 2
	// 	);
	// }
	// 	// assert(streamOut.write(combined));
	// 	assert(streamOut.write(chunk2));
	// 	cursor += chunkSize;
	// }, interval);

	const resource = createAudioResource(soundboard.stream, { inputType: StreamType.Raw });
	const player = createAudioPlayer();
	player.play(resource);
	connection.subscribe(player);
});

client.login(DISCORD_BOT_TOKEN);
