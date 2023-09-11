local combineLatest = require('../observables/combineLatest').combineLatest
local extendedTypes = require('../extended-types')
local joinAllInternals = require('./joinAllInternals')

type ObservableInput<T> = extendedTypes.ObservableInput<T>
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function combineLatestAll<R>(project: ((...any) -> R)?)
    return joinAllInternals(combineLatest, project)
end

return combineLatestAll :: (
    (<T>() -> OperatorFunction<ObservableInput<T>, { T }>)
    & (<T>() -> OperatorFunction<any, { T }>)
    & (<T, R>(project: (...T) -> R) -> OperatorFunction<ObservableInput<T>, R>)
    & (<R>(project: (...any) -> R) -> OperatorFunction<any, R>)
)
