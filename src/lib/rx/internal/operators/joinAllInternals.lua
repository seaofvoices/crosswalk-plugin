local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local types = require('../types')
local pipe = require('../util/pipe').pipe
local identity = require('../util/identity')
local mapOneOrManyArgs = require('../util/mapOneOrManyArgs')
local mergeMap = require('./mergeMap')
local toArray = require('./toArray')

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>
type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function joinAllInternals<T, R>(
    joinFn: (sources: { ObservableInput<T> }) -> Observable<T>,
    project: ((...any) -> R)?
)
    return pipe(
        toArray(),
        mergeMap(function(sources)
            return joinFn(sources)
        end),
        if project == nil then identity :: any else mapOneOrManyArgs(project)
    )
end

return joinAllInternals
