local extendedTypes = require('../extended-types')
local identity = require('../util/identity')
local mergeMap = require('./mergeMap')

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function mergeAll<T>(concurrent: number?): OperatorFunction<ObservableInput<T>, T>
    return mergeMap(identity :: any, concurrent)
end

return mergeAll
