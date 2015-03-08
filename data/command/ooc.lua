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

require("ext.string")
local Command	= require("obj.Command")

--- Command for sending Out of Character chat.
-- @class table
-- @name OOC
local OOC		= Command:clone()
OOC.keyword		= "ooc"

--- Passes everything after the keyword to the command execution.
function OOC:parse(player, mob, input)
	local cmd, msg = string.getWord(input)
	self:execute(player, mob, msg)
end

--- Sends a message on the OOC channel.
-- @param player Player chatting
-- @param mob Mob chatting.
-- @param msg Message to be sent.
function OOC:execute(player, mob, msg)
	local formatted = string.format("{Y%s OOC: '{W%s{Y'{x", mob:getName(), msg)
	for i,p in ipairs(Game.players) do
		if p == player then
			p:sendMessage(string.format("{YYou OOC: '{W%s{Y'{x", msg), MessageMode.COMMAND)
		elseif p:getState() == PlayerState.PLAYING then
			p:sendMessage(formatted, MessageMode.CHAT)
		end
	end
end

return OOC
