local Subscription = require('./Subscription')
local types = require('./types')

type Subscription = Subscription.Subscription
type Subscribable<T> = types.Subscribable<T>
type Observer<T> = types.Observer<T>
type PartialObserver<T> = types.PartialObserver<T>
type SubscriptionLike = types.SubscriptionLike
type TeardownLogic = types.TeardownLogic

export type SubscriberOverrides<T> = {
    next: ((self: Subscriber<T>, value: T) -> ())?,
    error: ((self: Subscriber<T>, err: any) -> ())?,
    complete: ((self: Subscriber<T>) -> ())?,
    finalize: ((self: Subscriber<T>) -> ())?,
}

export type Subscriber<T> = Observer<T> & Subscription

type Private<T> = {
    _isStopped: boolean,
    _destination: Observer<T>,

    _nextOverride: ((self: Subscriber<T>, value: T) -> ())?,
    _errorOverride: ((self: Subscriber<T>, err: any) -> ())?,
    _completeOverride: ((self: Subscriber<T>) -> ())?,
    _onFinalize: ((self: Subscriber<T>) -> ())?,

    _next: (self: Subscriber<T>, value: T) -> (),
    _error: (self: Subscriber<T>, err: any) -> (),
    _complete: (self: Subscriber<T>) -> (),
}
type SubscriberStatic = {
    new: <T>(
        destination: nil | Subscriber<T> | PartialObserver<T> | (value: T) -> ()
    ) -> Subscriber<T>,
    newWithOverrides: <T>(
        destination: nil | Subscriber<any> | PartialObserver<any> | (value: any) -> (),
        overrides: SubscriberOverrides<T>
    ) -> Subscriber<T>,
    is: (value: unknown) -> boolean,

    -- bring static version of Private<T> methods
    _next: <T>(self: Subscriber<T>, value: T) -> (),
    _error: <T>(self: Subscriber<T>, err: any) -> (),
    _complete: <T>(self: Subscriber<T>) -> (),

    -- bring static version of Observer<T> methods
    next: <T>(self: Subscriber<T>, value: T) -> (),
    error: <T>(self: Subscriber<T>, err: any) -> (),
    complete: <T>(self: Subscriber<T>) -> (),

    -- bring static version of Subscription methods
    unsubscribe: <T>(self: Subscriber<T>) -> (),
}

local Subscriber: SubscriberStatic = setmetatable({}, { __index = Subscription }) :: any
local SubscriberMetatable = {
    __index = Subscriber,
}

type ConsumerObserver<T> = Observer<T>

type ConsumerObserverPrivate<T> = {
    partialObserver: PartialObserver<T>,
}
type ConsumerObserverStatic = {
    new: <T>(partialObserver: PartialObserver<T>) -> ConsumerObserver<T>,

    -- bring static version of Observer<T> methods
    next: <T>(self: ConsumerObserver<T>, value: T) -> (),
    error: <T>(self: ConsumerObserver<T>, err: any) -> (),
    complete: <T>(self: ConsumerObserver<T>) -> (),
}

local ConsumerObserver: ConsumerObserverStatic = {} :: any
local ConsumerObserverMetatable = {
    __index = ConsumerObserver,
}

function ConsumerObserver.new<T>(partialObserver: PartialObserver<T>): ConsumerObserver<T>
    local self: ConsumerObserverPrivate<T> = {
        partialObserver = partialObserver,
    }

    return setmetatable(self, ConsumerObserverMetatable) :: any
end

function ConsumerObserver:next<T>(value: T)
    local self: ConsumerObserverPrivate<T> & ConsumerObserver<T> = self :: any

    local partialObserver = self.partialObserver
    if partialObserver.next then
        local success, err: any = pcall(partialObserver.next, partialObserver :: Observer<T>, value)

        if not success then
            -- reportUnhandledError(err)
            warn('todo: unhandled error: ' .. tostring(err))
        end
    end
end

function ConsumerObserver:error<T>(err: any)
    local self: ConsumerObserverPrivate<T> & ConsumerObserver<T> = self :: any

    local partialObserver = self.partialObserver
    if partialObserver.error then
        local success, processErr: any =
            pcall(partialObserver.error, partialObserver :: Observer<T>, err)

        if not success then
            -- reportUnhandledError(err)
            warn('todo: unhandled error: ' .. tostring(processErr))
        end
    else
        -- reportUnhandledError(err)
        warn('todo: unhandled error: ' .. tostring(err))
    end
end

function ConsumerObserver:complete<T>()
    local self: ConsumerObserverPrivate<T> & ConsumerObserver<T> = self :: any

    local partialObserver = self.partialObserver
    if partialObserver.complete then
        local success, err: any = pcall(partialObserver.complete, partialObserver :: Observer<T>)

        if not success then
            -- reportUnhandledError(err)
            warn('todo: unhandled error: ' .. tostring(err))
        end
    end
end

local function createSafeObserver<T>(
    observerOrNext: nil | PartialObserver<T> | (value: T) -> ()
): Observer<T>
    if observerOrNext == nil then
        return ConsumerObserver.new({})
    elseif type(observerOrNext) == 'function' then
        return ConsumerObserver.new({
            next = function(_self, value: T)
                return observerOrNext(value)
            end,
        })
    else
        return ConsumerObserver.new(observerOrNext)
    end
end

local function hasAddAndUnsubscribe(value: unknown): boolean
    return Subscription.is(value)
end

