import * as dotenv from 'dotenv';
import { Client, GatewayIntentBits, channelLink } from 'discord.js';
import { createClient } from '@supabase/supabase-js';
import { assert, transformUser } from './util';
import { Intro, Sound } from './types';
import { z } from 'zod';
import Soundboard from './soundboard';
import { getVoiceConnection } from '@discordjs/voice';

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

let loaded = false;
let soundboard: Soundboard | null = null;
let intros: Map<string, string> | null = null;
const lastDisconnect = new Map<string, number>();

client.on('ready', async () => {
	console.log(`[Event:Ready] Logged in as ${client.user!.tag}!`);
	const guild = await client.guilds.fetch(GUILD_ID);
	const members = await guild.members.fetch();

	let joinedMembersInDB: Set<string>;
	{
		const res = await supabase.from('members').select('id,joined');
		if (res.error) throw res.error;
		const data = z.array(z.object({ id: z.string(), joined: z.boolean() })).parse(res.data);
		joinedMembersInDB = new Set(data.filter((x) => x.joined).map((x) => x.id));
	}

	const data = await Promise.all(
		members
			.map((member) => member.user)
			.filter((user) => !user.bot)
			.map(async ({ id }) => {
				joinedMembersInDB.delete(id);
				// Requires force fetch to get the accent color
				// https://discord.js.org/docs/packages/discord.js/14.14.1/User:Class#accentColor
				const user = await client.users.fetch(id, { force: true });
				return transformUser(user);
			})
	);

	await supabase.from('members').upsert(data);
	if (joinedMembersInDB.size > 0) {
		await supabase
			.from('members')
			.update({ joined: false })
			.in('id', [...joinedMembersInDB.values()]);
	}

	console.log('[Event:Ready] Updated DB!');

	soundboard = new Soundboard(GUILD_ID, client, supabase);

	{
		const res = await supabase.from('sounds').select('*');
		if (res.error) throw res.error;
		await Promise.allSettled(
			z
				.array(Sound)
				.parse(res.data)
				.map((x) => soundboard!.addSound(x))
		);
		console.log('[Event:Ready] Added sounds!');
	}

	{
		const res = await supabase.from('intros').select('*');
		if (res.error) throw res.error;
		intros = new Map(
			z
				.array(Intro)
				.parse(res.data)
				.map((x) => [x.id, x.sound])
		);
		console.log('[Event:Ready] Added intros!');
	}

	loaded = true;

	supabase
		.channel('table-db-changes')
		.on(
			'postgres_changes',
			{
				event: 'INSERT',
				schema: 'public',
				table: 'sounds'
			},
			(payload) => {
				console.log('[Channel:table-db-changes] Sound INSERT:', payload);
				const data = z.object({ new: Sound }).parse(payload);
				soundboard!.addSound(data.new);
			}
		)
		.on(
			'postgres_changes',
			{
				event: 'DELETE',
				schema: 'public',
				table: 'sounds'
			},
			(payload) => {
				console.log('[Channel:table-db-changes] Sound DELETE:', payload);
				const data = z.object({ old: z.object({ id: z.string().uuid() }) }).parse(payload);
				soundboard!.removeSound(data.old.id);
			}
		)
		.on(
			'postgres_changes',
			{
				event: 'INSERT',
				schema: 'public',
				table: 'intros'
			},
			(payload) => {
				console.log('[Channel:table-db-changes] Intro INSERT:', payload);
				const data = z.object({ new: Intro }).parse(payload);
				intros!.set(data.new.id, data.new.sound);
			}
		)
		.on(
			'postgres_changes',
			{
				event: 'UPDATE',
				schema: 'public',
				table: 'intros'
			},
			(payload) => {
				console.log('[Channel:table-db-changes] Intro UPDATE:', payload);
				const data = z.object({ new: Intro }).parse(payload);
				intros!.set(data.new.id, data.new.sound);
			}
		)
		.on(
			'postgres_changes',
			{
				event: 'DELETE',
				schema: 'public',
				table: 'intros'
			},
			(payload) => {
				console.log('[Channel:table-db-changes] Intro DELETE:', payload);
				const data = z.object({ old: z.object({ id: z.string() }) }).parse(payload);
				intros!.delete(data.old.id);
			}
		)
		.subscribe((state) => {
			console.log('[Channel:table-db-changes] State:', state);
		});
});

client.on('userUpdate', async (_oldUser, newUser) => {
	const guild = await client.guilds.fetch(GUILD_ID);
	const members = await guild.members.fetch();
	const member = members.get(newUser.id);
	if (member === undefined) return;
	if (newUser.bot) return;
	const user = await client.users.fetch(newUser.id, { force: true });
	await supabase.from('members').upsert(transformUser(user));
	console.log('[Event:UserUpdate] Updated User!');
});

client.on('guildMemberAdd', async (member) => {
	if (member.guild.id !== GUILD_ID) return;
	if (member.user.bot) return;
	const user = await client.users.fetch(member.user.id, { force: true });
	await supabase.from('members').upsert(transformUser(user));
	console.log('[Event:GuildMemberAdd] Updated User!');
});

client.on('guildMemberRemove', async (member) => {
	if (member.guild.id !== GUILD_ID) return;
	if (member.user.bot) return;
	const user = await client.users.fetch(member.user.id, { force: true });
	await supabase.from('members').upsert(transformUser(user, false));
	console.log('[Event:GuildMemberRemove] Updated User!');
});

client.on('voiceStateUpdate', async (oldState, newState) => {
	if (!loaded) return;
	assert(intros !== null);
	assert(soundboard !== null);

	const member = newState.member;
	if (member === null || member.guild.id !== GUILD_ID || member.user.bot) return;
	const user = member.user;

	const wasInVC = oldState.channel !== null;
	const nowInVC = newState.channel !== null;

	const joinedVC = !wasInVC && nowInVC;
	const leftVC = wasInVC && !nowInVC;
	const changedVC = wasInVC && nowInVC && oldState.channel.id !== newState.channel.id;

	if (joinedVC || changedVC) {
		if (changedVC && oldState.channel.guild.id === GUILD_ID) {
			lastDisconnect.set(`${user.id}-${oldState.channel.id}`, Date.now());
		}
		if (newState.channel.guild.id !== GUILD_ID) return;
		const latestDisconnect = lastDisconnect.get(`${user.id}-${newState.channel.id}`);
		if (latestDisconnect !== undefined && Date.now() - latestDisconnect < 5_000) {
			console.log('[Event:VoiceStateUpdate] User reconnected, ignoring!');
			return;
		}
		const intro = intros.get(user.id);
		if (intro === undefined) return;
		const res = await soundboard.play(intro, user.id);
		if (!res) return;
		console.log(`[Event:VoiceStateUpdate] Playing intro for User(${user.id}) "${user.username}"!`);
	} else if (leftVC) {
		if (oldState.channel.guild.id !== GUILD_ID) return;
		lastDisconnect.set(`${user.id}-${oldState.channel.id}`, Date.now());
		const connection = getVoiceConnection(GUILD_ID);
		if (connection === undefined) return;
		if (oldState.channel.id !== connection.joinConfig.channelId) return;
		if (oldState.channel.members.filter((x) => !x.user.bot).size > 0) {
			return;
		}
		connection.disconnect();
		console.log(`[Event:VoiceStateUpdate] Left VC!`);
	}
});

client.login(DISCORD_BOT_TOKEN);
