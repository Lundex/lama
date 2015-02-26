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

--- Cloneable that holds data about a Mob's race.
-- @author milkmanjack
module("obj.Race", package.seeall)

local Classification			= require("obj.Classification")
local Race						= Classification:clone()

Race.baseHealth					= 100
Race.baseMana					= 100
Race.baseMoves					= 100

Race.baseStrength				= 25
Race.baseAgility				= 25
Race.baseDexterity				= 25
Race.baseConstitution			= 25
Race.baseIntelligence			= 25

return Race