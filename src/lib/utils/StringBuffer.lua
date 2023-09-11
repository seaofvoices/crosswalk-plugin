type Style = 'bold' | 'dim' | 'italic' | 'underline'
type Color = 'green' | 'red' | 'cyan' | 'yellow'

type WithContent = string | (StringBuffer) -> ()

export type StringBuffer = {
    write: (self: StringBuffer, content: string) -> StringBuffer,
    writeLine: (self: StringBuffer, content: string) -> StringBuffer,
    newLine: (self: StringBuffer) -> StringBuffer,
    format: (self: StringBuffer, message: string, ...any) -> StringBuffer,
    withStyle: (self: StringBuffer, style: Style, content: WithContent) -> StringBuffer,
    withColor: (self: StringBuffer, color: Color, content: WithContent) -> StringBuffer,
    indent: (self: StringBuffer) -> StringBuffer,
    dedent: (self: StringBuffer) -> StringBuffer,
    toString: (self: StringBuffer) -> string,
}

type Private = {
    _content: { string },
    _indentation: string,
    _indentationLevel: number,

    _maybeWriteIndent: (self: StringBuffer) -> (),
}

type StringBufferConfig = {
    indentation: string?,
}

type StringBufferStatic = StringBuffer & Private & {
    new: (config: StringBufferConfig?) -> StringBuffer,
}

local StringBuffer: StringBufferStatic = {} :: any
local StringBufferMetatable = {
    __index = StringBuffer,
    __tostring = function(self)
        return self:toString()
    end,
}

function StringBuffer.new(config: StringBufferConfig?): StringBuffer
    local self: Private = {
        _content = {},
        _indentation = (if config then config.indentation else nil) or '    ',
        _indentationLevel = 0,

        -- typechecker needs to think that we've defined private methods
        _maybeWriteIndent = nil :: any,
    }
    return setmetatable(self, StringBufferMetatable) :: any
end

function StringBuffer:write(content: string): StringBuffer
    local self = self :: StringBuffer & Private
    self:_maybeWriteIndent()
    table.insert(self._content, content)
    return self
end

function StringBuffer:writeLine(content: string): StringBuffer
    local self = self :: StringBuffer & Private
    self:_maybeWriteIndent()
    table.insert(self._content, content .. '\n')
    return self
end

function StringBuffer:newLine(): StringBuffer
    local self = self :: StringBuffer & Private
    table.insert(self._content, '\n')
    return self
end

function StringBuffer:format(message, ...): StringBuffer
    local self = self :: StringBuffer & Private
    self:_maybeWriteIndent()

    table.insert(self._content, string.format(message, ...))
    return self
end

local MAP_STYLE: { [string]: string } = {
    bold = '\x1b[1m',
    dim = '\x1b[2m',
    italic = '\x1b[3m',
    underline = '\x1b[4m',
}
local MAP_RESET_STYLE: { [string]: string } = {
    bold = '\x1b[22m',
    dim = '\x1b[22m',
    italic = '\x1b[23m',
    underline = '\x1b[24m',
}

function StringBuffer:withStyle(style: Style, content: WithContent): StringBuffer
    local self = self :: StringBuffer & Private

    local code = MAP_STYLE[style]
    local resetCode = MAP_RESET_STYLE[style]
    local hasCodes = code ~= nil and resetCode ~= nil

    if hasCodes then
        self:write(code)
    end

    if type(content) == 'string' then
        self:write(content)
    else
        content(self)
    end

    if hasCodes then
        self:write(resetCode)
    end

    return self
end

local MAP_COLOR: { [string]: string } = {
    red = '\x1b[31m',
    green = '\x1b[32m',
    cyan = '\x1b[36m',
    yellow = '\x1b[33m',
}

function StringBuffer:withColor(color: Color, content: WithContent): StringBuffer
    local self = self :: StringBuffer & Private

    local code = MAP_COLOR[color]

    if code then
        self:write(code)
    end

    if type(content) == 'string' then
        self:write(content)
    else
        content(self)
    end

    if code then
        self:write('\x1b[39m')
    end

    return self
end

function StringBuffer:indent(): StringBuffer
    local self = self :: StringBuffer & Private
    self._indentationLevel += 1
    return self
end

function StringBuffer:dedent(): StringBuffer
    local self = self :: StringBuffer & Private
    self._indentationLevel = math.max(self._indentationLevel - 1, 0)
    return self
end

function StringBuffer:_maybeWriteIndent()
    local self = self :: StringBuffer & Private

    if self._indentationLevel == 0 then
        return
    end

    local last = self._content[#self._content]

    if last == nil or string.sub(last, -1, -1) == '\n' then
        table.insert(self._content, string.rep(self._indentation, self._indentationLevel))
    end
end

function StringBuffer:toString(): string
    local self = self :: StringBuffer & Private
    return table.concat(self._content, '')
end

return StringBuffer
