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

local md5			= require("md5")

--- Singleton that provides database management utilities.
-- @class table
-- @name DatabaseManager
-- @field charDirectory Where character saves are stored.
-- @field extension File extension for saves.
local DatabaseManager		= {}

-- file information
DatabaseManager.charDirectory	= "character"
DatabaseManager.extension		= "slua"

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

--- Get the character filename for a given name.
-- @param name Name of the character to generate a filename for.
-- @return Properly formatted filename for character based on its name.
function DatabaseManager.getCharacterFileFromName(name)
	name = string.lower(DatabaseManager.legalizeName(name)) -- legalize it.
	name = string.gsub(name, "[^a-zA-Z]", "") -- remove non-alpha characters.
	return string.format("%s/%s.%s", DatabaseManager.charDirectory, name, DatabaseManager.extension)
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
	return string.format("--[[\
	Character data generated in lama.\
]]\
local character = {}\
character.password		= \"%s\"\
character.name			= \"%s\"\
character.description	= \"%s\"\
character.level			= %d\
character.experience	= %d\
character.health		= %d\
character.mana			= %d\
character.moves			= %d\
character.location		= {x=%d,y=%d,z=%d}\
\
return character",
	mob.characterData.password,
	mob.name,
	DatabaseManager.safeString(mob.description),
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
	mob.level = data.level
	mob.experience = data.experience
	mob.health = data.health
	mob.mana = data.mana
	mob.moves = data.moves
	local location = Game.map:getTile(data.location.x, data.location.y, data.location.z)
	return mob, location
end

--- Format a string so it's safe for saving.
-- @param s String to format.
-- @return The formatted string.
function DatabaseManager.safeString(s)
	s = string.gsub(s, "\r", "\\r")
	s = string.gsub(s, "\n", "\\n")
	return s
end

_G.DatabaseManager = DatabaseManager

return DatabaseManager
