local ScriptEditorServiceTypes = require('./ScriptEditorServiceTypes')
local TextEdit = require('./TextEdit')

type AutoCompleteRequest = ScriptEditorServiceTypes.AutoCompleteRequest
type TextEdit = TextEdit.TextEdit

type TextPosition = { line: number, character: number }
type TextSpan = { start: TextPosition, ['end']: TextPosition }

export type EditorContextData = {
    positions: {
        cursor: TextPosition,
        currentWord: TextPosition,
    },
    -- spans: {
    --     line: TextSpan,
    --     currentWord: TextSpan
    -- },
    source: string,
    lines: { string },
    currentLine: string,
    currentLineToCursor: string,
    currentWord: string,
}

export type EditorContext = EditorContextData & {
    toAbsolutePosition: (self: EditorContext, position: TextPosition) -> number,
    sourceBefore: (self: EditorContext, position: TextPosition, length: number?) -> string,
    replaceCurrentWord: (self: EditorContext) -> TextEdit,
}

type EditorContextStatic = EditorContext & {
    new: (request: AutoCompleteRequest) -> EditorContext,
}

local EditorContext: EditorContextStatic = {} :: any
local CrosswalkContextMetatable = {
    __index = EditorContext,
}

local function getSource(request: AutoCompleteRequest): string
    local document = request.textDocument.document

    if document ~= nil then
        return document:GetText()
    end

    local currentModuleScript = request.textDocument.script

    if currentModuleScript ~= nil then
        return currentModuleScript.RuntimeSource
    end

    error('unable to obtain text content')
end

function EditorContext.new(request: AutoCompleteRequest): EditorContext
    local position = request.position

    local source = getSource(request)
    local lines = string.split(source, '\n')
    local currentLine = lines[position.line]
    local currentLineToCursor = string.sub(currentLine, 1, position.character - 1)

    local currentWord = string.match(currentLineToCursor, '%a%w*$') or ''

    local self: EditorContextData = {
        positions = {
            cursor = position,
            currentWord = {
                line = position.line,
                character = position.character - string.len(currentWord),
            },
        },
        source = source,
        lines = lines,
        currentLine = currentLine,
        currentLineToCursor = currentLineToCursor,
        currentWord = currentWord,
    }
    return setmetatable(self, CrosswalkContextMetatable) :: any
end

function EditorContext:toAbsolutePosition(position: TextPosition): number
    local sum = position.character
    for i = 1, position.line - 1 do
        local line = self.lines[i]
        if line then
            sum += string.len(line) + 1
        else
            break
        end
    end
    return sum
end

function EditorContext:sourceBefore(position: TextPosition, length: number?): string
    local absolute = self:toAbsolutePosition(position)

    return string.sub(
        self.source,
        if length == nil then 1 else math.max(1, absolute - length),
        absolute - 1
    )
end

function EditorContext:replaceCurrentWord(): TextEdit
    local currentWordPosition = self.positions.currentWord
    return TextEdit.new(
        currentWordPosition.line,
        currentWordPosition.character,
        nil,
        self.positions.cursor.character
    )
end

return EditorContext
