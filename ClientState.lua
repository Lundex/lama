--[[	Author:	Milkmanjack
		Date:	4/2/13
		Singleton meant to give context for enum-styled members.
]]

local ClientState						= {}
ClientState.NEW							= 0
ClientState.NAME						= 1

-- if it's an unrecognized name, make a new character
ClientState.NEW_CHAR_NAME_CONFIRM		= 2
ClientState.NEW_CHAR_PASSWORD			= 3
ClientState.NEW_CHAR_PASSWORD_CONFIRM	= 4

-- if it's recognized (character exists), log in
ClientState.LOAD_CHAR_PASSWORD			= 5

-- login process
ClientState.MOTD						= 6
ClientState.PLAYING						= 7

-- text representations of states
ClientState.names											= {}
ClientState.names[ClientState.NEW]							= "connecting"
ClientState.names[ClientState.NAME]							= "name"
ClientState.names[ClientState.NEW_CHAR_NAME_CONFIRM]		= "(new char) name confirm"
ClientState.names[ClientState.NEW_CHAR_PASSWORD]			= "(new char) password"
ClientState.names[ClientState.NEW_CHAR_PASSWORD_CONFIRM]	= "(new char) password confirm"
ClientState.names[ClientState.LOAD_CHAR_PASSWORD]			= "(load char) password"
ClientState.names[ClientState.MOTD]							= "MOTD"
ClientState.names[ClientState.PLAYING]						= "PLAYING"

-- quick access
function ClientState:name(state)
	return self.names[state]
end

return ClientState
