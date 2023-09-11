local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local Subscription = require('../Subscription')
local extendedTypes = require('../extended-types')
local identity = require('../util/identity')

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Subscriber.Subscriber<T>
type Subscription = Subscription.Subscription
type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

export type RetryConfig = {
    count: number?,
    delay: number? | ((error: any, retryCount: number) -> ObservableInput<any>),
    resetOnSuccess: boolean?,
}

local function retry<T>(configOrCount: nil | number | RetryConfig): MonoTypeOperatorFunction<T>
    local config: RetryConfig
    if type(configOrCount) == 'table' then
        config = configOrCount
    else
        config = {
            count = configOrCount or math.huge,
        }
    end
    local count = config.count or math.huge
    local delay = config.delay
    local resetOnSuccess = if config.resetOnSuccess == nil then false else config.resetOnSuccess

    if count <= 0 then
        return identity :: any
    end

    local function operation(source: Observable<T>): Observable<T>
        return Observable.new(function(_, destination: Subscriber<T>)
            local soFar = 0
            local innerSub: Subscription? = nil

            local function subscribeForRetry()
                local syncUnsub = false

                local operateConfig = {
                    destination = destination,
                    next = function(_, value)
                        -- If we're resetting on success
                        if resetOnSuccess then
                            soFar = 0
                        end
                        destination:next(value)
                    end,
                    error = function(_, err)
                        local currentSoFar = soFar
                        soFar += 1
                        if currentSoFar < count then
                            -- We are still under our retry count
                            local function resub()
                                if innerSub then
                                    innerSub:unsubscribe()
                                    innerSub = nil
                                    subscribeForRetry()
                                else
                                    syncUnsub = true
                                end
                            end

                            if delay ~= nil then
                                -- todo: implement delay
                                error('implement delay option')
                                -- -- The user specified a retry delay.
                                -- -- They gave us a number, use a timer, otherwise, it's a function,
                                -- -- and we're going to call it to get a notifier.
                                -- local notifier = if type(delay) == 'number'
                                --     then timer(delay)
                                --     else from(delay(err, soFar))
                                -- local notifierSubscriber = operate({
                                --     destination = destination,
                                --     next = function()
                                --         -- After we get the first notification, we
                                --         -- unsubscribe from the notifier, because we don't want anymore
                                --         -- and we resubscribe to the source.
                                --         notifierSubscriber:unsubscribe()
                                --         resub()
                                --     end,
                                --     complete = function()
                                --         -- The notifier completed without emitting.
                                --         -- The author is telling us they want to complete.
                                --         destination:complete()
                                --     end,
                                -- })
                                -- notifier:subscribe(notifierSubscriber)
                            else
                                -- There was no notifier given. Just resub immediately.
                                resub()
                            end
                        else
                            destination:error(err)
                        end
                    end,
                }

                innerSub = source:subscribe(operate(operateConfig))

                if syncUnsub then
                    if innerSub then
                        innerSub:unsubscribe()
                    end
                    innerSub = nil
                    subscribeForRetry()
                end
            end

            subscribeForRetry()
        end)
    end

    return operation
end

return retry
