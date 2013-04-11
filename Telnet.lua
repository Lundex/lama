--- Singleton that contains all telnet-specific data and operations.
-- @author milkmanjack
module("Telnet", package.seeall)

--- Singleton that contains all telnet-specific data and operations.
-- @class table
-- @name Telnet
local Telnet  							= {}

--- Contains enum-styled values for telnet commands.
-- @class table
-- @name Telnet.commands
-- @field IAC 255
-- @field DONT 254
-- @field DO 253
-- @field WONT 252
-- @field WILL 251
-- @field SB 250
-- @field GA 249
-- @field EL 248
-- @field EC 247
-- @field SE 240
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

--- Contains textual representations of Telnet.commands enums.
-- @class table
-- @name Telnet.commands.names
-- @field Telnet.commands.IAC "IAC"
-- @field Telnet.commands.DONT "DONT"
-- @field Telnet.commands.DO "DO"
-- @field Telnet.commands.WONT "WONT"
-- @field Telnet.commands.WILL "WILL"
-- @field Telnet.commands.SB "SB"
-- @field Telnet.commands.GA "GA"
-- @field Telnet.commands.EL "EL"
-- @field Telnet.commands.EC "EC"
-- @field Telnet.commands.SE "SE"
Telnet.commands.names						= {}
Telnet.commands.names[Telnet.commands.IAC]	= "IAC"
Telnet.commands.names[Telnet.commands.DONT]	= "DONT"
Telnet.commands.names[Telnet.commands.DO]	= "DO"
Telnet.commands.names[Telnet.commands.WONT]	= "WONT"
Telnet.commands.names[Telnet.commands.WILL]	= "WILL"
Telnet.commands.names[Telnet.commands.SB]	= "SB"
Telnet.commands.names[Telnet.commands.GA]	= "GA"
Telnet.commands.names[Telnet.commands.EL]	= "EL"
Telnet.commands.names[Telnet.commands.EC]	= "EC"
Telnet.commands.names[Telnet.commands.SE]	= "SE"

--- Allows for quick reference to Telnet.commands.names enums.
-- @param command The command to retrieve the name of.
-- @return Name of the command.
function Telnet.commands.name(command)
	return Telnet.commands.names[command] or string.format("(%s)", tostring(command))
end

_G.Telnet = Telnet

return Telnet
