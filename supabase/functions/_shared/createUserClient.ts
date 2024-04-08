import { createClient } from "supabase";
import { nonNull } from "./util.ts";
import { UNAUTHORIZED_ERROR } from "./util.ts";

export default (req: Request) => {
    const token = req.headers.get("Authorization");
    if (token === null) throw UNAUTHORIZED_ERROR;
    return createClient(
        nonNull(Deno.env.get("SUPABASE_URL")),
        nonNull(Deno.env.get("SUPABASE_ANON_KEY")),
        {
            global: { headers: { Authorization: token } },
        }
    );
};
