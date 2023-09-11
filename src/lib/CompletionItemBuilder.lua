local ScriptEditorServiceTypes = require('./ScriptEditorServiceTypes')

type CompletionItem = ScriptEditorServiceTypes.CompletionItem
type TextEdit = ScriptEditorServiceTypes.TextEdit

export type CompletionItemBuilder = {
    build: (self: CompletionItemBuilder) -> { CompletionItem },
    addLabel: (self: CompletionItemBuilder, label: string) -> CompletionItemBuilder,
    kind: (self: CompletionItemBuilder, kind: Enum.CompletionItemKind) -> CompletionItemBuilder,
    detail: (self: CompletionItemBuilder, detail: string) -> CompletionItemBuilder,
}

type Private = {
    _textEdit: TextEdit,
    _labels: { string },
    _detail: string,
    _kind: Enum.CompletionItemKind,
}
type CompletionItemBuilderStatic = CompletionItemBuilder & Private & {
    new: (textEdit: TextEdit) -> CompletionItemBuilder,
}

local CompletionItemBuilder: CompletionItemBuilderStatic = {} :: any
local CompletionItemMetatable = {
    __index = CompletionItemBuilder,
}

function CompletionItemBuilder.new(textEdit: TextEdit): CompletionItemBuilder
    local self: Private = {
        _textEdit = textEdit,
        _labels = {},
        _detail = '',
        _kind = Enum.CompletionItemKind.Text,
    }

    return setmetatable(self, CompletionItemMetatable) :: any
end

function CompletionItemBuilder:build(): { CompletionItem }
    local self = self :: Private & CompletionItemBuilder
    local completions = {}
    for _, label in self._labels do
        table.insert(completions, {
            label = label,
            kind = self._kind,
            tags = {},
            detail = self._detail,
            documentation = { value = '' },
            overloads = 0,
            -- codeSample = "",
            -- preselect = false,
            textEdit = self._textEdit,
        })
    end
    if _G.DEV and #completions == 0 then
        error('expected at least one label to build completion item')
    end
    return completions
end

function CompletionItemBuilder:addLabel(label: string): CompletionItemBuilder
    local self = self :: Private & CompletionItemBuilder
    if not table.find(self._labels, label) then
        table.insert(self._labels, label)
    end
    return self
end

function CompletionItemBuilder:kind(kind: Enum.CompletionItemKind): CompletionItemBuilder
    local self = self :: Private & CompletionItemBuilder
    self._kind = kind
    return self
end

function CompletionItemBuilder:detail(detail: string): CompletionItemBuilder
    local self = self :: Private & CompletionItemBuilder
    self._detail = detail
    return self
end

return CompletionItemBuilder
