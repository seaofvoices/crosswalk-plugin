local CompletionContextProvider = require('./CompletionContextProvider')
local CrosswalkConfig = require('./CrosswalkConfig')
local CrosswalkContextProvider = require('./CrosswalkContextProvider')
local ScriptEditorServiceTypes = require('./ScriptEditorServiceTypes')
local createFolder = require('./utils/createFolder')
local createModuleScript = require('./utils/createModuleScript')
local generateCompletions = require('./generateCompletions')

type CrosswalkContextProvider = CrosswalkContextProvider.CrosswalkContextProvider
type CompletionContextProvider = CompletionContextProvider.CompletionContextProvider

export type CrosswalkPlugin = {
    enable: (self: CrosswalkPlugin) -> (),
    disable: (self: CrosswalkPlugin) -> (),
}

type Private = {
    _enabled: boolean,
    _crosswalkContextProvider: CrosswalkContextProvider,
    _completionContextProvider: CompletionContextProvider,
    _plugin: Plugin,
    _autocompleteCallbackId: string,
    _teardownFns: { () -> () },
    _moduleFunctions: CrosswalkConfig.Fns,

    _scriptEditorService: ScriptEditorService,
    _serverStorage: ServerStorage,
    _replicatedStorage: ReplicatedStorage,
    _selectionService: Selection,

    _teardown: (
        self: Private & CrosswalkPlugin,
        teardown: RBXScriptConnection | (() -> ()) | Instance
    ) -> (),
    _selectAndOpenScript: (
        self: Private & CrosswalkPlugin,
        moduleScript: ModuleScript
    ) -> (),
}
type CrosswalkPluginStatic = CrosswalkPlugin & Private & {
    new: (plugin: Plugin) -> CrosswalkPlugin,
}

local CrosswalkPlugin: CrosswalkPluginStatic = {} :: any
local CrosswalkPluginMetatable = {
    __index = CrosswalkPlugin,
}

function CrosswalkPlugin.new(plugin: Plugin): CrosswalkPlugin
    local crosswalkContextProvider = CrosswalkContextProvider.new()
    local self: Private = {
        _enabled = false,
        _crosswalkContextProvider = crosswalkContextProvider,
        _completionContextProvider = CompletionContextProvider.new(crosswalkContextProvider),
        _plugin = plugin,
        _autocompleteCallbackId = 'crosswalk-autocomplete',
        _teardownFns = {},
        _moduleFunctions = {
            init = true,
            start = true,
            onPlayerReady = true,
            onPlayerLeaving = true,
            onUnapprovedExecution = false,
        },

        _scriptEditorService = game:GetService('ScriptEditorService') :: ScriptEditorService,
        _serverStorage = game:GetService('ServerStorage') :: ServerStorage,
        _replicatedStorage = game:GetService('ReplicatedStorage') :: ReplicatedStorage,
        _selectionService = game:GetService('Selection') :: Selection,

        -- typechecker expect _teardown function even if it's defined later
        _teardown = nil :: any,
        _selectAndOpenScript = nil :: any,
    }
    return setmetatable(self, CrosswalkPluginMetatable) :: any
end

