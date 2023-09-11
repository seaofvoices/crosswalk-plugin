local Observable = require('../Observable')
local SubscriberModule = require('../Subscriber')
local extendedTypes = require('../extended-types')
local from = require('../observables/from').from

local operate = SubscriberModule.operate

type Subscriber<T> = SubscriberModule.Subscriber<T>
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type Observable<T> = Observable.Observable<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function mergeInternals<T, R>(
    source: Observable<T>,
    destination: Subscriber<R>,
    project: (value: T, index: number) -> ObservableInput<R>,
    concurrent: number,
    onBeforeNext: ((innerValue: R) -> ())?,
    expand: boolean?,
    _innerSubScheduler: nil, -- SchedulerLike,
    additionalFinalizer: (() -> ())?
)
    -- Buffered values, in the event of going over our concurrency limit
    local buffer: { T } = {}
    -- The number of active inner subscriptions.
    local active = 0
    -- An index to pass to our accumulator function
    local index = 0
    -- Whether or not the outer source has completed.
    local isComplete = false

    -- Checks to see if we can complete our result or not.
    local function checkComplete()
        -- If the outer has completed, and nothing is left in the buffer,
        -- and we don't have any active inner subscriptions, then we can
        -- Emit the state and complete.
        if isComplete and (#buffer == 0) and not active then
            destination:complete()
        end
    end

    local doInnerSub

    -- If we're under our concurrency limit, just start the inner subscription, otherwise buffer and wait.
    local function outerNext(value: T)
        if active < concurrent then
            doInnerSub(value)
        else
            table.insert(buffer, value)
        end
    end

    function doInnerSub(value: T)
        -- If we're expanding, we need to emit the outer values and the inner values
        -- as the inners will "become outers" in a way as they are recursively fed
        -- back to the projection mechanism.
        if expand then
            destination:next(value :: any)
        end

        -- Increment the number of active subscriptions so we can track it
        -- against our concurrency limit later.
        active += 1

        -- A flag used to show that the inner observable completed.
        -- This is checked during finalization to see if we should
        -- move to the next item in the buffer, if there is on.
        local innerComplete = false

        -- Start our inner subscription.
        local currentIndex = index
        index += 1

        from(project(value, currentIndex)):subscribe(operate({
            destination = destination,
            next = function(_self, innerValue)
                -- `mergeScan` has additional handling here. For example
                -- taking the inner value and updating state.
                if onBeforeNext ~= nil then
                    onBeforeNext(innerValue)
                end

                if expand then
                    -- If we're expanding, then just recurse back to our outer
                    -- handler. It will emit the value first thing.
                    outerNext(innerValue :: any)
                else
                    -- Otherwise, emit the inner value.
                    destination:next(innerValue)
                end
            end,
            complete = function()
                -- Flag that we have completed, so we know to check the buffer
                -- during finalization.
                innerComplete = true
            end,
            finalize = function()
                -- During finalization, if the inner completed (it wasn't errored or
                -- cancelled), then we want to try the next item in the buffer if
                -- there is one.
                if innerComplete then
                    -- We have to wrap this in a try/catch because it happens during
                    -- finalization, possibly asynchronously, and we want to pass
                    -- any errors that happen (like in a projection function) to
                    -- the outer Subscriber.
                    local success, err: any = pcall(function()
                        -- INNER SOURCE COMPLETE
                        -- Decrement the active count to ensure that the next time
                        -- we try to call `doInnerSub`, the number is accurate.
                        active -= 1
                    end)

                    -- If we have more values in the buffer, try to process those
                    -- Note that this call will increment `active` ahead of the
                    -- next conditional, if there were any more inner subscriptions
                    -- to start.
                    while #buffer > 0 and active < concurrent do
                        local bufferedValue = table.remove(buffer, 1) :: T
                        -- Particularly for `expand`, we need to check to see if a scheduler was provided
                        -- for when we want to start our inner subscription. Otherwise, we just start
                        -- are next inner subscription.

                        -- todo: innerSubScheduler not implemented
                        -- if (innerSubScheduler) then
                        --   executeSchedule(destination, innerSubScheduler, () => doInnerSub(bufferedValue));
                        -- else
                        doInnerSub(bufferedValue)
                        -- end
                    end

                    -- Check to see if we can complete, and complete if so.
                    checkComplete()

                    if not success then
                        destination:error(err)
                    end
                end
            end,
        }))
    end

    -- Subscribe to our source observable.
    source:subscribe(operate({
        destination = destination,
        next = function(_: Subscriber<T>, value: T)
            outerNext(value)
        end,
        complete = function(_: Subscriber<T>)
            -- Outer completed, make a note of it, and check to see if we can complete everything.
            isComplete = true
            checkComplete()
        end,
    }))

    -- Additional finalization (for when the destination is torn down).
    -- Other finalization is added implicitly via subscription above.
    return function()
        if additionalFinalizer then
            additionalFinalizer()
        end
    end
end

return mergeInternals
