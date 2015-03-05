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

--- Kill command.
-- @class table
-- @name Kill
local Kill		= Command:clone()
Kill.keyword	= "kill"

--- Kill stuff.
function Kill:parse(player, mob, input)
	local cmd, keywords = string.getWord(input)
	if not keywords then
		player:sendMessage("Kill whom?")
		return
	end

	for i,victim in ipairs(mob:getLoc():getContents()) do
		if victim:match(keywords) then
			self:execute(player, mob, victim)
			return
		end
	end
end

function Kill:execute(player, mob, victim)
	mob:engage(victim)
	mob:combatRound()
end

return Kill
