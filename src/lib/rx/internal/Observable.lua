local SubscriberModule = require('./Subscriber')
local Subscription = require('./Subscription')
local pipe = require('./util/pipe')
local types = require('./types')

local Subscriber = SubscriberModule.Subscriber
export type Subscriber<T> = SubscriberModule.Subscriber<T>
type Subscription = Subscription.Subscription
type Subscribable<T> = types.Subscribable<T>
type SubscriptionLike = types.SubscriptionLike
type TeardownLogic = types.TeardownLogic
type PartialObserver<T> = types.PartialObserver<T>
type UnaryFunction<T, R> = types.UnaryFunction<T, R>

export type Observable<T> = {
    subscribe: (
        Observable<T>,
        observer: nil | PartialObserver<T> | (value: T) -> ()
    ) -> Subscription,

    pipe: ((self: Observable<T>) -> Observable<T>)
        & (<A>(self: Observable<T>, UnaryFunction<Observable<T>, A>) -> A)
        & (<A, B>(
            self: Observable<T>,
            UnaryFunction<Observable<T>, A>,
            UnaryFunction<A, B>
        ) -> B)
        & (<A, B, C>(
            self: Observable<T>,
            UnaryFunction<Observable<T>, A>,
            UnaryFunction<A, B>,
            UnaryFunction<B, C>
        ) -> C)
        & (<A, B, C, D>(
            self: Observable<T>,
            UnaryFunction<Observable<T>, A>,
            UnaryFunction<A, B>,
            UnaryFunction<B, C>,
            UnaryFunction<C, D>
        ) -> D)
        & (<A, B, C, D, E>(
            self: Observable<T>,
            UnaryFunction<Observable<T>, A>,
            UnaryFunction<A, B>,
            UnaryFunction<B, C>,
            UnaryFunction<C, D>,
            UnaryFunction<D, E>
        ) -> E),
}

type Private<T> = {
    _subscribe: ((Observable<T>, subscriber: Subscriber<T>) -> TeardownLogic)?,
    _trySubscribe: (Observable<T> & Private<T>, sink: Subscriber<T>) -> TeardownLogic,
}
type ObservableStatic = {
    new: <T>(
        subscribe: (
            ((self: Observable<T>, subscriber: Subscriber<T>) -> TeardownLogic)
            | ((self: Observable<T>, subscriber: Subscriber<T>) -> ())
        )?
    ) -> Observable<T>,
    is: (unknown) -> boolean,

    -- bring static version of Observable<T> methods
    pipe: <T>(self: Observable<T>, ...UnaryFunction<any, any>) -> any,

    subscribe: <T>(
        Observable<T>,
        observer: nil | PartialObserver<T> | (value: T) -> ()
    ) -> Subscription,
    _trySubscribe: <T>(Observable<T>, sink: Subscriber<T>) -> TeardownLogic,
}

local Observable: ObservableStatic = {} :: any
local ObservableMetatable = {
    __index = Observable,
}

function Observable.new<T>(
    subscribe: ((Observable<T>, subscriber: Subscriber<T>) -> TeardownLogic)?
): Observable<T>
    local self = {
        _subscribe = subscribe,
    }

    return setmetatable(self, ObservableMetatable) :: any
end

function Observable.is(value: unknown): boolean
    if type(value) == 'table' then
        local metatable = getmetatable(value :: any)

        if metatable ~= nil then
            return metatable == ObservableMetatable
        end
    end
    return false
end

function Observable:subscribe<T>(
    observerOrNext: nil | PartialObserver<T> | Subscriber<T> | (value: T) -> ()
): Subscription
    local self: Private<T> & Observable<T> = self :: any

    local subscriber = if Subscriber.is(observerOrNext)
        then observerOrNext :: Subscriber<T>
        else Subscriber.new(observerOrNext)

    subscriber:add(self:_trySubscribe(subscriber))

    return subscriber
end

function Observable:_trySubscribe<T>(sink: Subscriber<T>): TeardownLogic
    local self: Private<T> & Observable<T> = self :: any

    local success, result = pcall(function()
        return (self._subscribe :: any)(self, sink)
    end)

    if success then
        return result
    else
        sink:error(result)
        return nil
    end
end

function Observable:pipe<T>(...: UnaryFunction<any, any>): any
    local operations = table.pack(...)
    return pipe.pipeFromArray(operations)(self)
end

-- todo: async iterable implementation

return Observable
