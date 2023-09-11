local CrosswalkConfig = require('./CrosswalkConfig')
local CrosswalkContext = require('./CrosswalkContext')
local Rx = require('./rx/init')
local exists = require('./observables/exists')
local loadModules = require('./observables/loadModules')
local searchInstance = require('./observables/searchInstance')

type Subscription = Rx.Subscription
export type CrosswalkContext = CrosswalkContext.CrosswalkContext
type CrosswalkContextData = CrosswalkContext.CrosswalkContextData
export type ModuleKind = CrosswalkContext.ModuleKind
export type ModuleTreeNode = CrosswalkContext.ModuleTreeNode
export type RootTreeNode = CrosswalkContext.RootTreeNode

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')

type ModuleFolders = {
    server: Instance?,
    client: Instance?,
    shared: Instance?,
}

export type CrosswalkContextProvider = {
    connect: (self: CrosswalkContextProvider) -> () -> (),
    onModuleFolderChange: (
        self: CrosswalkContextProvider,
        callback: (ModuleFolders) -> ()
    ) -> () -> (),
    disconnectAll: (self: CrosswalkContextProvider) -> (),
    getContext: (self: CrosswalkContextProvider) -> CrosswalkContext,
}

type Private = {
    _value: CrosswalkContextData,
}
type CompletionContextProviderStatic = CrosswalkContextProvider & Private & {
    new: () -> CrosswalkContextProvider,
}

local CrosswalkContextProvider: CompletionContextProviderStatic = {} :: any
local CrosswalkContextProviderMetatable = {
    __index = CrosswalkContextProvider,
}

function CrosswalkContextProvider.new(): CrosswalkContextProvider
    local self: Private = {
        _value = {
            assets = {
                serverModules = ServerStorage:FindFirstChild(CrosswalkConfig.names.server),
                clientModules = ReplicatedStorage:FindFirstChild(CrosswalkConfig.names.client),
                sharedModules = ReplicatedStorage:FindFirstChild(CrosswalkConfig.names.shared),
            },
            moduleTrees = {
                shared = {},
                client = {},
                server = {},
            },
        },
    }
    return setmetatable(self, CrosswalkContextProviderMetatable) :: any
end

function CrosswalkContextProvider:getContext(): CrosswalkContext
    local self = self :: Private & CrosswalkContextProvider

    return CrosswalkContext.new(table.clone(self._value))
end

function CrosswalkContextProvider:onModuleFolderChange(callback: (ModuleFolders) -> ()): () -> ()
    local subscription = Rx.combineLatest({
        server = searchInstance(ServerStorage, CrosswalkConfig.names.server),
        client = searchInstance(ReplicatedStorage, CrosswalkConfig.names.client),
        shared = searchInstance(ReplicatedStorage, CrosswalkConfig.names.shared),
    }):subscribe(callback)

    return function()
        subscription:unsubscribe()
    end
end

function CrosswalkContextProvider:connect(): () -> ()
    local self = self :: Private & CrosswalkContextProvider

    local observable = Rx.combineLatest({
        assets = Rx.combineLatest({
            server = searchInstance(ServerStorage, CrosswalkConfig.names.server):pipe(exists()),
            client = searchInstance(ReplicatedStorage, CrosswalkConfig.names.client):pipe(exists()),
            shared = searchInstance(ReplicatedStorage, CrosswalkConfig.names.shared):pipe(exists()),
        }),
        moduleTrees = Rx.combineLatest({
            server = searchInstance(ServerStorage, CrosswalkConfig.names.server):pipe(
                exists(),
                loadModules()
            ),
            client = searchInstance(ReplicatedStorage, CrosswalkConfig.names.client):pipe(
                exists(),
                loadModules()
            ),
            shared = searchInstance(ReplicatedStorage, CrosswalkConfig.names.shared):pipe(
                exists(),
                loadModules()
            ),
        }),
    })

    local subscription = observable:subscribe({
        next = function(_, value: CrosswalkContextData)
            self._value = value
        end,
        error = function(_, err)
            warn('error! ' .. tostring(err))
        end,
    })

    return function()
        subscription:unsubscribe()
    end
end

return CrosswalkContextProvider
