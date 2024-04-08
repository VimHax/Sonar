import { createClient } from "supabase";
import { nonNull } from "./util.ts";

export default () =>
    createClient(
        nonNull(Deno.env.get("SUPABASE_URL")),
        nonNull(Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"))
    );
