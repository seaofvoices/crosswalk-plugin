local Observable = require('../Observable')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function create<T>(creator: (subscriber: Subscriber<T>) -> ()): Observable<T>
    return Observable.new(function(_, subscriber: Subscriber<T>)
        creator(subscriber)
    end)
end

return create
