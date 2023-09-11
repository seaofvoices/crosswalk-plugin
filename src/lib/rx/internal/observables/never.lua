local Observable = require('../Observable')
local noop = require('../util/noop')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local neverObservable = nil

local function never(): Observable<any>
    if neverObservable == nil then
        neverObservable = Observable.new(noop)
        return neverObservable
    else
        return neverObservable
    end
end

return never
