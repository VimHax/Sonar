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
import { nonNull, getMemberID, serve } from "../_shared/util.ts";
import { createResponse } from "../_shared/util.ts";
import { HTTPStatus } from "../_shared/util.ts";

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

serve(async (req) => {
    const { memberID } = await getMemberID(req);

    const user = (await rest.get(
        Routes.user(memberID)
    )) as RESTGetAPIUserResult;

    const avatarRoute = getAvatarRoute(user);
    const bannerRoute = getBannerRoute(user);

    const response = {
        username: user.username,
        global_name: user.global_name,
        avatar: `${RouteBases.cdn}${avatarRoute}`,
        banner: bannerRoute === null ? null : `${RouteBases.cdn}${bannerRoute}`,
        accent_color: user.accent_color ?? null,
    };

    return createResponse(response, HTTPStatus.Ok);
});
