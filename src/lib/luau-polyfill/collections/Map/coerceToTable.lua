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
local Map = require('./Map')
local arrayReduce = require('../Array/reduce')
local instanceOf = require('../../instance-of/init')
local types = require('../../es7-types/init')

type Map<K, V> = types.Map<K, V>
type Table<K, V> = types.Table<K, V>

local function coerceToTable(mapLike: Map<any, any> | Table<any, any>): Table<any, any>
    if not instanceOf(mapLike, Map) then
        return mapLike :: Table<any, any>
    end

    -- create table from map
    return arrayReduce(mapLike:entries(), function(tbl, entry)
        tbl[entry[1]] = entry[2]
        return tbl
    end, {})
end

return coerceToTable
