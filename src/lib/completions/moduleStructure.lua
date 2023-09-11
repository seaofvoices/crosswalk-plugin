local CompletionContextProvider = require('../CompletionContextProvider')
local ScriptEditorServiceTypes = require('../ScriptEditorServiceTypes')

type CompletionContext = CompletionContextProvider.CompletionContext
type ModuleKind = CompletionContextProvider.ModuleKind
type CompletionItem = ScriptEditorServiceTypes.CompletionItem

local function moduleStructure(context: CompletionContext): { CompletionItem }
    if string.match(context.editor.source, 'return%s+function%(') then
        return {}
    end

    local moduleKind: ModuleKind? = context.crosswalk:getModuleKind(context.script)

    if moduleKind == nil then
        return {}
    end
    local moduleKind: ModuleKind = moduleKind :: ModuleKind

    local arguments = if moduleKind == 'server'
        then 'Modules, ServerModules, Services'
        elseif moduleKind == 'client' then 'Modules, ClientModules, Services'
        else 'SharedModules, Services, isServer'

    return context.editor
        :replaceCurrentWord()
        :line(string.format('return function(%s)', arguments))
        :indent()
        :line('local module = {}')
        :line()
        :line('return module')
        :dedent()
        :line('end')
        :intoCompletion()
        :detail(string.format('crosswalk %s module', moduleKind))
        :addLabel('cw module')
        :addLabel('crosswalk module')
        :kind(Enum.CompletionItemKind.File)
        :build()
end

return moduleStructure
