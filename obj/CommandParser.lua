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

--- Cloneable that parses commands on behalf of a player.
-- @author milkmanjack
module("obj.CommandParser", package.seeall)

local Cloneable		= require("obj.Cloneable")

--- Cloneable that parses commands on behalf of a player.
-- @class table
-- @name CommandParser
local CommandParser	= Cloneable.clone()

--- List of all commands we recognized.
-- @class table
-- @name CommandParser.commands
CommandParser.commands	= nil -- list of commands we recognize

--- Creates a unique commands table per CommandParser.
function CommandParser:initialize()
	self.commands = {}
end

--- Parses command input with a player as an assumed source.
-- @param player Player to be treated as the source of the input.
-- @param mob Mob of the Player being treated as the source of the input.
-- @return true on successful command match.<br/>false otherwise.
function CommandParser:parse(player, mob, input)
	for i,v in ipairs(self.commands) do
		if v:match(player, mob, input) then
			v:parse(player, mob, input)
			return true
		end
	end

	return false
end

--- Adds a Command to the list of commands we recognize.
-- @param command Command to be added.
function CommandParser:addCommand(command)
	table.insert(self.commands, command)
end

--- Remove a Command from the list of commands we recognize.
-- @param command Command to be removed.
function CommandParser:removeCommand(command)
	table.removeValue(self.commands, command)
end

return CommandParser
