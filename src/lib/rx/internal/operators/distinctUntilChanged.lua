local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local identity = require('../util/identity')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Subscriber.Subscriber<T>
type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>

local function defaultCompare(a: any, b: any): boolean
    return a == b
end

local function distinctUntilChanged<T, K>(
    comparator: ((previous: K, current: K) -> boolean)?,
    keySelector: ((value: T) -> K)?
): MonoTypeOperatorFunction<T>
    local actualComparator: (previous: K, current: K) -> boolean = if comparator == nil
        then defaultCompare
        else comparator
    local actualKeySelector: (value: T) -> K = if keySelector == nil
        then identity :: any
        else keySelector

    local function operation(source: Observable<T>)
        return Observable.new(function(_, destination: Subscriber<T>)
            -- The previous key, used to compare against keys selected
            -- from new arrivals to determine "distinctiveness".
            local previousKey: K
            -- Whether or not this is the first value we've gotten.
            local first = true

            source:subscribe(operate({
                destination = destination,
                next = function(_, value: T)
                    -- We always call the key selector.
                    local currentKey = actualKeySelector(value)

                    -- If it's the first value, we always emit it.
                    -- Otherwise, we compare this key to the previous key, and
                    -- if the comparer returns false, we emit.
                    if first or not actualComparator(previousKey, currentKey) then
                        -- Update our state *before* we emit the value
                        -- as emission can be the source of re-entrant code
                        -- in functional libraries like this. We only really
                        -- need to do this if it's the first value, or if the
                        -- key we're tracking in previous needs to change.
                        first = false
                        previousKey = currentKey

                        -- Emit the value!
                        destination:next(value)
                    end
                end,
            }))
        end)
    end

    return operation
end

type DistinctUntilChanged = <T>(
    comparator: ((previous: T, current: T) -> boolean)?
) -> MonoTypeOperatorFunction<T>

type DistinctUntilChangedWithKeys = <T, K>(
    comparator: (previous: K, current: K) -> boolean,
    keySelector: (value: T) -> K
) -> MonoTypeOperatorFunction<T>

return (distinctUntilChanged :: any) :: DistinctUntilChanged & DistinctUntilChangedWithKeys
