local Cloneable	= require("obj.Cloneable")
local MapTile	= require("obj.MapTile")
local Map		= Cloneable.clone()

-- runtime data
Map.tiles		= nil
Map.width		= 0
Map.height		= 0
Map.layers		= 0

function Map:generate(width,height,layers)
	local tiles = {}
	self.width		= width
	self.height		= height
	self.lazyers	= layers
	for z=1, layers do
		tiles[z] = {}
		for y=1, height do
			tiles[z][y] = {}
			for x=1, width do
				tiles[z][y][x] = MapTile:new(self,x,y,z)
			end
		end
	end

	self.tiles = tiles
	return tiles
end

function Map:getTile(x,y,z)
	return self.tiles[x][y][z]
end

return Map
