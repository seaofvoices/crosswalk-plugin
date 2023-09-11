local function moveArray<T>(target: { T }, ...: { T })
    for i = 1, select('#', ...) do
        local transferArray = select(i, ...)

        table.move(transferArray, 1, #transferArray, 1 + #target, target)
    end
end

return moveArray
