import { REST } from "discordjs/rest";
import {
    Routes,
    RESTGetAPIUserResult,
    CDNRoutes,
    ImageFormat,
    DefaultUserAvatarAssets,
    APIUser,
    RouteBases,
} from "discord-api-types/v10";
import { nonNull } from "../_shared/util.ts";
import supabaseClient from "../_shared/supabaseClient.ts";

const rest = new REST({ version: "10" }).setToken(
    nonNull(Deno.env.get("DISCORD_BOT_TOKEN"))
);

function getImageFormat(hash: string): ImageFormat.GIF | ImageFormat.PNG {
    return hash.startsWith("a_") ? ImageFormat.GIF : ImageFormat.PNG;
}

function getAvatarRoute(user: APIUser): string {
    if (user.avatar === null) {
        if (user.discriminator === "0") {
            return CDNRoutes.defaultUserAvatar(
                ((parseInt(user.id) >> 22) % 6) as DefaultUserAvatarAssets
            );
        } else {
            return CDNRoutes.defaultUserAvatar(
                (parseInt(user.discriminator) % 6) as DefaultUserAvatarAssets
            );
        }
    } else {
        return CDNRoutes.userAvatar(
            user.id,
            user.avatar,
            getImageFormat(user.avatar)
        );
    }
}

function getBannerRoute(user: APIUser): string | null {
    if (!user.banner) {
        return null;
    } else {
        return CDNRoutes.userBanner(
            user.id,
            user.banner,
            getImageFormat(user.banner)
        );
    }
}

Deno.serve(async (req) => {
    try {
        const userClient = supabaseClient(req);
        const {
            data: { user },
            error,
        } = await userClient.auth.getUser();
        if (error) throw error;

        if (user === null) throw new Error("Unable to retrieve user.");
        if (
            !user.identities ||
            user.identities.length != 1 ||
            user.identities[0].provider !== "discord"
        ) {
            throw new Error("Unable to retrieve user identity.");
        }

        const res = (await rest.get(
            Routes.user(user.identities[0].id)
        )) as RESTGetAPIUserResult;

        const avatarRoute = getAvatarRoute(res);
        const bannerRoute = getBannerRoute(res);

        const data = {
            username: res.username,
            global_name: res.global_name,
            avatar: `${RouteBases.cdn}${avatarRoute}`,
            banner:
                bannerRoute === null ? null : `${RouteBases.cdn}${bannerRoute}`,
            accent_color: res.accent_color ?? null,
        };

        return new Response(JSON.stringify(data), {
            headers: { "Content-Type": "application/json" },
        });
    } catch (error) {
        console.error(error);
        return new Response(null, {
            headers: { "Content-Type": "application/json" },
            status: 500,
        });
    }
});
