--[[	Author:	Milkmanjack
		Date:	4/2/13
		Singleton meant to give context for enum-styled members.
]]

local GameState		= {}
GameState.NEW		= 0
GameState.READY		= 1
GameState.SHUTDOWN	= 2

-- text representations of states
GameState.names		= {}
GameState.names[GameState.NEW]			= "new"
GameState.names[GameState.READY]		= "ready"
GameState.names[GameState.SHUTDOWN]		= "shutdown"

-- quick access
function GameState:name(state)
	return self.names[state]
end

return GameState
