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
return {
    assign = require('./assign'),
    entries = require('./entries'),
    freeze = require('./freeze'),
    is = require('./is'),
    isFrozen = require('./isFrozen'),
    keys = require('./keys'),
    preventExtensions = require('./preventExtensions'),
    seal = require('./seal'),
    values = require('./values'),
    -- Special marker type used in conjunction with `assign` to remove values
    -- from tables, since nil cannot be stored in a table
    None = require('./None'),
}
