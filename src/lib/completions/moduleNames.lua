local CompletionContextProvider = require('../CompletionContextProvider')
local ScriptEditorServiceTypes = require('../ScriptEditorServiceTypes')
local moveArray = require('../utils/moveArray')

type CompletionContext = CompletionContextProvider.CompletionContext
type ModuleKind = CompletionContextProvider.ModuleKind
type ModuleTreeNode = CompletionContextProvider.ModuleTreeNode
type RootTreeNode = CompletionContextProvider.RootTreeNode
type CompletionItem = ScriptEditorServiceTypes.CompletionItem

local function collectNestedModules(
    node: ModuleTreeNode | RootTreeNode,
    recursive: boolean,
    names: { string }?
): { string }
    local actualNames = names or {}

    if type(node.moduleScript) == 'userdata' then
        local treeNode: ModuleTreeNode = node
        for name, childNode in treeNode.children do
            table.insert(actualNames, name)
            if recursive then
                collectNestedModules(childNode, true, actualNames)
            end
        end
    else
        local root: RootTreeNode = node
        for name, childNode in root do
            table.insert(actualNames, name)
            if recursive then
                collectNestedModules(childNode, true, actualNames)
            end
        end
    end

    return actualNames
end

local function collectAccessibleModules(
    node: ModuleTreeNode | RootTreeNode,
    names: { string }?,
    skipName: string?
): { string }
    local actualNames = if names == nil then collectNestedModules(node, true) else names

    if type(node.moduleScript) == 'userdata' then
        local treeNode: ModuleTreeNode = node

        if names ~= nil then
            for name in treeNode.children do
                if name ~= skipName then
                    table.insert(actualNames, name)
                end
            end
        end

        if treeNode.parent then
            collectAccessibleModules(
                treeNode.parent,
                actualNames,
                skipName or treeNode.moduleScript.Name
            )
        end
    else
        local root: RootTreeNode = node
        for name in root do
            if name ~= skipName then
                table.insert(actualNames, name)
            end
        end
    end

    return actualNames
end

local function modules(context: CompletionContext): { CompletionItem }
    local editor = context.editor

    -- if editor.currentWord ~= '' then
    --     return {}
    -- end

    local crosswalk = context.crosswalk
    local moduleKind: ModuleKind? = crosswalk:getModuleKind(context.script)

    if moduleKind == nil then
        return {}
    end
    local moduleKind: ModuleKind = moduleKind :: ModuleKind

    local beforeCursor = editor:sourceBefore(editor.positions.cursor)

    local reversedBeforeCursor = string.reverse(beforeCursor)
    local matchBeforeIndexReversed = string.match(reversedBeforeCursor, '^[%w_]*.%s*([%w_]+[%a_])')

    if matchBeforeIndexReversed == nil then
        return {}
    end
    local matchBeforeIndex = string.reverse(matchBeforeIndexReversed :: string)

    local treeNode = crosswalk:findModuleScript(context.script :: ModuleScript, moduleKind)

    if treeNode == nil then
        return {}
    end
    local treeNode = treeNode :: ModuleTreeNode

    local names = {}

    if matchBeforeIndex == 'Modules' then
        moveArray(names, collectAccessibleModules(treeNode))
        moveArray(names, collectNestedModules(crosswalk.moduleTrees.shared, false))
    elseif matchBeforeIndex == 'ClientModules' and moduleKind == 'server' then
        moveArray(names, collectNestedModules(crosswalk.moduleTrees.client, false))
    elseif matchBeforeIndex == 'ServerModules' and moduleKind == 'client' then
        moveArray(names, collectNestedModules(crosswalk.moduleTrees.server, false))
    elseif matchBeforeIndex == 'SharedModules' and moduleKind == 'shared' then
        moveArray(names, collectAccessibleModules(treeNode))
    end

    local completions = {}

    for _, name in names do
        moveArray(
            completions,
            editor
                :replaceCurrentWord()
                :line(name)
                :intoCompletion()
                :addLabel(name)
                :kind(Enum.CompletionItemKind.Field)
                :build()
        )
    end

    return completions
end

return modules
