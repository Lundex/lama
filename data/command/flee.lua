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

--- Flee command.
-- @class table
-- @name Flee
local Flee		= Command:clone()
Flee.keyword	= "flee"

--- Flee.
function Flee:execute(player, mob)
	mob:disengage()
end

return Flee
