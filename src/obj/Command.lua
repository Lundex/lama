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

--- Cloneable that is used to handle text commands.
-- @author milkmanjack
module("obj.Command", package.seeall)

require("ext.string")
local Cloneable	= require("obj.Cloneable")

--- Cloneable that is used to handle text commands.
-- @class table
-- @name Command
-- @field keyword Keyword for the Cloneable.
local Command	= Cloneable.clone()
Command.keyword	= nil

--- Verify that the given input can/will trigger this Command.
-- @return true on success.<br/>false otherwise.
function Command:match(player, mob, input)
	-- for now it just checks if the first word of the input autocompletes into the Command's keyword.
	local word = string.getWord(input)
	return (word and string.find(self.keyword, word) == 1) or false
end

--- Parses a string and runs the Command with necessary arguments.
-- @param player Player running the command
-- @param mob Mob running the command.
-- @param input Input to be parsed.
function Command:parse(player, mob, input)
	self:execute(player, mob, input)
end

--- Execute the command by the given player/mob pair.
-- @param player Player running the command
-- @param mob Mob running the command.
function Command:execute(player, mob)
end

return Command
