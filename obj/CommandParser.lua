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
function CommandParser:parse(player, mob, input)
	-- some generic parsing cause I'm too lazy to implement real commands right now
	if input == "hotboot" then
		Game.hotboot()
	elseif string.find("north", input) == 1 then
		if mob:step(Direction.NORTH) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("south", input) == 1 then
		if mob:step(Direction.SOUTH) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("east", input) == 1 then
		if mob:step(Direction.EAST) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("west", input) == 1 then
		if mob:step(Direction.WEST) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("who", input) == 1 then
		local msg = "\[ Connected Players ]"
		for i,v in ipairs(Game:getPlayers()) do
			msg = string.format("%s\n-> %s", msg, v:getMob():getName())
		end

		player:sendMessage(msg)

	elseif string.find("look", input) == 1 then
		player:getMob():showRoom()

	elseif string.find(input, "ooc") == 1 then
		local msg = string.sub(input, 5)
		Game.announce(string.format("%s OOC: '%s'", mob:getName(), msg), MessageMode.CHAT, PlayerState.PLAYING)
	end
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
