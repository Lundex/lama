--- Cloneable that holds data for mobile creatures.
-- @author milkmanjack
module("obj.Mob", package.seeall)

local MapObject	= require("obj.MapObject")

--- Cloneable that holds data for mobile creatures.
-- @class table
-- @name Mob
-- @field name Name of the creature.
-- @field description A complete description of the creature.
-- @field level Experience level of the creature.
-- @field experience Experience accumulated this level.
-- @field health Current health.
-- @field mana Current mana.
-- @field moves Current moves.
-- @field player The Player we're associated with.
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

--- Takes a step in the given direction.
-- @param direction Direction to step in.
-- @return true on successful step.<br/>false otherwise.
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

--- Shortcut to player:send(data,i,j)
function Mob:send(data, i, j)
	if self.player then
		return self.player:send(data,i,j)
	end
end

--- Shortcut to player:sendString(str)
function Mob:sendString(str)
	if self.player then
		return self.player:sendString(str)
	end
end

--- Shortcut to player:sendLine(str)
function Mob:sendLine(str)
	if self.player then
		return self.player:sendLine(str)
	end
end

--- Shortcut to player:setMessageMode(mode)
function Mob:setMessageMode(mode)
	if self.player then
		self.player:setMessageMode(mode)
	end
end

--- Shortcut to player:getMessageMode()
function Mob:getMessageMode(mode)
	return self.player and self.player:getMessageMode()
end

--- Shortcut to player:sendMessage(msg, mode, autobreak)
function Mob:sendMessage(msg, mode, autobreak)
	if self.player then
		self.player:sendMessage(msg, mode, autobreak)
	end
end

-- shortcut to player:askQuestion(msg)
function Mob:askQuestion(msg)
	if self.player then
		self.player:askQuestion(msg)
	end
end

--- Shows a description of the room the mob inhabits to the mob.
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

--- Associate this Mob with the given Player. A Mob's Player
-- shares a mututal reference with the Mob, so when the
-- Mob's Player changes, so does the Player's Mob.
-- @param player The player to associate with.
function Mob:setPlayer(player)
	self.player = player

	-- make sure it's mutual
	if player:getMob() ~= self then
		player:setMob(self)
	end
end

--- De-associates this Mob from our current Player.
function Mob:unsetPlayer()
	local oldPlayer = self.player
	self.player = nil

	-- make sure it's mutual
	if oldPlayer:getMob() == self then
		oldPlayer:unsetMob()
	end
end

--- Check if this Mob has a Player controlling it.
-- @return true if this Mob is controlled by a Player.<br/>false otherwise.
function Mob:isPlayerControlled()
	return self.player ~= nil
end

--- Get current Player.
-- @return Current Player, if any.
function Mob:getPlayer()
	return self.player
end

return Mob
