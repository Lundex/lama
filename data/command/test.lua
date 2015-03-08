--[[
    lama is a MUD server made in Lua.
    Copyright (C) 2013 Curtis Erickson

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--- Command for listing usable commands.
-- @author milkmanjack
local Command		= require("obj.Command")

--- Test command.
-- @class table
-- @name Test
local Test		= Command:clone()
Test.keyword	= "test"

--- Tests stuff.
function Test:parse(player, mob, input)
	local cmd, _ = string.getWord(input)
	local a, _ = string.getWord(_)
	local b, _ = string.getWord(_)
	self:execute(player, mob, a, b)
end

function Test:execute(player, mob, a, b)
	mob:sendMessage(matchKeywords(a, b) or "not matched", MessageMode.COMMAND)
end

return Test
