local instanceOf = require('../../luau-polyfill/instance-of/init')
local types = require('./types')

type SubscriptionLike = types.SubscriptionLike
type TeardownLogic = types.TeardownLogic

export type Subscription = SubscriptionLike & {
    add: (self: Subscription, teardown: TeardownLogic) -> (),
    remove: (self: Subscription, teardown: TeardownLogic) -> (),
}

type Private = {
    _closed: boolean,
    _finalizers: { TeardownLogic }?,
    _initialTeardown: (() -> ())?,
}
type SubscriptionStatic = Subscription & Private & {
    new: (initialTeardown: (() -> ())?) -> Subscription,
    is: (object: unknown) -> boolean,
}

local Subscription: SubscriptionStatic = {} :: any
local SubscriptionMetatable = {
    __index = Subscription,
}

function Subscription.new(initialTeardown: (() -> ())?): Subscription
    local self: Private = {
        _closed = false,
        _finalizers = nil,
        _initialTeardown = initialTeardown,
    }

    return setmetatable(self, SubscriptionMetatable) :: any
end

function Subscription.is(value: unknown): boolean
    return instanceOf(value, Subscription)
end

function Subscription:isClosed(): boolean
    local self = self :: Private & Subscription
    return self._closed
end

local function execFinalizer(finalizer: TeardownLogic)
    if finalizer == nil then
        -- do nothing
    elseif type(finalizer) == 'function' then
        finalizer()
    else
        finalizer:unsubscribe()
    end
end

function Subscription:unsubscribe()
    local self = self :: Private & Subscription

    local errors = {}

    if self._closed then
        return
    end

    if self._initialTeardown ~= nil then
        local success, err: any = pcall(self._initialTeardown)
        if not success then
            -- if UnsubscriptionError.is(err) then
            -- move err.errors into errors
            -- else
            table.insert(errors, err)
        end
    end

    local finalizers = self._finalizers
    self._finalizers = nil

    if finalizers ~= nil then
        for _, finalizer in finalizers do
            local success, err: any = pcall(execFinalizer, finalizer)
            if not success then
                -- if UnsubscriptionError.is(err) then
                -- move err.errors into errors
                -- else
                table.insert(errors, err)
            end
        end
    end

    if #errors > 0 then
        -- todo: throw UnsubscriptionError(errors)
        error('error while unsubscribing')
    end
end

function Subscription:add(teardown: TeardownLogic)
    local self = self :: Private & Subscription

    if self._closed then
        execFinalizer(teardown)
    else
        if Subscription.is(teardown) then
            (teardown :: Subscription):add(function()
                self:remove(teardown)
            end)
        end
    end
end

function Subscription:remove(teardown: TeardownLogic)
    local self = self :: Private & Subscription

    if self._finalizers ~= nil then
        local index = table.find(self._finalizers, teardown)
        if index ~= nil then
            table.remove(self._finalizers, index)
        end
    end
end

return Subscription
