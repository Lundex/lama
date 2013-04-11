--- Cloneable:MapObject that represents the lowest-level MapObject location on a Map.
-- @author milkmanjack
module("obj.MapTile", package.seeall)

local MapObject	= require("obj.MapObject")
local Mob		= require("obj.Mob")

--- Cloneable:MapObject that represents the lowest-level MapObject location on a Map.
-- @class table
-- @name MapTile
-- @field name Name of the MapTile.
-- @field description Complete description of the MapTile.
-- @field x X location.
-- @field y Y location.
-- @field z Z location.

local MapTile	= MapObject:clone()

-- we have a tricky situation here cause MapTiles inherit from MapObjects (which I think I should change).
-- cause MapTiles are the things that MapObjects generally are gonna inhabit, on top of other MapObjects.
-- MapTiles essentially will be the only thing with an x/y/z coordinate, and MapObjects will just borrow those values

-- maptile settings
MapTile.name		= "a void"
MapTile.description	= "a vast, undefineable void..."

-- runtime data
MapTile.x			= 0
MapTile.y			= 0
MapTile.z			= 0

--- Creates a unique contents table per MapObject.
-- Also has the potential to assign a Map and XYZ location.
-- @param map Map to be moved to.
-- @param x X loc to be assigned.
-- @param y Y loc to be assigned.
-- @param z Z loc to be assigned.
function MapTile:initialize(map,x,y,z)
	self.contents	= {}
	if map then
		self:moveToMap(map)
	end

	if x and y and z then
		self:setXYZLoc(x,y,z)
	end
end

--- Assigns a complete XYZ location.
-- @param x X location to set.
-- @param y Y location to set.
-- @param z Z location to set.
function MapTile:setXYZLoc(x,y,z)
	self.x = x
	self.y = y
	self.z = z
end

--- MapTiles cannot inhabit any other MapObject, so this simply returns self.
-- @return self
function MapTile:getLoc()
	return self
end

--- Get current x location.
-- @return Current x location.
function MapTile:getX()
	return self.x
end

--- Get current y location.
-- @return Current y location.
function MapTile:getY()
	return self.y
end

--- Get current z location.
-- @return Current z location.
function MapTile:getZ()
	return self.z
end

return MapTile
