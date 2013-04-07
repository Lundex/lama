--[[	Author:	Milkmanjack
		Date:	4/1/13
		Player object holds data relevant to a playable character.
]]

local Cloneable		= require("obj.Cloneable")
local Client		= require("obj.Client")
local Player		= Cloneable.clone()

-- runtime data
Player.id			= -1
Player.state		= PlayerState.NEW
Player.client		= nil -- the client attached to this player
Player.mob			= nil -- the mob attached to this player

function Player:initialize(client)
	self.client	= client
end

function Player:toString()
	return string.format("player#%d{%s}", self.id, self.mob and tostring(self.mob) or tostring(self.client) or "???")
end

function Player:send(data, i, j)
	return self.client:send(data,i,j)
end

function Player:sendString(str)
	return self.client:sendString(str)
end

function Player:sendLine(str)
	return self.client:sendLine(str)
end

function Player:setID(id)
	self.id = id
end

function Player:setState(state)
	self.state = state
end

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

function Player:unsetMob()
	local oldMob = self.mob
	self.mob = nil

	-- make sure it's mutual
	if oldMob:getPlayer() == self then
		oldMob:unsetPlayer()
	end
end

function Player:unsetClient()
	self.client = nil
end

function Player:getID()
	return self.id
end

function Player:getState()
	return self.state
end

function Player:getClient()
	return self.client
end

function Player:getMob()
	return self.mob
end

return Player