local function overrideNext<T>(this: Subscriber<T> & Private<T>, value: T)
    if this._nextOverride ~= nil then
        local success, err: any = pcall(function()
            -- typechecker complains that method could be nil when
            -- using the syntax `this:_nextOverride(value)`
            this._nextOverride(this, value)
        end)
        if not success then
            this._destination:error(err)
        end
    end
end

local function overrideError<T>(this: Subscriber<T> & Private<T>, err: any)
    if this._errorOverride ~= nil then
        local success, overrideErr: any = pcall(function()
            -- typechecker complains that method could be nil when
            -- using the syntax `this:_errorOverride(err)`
            this._errorOverride(this, err)
        end)
        if not success then
            this._destination:error(overrideErr)
        end
        this:unsubscribe()
    end
end

local function overrideComplete<T>(this: Subscriber<T> & Private<T>)
    if this._completeOverride ~= nil then
        local success, err: any = pcall(function()
            -- typechecker complains that method could be nil when
            -- using the syntax `this:_completeOverride()`
            this._completeOverride(this)
        end)
        if not success then
            this._destination:error(err)
        end
        this:unsubscribe()
    end
end

function Subscriber.new<T>(
    destination: nil | Subscriber<T> | PartialObserver<T> | (value: T) -> ()
): Subscriber<T>
    local self: Private<T> = Subscription.new() :: any
    self._destination = if Subscriber.is(destination)
        then destination :: Observer<T>
        else createSafeObserver(destination)
    self._isStopped = false

    if self._nextOverride ~= nil then
        self._next = overrideNext :: any
    end
    if self._errorOverride ~= nil then
        self._error = overrideError :: any
    end
    if self._nextOverride ~= nil then
        self._complete = overrideComplete :: any
    end

    if hasAddAndUnsubscribe(destination) then
        ((destination :: any) :: Subscription):add(self :: any)
    end

    return setmetatable(self, SubscriberMetatable) :: any
end

function Subscriber.newWithOverrides<T>(
    destination: nil | Subscriber<any> | PartialObserver<any> | (value: any) -> (),
    overrides: SubscriberOverrides<T>
): Subscriber<T>
    local self: Private<T> = Subscription.new() :: any
    self._destination = if Subscriber.is(destination)
        then destination :: Observer<T>
        else createSafeObserver(destination)
    self._isStopped = false

    if overrides ~= nil then
        self._nextOverride = overrides.next :: any
        self._errorOverride = overrides.error :: any
        self._completeOverride = overrides.complete :: any
        self._onFinalize = overrides.finalize :: any
    end

    if self._nextOverride ~= nil then
        self._next = overrideNext :: any
    end
    if self._errorOverride ~= nil then
        self._error = overrideError :: any
    end
    if self._nextOverride ~= nil then
        self._complete = overrideComplete :: any
    end

    if hasAddAndUnsubscribe(destination) then
        ((destination :: any) :: Subscription):add(self :: any)
    end

    return setmetatable(self, SubscriberMetatable) :: any
end

function Subscriber.is(value: unknown): boolean
    if type(value) == 'table' then
        local metatable = getmetatable(value :: any)

        if metatable ~= nil then
            return metatable == SubscriberMetatable
        end
    end
    return false
end

function Subscriber:next<T>(value: T)
    local self: Private<T> & Subscriber<T> = self :: any

    if self._isStopped then
        -- handleStoppedNotification(nextNotification(value), self);
    else
        self:_next(value)
    end
end

function Subscriber:error<T>(err: any)
    local self: Private<T> & Subscriber<T> = self :: any

    if self._isStopped then
        -- handleStoppedNotification(errorNotification(value), self);
    else
        self._isStopped = true
        self:_error(err)
    end
end

function Subscriber:complete<T>()
    local self: Private<T> & Subscriber<T> = self :: any

    if self._isStopped then
        -- handleStoppedNotification(COMPLETE_NOTIFICATION, self);
    else
        self._isStopped = true
        self:_complete()
    end
end

function Subscriber:unsubscribe<T>()
    local self: Private<T> & Subscriber<T> = self :: any

    if not self:isClosed() then
        self._isStopped = true
        Subscription.unsubscribe(self)
        if self._onFinalize ~= nil then
            self._onFinalize(self)
        end
    end
end

function Subscriber:_next<T>(value: T)
    local self: Private<T> & Subscriber<T> = self :: any

    self._destination:next(value)
end

function Subscriber:_error<T>(err: any)
    local self: Private<T> & Subscriber<T> = self :: any

    local success, returnedErr = pcall(function()
        self._destination:error(err)
    end)

    self:unsubscribe()

    if not success then
        error(returnedErr)
    end
end

function Subscriber:_complete<T>()
    local self: Private<T> & Subscriber<T> = self :: any

    local success, err = pcall(function()
        self._destination:complete()
    end)

    self:unsubscribe()

    if not success then
        error(err)
    end
end

export type OperateConfig<In, Out> = SubscriberOverrides<In> & {
    -- The destination subscriber to forward notifications to. This is also the
    -- subscriber that will receive unhandled errors if your `next`, `error`, or `complete`
    -- overrides throw.
    destination: Subscriber<Out>,
}

local function operate<In, Out>(config: OperateConfig<In, Out>): Subscriber<In>
    return Subscriber.newWithOverrides(config.destination, {
        next = config.next,
        error = config.error,
        complete = config.complete,
        finalize = config.finalize,
    })
end

return {
    Subscriber = Subscriber,
    operate = operate,
}
