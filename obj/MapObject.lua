local Cloneable	= require("obj.Cloneable")
local MapObject	= Cloneable.clone()

-- mapobject settings
MapObject.name			= "mapobject"
MapObject.description	= "a map object"

-- runtime data
MapObject.map		= nil -- the map we are a part of
MapObject.loc		= nil -- the MapObject we're located in/on (usually a MapTile, but can be a MapObject too)
MapObject.contents	= nil -- things contained within a tile

function MapObject:initialize(map,loc)
	self.contents = {}
	if map then
		self:moveToMap(map)
	end

	if loc then
		self:setLoc(loc)
	end
end

function MapObject:toString()
	return self.name
end

function MapObject:moveToMap(map)
	local oldMap = self.map
	self.map = map

	-- mutuality
	if oldMap and oldMap:contains(self) then
		-- our current location cannot be in the old map.
		-- if it is, clear it.
		if self:getLoc():getMap() == oldMap then
			self:setLoc(nil)
		end

		oldMap:removeFromContents(self)
	end

	-- mutuality
	if map and not map:contains(self) then
		map:addToContents(self)
	end
end

-- respects result of permitEntrance before setting location directly
function MapObject:move(mapObject)
	if not mapObject:permitEntrance(self) then
		return false
	end

	self:setLoc(mapObject)
	return true
end

function MapObject:setLoc(mapObject)
	local oldLoc = self:getLoc()
	self.loc = mapObject

	-- mutuality
	if oldLoc and oldLoc:contains(self) then
		oldLoc:removeFromContents(self)
	end

	-- mutuality
	if mapObject and not mapObject:contains(self) then
		mapObject:addToContents(self)
		local targetMap = mapObject:getMap()
		if self:getMap() ~= targetMap then
			self:moveToMap(targetMap)
		end
	end
end

function MapObject:setXYZLoc(x,y,z)
	local tile = self.map:getTile(x,y,z)
	if not tile then
		return self:setLoc()
	end

	return self:setLoc(tile)
end

-- check whether mapobject can enter this MapObject.
function MapObject:permitEntrance(mapObject)
	return true
end

-- fires when a mapObject enters our contents
function MapObject:onEnter(mapObject)
end

function MapObject:contains(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			return true
		end
	end

	return false
end

function MapObject:addToContents(mapObject)
	table.insert(self.contents, mapObject)

	-- mutuality
	if mapObject:getLoc() ~= self then
		mapObject:setLoc(self)
	end

	self:onEnter(mapObject)
end

function MapObject:removeFromContents(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			table.remove(self.contents, i)
		end
	end

	-- mutuality
	if mapObject:getLoc() == self then
		mapObject:setLoc(nil)
	end
end

function MapObject:setName(name)
	self.name = name
end

function MapObject:setDescription(description)
	self.description = description
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

function MapObject:getContents()
	return self.contents
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
