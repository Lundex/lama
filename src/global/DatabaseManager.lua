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

--- Singleton that provides database management utilities.
-- @author milkmanjack
module("DatabaseManager", package.seeall)

local md5					= require("md5")
local Race					= require("obj.Race")
local Class					= require("obj.Class")

--- Singleton that provides database management utilities.
-- @class table
-- @name DatabaseManager
-- @field charDirectory Where character saves are stored.
-- @field extension File extension for saves.
local DatabaseManager		= {}

-- file information
DatabaseManager.dataDirectory	= "data"
DatabaseManager.charDirectory	= "character"
DatabaseManager.raceDirectory	= "race"
DatabaseManager.classDirectory	= "class"
DatabaseManager.extension		= "lua"

-- ID stuff
DatabaseManager.raceID			= 1
DatabaseManager.classID			= 1
DatabaseManager.characterID		= 1

-- runtime information
DatabaseManager.races			= {}
DatabaseManager.classes			= {}

-- header information
function DatabaseManager.getHeader(type)
	return string.format("--[[\
	[%s] %s file generated for %s (%s).\
]]\
", os.date(), string.upper(type or "save"), Game.getName(), Game.getVersion())
end

--- Get the legalized name form of the given string.
-- @param name Name to be legalized.
-- @return The legalized name, or nil followed by an error message.
function DatabaseManager.legalizeName(name)
	name = string.lower(name) -- lowercase please

	-- names with 1 hyphen are legal
	-- "Billy-Bob", "Al-thud"
	local hFirst, hLast= string.match(name, "([a-z]+)%-([a-z]+)")
	if hFirst and hLast then
		return string.format("%s%s-%s%s",
								string.upper(string.sub(hFirst, 1, 1)),
								string.sub(hFirst, 2),
								string.sub(hLast, 1, 1),
								string.sub(hLast, 2)
							)
	end

	--- names with one apostrophe are legal
	-- "Al'thud", "Tal'ic"
	hFirst, hLast= string.match(name, "([a-z]+)'([a-z]+)")
	if hFirst and hLast then
		return string.format("%s%s'%s%s",
								string.upper(string.sub(hFirst, 1, 1)),
								string.sub(hFirst, 2),
								string.sub(hLast, 1, 1),
								string.sub(hLast, 2)
							)
	end

	-- standard name made of only alphanumeric characters, beginning with a capital letter.
	-- "Garret", "Judas"
	name = string.match(name, "([a-z]+)")
	if name then
		return string.format("%s%s",
								string.upper(string.sub(name, 1, 1)),
								string.sub(name, 2)
							)
	end

	return nil, "invalid name"
end

--- Format a string so it's safe for saving.
-- @param s String to format.
-- @return The formatted string.
function DatabaseManager.safeString(s)
	s = string.gsub(s, "\r", "\\r")
	s = string.gsub(s, "\n", "\\n")
	return s
end


--- Get the character filename for a given name.
-- @param name Name of the character to generate a filename for.
-- @return Properly formatted filename for character based on its name.
function DatabaseManager.getCharacterFileFromName(name)
	name = string.lower(DatabaseManager.legalizeName(name)) -- legalize it.
	name = string.gsub(name, "[^a-zA-Z]", "") -- remove non-alpha characters.
	return string.format("%s/%s/%s.%s", DatabaseManager.dataDirectory, DatabaseManager.charDirectory, name, DatabaseManager.extension)
end

--- Check if a character name is in use.
-- @param name Name to check.
-- @return true if name is taken.<br/>false otherwise.
function DatabaseManager.characterNameTaken(name)
	local filename = DatabaseManager.getCharacterFileFromName(name)
	local file = io.open(filename, "r")
	if not file then
		return false
	end

	file:close()
	return true
end

--- Save a mob as a character.
-- @param mob Mob of the character to save.
function DatabaseManager.saveCharacter(mob)
	local filename = DatabaseManager.getCharacterFileFromName(mob:getName())
	local file = io.open(filename, "w+")
	file:write(DatabaseManager.generateCharacterData(mob))
	file:close()
end

