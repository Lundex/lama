--[[	Author:	Milkmanjack
		Date:	4/8/13
		Package meant to give context for enum-styled members.
]]

local MessageMode							= {}
MessageMode.GENERAL							= 0 -- miscellaneous messages
MessageMode.CHAT							= 1 -- chatting
MessageMode.ANNOUNCEMENT					= 2 -- game updates (logins, deaths, other stuff)
MessageMode.INFO							= 3
MessageMode.QUESTION						= 4 -- questions
MessageMode.MOVEMENT						= 5 -- movement updates (people moving, you moving, information about the rooms you enter)
MessageMode.COMBAT							= 6 -- combat updates (attacking one another, dodging, using skills, etc...)
MessageMode.FAILURE							= 7 -- a failure message!

-- text representations of states
MessageMode.names							= {}
MessageMode.names[MessageMode.GENERAL]		= "general"
MessageMode.names[MessageMode.CHAT]			= "chat"
MessageMode.names[MessageMode.ANNOUNCEMENT]	= "announcement"
MessageMode.names[MessageMode.INFO]			= "info"
MessageMode.names[MessageMode.FAILURE]		= "failure"
MessageMode.names[MessageMode.QUESTION]		= "question"
MessageMode.names[MessageMode.MOVEMENT]		= "movement"
MessageMode.names[MessageMode.COMBAT]		= "combat"

-- quick access
function MessageMode.name(state)
	return MessageMode.names[state]
end

_G.MessageMode = MessageMode

return MessageMode
