local function deepClone<T>(value: T): T
    if type(value) == 'table' then
        local cloned = table.clone(value)
        for key, value in pairs(cloned) do
            if type(value) == 'table' then
                cloned[key] = deepClone(value)
            end
        end
        return cloned :: any
    else
        return value
    end
end

return deepClone
