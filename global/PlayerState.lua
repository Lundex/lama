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

--- Singleton that contains enum-styled values for Player.state.
-- @author milkmanjack
module("PlayerState", package.seeall)

--- Singleton that contains enum-styled values for Player.state.
-- @class table
-- @name PlayerState
-- @field NEW Player has just been connected.
-- @field DISCONNECTING Player is in the process of disconnecting.
-- @field NAME Retreiving a name to be used by the player.
-- @field NEW_CHAR_NAME_CONFIRM Confirming they wish to use this name to create a new character.
-- @field NEW_CHAR_PASSWORD Asking for a password for their new character.
-- @field NEW_CHAR_PASSWORD_CONFIRM Asking to confirm their password.
-- @field LOAD_CHAR_PASSWORD Asking for the password for an existent character.
-- @field MOTD Getting the MOTD.
-- @field PLAYING Playing the game.
local PlayerState						= {}
PlayerState.NEW							= 0
PlayerState.DISCONNECTING				= 1
PlayerState.NAME						= 2
PlayerState.NEW_CHAR_NAME_CONFIRM		= 3
PlayerState.NEW_CHAR_PASSWORD			= 4
PlayerState.NEW_CHAR_PASSWORD_CONFIRM	= 5
PlayerState.OLD_CHAR_PASSWORD			= 6
PlayerState.MOTD						= 7
PlayerState.PLAYING						= 8

--- Contains textual representations of PlayerState enums.
-- @class table
-- @name PlayerState.names
-- @field PlayerState.NEW "new"
-- @field PlayerState.DISCONNECTING "disconnecting"
-- @field PlayerState.NAME "name"
-- @field PlayerState.NEW_CHAR_NAME_CONFIRM "(new char) name confirm"
-- @field PlayerState.NEW_CHAR_PASSWORD "(new char) password"
-- @field PlayerState.NEW_CHAR_PASSWORD_CONFIRM "(new char) password confirm"
-- @field PlayerState.LOAD_CHAR_PASSWORD "(load char) password"
-- @field PlayerState.MOTD "MOTD"
-- @field PlayerState.PLAYING "PLAYING"
PlayerState.names											= {}
PlayerState.names[PlayerState.NEW]							= "new"
PlayerState.names[PlayerState.DISCONNECTING]				= "disconnecting"
PlayerState.names[PlayerState.NAME]							= "name"
PlayerState.names[PlayerState.NEW_CHAR_NAME_CONFIRM]		= "name confirm"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD]			= "password"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD_CONFIRM]	= "password confirm"
PlayerState.names[PlayerState.OLD_CHAR_PASSWORD]			= "login password"
PlayerState.names[PlayerState.MOTD]							= "MOTD"
PlayerState.names[PlayerState.PLAYING]						= "playing"

--- Allows for quick reference to PlayerState.names enums.
-- @param state The state to retrieve the name of.
-- @return Name of the state.
function PlayerState.name(state)
	return PlayerState.names[state]
end

_G.PlayerState = PlayerState

return PlayerState
