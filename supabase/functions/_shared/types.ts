import { z } from "zod";

export const Sound = z
    .object({
        id: z.string().uuid(),
        name: z.string().min(1).max(100),
        thumbnail: z.string().uuid(),
        audio: z.string().uuid(),
        author: z.string(),
        created_at: z.string().datetime({ offset: true }),
    })
    .strict();

export type Sound = z.infer<typeof Sound>;
