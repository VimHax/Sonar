# Discord Bot

The Discord Bot for Sonar which plays the sounds and keeps the member data up to date. Mainly built using [TypeScript](https://www.typescriptlang.org/), [Node.js](https://nodejs.org) and [discord.js](https://discord.js.org/).

## How does it work?

### Managing Member Data

At startup the bot will look through all the current members of the server and update any outdated members. Any changes made to members (such as members joining, leaving and editing their profile) are then listened for (using the events emitted by the [`discord.js`](https://discord.js.org/) library such as [`guildMemberAdd`](https://discord.js.org/docs/packages/discord.js/14.14.1/Client:Class#guildMemberAdd), [`guildMemberRemove`](https://discord.js.org/docs/packages/discord.js/14.14.1/Client:Class#guildMemberRemove) and [`userUpdate`](https://discord.js.org/docs/packages/discord.js/14.14.1/Client:Class#userUpdate) respectively) to then replicate those updates in the database.

### Sound Playback

When started the bot will fetch all the sounds from the database and proceed to download all the audio files, decode them and keep them in memory. The bot will be notified about any newly added or removed sounds through [Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes) and will process the sound as previously mentioned or remove the sound from memory respectively.

When a user clicks on a sound in the Sonar application or triggers a shortcut the request is sent to the bot using the [Realtime Broadcast](https://supabase.com/docs/guides/realtime/broadcast) feature. When the request is received the bot then finds the decoded sound data from memory, mixes it together with any other playing sounds and then stream this data to Discord so that the bot can play it.

As I was unable to find an existing library for realtime sound mixing I created a [custom sound mixer](src/soundboard.ts) which can dynamically add new sounds and mix them together realtime. (A feature which [the player provided by @discordjs/voice lacks](https://discordjs.guide/voice/audio-player.html#playing-audio).)
