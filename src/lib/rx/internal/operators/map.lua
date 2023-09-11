local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local types = require('../types')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Subscriber.Subscriber<T>
type TeardownLogic = types.TeardownLogic
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function map<T, R>(project: (value: T, index: number) -> R): OperatorFunction<T, R>
    local function operation(source: Observable<T>): Observable<R>
        return Observable.new(function(_, destination: Subscriber<R>)
            -- The index of the value from the source. Used with projection.
            local index = 1
            -- Subscribe to the source, all errors and completions are sent along
            -- to the consumer.
            source:subscribe(operate({
                destination = destination,
                next = function(_: Subscriber<T>, value: T)
                    -- Call the projection function with the appropriate this context,
                    -- and send the resulting value to the consumer.
                    local currentIndex = index
                    index += 1
                    destination:next(project(value, currentIndex))
                end,
            }))
        end)
    end

    return operation
end

return map
