local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local from = require('../observables/from').from
local types = require('../types')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>
type OperateConfig<T, R> = Subscriber.OperateConfig<T, R>

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function switchMap<T, R>(
    project: (value: T, index: number) -> ObservableInput<R>
): OperatorFunction<T, R>
    local function operation(source: Observable<T>): Observable<R>
        return Observable.new(function(_, destination: Subscriber<R>)
            local innerSubscriber: Subscriber<R>? = nil
            local index = 1
            -- Whether or not the source subscription has completed
            local isComplete = false

            -- We only complete the result if the source is complete AND we don't have an active inner subscription.
            -- This is called both when the source completes and when the inners complete.
            local function checkComplete()
                if isComplete and not innerSubscriber then
                    destination:complete()
                end
            end

            source:subscribe(operate({
                destination = destination,
                next = function(_: Subscriber<T>, value: T)
                    -- Cancel the previous inner subscription if there was one
                    if innerSubscriber then
                        innerSubscriber:unsubscribe()
                    end
                    local outerIndex = index
                    index += 1

                    -- Start the next inner subscription
                    local innerObservable = from(project(value, outerIndex))
                    innerSubscriber = operate({
                        destination = destination,
                        complete = function()
                            -- The inner has completed. Null out the inner subscriber to
                            -- free up memory and to signal that we have no inner subscription
                            -- currently.
                            innerSubscriber = nil
                            checkComplete()
                        end,
                    })
                    innerObservable:subscribe(innerSubscriber)
                end,
                complete = function()
                    isComplete = true
                    checkComplete()
                end,
            }))
        end)
    end

    return operation
end

return switchMap
