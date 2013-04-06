--[[	Author:	Milkmanjack
		Date:	3/5/13
		Allows for pseudo-inheritance between objects.
]]

local Cloneable	= {}

--[[
	Create a class-style clone of a Cloneable (one that isn't initialized).
	If init is true, initialize as an instance-style clone.
	Arguments beyond the first 2 are passed to the instance's initialization function.
]]
function Cloneable.clone(parent, init, ...)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable,
							__tostring=parent and parent.toString or Cloneable.toString
							}
	)

	-- should we initialize?
	-- (only in cases where we're making an active instance)
	if init then
		instance:initialize(...)
	end

	return instance
end

--[[
	Shortcut for creating an instance-style clone (one that is initialized).
	Arguments beyond the first 2 are passed to the instance's initialization function.
]]
function Cloneable.new(parent, ...)
	return Cloneable.clone(parent, true, ...)
end

function Cloneable.getParent(clone)
	if clone == Cloneable then
		return nil
	end

	local mt = getmetatable(clone)
	return mt.__index
end

function Cloneable.isChildOf(clone, ancestor)
	local parent = clone:getParent()
	while parent do
		if parent == ancestor then
			return true
		end

		parent = parent:getParent()
	end

	return false
end

--[[
	Entry point for constructor-style initialization of instances.
]]
function Cloneable:initialize(...)
end

--[[
	Entry point for tostring() access.
]]
function Cloneable:toString()
	return "{cloneable}"
end

return Cloneable
