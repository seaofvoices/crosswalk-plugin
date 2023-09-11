local CrosswalkContextProvider = require('./CrosswalkContextProvider')
local EditorContext = require('./EditorContext')
local ScriptEditorServiceTypes = require('./ScriptEditorServiceTypes')

type CrosswalkContextProvider = CrosswalkContextProvider.CrosswalkContextProvider
type EditorContext = EditorContext.EditorContext
export type CrosswalkContext = CrosswalkContextProvider.CrosswalkContext
export type ModuleKind = CrosswalkContextProvider.ModuleKind
export type ModuleTreeNode = CrosswalkContextProvider.ModuleTreeNode
export type RootTreeNode = CrosswalkContextProvider.RootTreeNode
type AutoCompleteRequest = ScriptEditorServiceTypes.AutoCompleteRequest

export type CompletionContext = {
    script: LuaSourceContainer,
    editor: EditorContext,
    crosswalk: CrosswalkContext,
}

export type CompletionContextProvider = {
    getContext: (
        self: CompletionContextProvider,
        request: AutoCompleteRequest
    ) -> CompletionContext,
}

type Private = {
    _crosswalk: CrosswalkContextProvider,
}
type CompletionContextProviderStatic = CompletionContextProvider & Private & {
    new: (provider: CrosswalkContextProvider) -> CompletionContextProvider,
}

local CompletionContextProvider: CompletionContextProviderStatic = {} :: any
local CompletionContextProviderMetatable = {
    __index = CompletionContextProvider,
}

function CompletionContextProvider.new(
    provider: CrosswalkContextProvider
): CompletionContextProvider
    local self: Private = {
        _crosswalk = provider,
    }

    return setmetatable(self, CompletionContextProviderMetatable) :: any
end

local function getCurrentScript(request: AutoCompleteRequest): LuaSourceContainer
    local currentModuleScript = request.textDocument.script

    if currentModuleScript ~= nil then
        return currentModuleScript
    end

    local document = request.textDocument.document

    if document ~= nil then
        return document:GetScript()
    end

    error('unable to obtain current script instance')
end

function CompletionContextProvider:getContext(request: AutoCompleteRequest): CompletionContext
    local self = self :: Private & CompletionContextProvider

    return {
        script = getCurrentScript(request),
        editor = EditorContext.new(request),
        crosswalk = self._crosswalk:getContext(),
    }
end

return CompletionContextProvider
