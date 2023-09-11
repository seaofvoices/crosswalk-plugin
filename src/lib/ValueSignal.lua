type BaseValueSignal<T> = {
    get: (self: BaseValueSignal<T>) -> T,
    update: (self: BaseValueSignal<T>, value: T) -> (),
    onChange: (self: BaseValueSignal<T>, callback: (T) -> ()) -> () -> (),
}

type ValueSignalExtension = {
    map: <T, U>(
        self: BaseValueSignal<T> & ValueSignalExtension,
        mapper: (T) -> U
    ) -> BaseValueSignal<U> & ValueSignalExtension,
    -- zip: <T, U>(
    --     self: BaseValueSignal<T> & ValueSignalExtension,
    --     other: BaseValueSignal<U> & ValueSignalExtension
    -- ) -> BaseValueSignal<{ first: T, second: U }> & ValueSignalExtension,
}
export type ValueSignal<T> = BaseValueSignal<T> & ValueSignalExtension

type Private<T> = {
    _current: T,
    _onChange: { (T) -> () },
}
type ValueSignalStatic = ValueSignalExtension & {
    new: <T>(defaultValue: T) -> ValueSignal<T>,

    -- bring static version of BaseValueSignal<T> methods
    get: <T>(self: ValueSignal<T>) -> T,
    update: <T>(self: BaseValueSignal<T>, value: T) -> (),
    onChange: <T>(self: BaseValueSignal<T>, callback: (T) -> ()) -> () -> (),
}

local ValueSignal: ValueSignalStatic = {} :: any
local ValueSignalMetatable = {
    __index = ValueSignal,
}

function ValueSignal.new<T>(defaultValue: T): ValueSignal<T>
    local self: Private<T> = {
        _current = defaultValue,
        _onChange = {},
    }

    return setmetatable(self, ValueSignalMetatable) :: any
end

function ValueSignal:get<T>(): T
    local self: Private<T> & ValueSignal<T> = self :: any

    return self._current
end

function ValueSignal:update<T>(value: T)
    local self: Private<T> & ValueSignal<T> = self :: any

    if self._current == value then
        return
    end

    self._current = value

    for _, onChange in self._onChange do
        onChange(value)
    end
end

function ValueSignal:onChange<T>(callback: (T) -> ()): () -> ()
    local self: Private<T> & ValueSignal<T> = self :: any

    table.insert(self._onChange, callback)

    local disconnected = false
    local function disconnect()
        if disconnected then
            if _G.DEV then
                error('attempt to disconnect ValueSignal twice')
            end
            return
        end
        disconnected = true
        local index = table.find(self._onChange, callback)
        if index ~= nil then
            table.remove(self._onChange, index)
        end
    end

    return disconnect
end

function ValueSignal:map<T, U>(mapper: (T) -> U): ValueSignal<U>
    local self: Private<T> & ValueSignal<T> = self :: any

    local defaultValue = mapper(self._current)

    local newValueSignal = ValueSignal.new(defaultValue)

    local function onChange(newValue: T)
        local mappedValue = mapper(newValue)
        newValueSignal:update(mappedValue)
    end

    table.insert(self._onChange, onChange)

    return newValueSignal
end

return ValueSignal
