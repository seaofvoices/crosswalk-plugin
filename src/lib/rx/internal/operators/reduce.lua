local Observable = require('../Observable')
local extendedTypes = require('../extended-types')
local scanInternals = require('./scanInternals')

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

type Observable<T> = Observable.Observable<T>

local function reduceWithSeed<V, A, S>(
    accumulator: (acc: A | V, value: V, index: number) -> A,
    seed: S
): OperatorFunction<V, A>
    return function(source: Observable<V>)
        return Observable.new(function(_, subscriber)
            scanInternals(accumulator, seed, true, false, true, source, subscriber)
        end)
    end
end

local function reduceWithoutSeed<V, A>(
    accumulator: (acc: A | V, value: V, index: number) -> A
): OperatorFunction<V, A>
    return function(source: Observable<V>)
        return Observable.new(function(_, subscriber)
            scanInternals(accumulator, nil, false, false, true, source, subscriber)
        end)
    end
end

local function reduce<V, A, S>(
    accumulator: (acc: A | V, value: V, index: number) -> A,
    ...: any
): OperatorFunction<V, A>
    local hasSeed = select('#', ...) > 0
    if hasSeed then
        return reduceWithSeed(accumulator, ...)
    else
        return reduceWithoutSeed(accumulator) :: any
    end
end

return reduce :: <V, A, S>(
    accumulator: (acc: A | V, value: V, index: number) -> A,
    seed: S?
) -> OperatorFunction<V, A>
