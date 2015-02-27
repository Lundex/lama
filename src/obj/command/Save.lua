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

--- Command for saving our character.
-- @class table
-- @name Save
local Save		= Command:clone()
Save.keyword	= "save"

--- Save the character.
-- @param player Player to be saved.
-- @param mob Mob to be saved.
function Save:execute(player, mob)
	DatabaseManager.saveCharacter(mob)
	mob:sendMessage("SAVED!", MessageMode.INFO)
end

return Save
