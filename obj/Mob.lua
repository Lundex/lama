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

function Mob:step(direction)
	local oldLoc, newLoc = self:getLoc(), self.map:getStep(self, direction)
	if newLoc and newLoc:permitEntrance(self) then
		self:sendMessage(string.format("You take a step to the %s.", Direction.name(direction)), MessageMode.MOVEMENT)

		-- alert room to our entrance
		for i,v in ipairs(newLoc:getContents()) do
			v:sendMessage(string.format("%s has entered from the %s."), self:getName(), Direction.name(Direction.reverse(direction)), MessageMode.MOVEMENT)
		end

		self:move(newLoc)

		-- alert previous room to our exit
		for i,v in ipairs(oldLoc:getContents()) do
			v:sendMessage(string.format("%s has left to the %s."), self:getName(), Direction.name(direction), MessageMode.MOVEMENT)
		end

		return true
	end

	return false
end

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

function Mob:setMessageMode(mode)
	if self.player then
		self.player:setMessageMode(mode)
	end
end

function Mob:getMessageMode(mode)
	return self.player and self.player:getMessageMode()
end

function Mob:sendMessage(msg, mode, autobreak)
	if self.player then
		self.player:sendMessage(msg, mode, autobreak)
	end
end

-- shortcut to sendMessage() that provides the question message mode, and no linebreak that follows
function Mob:askQuestion(msg)
	if self.player then
		self.player:askQuestion(msg)
	end
end

function Mob:showRoom()
	local location = self:getLoc()
	local msg = string.format("%s\n %s (%d,%d,%d)", location:getName(), location:getDescription(), location:getX(), location:getY(), location:getZ())

	for i,v in ipairs(location:getContents()) do
		if v:isCloneOf(Mob) then
			msg = string.format("%s%s%s is here", msg, "\n", v:getName())
		end
	end

	-- non-mobs. later this'll be Items
	for i,v in ipairs(location:getContents()) do
		if not v:isCloneOf(Mob) then
			msg = string.format("%s%sa %s is here.", msg, "\n", v:getName())
		end
	end

	self:sendMessage(msg, MessageMode.INFO)
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
