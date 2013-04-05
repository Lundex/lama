--[[	Author:	Milkmanjack
		Date:	4/1/13
		Player object holds data relevant to a playable character.
]]

local Cloneable		= require("obj.Cloneable")
local Client		= require("obj.Client")
local Player		= Cloneable.clone()

-- runtime data
Player.client		= nil -- the client attached to this player
Player.mob			= nil -- the mob attached to this player

return Player
