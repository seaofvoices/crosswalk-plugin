local extendedTypes = require('../extended-types')
local reduce = require('./reduce')

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function count<T>(
    predicate: ((value: T, index: number) -> boolean)?
): OperatorFunction<T, number>
    return reduce(function(total: number, value: T, i: number): number
        if predicate == nil or predicate(value, i) then
            return total + 1
        else
            return total
        end
    end, 0)
end

return count
