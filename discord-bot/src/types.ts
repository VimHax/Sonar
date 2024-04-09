import { z } from 'zod';

export const Member = z
	.object({
		id: z.string(),
		username: z.string(),
		global_name: z.string().nullable(),
		avatar: z.string().url(),
		banner: z.string().url().nullable(),
		accent_color: z.number().int().nullable(),
		created_at: z.string().datetime({ offset: true })
	})
	.strict();

export const Sound = z
	.object({
		id: z.string().uuid(),
		name: z.string().min(1).max(100),
		thumbnail: z.string().uuid(),
		audio: z.string().uuid(),
		author: z.string(),
		created_at: z.string().datetime({ offset: true })
	})
	.strict();

export const Intro = z
	.object({
		id: z.string(),
		sound: z.string().uuid(),
		created_at: z.string().datetime({ offset: true })
	})
	.strict();

export type Member = z.infer<typeof Member>;
export type Sound = z.infer<typeof Sound>;
export type Intro = z.infer<typeof Intro>;
