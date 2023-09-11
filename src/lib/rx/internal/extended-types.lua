local Observable = require('./Observable')
local types = require('./types')

type Observable<T> = Observable.Observable<T>
type UnaryFunction<T, R> = types.UnaryFunction<T, R>

export type OperatorFunction<T, R> = UnaryFunction<Observable<T>, Observable<R>>

export type MonoTypeOperatorFunction<T> = OperatorFunction<T, T>

export type ArrayLike<T> = { T }
export type ObservableInput<T> =
    Observable<T>
    -- | InteropObservable<T>
    -- | AsyncIterable<T>
    -- | PromiseLike<T>
    | ArrayLike<T>
-- | Iterable<T>
-- | ReadableStreamLike<T>

return {}
