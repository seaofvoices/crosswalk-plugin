local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local empty = require('../observables/empty')
local extendedTypes = require('../extended-types')

local operate = Subscriber.operate

type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function take<T>(count: number): MonoTypeOperatorFunction<T>
    if count <= 0 then
        return empty
    end

    return function(source: Observable<T>)
        return Observable.new(function(_, destination: Subscriber<T>)
            local seen = 0
            local operatorSubscriber = operate({
                destination = destination,
                next = function(self, value: T)
                    seen += 1
                    if seen <= count then
                        destination:next(value)
                    else
                        self:unsubscribe()
                        destination:next(value)
                        destination:complete()
                    end
                end,
            })
            source:subscribe(operatorSubscriber)
        end)
    end
end

return take
