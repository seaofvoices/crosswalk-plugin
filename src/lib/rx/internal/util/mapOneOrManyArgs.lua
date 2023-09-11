local Array = require('../../../luau-polyfill/collections/Array/init')
local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local map = require('../operators/map')
local types = require('../types')

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function callOrApply<T, R>(fn: (...T) -> R, args: T | { T }): R
    return if Array.isArray(args) then fn(unpack(args :: { T })) else fn(args :: T)
end

local function mapOneOrManyArgs<T, R>(fn: (...T) -> R): OperatorFunction<T | { T }, R>
    return map(function(args)
        return callOrApply(fn, args)
    end)
end

return mapOneOrManyArgs
