local identity = require('./identity')
local types = require('../types')

local Array = require('../../../luau-polyfill/collections/Array/init')

type Subscribable<T> = types.Subscribable<T>
type UnaryFunction<T, R> = types.UnaryFunction<T, R>

local function pipeFromArray(
    fns: { UnaryFunction<unknown, unknown> }
): UnaryFunction<unknown, unknown>
    local fnsLength = #fns
    if fnsLength == 0 then
        return identity :: any
    end

    if fnsLength == 1 then
        return fns[1]
    end

    local function piped(input: unknown): unknown
        return Array.reduce(fns, function(prev, fn)
            return fn(prev)
        end, input)
    end

    return piped
end

local function pipe(...: UnaryFunction<any, any>): UnaryFunction<any, any>
    local fns = { ... }
    return pipeFromArray(fns)
end

type PipeFn =
    (<A, B>(UnaryFunction<A, B>) -> UnaryFunction<A, B>)
    & (<A, B, C>(UnaryFunction<A, B>, UnaryFunction<B, C>) -> UnaryFunction<A, C>)
    & (<A, B, C, D>(
        UnaryFunction<A, B>,
        UnaryFunction<B, C>,
        UnaryFunction<C, D>
    ) -> UnaryFunction<A, D>)
    & (<A, B, C, D, E>(
        UnaryFunction<A, B>,
        UnaryFunction<B, C>,
        UnaryFunction<C, D>,
        UnaryFunction<D, E>
    ) -> UnaryFunction<A, E>)
    & (<A, B, C, D, E, F>(
        UnaryFunction<A, B>,
        UnaryFunction<B, C>,
        UnaryFunction<C, D>,
        UnaryFunction<D, E>,
        UnaryFunction<E, F>
    ) -> UnaryFunction<A, F>)
    & (<A, B, C, D, E, F, G>(
        UnaryFunction<A, B>,
        UnaryFunction<B, C>,
        UnaryFunction<C, D>,
        UnaryFunction<D, E>,
        UnaryFunction<E, F>,
        UnaryFunction<F, G>
    ) -> UnaryFunction<A, G>)

return {
    pipeFromArray = pipeFromArray,
    pipe = (pipe :: any) :: PipeFn,
}
