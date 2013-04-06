local Cloneable	= require("obj.Cloneable")
local MapObject	= Cloneable.clone()

-- mapobject settings
MapObject.name			= "mapobject"
MapObject.description	= "a map object"

-- runtime data
MapObject.map		= nil -- the map we are a part of
MapObject.loc		= nil -- the MapObject we're located in/on (usually a MapTile, but can be a MapObject too)
MapObject.contents	= {} -- things contained within a tile

function MapObject:initialize(map,loc)
	self:setMap(map)
	self:setLoc(loc)
end

function MapObject:toString()
	return self.name
end

function MapObject:moveToMap(map)
	if self.map then
		self.map:removeFromContents(self)
	end

	self.map = map
	map:addToContents(self)
end

function MapObject:setLoc(mapObject)
	if self.loc then
		self.loc:removeFromContents(self)
	end

	self.loc = mapObject
	mapObject:addToContents(self)
end

function MapObject:setXYZLoc(x,y,z)
	local tile = self.map:getTile(x,y,z)
	if tile then
		self:setLoc(tile)
	end
end

function MapObject:addToContents(mapObject)
	table.insert(self.contents, mapObject)
end

function MapObject:removeFromContents(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			table.remove(self.contents, i)
		end
	end
end

function MapObject:getName()
	return self.name
end

function MapObject:getDescription()
	return self.description
end

function MapObject:getMap()
	return self.map
end

function MapObject:getLoc()
	return self.loc
end

function MapObject:getX()
	return self.loc and self.loc:getX() or nil
end

function MapObject:getY()
	return self.loc and self.loc:getY() or nil
end

function MapObject:getZ()
	return self.loc and self.loc:getZ() or nil
end

return MapObject
