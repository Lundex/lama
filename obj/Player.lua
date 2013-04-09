--- Handles relationships between <i>Client</i>s and <i>Mob</i>s.
-- @author milkmanjack
module("Player", package.seeall)

local Cloneable		= require("obj.Cloneable")
local Client		= require("obj.Client")
local Mob			= require("obj.Mob")

--- The Player table.
-- @class table
-- @name Player
-- @field id Our unique ID.
-- @field state Our state. Always a member of the <i>PlayerState</i> table.
-- @field client The <i>Client</i> we are associated with.
-- @field mob The <i>Mob</i> we are associated with.
-- @field messageMode Our message mode. Always a member of the <i>MessageMode</i> table.
local Player		= Cloneable.clone()

-- runtime data
Player.id			= -1
Player.state		= PlayerState.NEW
Player.client		= nil -- the client attached to this player
Player.mob			= nil -- the mob attached to this player
Player.messageMode	= nil -- the current message mode

--- Initialize the <i>Player</i> and associated it with the given <i>Client</i>.
-- @param client <i>Client</i> to be associated with this <i>Player</i>.
function Player:initialize(client)
	self.client	= client
end

--- Returns the string-value of the <i>Player</i>.
-- @return A string in the format of <tt>"player#&lt;id&gt;{@&lt;client remote address&gt;}"</tt>.
function Player:toString()
	return string.format("player#%d{@%s}", self.id, self.client:getAddress())
end

--- shortcut to <i>client:send(data,i,j)</i>.
function Player:send(data, i, j)
	return self.client:send(data,i,j)
end

--- Reset our messageMode to nil.
function Player:clearMessageMode()
	self.messageMode = nil
end

--- Set our message mode.
-- @param mode The mode to assign. Always a member of the <i>MessageMode</i> table.
function Player:setMessageMode(mode)
	self.messageMode = mode
end

--- Get our message mode.
-- @return Our message mode. Always a member of the <i>MessageMode</i> table.
function Player:getMessageMode()
	return self.messageMode
end

--- Sends a message to the <i>Player</i>.
-- @param msg The message to send.
-- @param mode The mode of the message. Always a member of the <i>MessageMode</i> table.
-- @param autobreak If <i>true</i> (default), the message is followed by a linefeed. Always a member of the <i>MessageMode</i> table.
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

--- shortcut to <i>sendMessage()</i> that provides the <i>MessageMode.QUESTION</i> mode, followed by no linebreak.
function Player:askQuestion(msg)
	self:sendMessage(msg, MessageMode.QUESTION, false)
end

--- shortcut to <i>client:sendMessage(str)</i>.
function Player:sendString(str)
	return self.client:sendString(str)
end

--- shortcut to <i>client:sendLine(str)</i>.
function Player:sendLine(str)
	return self.client:sendLine(str)
end

--- Set our ID.
-- @param id The ID to set.
function Player:setID(id)
	self.id = id
end

--- Set our state.
-- @param state The state to set.
function Player:setState(state)
	self.state = state
end

--- Associate this <i>Player</i> with the given <i>Mob</i>.
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

--- De-associate this <i>Player</i> from our current <i>Mob</i>.
function Player:unsetMob()
	local oldMob = self.mob
	self.mob = nil

	-- make sure it's mutual
	if oldMob:getPlayer() == self then
		oldMob:unsetPlayer()
	end
end

--- De-associate this <i>Player</i> from our current <i>Client</i>.
function Player:unsetClient()
	self.client = nil
end

--- Gets our current ID.
-- @return Our ID.
function Player:getID()
	return self.id
end

--- Gets our current ID.
-- @return Our state. Always a member of the <i>PlayerState</i> table.
function Player:getState()
	return self.state
end

--- Gets our current <i>Client</i>.
-- @return Our <i>Client</i>.
function Player:getClient()
	return self.client
end

--- Gets our current <i>Mob</i>.
-- @return Our <i>Mob</i>.
function Player:getMob()
	return self.mob
end

return Player
