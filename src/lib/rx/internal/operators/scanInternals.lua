local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local types = require('../types')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type UnaryFunction<T, R> = types.UnaryFunction<T, R>
type Subscriber<T> = Subscriber.Subscriber<T>

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function scanInternals<V, A, S>(
    accumulator: (acc: V | A | S, value: V, index: number) -> A,
    seed: S,
    hasSeed: boolean,
    emitOnNext: boolean,
    emitBeforeComplete: boolean,
    source: Observable<V>,
    destination: Subscriber<any>
)
    -- Whether or not we have state yet. This will only be
    -- false before the first value arrives if we didn't get
    -- a seed value.
    local hasState = hasSeed
    -- The state that we're tracking, starting with the seed,
    -- if there is one, and then updated by the return value
    -- from the accumulator on each emission.
    local state: any = seed
    -- An index to pass to the accumulator function.
    local index = 1

    source:subscribe(operate({
        destination = destination,
        next = function(_, value)
            local i = index
            index += 1

            if hasState then
                state = accumulator(state, value, i)
            else
                state = value
                hasState = true
            end

            if emitOnNext then
                destination:next(state)
            end
        end,
        complete = if emitBeforeComplete
            then function()
                if hasState then
                    destination:next(state)
                    destination:complete()
                end
            end
            else nil,
    }))
end

return scanInternals
