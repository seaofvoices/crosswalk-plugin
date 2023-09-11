local Array = require('../../../luau-polyfill/collections/Array/init')
local Observable = require('../Observable')
local SubscriberModule = require('../Subscriber')
local extendedTypes = require('../extended-types')
local fromRobloxEvent = require('./fromRobloxEvent')

type Subscriber<T> = SubscriberModule.Subscriber<T>
type Observable<T> = Observable.Observable<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

--[[
    Subscribes to an ArrayLike with a subscriber
    @param array The array or array-like to subscribe to
    @param subscriber
]]
local function subscribeToArray<T>(array: { T }, subscriber: Subscriber<T>)
    -- Loop over the array and emit each value. Note two things here:
    -- 1. We're making sure that the subscriber is not closed on each loop.
    --    This is so we don't continue looping over a very large array after
    --    something like a `take`, `takeWhile`, or other synchronous unsubscription
    --    has already unsubscribed.
    -- 2. In this form, reentrant code can alter that array we're looping over.
    --    This is a known issue, but considered an edge case. The alternative would
    --    be to copy the array before executing the loop, but this has
    --    performance implications.
    --   local length = #array
    for _, element in array do
        if subscriber:isClosed() then
            return
        end
        subscriber:next(element)
    end
    subscriber:complete()
end

--[[
    Synchronously emits the values of an array like and completes.
    This is exported because there are creation functions and operators that need to
    make direct use of the same logic, and there's no reason to make them run through
    `from` conditionals because we *know* they're dealing with an array.
    @param array The array to emit values from
]]
local function fromArrayLike<T>(array: { T })
    return Observable.new(function(_, subscriber: Subscriber<T>)
        subscribeToArray(array, subscriber)
    end)
end

local function isRobloxClass(value: unknown): boolean
    if type(value) == 'userdata' then
        local success, result = pcall(function()
            return typeof(value :: Instance) == 'RBXScriptSignal'
        end)
        return success and result
    end
    return false
end

local function from<T>(input: ObservableInput<T>): Observable<T>
    if Observable.is(input) then
        return input :: any
    elseif Array.isArray(input) then
        return fromArrayLike(input :: { T })
    elseif _G.ROBLOX and isRobloxClass(input) then
        return fromRobloxEvent(input :: RBXScriptSignal)
    end

    error('todo: createInvalidObservableTypeError `' .. type(input) .. '`')
end

return {
    from = from,
    fromArrayLike = fromArrayLike,
    subscribeToArray = subscribeToArray,
}
