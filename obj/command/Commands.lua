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
module("obj.Command.Commands", package.seeall)

local Command		= require("obj.Command")

--- Command for listing usable commands.
-- @class table
-- @name Commands
local Commands		= Command:clone()
Commands.keyword	= "commands"

--- Show commands.
function Commands:execute(player, mob)
	local msg = "--- Commands ---"
	local perLine = 5
	for i,v in ipairs(Game.parser:getCommands()) do
		msg = string.format("%s%s%16s", msg, math.mod(i-1, perLine) == 0 and "\n" or "", v.keyword)
	end

	mob:sendMessage(msg, MessageMode.INFO)
end

return Commands
