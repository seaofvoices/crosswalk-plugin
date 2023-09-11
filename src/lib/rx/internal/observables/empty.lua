local Observable = require('../Observable')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local emptyObservable = nil

local function empty(): Observable<any>
    if emptyObservable == nil then
        emptyObservable = Observable.new(function(_, subscriber: Subscriber<any>)
            subscriber:complete()
        end)
        return emptyObservable
    else
        return emptyObservable
    end
end

return empty
