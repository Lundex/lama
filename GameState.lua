--- Contains enum-styled values for Game.state.
-- @author milkmanjack
module("GameState", package.seeall)

--- Table that contains enum-styled values for Game.state.
-- @class table
-- @name GameState
-- @field NEW The Game is in its introductory stages.
-- @field READY The Game is currently running, and ready for play.
-- @field SHUTDOWN The Game is shutting down.
local GameState		= {}
GameState.NEW		= 0
GameState.READY		= 1
GameState.SHUTDOWN	= 2

--- Contains textual representations of GameState enums.
-- @class table
-- @name GameState.names
-- @field GameState.NEW "new"
-- @field GameState.READY "ready"
-- @field GameState.SHUTDOWN "shutdown"
GameState.names		= {}
GameState.names[GameState.NEW]			= "new"
GameState.names[GameState.READY]		= "ready"
GameState.names[GameState.SHUTDOWN]		= "shutdown"

--- Allows for quick reference to GameState.names enums.
-- @param state The state to retrieve the name of.
-- @return Name of the state.
function GameState.name(state)
	return GameState.names[state]
end

_G.GameState = GameState

return GameState
