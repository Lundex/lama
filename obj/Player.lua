--[[	Author:	Milkmanjack
		Date:	4/1/13
		Player object holds data relevant to a playable character.
]]

local Cloneable		= require("obj.Cloneable")
local Client		= require("obj.Client")
local Player		= Cloneable.clone()

-- runtime data
Player.id			= 0
Player.state		= PlayerState.NEW
Player.client		= nil -- the client attached to this player
Player.mob			= nil -- the mob attached to this player

function Player:initialize(client, id)
	self.client	= client
	self.id		= id
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

function Player:setState(state)
	self.state = state
end

function Player:setMob(mob)
	if self.mob then
		self.mob:unsetPlayer(self)
	end

	self.mob = mob
	mob:setPlayer(self)
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
