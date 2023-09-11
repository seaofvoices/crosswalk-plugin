local Array = require('../../../luau-polyfill/collections/Array/init')
local Object = require('../../../luau-polyfill/collections/Object/init')

local function isPOJO(object: any): boolean
    return type(object) == 'table'
end

local function arrayOrObject<T>(
    first: T | { T } | { [string]: T }
): { args: { T }, keys: { string }? }?
    if Array.isArray(first) then
        local first = first :: { T }
        return { args = first, keys = nil }
    end
    if isPOJO(first) then
        local first = first :: { [string]: T }
        local keys = Object.keys(first :: { [string]: T })
        return {
            args = Array.map(keys, function(key)
                return first[key]
            end),
            keys = keys,
        }
    end
    return nil
end

--[[
  * Used in functions where either a list of arguments, a single array of arguments, or a
  * dictionary of arguments can be returned. Returns an object with an `args` property with
  * the arguments in an array, if it is a dictionary, it will also return the `keys` in another
  * property.
]]
local function argsArgArrayOrObject<T>(
    args: { T } | { { [string]: T } } | { { T } }
): { args: { T }, keys: { string }? }
    if #args == 1 then
        local first = (args :: any)[1] :: T | { [string]: T } | { T }
        local result = arrayOrObject(first)
        if result ~= nil then
            return result
        end
    end

    return { args = args :: { T }, keys = nil }
end

return {
    argsArgArrayOrObject = argsArgArrayOrObject,
    arrayOrObject = arrayOrObject,
}
