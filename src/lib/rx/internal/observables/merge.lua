local Observable = require('../Observable')
local empty = require('./empty')
local extendedTypes = require('../extended-types')
local from = require('./from').from
local mergeAll = require('../operators/mergeAll')
local types = require('../types')

type TeardownLogic = types.TeardownLogic
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

-- todo: merge could possibly take SchedulerLike
local function merge(...: ObservableInput<unknown>): Observable<unknown>
    local concurrent = math.huge
    local sourcesLength = select('#', ...)

    local lastArg = if sourcesLength == 0 then nil else select(sourcesLength, ...)

    local sources = { ... }

    if type(lastArg) == 'number' then
        concurrent = lastArg
        sourcesLength -= 1
        table.remove(sources)
    end

    return if sourcesLength == 0
        then empty()
        elseif sourcesLength == 1 then from(sources[1])
        else mergeAll(concurrent)(from(sources))
end

return (merge :: any) :: <A>(...ObservableInput<A>) -> Observable<A>
