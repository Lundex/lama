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
PlayerState.LOAD_CHAR_PASSWORD			= 6
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
PlayerState.names[PlayerState.NEW_CHAR_NAME_CONFIRM]		= "(new char) name confirm"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD]			= "(new char) password"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD_CONFIRM]	= "(new char) password confirm"
PlayerState.names[PlayerState.LOAD_CHAR_PASSWORD]			= "(load char) password"
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
