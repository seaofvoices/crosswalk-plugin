local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')

local operate = Subscriber.operate

type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function takeWhile<T>(
    predicate: (value: T, index: number) -> boolean,
    inclusive: boolean?
): MonoTypeOperatorFunction<T>
    local actualInclusive = if inclusive == nil then false else inclusive

    return function(source: Observable<T>)
        return Observable.new(function(_, destination: Subscriber<T>)
            local index = 1
            local operatorSubscriber = operate({
                destination = destination,
                next = function(self, value: T)
                    local currentIndex = index
                    index += 1
                    if predicate(value, currentIndex) then
                        destination:next(value)
                    else
                        self:unsubscribe()
                        if actualInclusive then
                            destination:next(value)
                        end
                        destination:complete()
                    end
                end,
            })
            source:subscribe(operatorSubscriber)
        end)
    end
end

return takeWhile
