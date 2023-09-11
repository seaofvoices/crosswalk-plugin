local CompletionContextProvider = require('./CompletionContextProvider')
local ScriptEditorServiceTypes = require('./ScriptEditorServiceTypes')
local moduleNames = require('./completions/moduleNames')
local moduleStructure = require('./completions/moduleStructure')
local specialFunctions = require('./completions/specialFunctions')

type CompletionContext = CompletionContextProvider.CompletionContext
type AutoCompleteRequest = ScriptEditorServiceTypes.AutoCompleteRequest
type CompletionItem = ScriptEditorServiceTypes.CompletionItem

local completionFns: { (CompletionContext) -> { CompletionItem } } = {
    moduleStructure,
    specialFunctions,
    moduleNames,
}

local function generateCompletions(context: CompletionContext): { CompletionItem }
    local completions = {}

    for _, completionFn in completionFns do
        for _, newCompletion in completionFn(context) do
            table.insert(completions, newCompletion)
        end
    end

    return completions
end

return generateCompletions
