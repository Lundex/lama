--- A pseudo-heritage framework for table inheritance.
-- @author milkmanjack
module("Cloneable", package.seeall)

--- Table that provides psuedo-inheritance-type features for tables.<br/><br/>
-- Inheritance is achieved by using the __index metatable method, which just transfers attempts to index nil fields to the parent.<br/>
-- <ul><li><b>Cloneable.clone(parent)</b> provides an interface for making a <i>pure clone</i> that is set to refer to the given parent.</li>
-- <li><b>Cloneable.new(parent, ...)</b> provides an interface for making an <i>instance-style clone</i>, which has the properties of a <i>pure clone</i>, but is initialized.</li></ul>
-- In effect, <i>pure clones</i> are meant to act as a <b>class</b> of a sort, and <i>instance-style clones</i> are meant to act as <b>instances of a class</b>.
-- @class table
-- @name Cloneable
local Cloneable	= {}

--- Create a pure clone of a Cloneable.
-- @param parent The parent to clone. Defaults to Cloneable.
-- @return A pure clone of the parent.
function Cloneable.clone(parent)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable,
							__tostring=parent and parent.toString or Cloneable.toString
							}
	)

	return instance
end

--- Creates an instance-style clone of a Cloneable.
-- The clone is initialized, passing all arguments beyond the first to the clone's initialize() function.
-- @param parent The parent to clone. Defaults to Cloneable.
-- @param ... These arguments are passed to the clone's initialize() function.
-- @return An instance-style clone of the parent.
function Cloneable.new(parent, ...)
	local c = Cloneable.clone(parent)
	c:initialize(...)
	return c
end

--- Get the direct parent of the given Cloneable.
-- @param clone The clone whose parent we want to check.
-- @return The parent!
function Cloneable.getParent(clone)
	if clone == Cloneable then
		return nil
	end

	local mt = getmetatable(clone)
	return mt.__index
end

--- Traverses a clone's parentage via their metatable's __index value.
-- Determines whether or not this clone is a clone of another Cloneable.
-- @param clone The Cloneable to check.
-- @param ancestor The Cloneable we might be a clone of.
-- @return true if given clone is a clone of given ancestor.<br/>false otherwise.
function Cloneable.isCloneOf(clone, ancestor)
	local parent = clone:getParent()
	while parent do
		if parent == ancestor then
			return true
		end

		parent = parent:getParent()
	end

	return false
end

--- Constructor for instance-style clones.
function Cloneable:initialize(...)
end

--- Stringifier for Cloneables.
function Cloneable:toString()
	return "{cloneable}"
end

return Cloneable
