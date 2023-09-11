local CompletionItemBuilder = require('./CompletionItemBuilder')

type CompletionItemBuilder = CompletionItemBuilder.CompletionItemBuilder

export type TextEdit = {
    line: (self: TextEdit, line: string?) -> TextEdit,
    indent: (self: TextEdit) -> TextEdit,
    dedent: (self: TextEdit) -> TextEdit,
    intoCompletion: (self: TextEdit) -> CompletionItemBuilder,
}

type Private = {
    _lines: { string },
    _fromLine: number,
    _fromCharacter: number,
    _toLine: number,
    _toCharacter: number,
    _indentation: number,
    _indentationString: string,
}
type TextEditStatic = TextEdit & Private & {
    new: (
        fromLine: number,
        fromCharacter: number,
        toLine: number?,
        toCharacter: number?
    ) -> TextEdit,
}

local TextEdit: TextEditStatic = {} :: any
local TextEditMetatable = {
    __index = TextEdit,
}

function TextEdit.new(
    fromLine: number,
    fromCharacter: number,
    toLine: number?,
    toCharacter: number?
): TextEdit
    local self: Private = {
        _lines = {},
        _fromLine = fromLine,
        _fromCharacter = fromCharacter,
        _toLine = toLine or fromLine,
        _toCharacter = toCharacter or fromCharacter,
        _indentation = 0,
        _indentationString = '    ',
    }

    return setmetatable(self, TextEditMetatable) :: any
end

function TextEdit:line(line: string?): TextEdit
    local self = self :: Private & TextEdit

    local content = line or ''

    if string.len(content) > 0 and self._indentation > 0 then
        content = string.rep(self._indentationString, self._indentation) .. content
    end

    table.insert(self._lines, content)

    return self
end

function TextEdit:indent(): TextEdit
    local self = self :: Private & TextEdit
    self._indentation += 1
    return self
end

function TextEdit:dedent(): TextEdit
    local self = self :: Private & TextEdit
    self._indentation -= 1
    if self._indentation < 0 then
        self._indentation = 0
        if _G.DEV then
            error(
                'unable to reduce indentation, make sure to increase '
                    .. 'indentation before reducing it'
            )
        end
    end
    return self
end

function TextEdit:intoCompletion(): CompletionItemBuilder
    local self = self :: Private & TextEdit
    return CompletionItemBuilder.new({
        newText = table.concat(self._lines, '\n'),
        replace = {
            start = {
                line = self._fromLine,
                character = self._fromCharacter,
            },
            ['end'] = {
                line = self._toLine,
                character = self._toCharacter,
            },
        },
    })
end

return TextEdit
