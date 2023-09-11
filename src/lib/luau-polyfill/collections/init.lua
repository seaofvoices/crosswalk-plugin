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
local Array = require('./Array/init')
local Map = require('./Map/init')
local Object = require('./Object/init')
local Set = require('./Set/init')
local WeakMap = require('./WeakMap')
local inspect = require('./inspect')

local types = require('../es7-types/init')

export type Array<T> = types.Array<T>
export type Map<T, V> = types.Map<T, V>
export type Object = types.Object
export type Set<T> = types.Set<T>
export type WeakMap<T, V> = types.WeakMap<T, V>

return {
    Array = Array,
    Object = Object,
    Map = Map.Map,
    coerceToMap = Map.coerceToMap,
    coerceToTable = Map.coerceToTable,
    Set = Set,
    WeakMap = WeakMap,
    inspect = inspect,
}
