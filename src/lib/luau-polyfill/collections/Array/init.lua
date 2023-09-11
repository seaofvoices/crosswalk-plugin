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

export type Array<T> = ES7Types.Array<T>

return {
    concat = require('./concat'),
    every = require('./every'),
    filter = require('./filter'),
    find = require('./find'),
    findIndex = require('./findIndex'),
    flat = require('./flat'),
    flatMap = require('./flatMap'),
    forEach = require('./forEach'),
    from = require('./from/init'),
    includes = require('./includes'),
    indexOf = require('./indexOf'),
    isArray = require('./isArray'),
    join = require('./join'),
    map = require('./map'),
    reduce = require('./reduce'),
    reverse = require('./reverse'),
    shift = require('./shift'),
    slice = require('./slice'),
    some = require('./some'),
    sort = require('./sort'),
    splice = require('./splice'),
    unshift = require('./unshift'),
}
