local Observable = require('../Observable')
local types = require('../types')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>
type Subscribable<T> = types.Subscribable<T>

local function fromSubscribable<T>(subscribable: Subscribable<T>): Observable<T>
    return Observable.new(function(_, subscriber: Subscriber<T>)
        subscribable:subscribe(subscriber)
    end)
end

return fromSubscribable
