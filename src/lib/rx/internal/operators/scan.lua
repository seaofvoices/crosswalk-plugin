local Observable = require('../Observable')
local extendedTypes = require('../extended-types')
local scanInternals = require('./scanInternals')
local types = require('../types')

type TeardownLogic = types.TeardownLogic
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function scan<V, A, S>(
    accumulator: (acc: V | A | S, value: V, index: number) -> A,
    seed: S?
): OperatorFunction<V, V | A>
    local hasSeed = seed ~= nil
    return function(source: Observable<V>)
        return Observable.new(function(_, subscriber: Subscriber<V | A>)
            scanInternals(accumulator, seed :: S, hasSeed, true, false, source, subscriber)
        end)
    end
end

return scan
