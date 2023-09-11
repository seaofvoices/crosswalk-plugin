local Observable = require('../Observable')
local SubscriberModule = require('../Subscriber')
local arrayOrObject = require('../util/argsArgArrayOrObject').arrayOrObject
local createObject = require('../util/createObject')
local empty = require('./empty')
local extendedTypes = require('../extended-types')
local from = require('./from').from
local Array = require('../../../luau-polyfill/collections/Array/init')
local identity = require('../util/identity')

local operate = SubscriberModule.operate

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = SubscriberModule.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local combineLatestInit

local function combineLatest<R>(
    sources: { [string]: ObservableInput<any> } | { ObservableInput<any> },
    resultSelector: ((...any) -> R)?
): Observable<R> | { Observable<any> }
    local parts = arrayOrObject(sources)

    if parts == nil then
        error('sources must be an array or object')
    end

    local parts =
        parts :: { args: { ObservableInput<any> } | { ObservableInput<any> }, keys: { string }? }

    local observables = parts.args
    local keys = parts.keys

    if #observables == 0 then
        -- If no observables are passed, or someone has passed an empty array
        -- of observables, or even an empty object POJO, we need to just
        -- complete (EMPTY), but we have to honor the scheduler provided if any.
        return empty()
    end

    local valueTransform = identity
    if keys ~= nil then
        function valueTransform(values: { any }): any
            return createObject(keys, values)
        end
    elseif resultSelector ~= nil then
        function valueTransform(values: { any }): any
            return resultSelector(unpack(values))
        end
    end

    return Observable.new(combineLatestInit(observables, valueTransform))
end

function combineLatestInit(
    observables: { ObservableInput<any> },
    valueTransform: ((values: { any }) -> any)?
): (Observable<any>, destination: Subscriber<any>) -> ()
    local actualValueTransform: (values: { any }) -> any = if valueTransform == nil
        then identity :: any
        else valueTransform

    return function(_: Observable<any>, destination: Subscriber<any>)
        local length = #observables

        -- A store for the values each observable has emitted so far. We match observable to value on index.
        local values = {}
        -- The number of currently active subscriptions, as they complete, we decrement this number to see if
        -- we are all done combining values, so we can complete the result.
        local active = length
        -- The number of inner sources that still haven't emitted the first value
        -- We need to track this because all sources need to emit one value in order
        -- to start emitting values.
        local remainingFirstValues = length
        -- The loop to kick off subscription. We're keying everything on index `i` to relate the observables passed
        -- in to the slot in the output array or the key in the array of keys in the output dictionary.

        for i = 1, length do
            local source = from(observables[i])
            local hasFirstValue = false
            source:subscribe(operate({
                destination = destination,
                next = function(_, value)
                    -- When we get a value, record it in our set of values.
                    values[i] = value
                    if not hasFirstValue then
                        -- If this is our first value, record that.
                        hasFirstValue = true
                        remainingFirstValues -= 1
                    end
                    if remainingFirstValues == 0 then
                        -- We're not waiting for any more
                        -- first values, so we can emit!
                        destination:next(actualValueTransform(Array.from(values)))
                    end
                end,
                complete = function()
                    active -= 1
                    if active == 0 then
                        destination:complete()
                    end
                end,
            }))
        end
    end
end

type CombineLatest =
    (<A>(sources: { ObservableInput<A> }) -> Observable<A>)
    & (<A, R>(
        sources: { ObservableInput<A> },
        resultSelector: (...A) -> R
    ) -> Observable<R>)
    & (<A, R>(
        sources: { ObservableInput<A> },
        resultSelector: (...A) -> R
    ) -> Observable<R>)
    & (<A, R>(sources: { [string]: A }) -> Observable<A>)

return {
    combineLatest = (combineLatest :: any) :: CombineLatest,
    combineLatestInit = combineLatestInit,
}
