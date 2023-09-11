local Array = require('../../../luau-polyfill/collections/Array/init')

local function createObject<T>(keys: { string }, values: { T }): { [string]: T }
    return Array.reduce(keys, function(result, key, i)
        result[key] = values[i]
        return result
    end, {})
end

return createObject
