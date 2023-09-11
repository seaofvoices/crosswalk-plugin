local Observable = require('../Observable')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function doSubscribe<T>(
    handler: (T) -> (),
    subscriber: Subscriber<T>,
    subTarget: RBXScriptSignal<T>
)
    local connection = subTarget:Connect(function(...)
        handler(...)
    end)
    subscriber:add(function()
        connection:Disconnect()
    end)
end

type RegisterEventOptions<T> = {
    packArguments: true | ((...any) -> T)?,
}

local function fromRobloxEvent<T>(
    event: RBXScriptSignal,
    options: RegisterEventOptions<T>?
): Observable<T>
    local packArguments = if options == nil then nil else options.packArguments

    return Observable.new(function(_, subscriber: Subscriber<T>)
        local function handler(...)
            local value = if packArguments == nil
                then ...
                elseif packArguments == true then table.pack(...)
                else (packArguments :: any)(...)
            subscriber:next(value)
        end

        doSubscribe(handler, subscriber, event)
    end)
end

return fromRobloxEvent
