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

--- Cloneable that handles relationships between Clients and Mobs.
-- @author milkmanjack
module("obj.Player", package.seeall)

local Cloneable		= require("obj.Cloneable")

--- Cloneable that handles relationships between Clients and Mobs.
-- @class table
-- @name Player
-- @field id Our unique ID.
-- @field state Current state. Always a member of the PlayerState table.
-- @field client The Client we are associated with.
-- @field mob The Mob we are associated with.
-- @field messageMode Our message mode. Always a member of the MessageMode table.
local Player		= Cloneable.clone()

-- runtime data
Player.id			= -1
Player.state		= PlayerState.NEW
Player.client		= nil -- the client attached to this player
Player.mob			= nil -- the mob attached to this player
Player.messageMode	= nil -- the current message mode

--- Initialize the Player and associated it with the given Client.
-- @param client Client to be associated with this Player.
function Player:initialize(client)
	self:setClient(client)
end

--- Returns the string-value of the Player.
-- @return A string in the format of <tt>"player#&lt;id&gt;{@&lt;client remote address&gt;}"</tt>.
function Player:toString()
	return string.format("{P#%d}%s@%s", self.id, self.mob and self.mob:getName() or "no mob", self.client:getAddress())
end

--- shortcut to client:send(data,i,j).
function Player:send(data, i, j)
	return self.client:send(data,i,j)
end

--- Reset messageMode to nil.
function Player:clearMessageMode()
	self.messageMode = nil
end

--- Set message mode.
-- @param mode The mode to assign. Always a member of the MessageMode table.
function Player:setMessageMode(mode)
	self.messageMode = mode
end

--- Get message mode.
-- @return Current message mode. Always a member of the MessageMode table.
function Player:getMessageMode()
	return self.messageMode
end

--- Sends a message to the Player.
-- @param msg The message to send.
-- @param mode The mode of the message. Always a member of the MessageMode table.
-- @param autobreak If true (default), the message is followed by a linefeed. Always a member of the MessageMode table.
function Player:sendMessage(msg, mode, autobreak)
	if mode == nil then
		mode = MessageMode.GENERAL
	end

	if autobreak == nil then
		autobreak = true
	end

	local oldMode = self:getMessageMode()
	if oldMode ~= mode then
		self:setMessageMode(mode)

		-- separate the next message from the previous
		-- but only if the previous mode was not nil
		if oldMode ~= nil then
			self:sendLine()
		end
	end

	-- if autobreak is true, append a linebreak to the message. (default)
	if autobreak == true then
		self:sendLine(msg)

	-- otherwise, just send it as a string with no linebreak
	else
		self:sendString(msg)
	end
end

--- shortcut to sendMessage() that provides the MessageMode.QUESTION mode, followed by no linebreak.
function Player:askQuestion(msg)
	self:sendMessage(msg, MessageMode.QUESTION, false)
end

--- shortcut to client:sendMessage(str).
function Player:sendString(str)
	return self.client:sendString(str)
end

--- shortcut to client:sendLine(str).
function Player:sendLine(str)
	return self.client:sendLine(str)
end

--- Set ID.
-- @param id The ID to set.
function Player:setID(id)
	self.id = id
end

--- Set state.
-- @param state The state to set.
function Player:setState(state)
	self.state = state
end

--- Associate this Player with the given Mob. A Player's Mob
-- shares a mututal reference with the Player, so when the
-- Player's Mob changes, so does the Mob's Player.
-- @param mob The mob to assign.
function Player:setMob(mob)
	if self.mob then
		self.mob:unsetPlayer(self)
	end

	self.mob = mob

	-- make sure it's mutual
	if mob:getPlayer() ~= self then
		mob:setPlayer(self)
	end
end

--- De-associate this Player from current Mob.
function Player:unsetMob()
	local oldMob = self.mob
	self.mob = nil

	-- make sure it's mutual
	if oldMob:getPlayer() == self then
		oldMob:unsetPlayer()
	end
end

--- Associate this Player with the given Client.
-- @param client Client to be associated.
function Player:setClient(client)
	self.client = client
end

--- De-associate this Player from current Client.
function Player:unsetClient()
	self.client = nil
end

--- Gets current ID.
-- @return Current ID.
function Player:getID()
	return self.id
end

--- Gets current state.
-- @return Current state. Always a member of the PlayerState table.
function Player:getState()
	return self.state
end

--- Gets current Client.
-- @return Current Client.
function Player:getClient()
	return self.client
end

--- Gets current Mob.
-- @return Current Mob, if any.
function Player:getMob()
	return self.mob
end

return Player
