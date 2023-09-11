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
    charCodeAt = require('./charCodeAt'),
    endsWith = require('./endsWith'),
    findOr = require('./findOr'),
    includes = require('./includes'),
    indexOf = require('./indexOf'),
    lastIndexOf = require('./lastIndexOf'),
    slice = require('./slice'),
    split = require('./split'),
    startsWith = require('./startsWith'),
    substr = require('./substr'),
    trim = require('./trim'),
    trimEnd = require('./trimEnd'),
    trimStart = require('./trimStart'),
    -- aliases for trimEnd and trimStart
    trimRight = require('./trimEnd'),
    trimLeft = require('./trimStart'),
}
