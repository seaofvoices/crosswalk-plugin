local function not_<T>(
    predicate: (value: T, index: number) -> boolean
): (value: T, index: number) -> boolean
    return function(value: T, index: number)
        return not predicate(value, index)
    end
end

return not_
