local StringBuffer = require('./utils/StringBuffer')

type ModuleKind = 'server' | 'client' | 'shared'

export type Fns = {
    init: boolean,
    start: boolean,
    onPlayerReady: boolean,
    onPlayerLeaving: boolean,
    onUnapprovedExecution: boolean,
}

local function defaultModuleSource(moduleKind: ModuleKind, fns: Fns): string
    local buffer = StringBuffer.new({ indentation = '\t' })
        :write('return function(')
        :write(
            if moduleKind == 'server'
                then 'Modules, ClientModules, Services'
                elseif moduleKind == 'client' then 'Modules, ServerModules, Services'
                else 'SharedModules, Services, isServer'
        )
        :writeLine(')')
        :indent()
        :writeLine('local module = {}')
        :newLine()

    if fns.init then
        buffer:writeLine('function module.Init()'):newLine():writeLine('end'):newLine()
    end

    if fns.start then
        buffer:writeLine('function module.Start()'):newLine():writeLine('end'):newLine()
    end

    if fns.onPlayerReady then
        buffer
            :writeLine('function module.OnPlayerReady(player: Player)')
            :newLine()
            :writeLine('end')
            :newLine()
    end

    if fns.onPlayerLeaving then
        buffer
            :writeLine('function module.OnPlayerLeaving(player: Player)')
            :newLine()
            :writeLine('end')
            :newLine()
    end

    if fns.onUnapprovedExecution then
        buffer
            :writeLine(
                'function module.OnUnapprovedExecution(player: Player, info: { functionName: string })'
            )
            :newLine()
            :writeLine('end')
            :newLine()
    end

    return buffer:writeLine('return module'):dedent():writeLine('end'):toString()
end

return {
    names = {
        server = 'ServerModules',
        client = 'ClientModules',
        shared = 'SharedModules',
    },
    defaultModules = {
        server = function(fns: Fns): string
            return defaultModuleSource('server', {
                init = fns.init,
                start = fns.start,
                onPlayerReady = fns.onPlayerReady,
                onPlayerLeaving = fns.onPlayerLeaving,
                onUnapprovedExecution = fns.onUnapprovedExecution,
            })
        end,
        client = function(fns: Fns): string
            return defaultModuleSource('client', {
                init = fns.init,
                start = fns.start,
                onPlayerReady = fns.onPlayerReady,
                onPlayerLeaving = false,
                onUnapprovedExecution = false,
            })
        end,
        shared = function(fns: Fns): string
            return defaultModuleSource('shared', {
                init = fns.init,
                start = fns.start,
                onPlayerReady = false,
                onPlayerLeaving = false,
                onUnapprovedExecution = false,
            })
        end,
    },
}
