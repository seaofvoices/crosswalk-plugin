local CompletionContextProvider = require('../CompletionContextProvider')
local ScriptEditorServiceTypes = require('../ScriptEditorServiceTypes')
local moveArray = require('../utils/moveArray')

type CompletionContext = CompletionContextProvider.CompletionContext
type CompletionItem = ScriptEditorServiceTypes.CompletionItem

type ModuleKind = 'server' | 'client' | 'shared'

local function specialFunctions(context: CompletionContext): { CompletionItem }
    if context.editor.currentWord == '' then
        return {}
    end

    local moduleKind: ModuleKind? = context.crosswalk:getModuleKind(context.script)

    if moduleKind == nil then
        return {}
    end

    local completions = {}

    local source = context.editor.source

    if not source:find('function%s+module%.Init%(%)') then
        moveArray(
            completions,
            context.editor
                :replaceCurrentWord()
                :line('function module.Init()')
                :line()
                :line('end')
                :intoCompletion()
                :detail('First function automatically called')
                :addLabel('function module.Init')
                :addLabel('cw module.init')
                :addLabel('crosswalk module.init')
                :kind(Enum.CompletionItemKind.Function)
                :build()
        )
    end

    if not source:find('function%s+module%.Start%(%)') then
        moveArray(
            completions,
            context.editor
                :replaceCurrentWord()
                :line('function module.Start()')
                :line()
                :line('end')
                :intoCompletion()
                :detail('Called after all `Init` functions')
                :addLabel('function module.Start')
                :addLabel('cw module.Start')
                :addLabel('crosswalk module.Start')
                :kind(Enum.CompletionItemKind.Function)
                :build()
        )
    end

    if moduleKind ~= 'shared' then
        if not source:find('function%s+module%.OnPlayerReady%(') then
            moveArray(
                completions,
                context.editor
                    :replaceCurrentWord()
                    :line('function module.OnPlayerReady(player: Player)')
                    :line()
                    :line('end')
                    :intoCompletion()
                    :detail(
                        if moduleKind == 'server'
                            then 'Called when server is allowed to send requests to player'
                            else 'Called when the client is ready to send requests to the server'
                    )
                    :addLabel('function module.OnPlayerReady')
                    :addLabel('cw module.OnPlayerReady')
                    :addLabel('crosswalk module.OnPlayerReady')
                    :kind(Enum.CompletionItemKind.Function)
                    :build()
            )
        end
    end

    if moduleKind == 'server' then
        if not source:find('function%s+module%.OnPlayerRemoving%(') then
            moveArray(
                completions,
                context.editor
                    :replaceCurrentWord()
                    :line('function module.OnPlayerRemoving(player: Player)')
                    :line()
                    :line('end')
                    :intoCompletion()
                    :detail('Called when a player is leaving')
                    :addLabel('function module.OnPlayerRemoving')
                    :addLabel('cw module.OnPlayerRemoving')
                    :addLabel('crosswalk module.OnPlayerRemoving')
                    :kind(Enum.CompletionItemKind.Function)
                    :build()
            )
        end

        if not source:find('function%s+module%.OnUnapprovedExecution%(') then
            moveArray(
                completions,
                context.editor
                    :replaceCurrentWord()
                    :line(
                        'function module.OnUnapprovedExecution(player: Player, info: { functionName: string })'
                    )
                    :line()
                    :line('end')
                    :intoCompletion()
                    :addLabel('function module.OnUnapprovedExecution')
                    :addLabel('cw module OnUnapprovedExecution')
                    :addLabel('crosswalk module OnUnapprovedExecution')
                    :kind(Enum.CompletionItemKind.Function)
                    :build()
            )
        end
    end

    return completions
end

return specialFunctions
