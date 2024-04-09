import { User } from 'discord.js';
import { Member } from './types';

export function transform(user: User): Omit<Member, 'created_at'> {
	return {
		id: user.id,
		username: user.username,
		global_name: user.globalName,
		avatar: user.avatarURL() ?? user.defaultAvatarURL,
		banner: user.bannerURL() ?? null,
		accent_color: user.accentColor ?? null
	};
}

/**
 * Format bytes as human-readable text.
 * https://stackoverflow.com/a/14919494/10685858
 *
 * @param bytes Number of bytes.
 * @param si True to use metric (SI) units, aka powers of 1000. False to use
 *           binary (IEC), aka powers of 1024.
 * @param dp Number of decimal places to display.
 *
 * @return Formatted string.
 */
export function humanFileSize(bytes: number, si = false, dp = 1) {
	const thresh = si ? 1000 : 1024;

	if (Math.abs(bytes) < thresh) {
		return bytes + ' B';
	}

	const units = si
		? ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
		: ['KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
	let u = -1;
	const r = 10 ** dp;

	do {
		bytes /= thresh;
		++u;
	} while (Math.round(Math.abs(bytes) * r) / r >= thresh && u < units.length - 1);

	return bytes.toFixed(dp) + ' ' + units[u];
}

/**
 * Assert that the provided condition is true.
 * @param x The condition to assert.
 * @throws If the condition evaluates to false.
 */
export function assert(x: boolean, message?: string): asserts x {
	if (!x) throw new Error(message ?? 'Assertion failed.');
}

/**
 * Assert that the provided value is not `null` or `undefined`.
 * @param x The value that will be asserted.
 * @returns The non-null value.
 * @throws If the value provided is null.
 */
export function nonNull<T>(x: T): NonNullable<T> {
	assert(x !== undefined && x !== null);
	return x;
}
