
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
Color.ESCAPE					= "{"

--- Contains textual representations of colors.
-- @class table
-- @name Color.names
Color.names						= {}
Color.names[Color.CLEAR]		= "clear"
Color.names[Color.BLINK]		= "blink"
Color.names[Color.C_BLACK]		= "black"
Color.names[Color.C_RED]		= "light red"
Color.names[Color.C_GREEN]		= "light green"
Color.names[Color.C_YELLOW]		= "light yellow"
Color.names[Color.C_BLUE]		= "light blue"
Color.names[Color.C_MAGENTA]	= "light magenta"
Color.names[Color.C_CYAN]		= "light cyan"
Color.names[Color.C_WHITE]		= "light white"
Color.names[Color.C_D_GREY]		= "grey"
Color.names[Color.C_B_RED]		= "dark red"
Color.names[Color.C_B_GREEN]	= "dark green"
Color.names[Color.C_B_YELLOW]	= "dark yellow"
Color.names[Color.C_B_BLUE]		= "dark blue"
Color.names[Color.C_B_MAGENTA]	= "dark magenta"
Color.names[Color.C_B_CYAN]		= "dark cyan"
Color.names[Color.C_B_WHITE]	= "dark white"

--- Allows for quick reference to Color.names enums.
-- @param color The color to retrieve the name of.
-- @return Name of the color.
function Color.name(color)
	return Color.names[color]
end

--- Contains letters for color escapes.
-- @class table
-- @name Color.letters
Color.letters					= {}
Color.letters["x"]				= Color.CLEAR
Color.letters["X"]				= Color.CLEAR
Color.letters["!"]				= Color.BLINK
Color.letters["["]				= Color.C_BLACK
Color.letters["r"]				= Color.C_RED
Color.letters["g"]				= Color.C_GREEN
Color.letters["y"]				= Color.C_YELLOW
Color.letters["b"]				= Color.C_BLUE
Color.letters["m"]				= Color.C_MAGENTA
Color.letters["c"]				= Color.C_CYAN
Color.letters["w"]				= Color.C_WHITE
Color.letters["D"]				= Color.C_D_GREY
Color.letters["R"]				= Color.C_B_RED
Color.letters["G"]				= Color.C_B_GREEN
Color.letters["Y"]				= Color.C_B_YELLOW
Color.letters["B"]				= Color.C_B_BLUE
Color.letters["M"]				= Color.C_B_MAGENTA
Color.letters["C"]				= Color.C_B_CYAN
Color.letters["W"]				= Color.C_B_WHITE

--- Allows for quick reference to Color.letters enums.
-- @param letter The letter to retrieve the color for.
-- @return Color for letter.
function Color.letter(letter)
	return Color.letters[letter]
end

--- Colorize a string.
function Color.colorize(s, strip)
	s = s .. "{x"
	local length = string.len(s)
	local swap = function(letter)
		if strip or not letter then
			return ""
		end

		if letter == Color.ESCAPE then
			return Color.ESCAPE
		end

		return Color.letter(letter) or ""
	end

	return string.gsub(s, Color.ESCAPE.."(.?)", swap)
end

--- Length of string ignoring colors.
function Color.safelen(s, strip)
	s = s .. "{x"
	local length = string.len(s)
	for letter in string.gmatch(s, Color.ESCAPE.."(.?)") do
		if letter == Color.ESCAPE then
			length = length - 1
		else
			length = length - 2
		end
	end

	return length
end

_G.Color = Color

return Color
