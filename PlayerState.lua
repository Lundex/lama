--[[	Author:	Milkmanjack
		Date:	4/2/13
		Package meant to give context for enum-styled members.
]]

local PlayerState						= {}
PlayerState.NEW							= 0
PlayerState.DISCONNECTING				= 1
PlayerState.NAME						= 2

-- if it's an unrecognized name, make a new character
PlayerState.NEW_CHAR_NAME_CONFIRM		= 3
PlayerState.NEW_CHAR_PASSWORD			= 4
PlayerState.NEW_CHAR_PASSWORD_CONFIRM	= 5

-- if it's recognized (character exists), log in
PlayerState.LOAD_CHAR_PASSWORD			= 6

-- login process
PlayerState.MOTD						= 7
PlayerState.PLAYING						= 8

-- text representations of states
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

-- quick access
function PlayerState.name(state)
	return PlayerState.names[state]
end

_G.PlayerState = PlayerState

return PlayerState
