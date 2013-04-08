--[[	Author:	Milkmanjack
		Date:	4/6/13
		Static tiles that contain other MapObjects.
		The lowest-level location for a MapObject, essentially.
]]

local MapObject	= require("obj.MapObject")
local Mob		= require("obj.Mob")
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
	self.contents	= {}
	if map then
		self:moveToMap(map)
	end

	if x and y and z then
		self:setXYZLoc(x,y,z)
	end
end

function MapTile:onEnter(mapObject)
end

function MapTile:setXYZLoc(x,y,z)
	self.x = x
	self.y = y
	self.z = z
end

function MapTile:getLoc()
	return self
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
