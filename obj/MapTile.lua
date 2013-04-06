local MapObject	= require("obj.MapObject")
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

function MapTile:initialize(map,x,y,z)
	self:moveToMap(map)
	if x and y and z then
		self:setXYZLoc(x,y,z)
	end
end

function MapTile:setXYZLoc(x,y,z)
	self.x = x
	self.y = y
	self.z = z
end

function MapTile:getLoc()
	return self:getX(),self:getY(),self:getZ()
end

function MapTile:getX()
	return self.x
end

function MapTile:getY()
	return self.y
end

function MapTile:getZ()
	return self.z
end

return MapTile
