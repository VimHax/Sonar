import * as dotenv from 'dotenv';
import { Client, GatewayIntentBits, User as DiscordUser } from 'discord.js';
import { User, createClient } from '@supabase/supabase-js';
import { z } from 'zod';
import { Member } from './types';

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

const client = new Client({ intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers] });

function transform(user: DiscordUser): Omit<Member, 'created_at'> {
	return {
		id: user.id,
		username: user.username,
		global_name: user.globalName,
		avatar: user.avatarURL() ?? user.defaultAvatarURL,
		banner: user.bannerURL() ?? null,
		accent_color: user.accentColor ?? null
	};
}

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
});

client.login(DISCORD_BOT_TOKEN);
