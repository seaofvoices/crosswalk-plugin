local deepClone = require('./utils/deepClone')

export type RootTreeNode = { [string]: ModuleTreeNode }

export type ModuleTreeNode = {
    moduleScript: ModuleScript,
    children: { [string]: ModuleTreeNode },
    parent: (ModuleTreeNode | RootTreeNode)?,
    -- api: {},
}
export type ModuleKind = 'server' | 'client' | 'shared'

export type CrosswalkContextData = {
    assets: {
        sharedModules: Instance?,
        serverModules: Instance?,
        clientModules: Instance?,
    },
    moduleTrees: {
        shared: RootTreeNode,
        client: RootTreeNode,
        server: RootTreeNode,
    },
}

export type CrosswalkContext = CrosswalkContextData & {
    getModuleKind: (self: CrosswalkContext, LuaSourceContainer) -> ModuleKind?,
    getAccessibleModules: (self: CrosswalkContext, module: LuaSourceContainer) -> { string },
    findModuleScript: (
        self: CrosswalkContext,
        moduleScript: ModuleScript,
        moduleKind: ModuleKind
    ) -> ModuleTreeNode?,
}

type CrosswalkContextStatic = CrosswalkContext & {
    new: (context: CrosswalkContextData) -> CrosswalkContext,
}

local CrosswalkContext: CrosswalkContextStatic = {} :: any
local CrosswalkContextMetatable = {
    __index = CrosswalkContext,
}

local function setupParents(node: ModuleTreeNode, parent: ModuleTreeNode | RootTreeNode)
    node.parent = parent
    for _, child in node.children do
        setupParents(child, node)
    end
end

function CrosswalkContext.new(context: CrosswalkContextData): CrosswalkContext
    local contextCopy = deepClone(context)

    for _, node in contextCopy.moduleTrees.server do
        setupParents(node, contextCopy.moduleTrees.server)
    end
    for _, node in contextCopy.moduleTrees.client do
        setupParents(node, contextCopy.moduleTrees.client)
    end
    for _, node in contextCopy.moduleTrees.shared do
        setupParents(node, contextCopy.moduleTrees.shared)
    end

    return setmetatable(contextCopy, CrosswalkContextMetatable) :: any
end

local function findModuleScript(
    moduleScript: ModuleScript,
    treeNode: ModuleTreeNode
): ModuleTreeNode?
    if treeNode.moduleScript == moduleScript then
        return treeNode
    end

    for _, child in treeNode.children do
        local result = findModuleScript(moduleScript, child)
        if result ~= nil then
            return result
        end
    end

    return nil
end

local function findModuleScriptInRoot(
    moduleScript: ModuleScript,
    root: { [string]: ModuleTreeNode }
): ModuleTreeNode?
    for _, node in root do
        local result = findModuleScript(moduleScript, node)

        if result ~= nil then
            return result
        end
    end

    return nil
end

function CrosswalkContext:getModuleKind(module: LuaSourceContainer): ModuleKind?
    if not module:IsA('ModuleScript') then
        return nil
    end
    local module = module :: ModuleScript

    for kind: ModuleKind, tree: { [string]: ModuleTreeNode } in
        {
            server = self.moduleTrees.server,
            client = self.moduleTrees.client,
            shared = self.moduleTrees.shared,
        } :: { [ModuleKind]: { [string]: ModuleTreeNode } }
    do
        if findModuleScriptInRoot(module, tree) ~= nil then
            return kind
        end
    end

    return nil
end

function CrosswalkContext:findModuleScript(
    moduleScript: ModuleScript,
    moduleKind: ModuleKind
): ModuleTreeNode?
    if moduleKind == 'server' then
        return findModuleScriptInRoot(moduleScript, self.moduleTrees.server)
    elseif moduleKind == 'client' then
        return findModuleScriptInRoot(moduleScript, self.moduleTrees.client)
    elseif moduleKind == 'shared' then
        return findModuleScriptInRoot(moduleScript, self.moduleTrees.shared)
    end

    return nil
end

return CrosswalkContext