function CrosswalkPlugin:enable()
    local self = self :: Private & CrosswalkPlugin

    if self._enabled then
        return
    end

    do
        local toolbar = self._plugin:CreateToolbar('crosswalk')

        local setupCrosswalkButton =
            toolbar:CreateButton('Setup crosswalk', 'Create crosswalk directories', '')
        setupCrosswalkButton.Enabled = false

        self:_teardown(setupCrosswalkButton.Click:Connect(function()
            if self._serverStorage:FindFirstChild(CrosswalkConfig.names.server) == nil then
                createFolder(self._serverStorage, CrosswalkConfig.names.server)
            end
            if self._replicatedStorage:FindFirstChild(CrosswalkConfig.names.client) == nil then
                createFolder(self._replicatedStorage, CrosswalkConfig.names.client)
            end
            if self._replicatedStorage:FindFirstChild(CrosswalkConfig.names.shared) == nil then
                createFolder(self._replicatedStorage, CrosswalkConfig.names.shared)
            end
        end))

        local newServerModuleButton = toolbar:CreateButton('Add server module', '', '')
        newServerModuleButton.Enabled = false

        self:_teardown(newServerModuleButton.Click:Connect(function()
            local serverModules = self._serverStorage:FindFirstChild(CrosswalkConfig.names.server)
            if serverModules ~= nil then
                local newScript = createModuleScript(
                    serverModules,
                    'NewModule',
                    CrosswalkConfig.defaultModules.server(self._moduleFunctions)
                )
                self:_selectAndOpenScript(newScript)
            end
        end))

        local newClientModuleButton = toolbar:CreateButton('Add client module', '', '')
        newClientModuleButton.Enabled = false

        self:_teardown(newClientModuleButton.Click:Connect(function()
            local clientModules =
                self._replicatedStorage:FindFirstChild(CrosswalkConfig.names.client)
            if clientModules ~= nil then
                local newScript = createModuleScript(
                    clientModules,
                    'NewModule',
                    CrosswalkConfig.defaultModules.client(self._moduleFunctions)
                )
                self:_selectAndOpenScript(newScript)
            end
        end))

        local newSharedModuleButton = toolbar:CreateButton('Add shared module', '', '')
        newSharedModuleButton.Enabled = false

        self:_teardown(newSharedModuleButton.Click:Connect(function()
            local sharedModules =
                self._replicatedStorage:FindFirstChild(CrosswalkConfig.names.shared)
            if sharedModules ~= nil then
                local newScript = createModuleScript(
                    sharedModules,
                    'NewModule',
                    CrosswalkConfig.defaultModules.shared(self._moduleFunctions)
                )
                self:_selectAndOpenScript(newScript)
            end
        end))

        self:_teardown(self._crosswalkContextProvider:onModuleFolderChange(function(assets)
            local isCrosswalkSetup = assets.client ~= nil
                and assets.server ~= nil
                and assets.shared ~= nil
            setupCrosswalkButton.Enabled = not isCrosswalkSetup
            newServerModuleButton.Enabled = isCrosswalkSetup
            newClientModuleButton.Enabled = isCrosswalkSetup
            newSharedModuleButton.Enabled = isCrosswalkSetup
        end))

        self:_teardown(toolbar)
    end

    self:_teardown(self._crosswalkContextProvider:connect())

    self._enabled = true

    local function crosswalkAutoComplete(
        request: ScriptEditorServiceTypes.AutoCompleteRequest
    ): ScriptEditorServiceTypes.AutoCompleteResponse
        local context = self._completionContextProvider:getContext(request)
        return {
            items = generateCompletions(context),
        }
    end

    self._scriptEditorService:RegisterAutocompleteCallback(
        self._autocompleteCallbackId,
        1,
        crosswalkAutoComplete
    )
    self:_teardown(function()
        self._scriptEditorService:DeregisterAutocompleteCallback(self._autocompleteCallbackId)
    end)
end

function CrosswalkPlugin:_teardown(teardown: RBXScriptConnection | (() -> ()) | Instance)
    local self = self :: Private & CrosswalkPlugin

    local teardownFn = if type(teardown) == 'function'
        then teardown
        else if typeof(teardown) == 'Instance'
            then function()
                teardown:Destroy()
            end
            else function()
                teardown:Disconnect()
            end

    table.insert(self._teardownFns, teardownFn)
end

function CrosswalkPlugin:disable()
    local self = self :: Private & CrosswalkPlugin

    if not self._enabled then
        return
    end

    self._enabled = false

    for _, fn in self._teardownFns do
        fn()
    end
    self._teardownFns = {}
end

function CrosswalkPlugin:_selectAndOpenScript(moduleScript: ModuleScript)
    local self = self :: Private & CrosswalkPlugin

    self._selectionService:Set({ moduleScript })
    self._plugin:OpenScript(moduleScript :: any, 3)
end

return CrosswalkPlugin
