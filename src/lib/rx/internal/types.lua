export type Unsubscribable = {
    unsubscribe: (Unsubscribable) -> (),
}

export type SubscriptionLike = Unsubscribable & {
    isClosed: (self: SubscriptionLike) -> boolean,
}

export type TeardownLogic = nil | SubscriptionLike | Unsubscribable | () -> ()

export type Observer<T> = {
    next: (self: Observer<T>, value: T) -> (),
    error: (self: Observer<T>, err: any) -> (),
    complete: (self: Observer<T>) -> (),
}

export type PartialObserver<T> = {
    next: ((self: Observer<T>, value: T) -> ())?,
    error: ((self: Observer<T>, err: any) -> ())?,
    complete: ((self: Observer<T>) -> ())?,
}

export type Subscribable<T> = {
    subscribe: (Subscribable<T>, observer: PartialObserver<T>) -> Unsubscribable,
}

export type UnaryFunction<T, R> = (source: T) -> R

return {}
