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
-- @field MCCP 85
-- @field MCCP2 86
-- @field MSSP 70
-- @field MSDP 69
-- @field TTYPE 24
-- @field IS 0
-- @field SEND 1
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

-- protocol options (I guess)
Telnet.commands.MCCP						= 85
Telnet.commands.MCCP2						= 86
Telnet.commands.MSSP						= 70
Telnet.commands.MSDP						= 69
Telnet.commands.TTYPE						= 24

-- MSSP negotiation commands
Telnet.commands.MSSP_VAL					= 2
Telnet.commands.MSSP_VAR					= 1 -- I'll have to separate the different message types.

-- environment options (I guess)
Telnet.commands.SEND						= 1
Telnet.commands.IS							= 0


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
-- @field Telnet.commands.MCCP "MCCP"
-- @field Telnet.commands.MCCP2 "MCCP2"
-- @field Telnet.commands.MSSP "MSSP"
-- @field Telnet.commands.MSDP "MSDP"
-- @field Telnet.commands.TTYPE "TTYPE"
-- @field Telnet.commands.MSSP_VAL "MSDP_VAL"
-- @field Telnet.commands.MSSP_VAR "MSDP_VAR"
-- @field Telnet.commands.SEND "SEND"
-- @field Telnet.commands.IS "IS"
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

-- protocols
Telnet.commands.names[Telnet.commands.MCCP] = "MCCP"
Telnet.commands.names[Telnet.commands.MCCP2] = "MCCP2"
Telnet.commands.names[Telnet.commands.MSSP] = "MSSP"
Telnet.commands.names[Telnet.commands.MSDP] = "MSDP"
Telnet.commands.names[Telnet.commands.TTYPE] = "TTYPE"


-- MSSP negotiation commands
Telnet.commands.names[Telnet.commands.MSSP_VAL] = "MSDP_VAL"
Telnet.commands.names[Telnet.commands.MSSP_VAR] = "MSDP_VAR"

-- environment options
Telnet.commands.names[Telnet.commands.SEND]	= "SEND"
Telnet.commands.names[Telnet.commands.IS]	= "IS"

--- Allows for quick reference to Telnet.commands.names enums.
-- @param command The command to retrieve the name of.
-- @return Name of the command.
function Telnet.commands.name(command)
	return Telnet.commands.names[command] or string.format("(%s)", tostring(command))
end

--- Returns a string with every Telnet command in the given command named, separated by commas.
-- @param command The command to name all of the options in.
-- @return Formatted string of all command option names.
function Telnet.commands.nameAll(command)
	local msg
	for i=1, string.len(command) do
		msg = string.format("%s%s%s", msg or "", msg and "," or "", Telnet.commands.name(string.byte(command, i)))
	end

	return msg
end

_G.Telnet = Telnet

return Telnet
