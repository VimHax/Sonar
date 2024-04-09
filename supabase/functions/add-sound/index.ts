import { z } from "zod";
import { getMemberID, serve } from "../_shared/util.ts";
import createAdminClient from "../_shared/createAdminClient.ts";
import { createResponse } from "../_shared/util.ts";
import { HTTPStatus } from "../_shared/util.ts";

type Cleanup = () => Promise<void>;

const Form = z.object({
    name: z.string().min(1).max(100),
    thumbnail: z.instanceof(File),
    audio: z.instanceof(File),
});

const adminClient = createAdminClient();

function generateCleanup(bucket: string, path: string): Cleanup {
    return async () => {
        await adminClient.storage.from(bucket).remove([path]);
    };
}

serve(async (req) => {
    const formData = await req.formData();
    const data: { [key: string]: FormDataEntryValue } = {};
    formData.forEach((value, key) => (data[key] = value));
    const form = Form.parse(data);

    const { memberID } = await getMemberID(req);

    const thumbnailID = crypto.randomUUID();
    let thumbnailCleanup: Cleanup;
    {
        const bucket = "thumbnail";
        const path = `${memberID}/${thumbnailID}`;
        const { error } = await adminClient.storage
            .from(bucket)
            .upload(path, form.thumbnail, {
                contentType: "image/*",
            });
        if (error) throw error;
        thumbnailCleanup = generateCleanup(bucket, path);
    }

    const audioID = crypto.randomUUID();
    let audioCleanup: Cleanup;
    {
        const bucket = "audio";
        const path = `${memberID}/${audioID}`;
        const { error } = await adminClient.storage
            .from(bucket)
            .upload(path, form.audio, {
                contentType: "audio/*",
            });
        if (error) {
            await thumbnailCleanup();
            throw error;
        }
        audioCleanup = generateCleanup(bucket, path);
    }

    const res = await adminClient.from("sounds").insert({
        name: form.name,
        thumbnail: thumbnailID,
        audio: audioID,
        author: memberID,
    });

    if (res.error) {
        await Promise.allSettled([thumbnailCleanup(), audioCleanup()]);
        throw res.error;
    }

    return createResponse("Success.", HTTPStatus.Ok);
});
