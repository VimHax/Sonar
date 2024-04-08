import createUserClient from "./createUserClient.ts";
import { User, type SupabaseClient } from "supabase";

export enum HTTPStatus {
    Ok = 200,
    Unauthorized = 401,
    InternalServerError = 500,
}

export const UNAUTHORIZED_ERROR = new Error("Unauthorized.");

export async function getMemberID(
    req: Request
): Promise<{ client: SupabaseClient; user: User; memberID: string }> {
    const userClient = createUserClient(req);
    const {
        data: { user },
        error,
    } = await userClient.auth.getUser();
    if (error) throw UNAUTHORIZED_ERROR;

    if (user === null) throw new Error("Unable to retrieve user.");
    if (
        !user.identities ||
        user.identities.length != 1 ||
        user.identities[0].provider !== "discord"
    ) {
        throw new Error("Unable to retrieve user identity.");
    }

    return { client: userClient, user, memberID: user.identities[0].id };
}

export function serve(handler: (req: Request) => Response | Promise<Response>) {
    Deno.serve(async (req) => {
        try {
            return await handler(req);
        } catch (error) {
            if (error === UNAUTHORIZED_ERROR) {
                return createResponse("Unauthorized.", HTTPStatus.Unauthorized);
            } else {
                console.error(error);
                return createResponse(
                    "Internal server error.",
                    HTTPStatus.InternalServerError
                );
            }
        }
    });
}

export function createResponse(body: unknown, status: HTTPStatus) {
    return new Response(JSON.stringify(body), {
        headers: { "Content-Type": "application/json" },
        status,
    });
}

/**
 * Assert that the provided condition is true.
 * @param x The condition to assert.
 * @throws If the condition evaluates to false.
 */
export function assert(x: boolean, message?: string): asserts x {
    if (!x) throw new Error(message ?? "Assertion failed.");
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
