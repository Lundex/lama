--[[	Author:	Milkmanjack
		Date:	4/2/13
		Holds data for mobile creatures.
]]

local Cloneable	= require("obj.Cloneable")
local Mob		= Cloneable.clone()

-- creature data
Mob.name			= "creature"
Mob.description		= "It's a creature."

Mob.level			= 1
Mob.experience		= 0

Mob.health			= 100
Mob.mana			= 100
Mob.moves			= 100

function Mob:initialize(name)
	self.name	= name
end

function Mob:toString()
	return self.name
end

return Mob
