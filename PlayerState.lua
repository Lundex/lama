--[[	Author:	Milkmanjack
		Date:	4/2/13
		Package meant to give context for enum-styled members.
]]

local PlayerState						= {}
PlayerState.NEW							= 0
PlayerState.NAME						= 1

-- if it's an unrecognized name, make a new character
PlayerState.NEW_CHAR_NAME_CONFIRM		= 2
PlayerState.NEW_CHAR_PASSWORD			= 3
PlayerState.NEW_CHAR_PASSWORD_CONFIRM	= 4

-- if it's recognized (character exists), log in
PlayerState.LOAD_CHAR_PASSWORD			= 5

-- login process
PlayerState.MOTD						= 6
PlayerState.PLAYING						= 7

-- text representations of states
PlayerState.names											= {}
PlayerState.names[PlayerState.NEW]							= "connecting"
PlayerState.names[PlayerState.NAME]							= "name"
PlayerState.names[PlayerState.NEW_CHAR_NAME_CONFIRM]		= "(new char) name confirm"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD]			= "(new char) password"
PlayerState.names[PlayerState.NEW_CHAR_PASSWORD_CONFIRM]	= "(new char) password confirm"
PlayerState.names[PlayerState.LOAD_CHAR_PASSWORD]			= "(load char) password"
PlayerState.names[PlayerState.MOTD]							= "MOTD"
PlayerState.names[PlayerState.PLAYING]						= "PLAYING"

-- quick access
function PlayerState:name(state)
	return self.names[state]
end

return PlayerState
