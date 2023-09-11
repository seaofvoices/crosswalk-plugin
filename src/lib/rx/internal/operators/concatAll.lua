local extendedTypes = require('../extended-types')
local mergeAll = require('./mergeAll')

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function concatAll<T>(): OperatorFunction<ObservableInput<T>, T>
    return mergeAll(1)
end

return concatAll
