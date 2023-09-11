local Observable = require('../Observable')

type Observable<T> = Observable.Observable<T>

local function throwError(errorFactory: () -> any): Observable<any>
    return Observable.new(function(_, subscriber)
        subscriber:error(errorFactory())
    end)
end

return throwError
