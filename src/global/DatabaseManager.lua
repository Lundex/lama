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

local md5					= require("md5")
local Mob					= require("obj.Mob")

--- Singleton that provides database management utilities.
-- @class table
-- @name DatabaseManager
-- @field charDirectory Where character saves are stored.
-- @field extension File extension for saves.
DatabaseManager				= {}

-- templates for savefiles
DatabaseManager.charTemplate= [[%s
local character			= {}
character.password		= "%s"
character.name			= "%s"
character.description	= "%s"
character.race			= "%s"
character.class			= "%s"
character.level			= %d
character.experience	= %d
character.health		= %d
character.mana			= %d
character.moves			= %d
character.location		= {x=%d,y=%d,z=%d}

return character
]]

-- file information
DatabaseManager.dataDirectory	= "data"
DatabaseManager.raceDirectory	= "race"
DatabaseManager.classDirectory	= "class"
DatabaseManager.charDirectory	= "character"
DatabaseManager.cmdDirectory	= "command"
DatabaseManager.extension		= "lua"

-- runtime data
DatabaseManager.commands		= {}
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

--- Get the XML format of a character.
-- @param mob Mob of the character to generate data of.
-- @return The XML format of the character.
function DatabaseManager.generateCharacterData(mob)
	local template = DatabaseManager.charTemplate
	return string.format(template,
	DatabaseManager.getHeader("character"),
	mob.characterData.password,
	mob.name,
	DatabaseManager.safeString(mob.description),
	mob.race:getName(),
	mob.class:getName(),
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
function DatabaseManager.loadCharacter(name)
	local filename = DatabaseManager.getCharacterFileFromName(name)
	local data = dofile(filename)
	local location = Game.map:getTile(data.location.x, data.location.y, data.location.z)
	local mob = Mob:new()
	mob:setPassword(data.password)
	mob:setKeywords(name)
	mob:setName(data.name)
	mob:setDescription(data.description)
	mob.race = DatabaseManager.getRaceByName(data.race)
	mob.class = DatabaseManager.getClassByName(data.class)
	mob.level = data.level
	mob.experience = data.experience
	mob.health = data.health
	mob.mana = data.mana
	mob.moves = data.moves
	return mob, location
end

function DatabaseManager.getRaceByName(name)
	for i,race in ipairs(DatabaseManager.races) do
		if string.find(race:getName(), name) == 1 then
			return race
		end
	end
end

--- Load races.
function DatabaseManager.loadRaces()
	local directory = string.format("%s/%s", DatabaseManager.dataDirectory, DatabaseManager.raceDirectory)
	for i in lfs.dir(directory) do
		if i ~= "." and i ~= ".." then
			if string.match(i, ".+%.lua") then -- it's an lua file!
				local race = dofile(directory .. "/" .. i)
				Game.info("Loading race '" .. race:getName() .. "'")
				table.insert(DatabaseManager.races, race)
			end
		end
	end
end

function DatabaseManager.getClassByName(name)
	for i,class in ipairs(DatabaseManager.classes) do
		if string.find(class:getName(), name) == 1 then
			return class
		end
	end
end

--- Load classes.
function DatabaseManager.loadClasses()
	local directory = string.format("%s/%s", DatabaseManager.dataDirectory, DatabaseManager.classDirectory)
	for i in lfs.dir(directory) do
		if i ~= "." and i ~= ".." then
			if string.match(i, ".+%.lua") then -- it's an lua file!
				local class = dofile(directory .. "/" .. i)
				Game.info("Loading class '" .. class:getName() .. "'")
				table.insert(DatabaseManager.classes, class)
			end
		end
	end
end

--- Load commands.
function DatabaseManager.loadCommands()
	local directory = string.format("%s/%s", DatabaseManager.dataDirectory, DatabaseManager.cmdDirectory)
	for i in lfs.dir(directory) do
		if i ~= "." and i ~= ".." and i ~= "Movement.lua" then
			if string.match(i, ".+%.lua") then -- it's an lua file!
				local command = dofile(directory .. "/" .. i)
				Game.info("Loading command '" .. command:getKeyword() .. "'")
				table.insert(DatabaseManager.commands, command)
			end
		end
	end
end

_G.DatabaseManager = DatabaseManager

return DatabaseManager
