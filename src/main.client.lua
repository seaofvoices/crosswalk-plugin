local CrosswalkPlugin = require('./lib/CrosswalkPlugin')

local crosswalkPlugin = CrosswalkPlugin.new(plugin)

crosswalkPlugin:enable()

plugin.Unloading:Connect(function()
    crosswalkPlugin:disable()
end)
