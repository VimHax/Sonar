import * as dotenv from 'dotenv';
import express, { ErrorRequestHandler, Request } from 'express';
import morgan from 'morgan';
import { Client, GatewayIntentBits } from 'discord.js';
import { User, createClient } from '@supabase/supabase-js';

dotenv.config();

function env(name: string): string {
	const value = process.env[name];
	if (!value) throw new Error(`${name} is missing`);
	return value;
}

const SUPABASE_URL = env('SUPABASE_URL');
const SUPABASE_SERVICE_ANON_KEY = env('SUPABASE_SERVICE_ANON_KEY');
const SUPABASE_SERVICE_ROLE_KEY = env('SUPABASE_SERVICE_ROLE_KEY');
const DISCORD_BOT_TOKEN = env('DISCORD_BOT_TOKEN');
const PORT = env('PORT');

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// Express

const app = express();
const UNAUTHORIZED = new Error('Unauthorized.');

app.use(morgan('combined'));

interface AuthRequest extends Request {
	auth?: { valid: true; user: User } | { valid: false };
}

app.use((req: AuthRequest, res, next) => {
	req.auth = { valid: false };
	const authHeader = req.headers.authorization;
	if (!authHeader) throw UNAUTHORIZED;
	req.auth = { valid: false };
	next();
});

app.get('/user/:userID', async (req: AuthRequest, res) => {
	const user = await client.users.fetch(req.params.userID);
	const x = await supabase.auth.getUser();
	console.log(x);
	res.json(user);
});

app.use(((err, req, res, next) => {
	if (res.headersSent) return next(err);
	if (err === UNAUTHORIZED) {
		res.status(401);
		res.json({ error: 'UNAUTHORIZED' });
	} else {
		console.error(err);
		res.status(500);
		res.json({ error: 'INTERNAL_ERROR' });
	}
}) as ErrorRequestHandler);

// Discord Bot

const client = new Client({ intents: [GatewayIntentBits.Guilds] });

client.on('ready', () => {
	console.log(`Logged in as ${client.user!.tag}!`);
	app.listen(PORT, () => {
		console.log(`Listening on port ${PORT}`);
	});
});

client.on('interactionCreate', async (interaction) => {
	if (!interaction.isChatInputCommand()) return;

	if (interaction.commandName === 'ping') {
		await interaction.reply('Pong!');
	}
});

client.login(DISCORD_BOT_TOKEN);
