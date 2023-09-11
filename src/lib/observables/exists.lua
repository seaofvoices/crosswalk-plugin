local Rx = require('../rx/init')

local function exists<T>(): Rx.OperatorFunction<T?, T>
    return Rx.filter(function(value: T?)
        return value ~= nil
    end)
end

return exists
