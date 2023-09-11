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
local ES7Types = require('../../es7-types/init')
local Map = require('./Map')
local coerceToMap = require('./coerceToMap')
local coerceToTable = require('./coerceToTable')

export type Map<K, V> = ES7Types.Map<K, V>

return {
    Map = Map,
    coerceToMap = coerceToMap,
    coerceToTable = coerceToTable,
}
