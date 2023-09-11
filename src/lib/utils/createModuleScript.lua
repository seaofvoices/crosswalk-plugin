local function createModuleScript(parent: Instance, name: string, content: string): ModuleScript
    local module = Instance.new('ModuleScript') :: ModuleScript
    module.Name = name
    module.Source = content
    module.Parent = parent
    return module
end

return createModuleScript
