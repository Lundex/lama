--- Singleton that contains enum-styled values for directional movement.
-- @author milkmanjack
module("Directions", package.seeall)

--- Singleton that contains enum-styled values for directional movement.
-- @class table
-- @name Direction
-- @field NORTH North.
-- @field SOUTH South.
-- @field EAST East.
-- @field WEST West.
-- @field NORTHEAST Northeast.
-- @field NORTHWEST Northwest.
-- @field SOUTHEAST Southeast.
-- @field SOUTHWEST Southwest.
local Direction							= {}
Direction.NORTH							= 0
Direction.SOUTH							= 1
Direction.EAST							= 2
Direction.WEST							= 3
Direction.NORTHEAST						= 4
Direction.NORTHWEST						= 5
Direction.SOUTHEAST						= 6
Direction.SOUTHWEST						= 7

--- Contains textual representations of Direction enums.
-- @class table
-- @name Direction.names
-- @field Direction.NORTH "north"
-- @field Direction.SOUTH "south"
-- @field Direction.EAST "east"
-- @field Direction.WEST "west"
-- @field Direction.NORTHEAST "northeast"
-- @field Direction.NORTHWEST "northwest"
-- @field Direction.SOUTHEAST "southeast"
-- @field DIRECTION.SOUTHWEST "southwest"
Direction.names							= {}
Direction.names[Direction.NORTH]		= "north"
Direction.names[Direction.SOUTH]		= "south"
Direction.names[Direction.EAST]			= "east"
Direction.names[Direction.WEST]			= "west"
Direction.names[Direction.NORTHEAST]	= "northeast"
Direction.names[Direction.NORTHWEST]	= "northwest"
Direction.names[Direction.SOUTHEAST]	= "southeast"
Direction.names[Direction.SOUTHWEST]	= "southwest"

--- Allows for quick reference Direction.names enums.
-- @param state The direction to retrieve the name of.
-- @return Name of the direction.
function Direction.name(state)
	return Direction.names[state]
end

--- Reverses the given direction.
-- @param direction Direction to reverse.
-- @return The reverse of the given direction.
function Direction.reverse(direction)
	if direction == Direction.NORTH then
		return Direction.SOUTH
	elseif direction == Direction.SOUTH then
		return Direction.NORTH
	elseif direction == Direction.EAST then
		return Direction.WEST
	elseif direction == Direction.WEST then
		return Direction.EAST
	elseif direction == Direction.NORTHEAST then
		return Direction.SOUTHWEST
	elseif direction == Direction.NORTHWEST then
		return Direction.SOUTHEAST
	elseif direction == Direction.SOUTHEAST then
		return Direction.NORTHWEST
	elseif direction == Direction.SOUTHWEST then
		return Direction.NORTHEAST
	end
end

_G.Direction = Direction

return Direction
