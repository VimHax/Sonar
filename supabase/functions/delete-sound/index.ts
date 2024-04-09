import { z } from "zod";
import { getMemberID, serve } from "../_shared/util.ts";
import createAdminClient from "../_shared/createAdminClient.ts";
import { createResponse } from "../_shared/util.ts";
import { HTTPStatus } from "../_shared/util.ts";
import { Sound } from "../_shared/types.ts";

const Body = z.object({
    id: z.string().uuid(),
});

const adminClient = createAdminClient();

serve(async (req) => {
    const body = Body.parse(await req.json());

    await getMemberID(req);

    const res = await adminClient
        .from("sounds")
        .delete()
        .eq("id", body.id)
        .select();
    if (res.error) throw res.error;
    if (res.data.length !== 1) throw new Error("Unable to retrieve sound.");
    const sound = Sound.parse(res.data[0]);

    await adminClient.storage
        .from("thumbnail")
        .remove([`${sound.author}/${sound.thumbnail}`]);
    await adminClient.storage
        .from("audio")
        .remove([`${sound.author}/${sound.audio}`]);

    return createResponse("Success.", HTTPStatus.Ok);
});
