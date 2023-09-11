local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local types = require('../types')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function filter<T, R>(
    predicate: (value: T, index: number) -> boolean,
    _selfArg: any?
): OperatorFunction<T, R>
    local function operation(source: Observable<T>)
        return Observable.new(
            function(_self: Observable<R>, destination: Subscriber<R>): TeardownLogic
                local index = 1

                source:subscribe(operate({
                    destination = destination,
                    next = function(_: Subscriber<T>, value: T)
                        local currentIndex = index
                        index += 1
                        if predicate(value, currentIndex) then
                            destination:next((value :: any) :: R)
                        end
                    end,
                }))

                return nil
            end
        )
    end
    return operation
end

return filter