--- Load a character into a mob.
-- @param name Name of the character to be loaded.
-- @param mob The mob for character data to be read into.<br/>if nil, a new mob will be generated and returned.
-- @return The mob that data was read into.
function DatabaseManager.loadCharacter(name, mob)
	local filename = DatabaseManager.getCharacterFileFromName(name)
	return DatabaseManager.readCharacterData(dofile(filename), mob)
end

--- Get the XML format of a character.
-- @param mob Mob of the character to generate data of.
-- @return The XML format of the character.
function DatabaseManager.generateCharacterData(mob)
	local tmpFilename = string.format("%s/character.tmp", DatabaseManager.dataDirectory)
	local templateFile = io.open(tmpFilename, "r")
	local template = templateFile:read("*a")
	return string.format(template,
	DatabaseManager.getHeader("character"),
	mob.characterData.password,
	mob.name,
	DatabaseManager.safeString(mob.description),
	mob.race:getID(),
	mob.class:getID(),
	mob.level,
	mob.experience,
	mob.health,
	mob.mana,
	mob.moves,
	mob:getLoc():getX(),
	mob:getLoc():getY(),
	mob:getLoc():getZ()
	)
end

--- Read XML data into a mob's attributes.<br/>
-- <b>I am not liking the Expat library. I might switch to LuaXML.</b>
-- @param xml The XML to be read.
-- @param mob Optional mob to read data into.<br/>If not specified, will return a new mob created with the XML data.
-- @return The mob that the data was applied to.
function DatabaseManager.readCharacterData(data, mob)
	mob = mob or Mob:new()
	mob:setPassword(data.password)
	mob:setKeywords(name)
	mob:setName(data.name)
	mob:setDescription(data.description)
	mob.race = DatabaseManager.getRaceByID(data.race)
	mob.class = DatabaseManager.getClassByID(data.class)
	mob.level = data.level
	mob.experience = data.experience
	mob.health = data.health
	mob.mana = data.mana
	mob.moves = data.moves
	local location = Game.map:getTile(data.location.x, data.location.y, data.location.z)
	return mob, location
end

-- race stuff
function DatabaseManager.getRaceByName(name)
	for i,race in ipairs(DatabaseManager.races) do
		if string.find(race:getName(), name) == 1 then
			return race
		end
	end
end

function DatabaseManager.getRaceByID(id)
	for i,race in ipairs(DatabaseManager.races) do
		if race:getID() == id then
			return race
		end
	end
end

function DatabaseManager.loadRaces()
	local dir = string.format("%s/%s", DatabaseManager.dataDirectory, DatabaseManager.raceDirectory)
	for i in lfs.dir(dir) do
		if i ~= "." and i ~= ".." then
			local file = string.match(i, "(.+)%.lua")
			if file then -- it's an lua file!
				local data = dofile(dir .. "/" .. file .. ".lua")
				DatabaseManager.loadRace(data)
			end
		end
	end
end

function DatabaseManager.loadRace(data)
	local race						= Race:clone()
	race.id							= data.id
	race.name						= data.name
	race.who						= data.who
	race.baseHealth					= data.baseHealth
	race.healthPerLevel				= data.healthPerLevel
	race.baseMana					= data.baseMana
	race.manaPerLevel				= data.manaPerLevel
	race.baseMoves					= data.baseMoves
	race.movesPerLevel				= data.movesPerLevel
	race.baseStrength				= data.baseStrength
	race.strengthPerLevel			= data.strengthPerLevel
	race.baseAgility				= data.baseAgility
	race.agilityPerLevel			= data.agilityPerLevel
	race.baseDexterity				= data.baseDexterity
	race.dexterityPerLevel			= data.dexterityPerLevel
	race.baseConstitution			= data.baseConstitution
	race.constitutionPerLevel		= data.constitutionPerLevel
	race.baseIntelligence			= data.baseIntelligence
	race.intelligencePerLevel		= data.intelligencePerLevel
	table.insert(DatabaseManager.races, race)
end

