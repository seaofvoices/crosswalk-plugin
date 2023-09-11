local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local filter = require('../operators/filter')
local from = require('./from').from
local not_ = require('../util/not')
local types = require('../types')

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>

type MonoTypeOperatorFunction<T> = extendedTypes.MonoTypeOperatorFunction<T>
type ObservableInput<T> = extendedTypes.ObservableInput<T>

local function partition<T, A>(
    source: ObservableInput<T>,
    predicate: (value: T, index: number) -> boolean,
    thisArg: any?
): { include: Observable<T>, exclude: Observable<T> }
    return {
        include = filter(predicate, thisArg)(from(source)) :: Observable<T>,
        exclude = filter(not_(predicate))(from(source)) :: Observable<T>,
    }
end

return partition
