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
	local tiles = {}
	self.width	= width
	self.height	= height
	self.layers	= layers
	for z=1, layers do
		tiles[z] = {}
		for y=1, height do
			tiles[z][y] = {}
			for x=1, width do
				tiles[z][y][x] = MapTile:new(self, x, y, z)
			end
		end
	end

	self.tiles = tiles
	return tiles
end

function Map:addToContents(mapObject)
	table.insert(self.contents, mapObject)
end

function Map:removeFromContents(mapObject)
	for i,v in ipairs(self.contents) do
		if v == mapObject then
			table.remove(self.contents, i)
		end
	end
end

function Map:setTile(tile, x, y, z)
	tile:setXYZLoc(x,y,z)
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
	return self.tiles[x][y][z]
end

return Map