function DatabaseManager.generateRaceData(race)
	local tmpFilename = string.format("%s/race.tmp", DatabaseManager.dataDirectory)
	local templateFile = io.open(tmpFilename, "r")
	local template = templateFile:read("*a")
	return string.format(template,
	DatabaseManager.getHeader("race"),
	race:getID(),
	race:getName(),
	race:getWho(),
	race:getBaseHealth(),
	race:getHealthPerLevel(),
	race:getBaseMana(),
	race:getManaPerLevel(),
	race:getBaseMoves(),
	race:getMovesPerLevel(),
	race:getBaseStrength(),
	race:getStrengthPerLevel(),
	race:getBaseDexterity(),
	race:getDexterityPerLevel(),
	race:getBaseAgility(),
	race:getAgilityPerLevel(),
	race:getBaseConstitution(),
	race:getConstitutionPerLevel(),
	race:getBaseIntelligence(),
	race:getIntelligencePerLevel()
	)
end

function DatabaseManager.saveRace(race)
	local filename = string.format("%s/%s/%s.lua", DatabaseManager.dataDirectory, DatabaseManager.raceDirectory)
	local file = io.open(filename, "w+")
	file:write(DatabaseManager.generateRaceData(race))
end

-- class stuff
function DatabaseManager.getClassByName(name)
	for i,class in ipairs(DatabaseManager.classes) do
		if string.find(class:getName(), name) == 1 then
			return class
		end
	end
end

function DatabaseManager.getClassByID(id)
	for i,class in ipairs(DatabaseManager.classes) do
		if class:getID() == id then
			return class
		end
	end
end

function DatabaseManager.loadClasses()
	local dir = string.format("%s/%s", DatabaseManager.dataDirectory, DatabaseManager.classDirectory)
	for i in lfs.dir(dir) do
		if i ~= "." and i ~= ".." then
			local file = string.match(i, "(.+)%.lua")
			if file then -- it's an lua file!
				local data = dofile(dir .. "/" .. file .. ".lua")
				DatabaseManager.loadClass(data)
			end
		end
	end
end

function DatabaseManager.loadClass(data)
	local class						= Class:clone()
	class.id						= data.id
	class.name						= data.name
	class.who						= data.who
	class.baseHealth				= data.baseHealth
	class.healthPerLevel			= data.healthPerLevel
	class.baseMana					= data.baseMana
	class.manaPerLevel				= data.manaPerLevel
	class.baseMoves					= data.baseMoves
	class.movesPerLevel				= data.movesPerLevel
	class.baseStrength				= data.baseStrength
	class.strengthPerLevel			= data.strengthPerLevel
	class.baseAgility				= data.baseAgility
	class.agilityPerLevel			= data.agilityPerLevel
	class.baseDexterity				= data.baseDexterity
	class.dexterityPerLevel			= data.dexterityPerLevel
	class.baseConstitution			= data.baseConstitution
	class.constitutionPerLevel		= data.constitutionPerLevel
	class.baseIntelligence			= data.baseIntelligence
	class.intelligencePerLevel		= data.intelligencePerLevel
	return class
end

function DatabaseManager.generateClassData(class)
	local tmpFilename = string.format("%s/class.tmp", DatabaseManager.dataDirectory)
	local templateFile = io.open(tmpFilename, "r")
	local template = templateFile:read("*a")
	return string.format(template,
	DatabaseManager.getHeader("class"),
	race:getID(),
	race:getName(),
	race:getWho(),
	race:getBaseHealth(),
	race:getHealthPerLevel(),
	race:getBaseMana(),
	race:getManaPerLevel(),
	race:getBaseMoves(),
	race:getMovesPerLevel(),
	race:getBaseStrength(),
	race:getStrengthPerLevel(),
	race:getBaseDexterity(),
	race:getDexterityPerLevel(),
	race:getBaseAgility(),
	race:getAgilityPerLevel(),
	race:getBaseConstitution(),
	race:getConstitutionPerLevel(),
	race:getBaseIntelligence(),
	race:getIntelligencePerLevel()
	)
end

function DatabaseManager.saveClass(class)
	local filename = string.format("%s/%s/%s.lua", DatabaseManager.dataDirectory, DatabaseManager.classDirectory)
	local file = io.open(filename, "w+")
	file:write(DatabaseManager.generateClassData(race))
end

_G.DatabaseManager = DatabaseManager

return DatabaseManager
