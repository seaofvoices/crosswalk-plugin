--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]
local __DEV__ = _G.__DEV__
local types = require('../../es7-types/init')

type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> ()
type callbackFnWithThisArg<T, U> = (thisArg: U, element: T, index: number, array: Array<T>) -> ()

-- Implements Javascript's `Array.prototype.forEach` as defined below
-- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
return function<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): ()
    if __DEV__ then
        if typeof(t) ~= 'table' then
            error(string.format('Array.forEach called on %s', typeof(t)))
        end
        if typeof(callback) ~= 'function' then
            error('callback is not a function')
        end
    end

    local len = #t
    local k = 1

    while k <= len do
        local kValue = t[k]

        if thisArg ~= nil then
            (callback :: callbackFnWithThisArg<T, U>)(thisArg, kValue, k, t)
        else
            (callback :: callbackFn<T>)(kValue, k, t)
        end

        if #t < len then
            -- don't iterate on removed items, don't iterate more than original length
            len = #t
        end
        k += 1
    end
end
