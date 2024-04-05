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
