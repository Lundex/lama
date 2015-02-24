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

--- Generic functionality for main.lua.
-- @author milkmanjack

--- Runs a require call in protected mode.
-- @param package Package to require.
-- @return The package value (package.loaded[package]) on success.<br/>nil followed by an error stack otherwise.
function prequire(package)
	-- pcall returns true or false, followed by the return value of the function it calls, or an error stack, respectively.
	local result, eop = pcall(function() return require(package) end)
	if not result then
		return nil, eop -- return nil followed by an error.
	end

	return eop -- return the package value
end

--- Matches a string of keywords to another string of keywords
function matchKeywords(needle, haystack)
	local _haystack = {}
	for i in string.gmatch(haystack, "([a-zA-Z0-9|'|-]+)") do
		table.insert(_haystack, i)
	end

	for i in string.gmatch(needle, "([a-zA-Z0-9|'|-]+)") do
		local found = false
		for _i, v in ipairs(_haystack) do
			if string.find(v, i) == 1 then
				found = true
			end
		end

		-- every keyword must be found, or it's not a match
		if not found then
			return nil
		end
	end

	return haystack
end
