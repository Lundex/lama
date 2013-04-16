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

--- Singleton that contains enum-styled values for Game.state.
-- @author milkmanjack
module("GameState", package.seeall)

--- Singleton that contains enum-styled values for Game.state.
-- @class table
-- @name GameState
-- @field NEW The Game is in its introductory stages.
-- @field READY The Game is currently running, and ready for play.
-- @field SHUTDOWN The Game is shutting down.
local GameState		= {}
GameState.NEW		= 0
GameState.READY		= 1
GameState.HOTBOOT	= 2
GameState.SHUTDOWN	= 3

--- Contains textual representations of GameState enums.
-- @class table
-- @name GameState.names
-- @field GameState.NEW "new"
-- @field GameState.READY "ready"
-- @field GameState.HOTBOOT "hotboot"
-- @field GameState.SHUTDOWN "shutdown"
GameState.names		= {}
GameState.names[GameState.NEW]			= "new"
GameState.names[GameState.READY]		= "ready"
GameState.names[GameState.HOTBOOT]		= "hotboot"
GameState.names[GameState.SHUTDOWN]		= "shutdown"

--- Allows for quick reference to GameState.names enums.
-- @param state The state to retrieve the name of.
-- @return Name of the state.
function GameState.name(state)
	return GameState.names[state]
end

_G.GameState = GameState

return GameState
