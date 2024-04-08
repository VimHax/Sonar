import * as dotenv from 'dotenv';
import { Client, GatewayIntentBits } from 'discord.js';
import { User, createClient } from '@supabase/supabase-js';

dotenv.config();

function env(name: string): string {
	const value = process.env[name];
	if (!value) throw new Error(`${name} is missing`);
	return value;
}

const SUPABASE_URL = env('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = env('SUPABASE_SERVICE_ROLE_KEY');
const DISCORD_BOT_TOKEN = env('DISCORD_BOT_TOKEN');

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.on('ready', () => {
	console.log(`Logged in as ${client.user!.tag}!`);
});

client.on('interactionCreate', async (interaction) => {
	if (!interaction.isChatInputCommand()) return;

	if (interaction.commandName === 'ping') {
		await interaction.reply('Pong!');
	}
});

client.login(DISCORD_BOT_TOKEN);
