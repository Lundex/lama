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

--- Extension of the string library.
-- @author milkmanjack
module("ext.string", package.seeall)

--- Gets the next word in the given string.<br/>
-- A word is defined as the first series of unbroken alphanumeric characters.
-- Special delimiters can be defined for the word. For example, if the next
-- word starts with a single or double quote (', "), it will end with a
-- single or double quote, respectively. If neither are found after the
-- first, then it will merely return everything.<br/>
-- Also returns the remainder of the given string, if anything remains.
-- The remainder of the string has its whitespace truncated via
-- string.truncate().
-- @param s String to get the next word from.
-- @return The word.
-- @return The remainder of the string, or nil.
function string.getWord(s)
	if not s then return nil, nil end

	local length = string.len(s)

	-- handles empty strings
	if length < 1 then
		return nil, nil
	end

	-- handles 1 character long strings
	if length == 1 then
		return s, nil
	end

	local _start, _end = 1, nil
	local first = string.sub(s, 1, 1)
	-- quotation mark delimiters
	if first == "'" or first == "\"" then
		_start = 2
		_end = string.find(s, first, _start)

	-- space delimiter
	else
		_end = string.find(s, " ", _start)
	end

	-- grab the observed word
	local word = string.sub(s, _start, (_end and _end-1) or nil)

	-- skip whitespace after the word
	if _end and _end < length then
		_end = _end+1
	end

	return word, (_end and _end < length and string.truncate(string.sub(s, _end))) or nil
end

--- Returns an iterator that iterates over the words within
-- the given string.
-- @param s String to iterate over.
-- @return Word iterator for the given string.
function string.getWords(s)
	local a, b = string.getWord(s)
	return function()
		-- return nil when done
		if not a then
			return nil
		end

		-- store previous iteration results
		local valueA, valueB = a, b

		-- iterate
		a,b = string.getWord(b)

		-- return previous results
		return valueA, valueB
	end
end

--- Remove whitespace from the front and back of a string.
-- @param s String to be truncated.
-- @return Truncated version of the string.
function string.truncate(s)
	local _start, _end = 1, string.len(s)
	while _start < _end and string.sub(s, _start, _start) == " " do
		_start = _start+1
	end

	while _end > _start and string.sub(s, _end, _end) == " " do
		_end = _end-1
	end

	return string.sub(s, _start, _end)
end
