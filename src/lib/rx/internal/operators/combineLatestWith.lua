local Observable = require('../Observable')
local combineLatestInit = require('../observables/combineLatest').combineLatestInit
local extendedTypes = require('../extended-types')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function combineLatestWith<T, A>(...: ObservableInput<A>): OperatorFunction<T, { T | A }>
    local otherSources = { ... }

    local function operation(source: Observable<T>): Observable<{ T | A }>
        return Observable.new(function(selfObservable, subscriber: Subscriber<{ T | A }>)
            local allSources = table.clone(otherSources)
            table.insert(allSources, 1, source)
            combineLatestInit(allSources)(selfObservable, subscriber)
        end)
    end

    return operation
end

return combineLatestWith
