local Observable = require('../Observable')
local Subscriber = require('../Subscriber')
local extendedTypes = require('../extended-types')
local fromModule = require('../observables/from')
local types = require('../types')

local subscribeToArray = fromModule.subscribeToArray

local operate = Subscriber.operate

type Observable<T> = Observable.Observable<T>
type TeardownLogic = types.TeardownLogic
type Subscriber<T> = Subscriber.Subscriber<T>

type OperatorFunction<T, R> = extendedTypes.OperatorFunction<T, R>

local function startWith<T, D>(...: D): OperatorFunction<T, T | D>
    local values = { ... }

    local function operation(source: Observable<T>): Observable<T | D>
        return Observable.new(
            function(_self: Observable<T>, destination: Subscriber<T | D>): TeardownLogic
                subscribeToArray(
                    values,
                    operate({
                        destination = destination,
                        complete = function()
                            source:subscribe(destination :: any)
                        end,
                    })
                )

                return nil
            end
        )
    end
    return operation
end

return startWith
