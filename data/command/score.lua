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

local Command	= require("obj.Command")

--- Command getting our scoreboard.
-- @class table
-- @name Score
local Score		= Command:clone()
Score.keyword	= "score"

--- Show our scoreboard.
-- @param player Player to show.
-- @param mob Mob to show.
function Score:execute(player, mob)
	mob:sendMessage(string.format("%s, the %s %s.\
    '%s'\
You are currently level %d, with %d experience collected in total.\
Str: %d (%d)  Agi: %d (%d)  Dex: %d (%d)  Con: %d (%d)  Int: %d (%d)\
You have %d/%d health, %d/%d mana, and %d/%d moves.",
					mob.name, mob.race:getName(), mob.class:getName(),
					mob.description or "Nothing worth mentioning.",
					mob.level, mob.experience,
					mob:getStrength(), mob:getBaseStrength(),
					mob:getAgility(), mob:getBaseAgility(),
					mob:getDexterity(), mob:getBaseDexterity(),
					mob:getConstitution(), mob:getBaseConstitution(),
					mob:getIntelligence(), mob:getBaseIntelligence(),
					mob:getHealth(), mob:getMaxHealth(),
					mob:getMana(), mob:getMaxMana(),
					mob:getMoves(), mob:getMaxMoves()
					)
	, MessageMode.COMMAND)
end

return Score
