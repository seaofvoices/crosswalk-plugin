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
    isFinite = require('./isFinite'),
    isInteger = require('./isInteger'),
    isNaN = require('./isNaN'),
    isSafeInteger = require('./isSafeInteger'),
    MAX_SAFE_INTEGER = require('./MAX_SAFE_INTEGER'),
    MIN_SAFE_INTEGER = require('./MIN_SAFE_INTEGER'),
    NaN = 0 / 0,
    toExponential = require('./toExponential'),
}
