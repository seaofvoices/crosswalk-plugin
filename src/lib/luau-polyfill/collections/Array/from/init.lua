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
local Map = require('../../Map/init')
local Set = require('../../Set/init')
local instanceof = require('../../../instance-of/init')
local isArray = require('../isArray')
local types = require('../../../es7-types/init')

local fromArray = require('./fromArray')
local fromMap = require('./fromMap')
local fromSet = require('./fromSet')
local fromString = require('./fromString')

type Array<T> = types.Array<T>
type Object = types.Object
type Set<T> = types.Set<T>
type Map<K, V> = types.Map<K, V>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U

return function<T, U>(
    value: string | Array<T> | Set<T> | Map<any, any>,
    mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
    thisArg: Object?
    -- FIXME Luau: need overloading so the return type on this is more sane and doesn't require manual casts
): Array<U> | Array<T> | Array<string>
    if value == nil then
        error('cannot create array from a nil value')
    end
    local valueType = typeof(value)

    local array: Array<U> | Array<T> | Array<string>

    if valueType == 'table' and isArray(value) then
        array = fromArray(value :: Array<T>, mapFn, thisArg)
    elseif instanceof(value, Set) then
        array = fromSet(value :: Set<T>, mapFn, thisArg)
    elseif instanceof(value, Map) then
        array = fromMap(value :: Map<any, any>, mapFn, thisArg)
    elseif valueType == 'string' then
        array = fromString(value :: string, mapFn, thisArg)
    else
        array = {}
    end

    return array
end
