local extendedTypes = require('../extended-types')
local map = require('./map')

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function mapTo<R>(value: R): OperatorFunction<any, R>
    return map(function(_)
        return value
    end)
end

return mapTo
