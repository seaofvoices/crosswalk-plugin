local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local from = require('../observables/from').from
local noop = require('../util/noop')

local operate = Subscriber.operate

type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function takeUntil<T>(notifier: ObservableInput<any>): MonoTypeOperatorFunction<T>
    return function(source: Observable<T>)
        return Observable.new(function(_, destination: Subscriber<T>)
            from(notifier):subscribe(operate({
                destination = destination,
                next = function(_, _value)
                    destination:complete()
                end,
                complete = noop,
            }))

            if not destination:isClosed() then
                source:subscribe(destination)
            end
        end)
    end
end

return takeUntil
