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

--- Cloneable:MapObject that holds data for mobile creatures.
-- @author milkmanjack
module("obj.Mob", package.seeall)

local MapObject	= require("obj.MapObject")
local CharacterData = require("obj.CharacterData")

--- Cloneable:MapObject that holds data for mobile creatures.
-- @class table
-- @name Mob
-- @field keywords Keywords for the creature.
-- @field name Name of the creature.
-- @field description A complete description of the creature.
-- @field level Experience level of the creature.
-- @field experience Experience accumulated this level.
-- @field race Mob's race.
-- @field class Mob's class.
-- @field health Current health.
-- @field mana Current mana.
-- @field moves Current moves.
-- @field player The Player we're associated with.
-- @field characterData Character data for this mob.
-- @field victim The Mob we're fighting.
-- @field combatEvent The event managing our combat rounds.
local Mob			= MapObject:clone()

-- mob data, bro.
Mob.keywords		= "mob"
Mob.name			= "mob"
Mob.description		= "It's a mob."

Mob.level			= 1
Mob.experience		= 0

Mob.race			= require("obj.race.Human")
Mob.class			= require("obj.class.Warrior")

Mob.health			= 100
Mob.mana			= 100
Mob.moves			= 100

Mob.player			= nil -- this is a cross-reference to a player that is controlling us.

-- combat stuff
Mob.victim			= nil -- a mob we're fighting
Mob.combatEvent		= nil -- current event for combat processing

--- Assigns a character data table.
function Mob:initialize()
	self.characterData = CharacterData:new()
end

--- Takes a step in the given direction.
-- @param direction Direction to step in.
-- @return true on successful step.<br/>false otherwise.
function Mob:step(direction)
	local oldLoc, newLoc = self:getLoc(), self.map:getStep(self, direction)
	if newLoc and newLoc:permitEntrance(self) then
		self:sendMessage(string.format("You take a step to the %s.", Direction.name(direction)), MessageMode.MOVEMENT)

		-- alert room to our entrance
		for i,v in ipairs(newLoc:getContents()) do
			v:sendMessage(string.format("%s has entered from the %s.", self:getName(), Direction.name(Direction.reverse(direction))), MessageMode.MOVEMENT)
		end

		self:move(newLoc)

		-- alert previous room to our exit
		for i,v in ipairs(oldLoc:getContents()) do
			v:sendMessage(string.format("%s has left to the %s.", self:getName(), Direction.name(direction)), MessageMode.MOVEMENT)
		end

		return true
	end

	return false
end

--- Shows a description of the room the mob inhabits to the mob.
function Mob:showRoom()
	local location = self:getLoc()
	local msg = string.format("%s (%d,%d,%d)\n %s", location:getName(), location:getX(), location:getY(), location:getZ(), location:getDescription())

	for i,v in ipairs(location:getContents()) do
		if v:isCloneOf(Mob) and v ~= self then
			msg = string.format("%s%s  %s is here", msg, "\n", v:getName())
		end
	end

	-- non-mobs. later this'll be Items
	for i,v in ipairs(location:getContents()) do
		if not v:isCloneOf(Mob) then
			msg = string.format("%s%sA %s is here.", msg, "\n", v:getName())
		end
	end

	self:sendMessage(msg, MessageMode.INFO)
end

-- resource
function Mob:getHealth()
	return self.health
end

function Mob:getBaseHealth()
	return self.race:getHealthForLevel(self.level) + self.class:getHealthForLevel(self.level) + (self:getConstitution() * Attribute.healthPerConstitution)
end

function Mob:getMaxHealth()
	return self:getBaseHealth()
end

function Mob:restoreHealth()
	self.health = self:getMaxHealth()
end

function Mob:modifyHealth(amount)
	self.health = math.min(math.max(0, self.health + amount), self:getMaxHealth())
end

function Mob:getMana()
	return self.mana
end

function Mob:getBaseMana()
	return self.race:getManaForLevel(self.level) + self.class:getManaForLevel(self.level) + (self:getIntelligence() * Attribute.manaPerIntelligence)
end

function Mob:getMaxMana()
	return self:getBaseMana()
end

function Mob:restoreMana()
	self.mana = self:getMaxMana()
end

function Mob:modifyMana(amount)
	self.mana = math.min(math.max(0, self.mana + amount), self:getMaxMana())
end

function Mob:getMoves()
	return self.moves
end

function Mob:getBaseMoves()
	return self.race:getMovesForLevel(self.level) + self.class:getMovesForLevel(self.level) + (self:getConstitution() * Attribute.movesPerConstitution)
end

function Mob:getMaxMoves()
	return self:getBaseMoves()
end

function Mob:restoreMoves()
	self.moves = self:getMaxMoves()
end

function Mob:modifyMoves(amount)
	self.moves = math.min(math.max(0, self.moves + amount), self:getMaxMoves())
end

-- secondary attributes
function Mob:getBaseStrength()
	return self.race:getStrengthForLevel(self.level)
end

function Mob:getStrength()
	return self:getBaseStrength()
end

function Mob:getBaseAgility()
	return self.race:getAgilityForLevel(self.level)
end

function Mob:getAgility()
	return self:getBaseAgility()
end

function Mob:getBaseDexterity()
	return self.race:getDexterityForLevel(self.level)
end

function Mob:getDexterity()
	return self:getBaseDexterity()
end

function Mob:getBaseConstitution()
	return self.race:getConstitutionForLevel(self.level)
end

function Mob:getConstitution()
	return self:getBaseConstitution()
end

function Mob:getBaseIntelligence()
	return self.race:getIntelligenceForLevel(self.level)
end

function Mob:getIntelligence()
	return self:getBaseIntelligence()
end

--- Engage another mob in combat.
-- @param target The mob to begin fighting.
function Mob:engage(target)
	self.victim				= target

	if not self.combatEvent then
		self.combatEvent	= Game.CombatPulseEvent:new(self, Game.time()+4)
		Game.queue(self.combatEvent)
	end
end

--- Disengage the current target.
function Mob:disengage()
	self.victim = nil
	Game.deque(self.combatEvent)
end

--- One hit.
function Mob:oneHit(victim)
	if not self.victim then
		self:engage(victim)
	end

	if victim:getVictim() == nil then
		victim:engage(self)
	end

	self:sendMessage(string.format("You hit %s!", victim:getName()), MessageMode.COMBAT)
	victim:sendMessage(string.format("%s hits you!", self:getName()), MessageMode.COMBAT)
end

--- Mob combat round.
function Mob:combatRound()
	if not self.victim or self.victim:getLoc() ~= self:getLoc() then
		self:disengage()
		return
	end

	self:oneHit(self.victim)
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

--- Assign the mob's password.
-- @param password New password.
function Mob:setPassword(password)
	self.characterData.password = password
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

--- Get the Mob's name.
-- @return Mob's name.
function Mob:getName()
	return self.name
end

--- Get the Mob's description.
-- @return Mob's description.
function Mob:getDescription()
	return self.description
end

--- Get the Mob's password.
-- @return The password.
function Mob:getPassword()
	return self.characterData.password
end

--- Shortcut to player:getMessageMode()
function Mob:getMessageMode(mode)
	return self.player and self.player:getMessageMode()
end

--- Get current Player.
-- @return Current Player, if any.
function Mob:getPlayer()
	return self.player
end

--- Check if this Mob has a Player controlling it.
-- @return true if this Mob is controlled by a Player.<br/>false otherwise.
function Mob:isPlayerControlled()
	return self.player ~= nil
end

--- Get the Mob's current victim.
-- @return Mob's victim.
function Mob:getVictim()
	return self.victim
end

return Mob
