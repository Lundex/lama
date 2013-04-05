--[[	Author:	Milkmanjack
		Date:	4/4/13
		Package that holds all telnet-specific data and operations.
		I'll fill this out later. Too lazy right now.
]]

local Telnet								= {}

-- telnet commands
Telnet.commands								= {}
Telnet.commands.IAC							= 255
Telnet.commands.DONT						= 254
Telnet.commands.DO							= 253
Telnet.commands.WONT						= 252
Telnet.commands.WILL						= 251
Telnet.commands.SB							= 250
Telnet.commands.GA							= 249
Telnet.commands.EL							= 248
Telnet.commands.EC							= 247
Telnet.commands.SE							= 240

-- for display purposes
Telnet.commands.names						= {}
Telnet.commands.names[Telnet.commands.IAC]	= "IAC"
Telnet.commands.names[Telnet.commands.DONT]	= "DONT"
Telnet.commands.names[Telnet.commands.DO]	= "DO"
Telnet.commands.names[Telnet.commands.WONT]	= "WONT"
Telnet.commands.names[Telnet.commands.WILL]	= "WILL"
Telnet.commands.names[Telnet.commands.SB]	= "SB"
Telnet.commands.names[Telnet.commands.GA]	= "GA"
Telnet.commands.names[Telnet.commands.EL]	= "EL"
Telnet.commands.names[Telnet.commands.SE]	= "SE"

function Telnet.commandName(command)
	return Telnet.commands.names[command] or ("INVALID (" .. tostring(command or 0) .. ")")
end

return Telnet
