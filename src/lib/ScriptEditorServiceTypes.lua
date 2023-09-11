export type AutoCompleteRequest = {
    position: {
        line: number,
        character: number,
    },
    textDocument: {
        document: ScriptDocument?,
        script: LuaSourceContainer?,
    },
}

export type TextEdit = {
    newText: string,
    replace: {
        start: { line: number, character: number },
        ['end']: { line: number, character: number },
    },
}

export type CompletionItem = {
    -- the label of the item which display in the Autocomplete menu
    label: string,
    -- specifies what type of Autocomplete item this is. Primarily this
    -- controls the icon given to the item in the editor. Not all kinds have
    -- a unique icon. If not specified, the editor uses the "Text" icon.
    kind: Enum.CompletionItemKind?,
    -- specifies an array of tags describing this completion item. See the
    -- CompletionItemTag for details on their function
    -- (https://create.roblox.com/docs/reference/engine/enums/CompletionItemTag)
    tags: { Enum.CompletionItemTag }?,
    -- specifies a string describing details about the completion item. For
    -- default items, this is a string representation of their type. Note that,
    -- in order for the documentation widget to display, documentation must be
    -- present, but `documentation.value` may be empty
    detail: string?,
    -- specifies the main body of the documentation in its value field.
    -- documentation is present, even if value is empty, so the documentation
    -- window displays if either details or overloads are specified
    documentation: {
        value: string,
    }?,
    -- specifies the number of overloads of a function autocompletion
    overloads: number?,
    -- links to a relevant page on the creator docs. This URL must be an https
    -- request to create.roblox.com, no other URLs display in the editor
    learnMoreLink: string?,
    -- specifies a sample use of the completion item. documentation must be
    -- non-empty to display this field
    codeSample: string?,
    -- If true, the editor sorts this completion item ahead of all others and
    -- selects it for the user by default. No effect if false or missing
    preselect: boolean?,
    -- If present, accepting the completion applies this text edit - replacing
    -- the span between the positions start and end with newText
    textEdit: TextEdit?,
}

export type AutoCompleteResponse = {
    -- array of the completion items. The order of this array is insignificant,
    -- and it resorts in the editor as the user types
    items: { CompletionItem },
}

return {}
