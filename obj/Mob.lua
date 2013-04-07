--[[	Author:	Milkmanjack
		Date:	4/2/13
		Holds data for mobile creatures.
]]

local MapObject	= require("obj.MapObject")
local Mob		= MapObject:clone()

-- creature data
Mob.name			= "creature"
Mob.description		= "It's a creature."

Mob.level			= 1
Mob.experience		= 0

Mob.health			= 100
Mob.mana			= 100
Mob.moves			= 100

Mob.player			= nil -- this is a cross-reference to a player that is controlling us.

function Mob:send(data, i, j)
	if self.player then
		return self.player:send(data,i,j)
	end
end

function Mob:sendString(str)
	if self.player then
		return self.player:sendString(str)
	end
end

function Mob:sendLine(str)
	if self.player then
		return self.player:sendLine(str)
	end
end

function Mob:setPlayer(player)
	self.player = player

	-- make sure it's mutual
	if player:getMob() ~= self then
		player:setMob(self)
	end
end

function Mob:unsetPlayer()
	local oldPlayer = self.player
	self.player = nil

	-- make sure it's mutual
	if oldPlayer:getMob() == self then
		oldPlayer:unsetMob()
	end
end

function Mob:isPlayerControlled()
	return self.player ~= nil
end

function Mob:getPlayer()
	return self.player
end

return Mob
