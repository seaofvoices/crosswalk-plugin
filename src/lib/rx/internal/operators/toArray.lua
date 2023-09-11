local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local reduce = require('./reduce')
local types = require('../types')

type Observable<T> = Observable.Observable<T>
type UnaryFunction<T, R> = types.UnaryFunction<T, R>
type Subscriber<T> = Subscriber.Subscriber<T>

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function arrReducer<T>(arr: { T }, value: T)
    table.insert(arr, value)
    return arr
end

local function toArray<T>(): OperatorFunction<T, { T }>
    local function operation(source: Observable<T>): Observable<{ T }>
        return Observable.new(function(_, subscriber: Subscriber<{ T }>)
            reduce(arrReducer, {})(source):subscribe(subscriber)
        end)
    end

    return operation
end

return toArray
