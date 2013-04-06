--[[	Author:	Milkmanjack
		Date:	3/30/12
		Extends table library a bit.
]]

--[[
	Provides a hard copy of a table.
	@param t	The table to copy.
	@return A copy of the given table.
]]
function table.copy(t)
	local c = {}
	for i,v in pairs(t) do
		c[i] = v
	end

	return c
end

--[[
	Provides a safe iterator over the members of the given table.
	@return An iterator in the same vein as pairs()
]]
function table.safePairs(t)
	return pairs(table.copy(t))
end

--[[
	Provides a safe iterator over the members of the given table.
	@return An iterator in the same vein as ipairs()
]]
function table.safeIPairs(t)
	return ipairs(table.copy(t))
end

--[[
	Shortcut to remove a value from a table (as opposed to by index).
]]
function table.removeValue(t, value)
	for i,v in pairs(t) do
		if v == value then
			table.remove(t, i)
		end
	end
end

--[[
	Converts the members of a table into a string, using tostring()
	to convert the individual members, placing delimiters between
	each member.
]]
function table.tostring(t,delimiter)
	delimiter	= delimiter or ","

	-- empty table?
	local first	= next(t)
	if not first then
		return ""
	end

	-- one entry table?
	local second = next(t, first)
	if not second then
		return tostring(t[first])
	end

	-- unique iterator that starts at the second entry
	local iterator = function()
		local i = second
		return function()
			local index, value = i, t[i]
			i = next(t, i)
			return index, value
		end
	end

	-- generate the rest of the string
	local msg = tostring(t[first])
	for i,v in iterator() do
		msg = string.format("%s%s%s", msg, delimiter, tostring(v))
	end

	return msg
end