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

local Command	= require("obj.Command")

--- Command template for directional movement.
-- @class table
-- @name Movement
local Movement		= Command:clone()
Movement.direction	= Direction.NORTH

--- Take a step in a direction.
-- @param player Player taking a step.
-- @param mob Mob taking a step.
function Movement:execute(player, mob)
	if mob:step(self.direction) then
		mob:showRoom()
	else
		player:sendMessage("Alas, you cannot go that way.", MessageMode.COMMAND)
	end
end

return Movement
