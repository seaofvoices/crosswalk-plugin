local Rx = require('../rx/init')

local function getChildren(): Rx.OperatorFunction<Instance, { Instance }>
    return Rx.switchMap(function(container: Instance)
        return Rx.create(function(subscriber: Rx.Subscriber<{ Instance }>)
            local function updateChildren()
                local nextChildren = container:GetChildren()
                subscriber:next(nextChildren)
            end

            local nameConnections: { [Instance]: RBXScriptConnection } = {}

            local function onChildAdded(child: Instance)
                nameConnections[child] = child:GetPropertyChangedSignal('Name'):Connect(function()
                    updateChildren()
                end)
                updateChildren()
            end

            local childAddedConnection = container.ChildAdded:Connect(onChildAdded)
            local childRemovedConnection = container.ChildRemoved:Connect(function(child: Instance)
                local connection: RBXScriptConnection? = nameConnections[child]
                if connection ~= nil then
                    connection:Disconnect()
                    nameConnections[child] = nil
                end
                updateChildren()
            end)

            subscriber:next(container:GetChildren())

            for _, child in container:GetChildren() do
                onChildAdded(child)
            end

            subscriber:add(function()
                childAddedConnection:Disconnect()
                childRemovedConnection:Disconnect()

                for _, connection in nameConnections do
                    connection:Disconnect()
                end

                nameConnections = {}
            end)
        end)
    end)
end

return getChildren
