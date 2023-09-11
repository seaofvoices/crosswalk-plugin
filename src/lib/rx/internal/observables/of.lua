local Observable = require('../Observable')
local fromArrayLike = require('./from').fromArrayLike

type Observable<T> = Observable.Observable<T>

local function of<T>(...: T): Observable<T>
    return fromArrayLike({ ... })
end

return of
