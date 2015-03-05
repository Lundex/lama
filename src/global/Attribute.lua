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

--- Singleton that contains enum-styled values for Player.state.
-- @author milkmanjack

--- Singleton that contains enum-styled values for Player.state.
-- @class table
-- @name PlayerState
-- @field healthPerStrength Health given per point of strength.
Attribute							= {}
Attribute.healthPerConstitution		= 8
Attribute.movesPerConstitution		= 8
Attribute.manaPerIntelligence		= 8

_G.Attribute = Attribute

return Attribute
