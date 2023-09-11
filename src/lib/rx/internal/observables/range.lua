local Observable = require('../Observable')
local empty = require('./empty')

type Observable<T> = Observable.Observable<T>
type Subscriber<T> = Observable.Subscriber<T>

local function range(start: number, count: number?): Observable<number>
    local actualCount = if count == nil then start else count
    start = if count == nil then 1 else start

    if actualCount <= 0 then
        return empty()
    end

    local endValue = actualCount + start - 1

    return Observable.new(function(_, subscriber: Subscriber<number>)
        for n = start, endValue do
            if subscriber:isClosed() then
                break
            end
            subscriber:next(n)
        end
        subscriber:complete()
    end)
end

return range
