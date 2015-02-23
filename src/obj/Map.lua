--[[
    lama is a MUD server made in Lua.
    Copyright (C) 2013 Curtis Erickson

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--- Cloneable that handles map data and processing.
-- @author milkmanjack
module("obj.Map", package.seeall)

local Cloneable	= require("obj.Cloneable")
local MapTile	= require("obj.MapTile")

--- Cloneable that handles map data and processing.
-- @class table
-- @name Map
-- @field width Horizontal width if the map.
-- @field height Vertical height of the map.
-- @field layers 3D height of the map.
local Map		= Cloneable.clone()

-- runtime data
Map.width		= 0
Map.height		= 0
Map.layers		= 0

--- A 3D grid containing all of the MapTiles within a Map.
-- The matrix is ordered in a layer->column->row format. Essentially, z->y->x.
-- @class table
-- @name Map.tiles
Map.tiles		= nil

--- Contains every MapObject within the Map, including MapTiles.
-- @class table
-- @name Map.contents
Map.contents	= nil

--- Creates a unique contents table for each Map.
function Map:initialize()
	self.contents = {}
end

--- Generates a new map of the given dimensions.
-- @param width Width of the map.
-- @param height Height of the map.
-- @param layers Layers of the map.
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

--- Adds a MapObject to our contents.
-- MapObjects and Maps share mutual references to each other.
-- If a MapObject is added to a Map's contents, the MapObject's
-- map is set to it, and it is removed from whatever map it was in
-- previously.
-- @param mapObject MapObject to be added.
function Map:addToContents(mapObject)
	table.insert(self.contents, mapObject)
	self.contents[mapObject] = true

	-- mutuality
	if mapObject:getMap() ~= self then
		mapObject:moveToMap(self)
	end
end

--- Removes a MapObject from our contents.
-- MapObjects and Maps share mutual references to each other.
-- If a MapObject is removed from a Map's contents, the MapObject's
-- map is set to nil, and it is removed from any location in that map.
-- @param mapObject MapObject to be removed.
function Map:removeFromContents(mapObject)
	table.removeValue(self.contents, mapObject)
	self.contents[mapObject] = nil

	-- mutuality
	if mapObject:getMap() == self then
		mapObject:moveToMap(nil)
		mapObject:setLoc(nil)
	end
end

--- Assign a MapTile to a given XYZ location.
-- @param tile The tile to be assigned.
-- @param x The X location.
-- @param y The Y location.
-- @param z The Z location.
function Map:setTile(tile, x, y, z)
	if tile:getMap() ~= self then
		tile:moveToMap(self)
	end

	if tile:getX() ~= x or tile:getY() ~= y or tile:getZ() ~= z then
		tile:setXYZLoc(x,y,z)
	end

	self.tiles[z][y][x] = tile
end

--- Gets the tile in the given direction from a MapObject.
-- @param mapObject A MapObject on the Map.
-- @param direction A direction. Always a member of the Direction table.
-- @param The MapTile in the given direction.<br/>nil if none is found.
function Map:getStep(mapObject, direction)
	local x,y,z = mapObject:getX(), mapObject:getY(), mapObject:getZ()

	-- update new xyz location
	if direction == Direction.NORTH or direction == Direction.NORTHEAST or direction == Direction.NORTHWEST then
		y = y + 1
	elseif direction == Direction.SOUTH or direction == Direction.SOUTHEAST or direction == Direction.SOUTHWEST then
		y = y - 1
	end

	if direction == Direction.EAST or direction == NORTHEAST or direction == NORTHWEST then
		x = x + 1
	elseif direction == Direction.WEST or direction == Direction.NORTHWEST or direction == Direction.SOUTHWEST then
		x = x - 1
	end

	return self:getTile(x,y,z)
end

--- Check if a Map contains a MapObject.
-- @param mapObject The MapObject to check for.
-- @return true if the Map contains it.<br/>false otherwise.
function Map:contains(mapObject)
	return self.contents[mapObject] == true
end

--- Gets contents list.
-- @return Contents list.
function Map:getContents()
	return self.contents
end

--- Gets width of map.
-- @return Width of map.
function Map:getWidth()
	return self.width
end

--- Gets height of map.
-- @return Height of map.
function Map:getHeight()
	return self.height
end

--- Gets layer count of map.
-- @return Layer count of map.
function Map:getLayers()
	return self.layers
end

--- Gets tile list.
-- @return Tile list.
function Map:getTiles()
	return self.tiles
end

--- Get a tile at the given XYZ location.
-- @param x X to check.
-- @param y Y to check.
-- @param z Z to check.
-- @return MapTile if tile is found.<br/>nil otherwise.
function Map:getTile(x,y,z)
	if x < 1 or x > self.width or
		y < 1 or y > self.height or
		z < 1 or z > self.layers then
		return nil
	end

	return self.tiles[z][y][x]
end

return Map
