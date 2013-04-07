local Cloneable	= require("obj.Cloneable")
local MapTile	= require("obj.MapTile")
local Map		= Cloneable.clone()

-- runtime data
Map.tiles		= nil
Map.width		= 0
Map.height		= 0
Map.layers		= 0
Map.contents	= nil

function Map:initialize()
	self.contents = {}
end

function Map:generate(width,height,layers)
	self.tiles	= {}
	self.width	= width
	self.height	= height
	self.layers	= layers

	-- initial "filling out"
	for z=1, layers do
		self.tiles[z] = {}
		for y=1, height do
			self.tiles[z][y] = {}
			for x=1, width do
				self.tiles[z][y][x] = nil
			end
		end
	end

	-- seed generic tiles
	for z=1, layers do
		for y=1, height do
			for x=1, width do
				self:setTile(MapTile:new(), x, y, z)
			end
		end
	end
end

function Map:contains(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			return true
		end
	end

	return false
end

function Map:addToContents(mapObject)
	table.insert(self.contents, mapObject)

	-- mutuality
	if mapObject:getMap() ~= self then
		mapObject:moveToMap(self)
	end
end

function Map:removeFromContents(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			table.remove(self.contents, i)
		end
	end

	-- mutuality
	if mapObject:getMap() == self then
		mapObject:moveToMap(nil)
		mapObject:setLoc(nil)
	end
end

function Map:setTile(tile, x, y, z)
	if tile:getMap() ~= self then
		tile:moveToMap(self)
	end

	if tile:getX() ~= x or tile:getY() ~= y or tile:getZ() ~= z then
		tile:setXYZLoc(x,y,z)
	end

	self.tiles[z][y][x] = tile
end

function Map:getContents()
	return self.contents
end

function Map:getWidth()
	return self.width
end

function Map:getHeight()
	return self.height
end

function Map:getLayers()
	return self.layers
end

function Map:getTile(x,y,z)
	if x < 1 or x > self.width or
		y < 1 or y > self.height or
		z < 1 or z > self.layers then
		return nil
	end

	return self.tiles[x][y][z]
end

return Map
