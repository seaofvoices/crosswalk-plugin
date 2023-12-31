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
local indexOf = require('./indexOf')
local types = require('../../es7-types/init')

type Array<T> = types.Array<T>

return function<T>(array: Array<T>, searchElement: T, fromIndex: number?): boolean
    return indexOf(array, searchElement, fromIndex) ~= -1
end
