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

--- Command for checking who is online.
-- @author milkmanjack
module("obj.Command.Who", package.seeall)

require("ext.string")
local Command	= require("obj.Command")

--- Command for checking who is online.
-- @class table
-- @name Who
local Who		= Command:clone()
Who.keyword		= "who"

--- Send a list of players to the player.
function Who:execute(player, mob)
	local msg = "\[ Connected Players ]"
	for i,v in ipairs(Game.getPlayers()) do
		local client = v:getClient()
		local mob = v:getMob()
		local TerminalType = client:getTerminalType()
		local MCCPStatus = client:getDo(Telnet.commands.MCCP2) and "enabled" or "disabled"
		msg = string.format("%s\n-> %s (terminal: %s) (MCCP %s)", msg, tostring(v), TerminalType, MCCPStatus)
	end

	player:sendMessage(msg)
end

return Who
