--[[	Author:	Milkmanjack
		Date:	4/8/13
		Package meant to give context for enum-styled members.
]]

local Direction							= {}
Direction.NORTH							= 0
Direction.SOUTH							= 1
Direction.EAST							= 2
Direction.WEST							= 3
Direction.NORTHEAST						= 4
Direction.NORTHWEST						= 5
Direction.SOUTHEAST						= 6
Direction.SOUTHWEST						= 7

-- text representations of states
Direction.names							= {}
Direction.names[Direction.NORTH]		= "north"
Direction.names[Direction.SOUTH]		= "south"
Direction.names[Direction.EAST]			= "east"
Direction.names[Direction.WEST]			= "west"
Direction.names[Direction.NORTHEAST]	= "northeast"
Direction.names[Direction.NORTHWEST]	= "northwest"
Direction.names[Direction.SOUTHEAST]	= "southeast"
Direction.names[Direction.SOUTHWEST]	= "southwest"

-- quick access
function Direction.name(state)
	return Direction.names[state]
end

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
