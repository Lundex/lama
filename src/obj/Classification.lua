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

--- Cloneable that holds data for classifying mobs.
-- @author milkmanjack
module("obj.Classification", package.seeall)

local Cloneable						= require("obj.Cloneable")

--- Cloneable that holds data for classifying mobs.
-- @class table
-- @name Classification
-- @field id ID of the classification.
-- @field name Name of the classification.
local Classification				= Cloneable.clone()
Classification.id					= 0
Classification.name					= "classification"
Classification.who					= "Classification"

-- resources
Classification.baseHealth			= 0
Classification.healthPerLevel		= 0
Classification.baseMana				= 0
Classification.manaPerLevel			= 0
Classification.baseMoves			= 0
Classification.movesPerLevel		= 0

-- secondary attributes
Classification.baseStrength			= 0
Classification.strengthPerLevel		= 0
Classification.baseAgility			= 0
Classification.agilityPerLevel		= 0
Classification.baseDexterity		= 0
Classification.dexterityPerLevel	= 0
Classification.baseConstitution		= 0
Classification.constitutionPerLevel	= 0
Classification.baseIntelligence		= 0
Classification.intelligencePerLevel	= 0

function Classification:getID()
	return self.ID
end

function Classification:getName()
	return self.name
end

function Classification:getWho()
	return self.who
end

function Classification:getBaseHealth()
	return self.baseHealth
end

function Classification:getHealthPerLevel(level)
	return self.healthPerLevel
end

function Classification:getHealthForLevel(level)
	return self:getBaseHealth() + self:getHealthPerLevel() * (level-1)
end

function Classification:getBaseMana()
	return self.baseMana
end

function Classification:getManaPerLevel(level)
	return self.manaPerLevel
end

function Classification:getManaForLevel(level)
	return self:getBaseMana() + self:getManaPerLevel() * (level-1)
end

function Classification:getBaseMoves()
	return self.baseMoves
end

function Classification:getMovesPerLevel(level)
	return self.movesPerLevel
end

function Classification:getMovesForLevel(level)
	return self:getBaseMoves() + self:getMovesPerLevel() * (level-1)
end

function Classification:getBaseStrength()
	return self.baseStrength
end

function Classification:getStrengthPerLevel(level)
	return self.strengthPerLevel
end

function Classification:getStrengthForLevel(level)
	return self:getBaseStrength() + self:getStrengthPerLevel() * (level-1)
end

function Classification:getBaseAgility()
	return self.baseAgility
end

function Classification:getAgilityPerLevel(level)
	return self.agilityPerLevel
end

function Classification:getAgilityForLevel(level)
	return self:getBaseAgility() + self:getAgilityPerLevel() * (level-1)
end

function Classification:getBaseDexterity()
	return self.baseDexterity
end

function Classification:getDexterityPerLevel(level)
	return self.dexterityPerLevel
end

function Classification:getDexterityForLevel(level)
	return self:getBaseDexterity() + self:getDexterityPerLevel() * (level-1)
end

function Classification:getBaseConstitution()
	return self.baseConstitution
end

function Classification:getConstitutionPerLevel(level)
	return self.constitutionPerLevel
end

function Classification:getConstitutionForLevel(level)
	return self:getBaseConstitution() + self:getConstitutionPerLevel() * (level-1)
end

function Classification:getBaseIntelligence()
	return self.baseIntelligence
end

function Classification:getIntelligencePerLevel(level)
	return self.intelligencePerLevel
end

function Classification:getIntelligenceForLevel(level)
	return self:getBaseIntelligence() + self:getIntelligencePerLevel() * (level-1)
end

return Classification