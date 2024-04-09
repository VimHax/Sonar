import * as dotenv from 'dotenv';
import { Client, GatewayIntentBits } from 'discord.js';
import { createClient } from '@supabase/supabase-js';
import { assert, transform } from './util';
import { Intro, Sound } from './types';
import { z } from 'zod';
import { joinVoiceChannel } from '@discordjs/voice';
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

	soundboard.subscribe(connection);
});

client.login(DISCORD_BOT_TOKEN);
