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

--- Singleton that provides character management utilities.
-- @author milkmanjack
module("CharacterManager", package.seeall)

--- Singleton that provides character management utilities.
-- @class table
-- @name CharacterManager
-- @field directory Where saves are stored.
-- @field extension File extension for saves.
local CharacterManager		= {}

-- file information
CharacterManager.directory	= "character"
CharacterManager.extension	= "xml"

--- Get the legalized name form of the given string.
-- @param name Name to be legalized.
-- @return The legalized name, or nil followed by an error message.
function CharacterManager.legalizeName(name)
	name = string.lower(name) -- lowercase please

	-- names with 1 hyphen are legal
	-- "Billy-Bob", "Al-thud"
	local hFirst, hLast= string.match(name, "([a-z]+)%-([a-z]+)")
	if hFirst and hLast then
		return string.format("%s%s-%s%s",
								string.upper(string.sub(hFirst, 1, 1)),
								string.sub(hFirst, 2),
								string.upper(string.sub(hLast, 1, 1)),
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
								string.upper(string.sub(hLast, 1, 1)),
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
function CharacterManager.getCharacterFileFromName(name)
	name = string.lower(CharacterManager.legalizeName(name)) -- legalize it.
	name = string.gsub(name, "[^a-zA-Z]", "") -- remove non-alpha characters.
	return string.format("%s/%s.%s", CharacterManager.directory, name, CharacterManager.extension)
end

--- Check if a character name is in use.
-- @param name Name to check.
-- @return true if name is taken.<br/>false otherwise.
function CharacterManager.characterNameTaken(name)
	local filename = CharacterManager.getCharacterFileFromName(name)
	local file = io.open(filename, "r")
	if not file then
		return false
	end

	file:close()
	return true
end

--- Save a mob as a character.
-- @param mob Mob of the character to save.
function CharacterManager.saveCharacter(mob)
	lfs.mkdir(CharacterManager.directory)
	local filename = CharacterManager.getCharacterFileFromName(mob:getName())
	os.remove(filename) -- just in case
	local file = io.open(filename, "w")
	file:write(CharacterManager.generateCharacterData(mob))
	file:close()
end

--- Load a character into a mob.
-- @param name Name of the character to be loaded.
-- @param mob The mob for character data to be read into.<br/>if nil, a new mob will be generated and returned.
-- @return The mob that data was read into.
function CharacterManager.loadCharacter(name, mob)
	local filename = CharacterManager.getCharacterFileFromName(name)
	return CharacterManager.readCharacterData(xml.load(filename), mob)
end

--- Get the XML format of a character.
-- @param mob Mob of the character to generate data of.
-- @return The XML format of the character.
function CharacterManager.generateCharacterData(mob)
	return string.format("<character password='%s'>\
	<name>%s</name>\
	<description>%s</description>\
	<level>%d</level>\
	<experience>%d</experience>\
	<health>%d</health>\
	<mana>%d</mana>\
	<moves>%d</moves>\
</character>",
	md5.sumhexa(mob.characterData.password),
	mob.name,
	mob.description,
	mob.level,
	mob.experience,
	mob.health,
	mob.mana,
	mob.moves
	)
end

--- Read XML data into a mob's attributes.<br/>
-- <b>I am not liking the Expat library. I might switch to LuaXML.</b>
-- @param xml The XML to be read.
-- @param mob Optional mob to read data into.<br/>If not specified, will return a new mob created with the XML data.
-- @return The mob that the data was applied to.
function CharacterManager.readCharacterData(data, mob)
	mob = mob or Mob:new()
	mob:setPassword(data.password)
	for i,v in ipairs(data) do
		if v[0] == "name" then
			mob.name = v[1]
		elseif v[0] == "description" then
			mob.description = v[1]
		elseif v[0] == "level" then
			mob.level = tonumber(v[1])
		elseif v[0] == "experience" then
			mob.experience = tonumber(v[1])
		elseif v[0] == "health" then
			mob.health = tonumber(v[1])
		elseif v[0] == "mana" then
			mob.mana = tonumber(v[1])
		elseif v[0] == "moves" then
			mob.moves = tonumber(v[1])
		end
	end

	return mob
end

_G.CharacterManager = CharacterManager

return CharacterManager
