local Observable = require('../Observable')
local extendedTypes = require('../extended-types')
local mergeInternals = require('./mergeInternals')
local types = require('../types')

type TeardownLogic = types.TeardownLogic
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function mergeMap<T, R>(
    project: (value: T, index: number) -> ObservableInput<R>,
    concurrent: number?
): OperatorFunction<T, R>
    local actualConcurrent = if concurrent == nil then math.huge else concurrent

    local function operation(source: Observable<T>): Observable<R>
        return Observable.new(function(_, subscriber: Subscriber<R>): TeardownLogic
            mergeInternals(source, subscriber, project, actualConcurrent)

            return nil
        end)
    end
    return operation
end

return mergeMap
