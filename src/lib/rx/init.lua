local Observable = require('./internal/Observable')
local Subscriber = require('./internal/Subscriber')
local Subscription = require('./internal/Subscription')
local combineLatestModule = require('./internal/observables/combineLatest')
local extendedTypes = require('./internal/extended-types')
local fromModule = require('./internal/observables/from')
local pipeModule = require('./internal/util/pipe')

local fromRobloxEvent
if _G.ROBLOX then
    fromRobloxEvent = require('./internal/observables/fromRobloxEvent')
end

export type Observable<T> = Observable.Observable<T>
export type Subscriber<T> = Subscriber.Subscriber<T>
export type Subscription = Subscription.Subscription
export type ObservableInput<T> = extendedTypes.ObservableInput<T>
export type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

return {
    -- Subscription
    Subscriber = Subscriber,
    Subscription = Subscription,

    -- Static observable creation exports
    combineLatest = combineLatestModule.combineLatest,
    create = require('./internal/observables/create'),
    empty = require('./internal/observables/empty'),
    from = fromModule.from,
    fromRobloxEvent = fromRobloxEvent,
    merge = require('./internal/observables/merge'),
    never = require('./internal/observables/never'),
    of = require('./internal/observables/of'),
    partition = require('./internal/observables/partition'),
    range = require('./internal/observables/range'),
    throwError = require('./internal/observables/throwError'),

    -- utils
    pipe = pipeModule.pipe,
    operate = Subscriber.operate,

    -- operators
    combineLatestAll = require('./internal/operators/combineLatestAll'),
    combineLatestWith = require('./internal/operators/combineLatestWith'),
    concatAll = require('./internal/operators/concatAll'),
    count = require('./internal/operators/count'),
    distinctUntilChanged = require('./internal/operators/distinctUntilChanged'),
    filter = require('./internal/operators/filter'),
    map = require('./internal/operators/map'),
    mapTo = require('./internal/operators/mapTo'),
    mergeAll = require('./internal/operators/mergeAll'),
    mergeMap = require('./internal/operators/mergeMap'),
    reduce = require('./internal/operators/reduce'),
    retry = require('./internal/operators/retry'),
    scan = require('./internal/operators/scan'),
    startWith = require('./internal/operators/startWith'),
    switchMap = require('./internal/operators/switchMap'),
    take = require('./internal/operators/take'),
    takeUntil = require('./internal/operators/takeUntil'),
    takeWhile = require('./internal/operators/takeWhile'),
}
