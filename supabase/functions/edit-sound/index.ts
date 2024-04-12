import { z } from "zod";
import { adminClient, getMemberID, serve } from "../_shared/util.ts";
import { createResponse } from "../_shared/util.ts";
import { HTTPStatus } from "../_shared/util.ts";
import { Sound } from "../_shared/types.ts";

const Form = z.object({
    id: z.string().uuid(),
    name: z.string().min(1).max(100).optional(),
    thumbnail: z.instanceof(File).optional(),
});

serve(async (req) => {
    const formData = await req.formData();
    const data: { [key: string]: FormDataEntryValue } = {};
    formData.forEach((value, key) => (data[key] = value));
    const form = Form.parse(data);

    if (form.name === undefined && form.thumbnail === undefined) {
        return createResponse("Success.", HTTPStatus.Ok);
    }

    await getMemberID(req);

    let sound: Sound;
    let updateName = false;
    {
        const res = await adminClient.from("sounds").select().eq("id", form.id);
        if (res.error) throw res.error;
        if (res.data.length !== 1) throw new Error("Unable to retrieve sound.");
        sound = Sound.parse(res.data[0]);
        if (form.name !== undefined && sound.name !== form.name) {
            updateName = true;
        }
    }

    let thumbnailID: string | null = null;
    if (form.thumbnail !== undefined) {
        thumbnailID = crypto.randomUUID();
        const bucket = "thumbnail";
        const { error } = await adminClient.storage
            .from(bucket)
            .upload(`${sound.author}/${thumbnailID}`, form.thumbnail, {
                contentType: "image/*",
            });
        if (error) throw error;

        await adminClient.storage
            .from(bucket)
            .remove([`${sound.author}/${sound.thumbnail}`]);
    }

    const res = await adminClient
        .from("sounds")
        .update({
            ...(updateName ? { name: form.name! } : {}),
            ...(thumbnailID !== null ? { thumbnail: thumbnailID } : {}),
        })
        .eq("id", sound.id);
    if (res.error) throw res.error;

    return createResponse("Success.", HTTPStatus.Ok);
});
