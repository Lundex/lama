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

--- Singleton that contains ANSI color codes.
-- @author milkmanjack
module("Color", package.seeall)

--- Singleton that contains ANSI color codes.
-- @class table
-- @name Color
local Color						= {}
Color.CLEAR						= "[0m"
Color.BLINK						= "[5m"
Color.C_BLACK					= "[0;30m"
Color.C_RED						= "[0;31m"
Color.C_GREEN					= "[0;32m"
Color.C_YELLOW					= "[0;33m"
Color.C_BLUE					= "[0;34m"
Color.C_MAGENTA					= "[0;35m"
Color.C_CYAN					= "[0;36m"
Color.C_WHITE					= "[0;37m"
Color.C_D_GREY					= "[1;30m"
Color.C_B_RED					= "[1;31m"
Color.C_B_GREEN					= "[1;32m"
Color.C_B_YELLOW				= "[1;33m"
Color.C_B_BLUE					= "[1;34m"
Color.C_B_MAGENTA				= "[1;35m"
Color.C_B_CYAN					= "[1;36m"
Color.C_B_WHITE					= "[1;37m"

--- Contains textual representations of colors.
-- @class table
-- @name Color.names
Color.names						= {}
Color.names[Color.CLEAR]		= "CLEAR"
Color.names[Color.BLINK]		= "BLINK"
Color.names[Color.C_BLACK]		= "C_BLACK"
Color.names[Color.C_RED]		= "C_RED"
Color.names[Color.C_GREEN]		= "C_GREEN"
Color.names[Color.C_YELLOW]		= "C_YELLOW"
Color.names[Color.C_BLUE]		= "C_BLUE"
Color.names[Color.C_MAGENTA]	= "C_MAGENTA"
Color.names[Color.C_CYAN]		= "C_CYAN"
Color.names[Color.C_WHITE]		= "C_WHITE"
Color.names[Color.C_D_GREY]		= "C_D_GREY"
Color.names[Color.C_B_RED]		= "C_B_RED"
Color.names[Color.C_B_GREEN]	= "C_B_GREEN"
Color.names[Color.C_B_YELLOW]	= "C_B_YELLOW"
Color.names[Color.C_B_BLUE]		= "C_B_BLUE"
Color.names[Color.C_B_MAGENTA]	= "C_B_MAGENTA"
Color.names[Color.C_B_CYAN]		= "C_B_CYAN"
Color.names[Color.C_B_WHITE]	= "C_B_WHITE"

--- Allows for quick reference to Color.names enums.
-- @param state The state to retrieve the name of.
-- @return Name of the state.
function Color.name(state)
	return Color.names[state]
end

_G.Color = Color

return Color
