--[[	Author:	Milkmanjack
		Date:	4/2/13
		Holds data for mobile creatures.
]]

local Cloneable	= require("obj.Cloneable")
local Creature	= Cloneable.clone()

-- creature data
Creature.name			= "creature"
Creature.description	= "It's a creature."

Creature.level			= 1
Creature.experience		= 0

Creature.health			= 100
Creature.mana			= 100
Creature.moves			= 100

return Creature
