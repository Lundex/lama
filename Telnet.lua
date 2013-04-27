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
local Telnet  									= {}

--- Contains telnet command options.
-- @class table
-- @name Telnet.command
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
-- @field EOR 239
-- @field ABORT 238
-- @field SUSP 237
-- @field xEOF 236
Telnet.command										= {}
Telnet.command.IAC									= 255
Telnet.command.DONT									= 254
Telnet.command.DO									= 253
Telnet.command.WONT									= 252
Telnet.command.WILL									= 251
Telnet.command.SB									= 250
Telnet.command.GA									= 249
Telnet.command.EL									= 248
Telnet.command.EC									= 247
Telnet.command.SE									= 240
Telnet.command.EOR									= 239
Telnet.command.ABORT								= 238
Telnet.command.SUSP									= 237
Telnet.command.xEOF									= 236

--- Contains telnet protocol options.
-- @class table
-- @name Telnet.protocol
-- @field MCCP 85
-- @field MCCP2 86
-- @field MSSP 70
-- @field MSDP 69
-- @field TTYPE 24
Telnet.protocol										= {}
Telnet.protocol.MCCP								= 85
Telnet.protocol.MCCP2								= 86
Telnet.protocol.MSSP								= 70
Telnet.protocol.MSDP								= 69
Telnet.protocol.TTYPE								= 24

--- Contains MSSP options.
-- @class table
-- @name Telnet.MSSP
-- @field VAL 2
-- @field VAR 1
Telnet.MSSP											= {}
Telnet.MSSP.VAL										= 2
Telnet.MSSP.VAR										= 1 -- I'll have to separate the different message types.

--- Contains environment options.
-- @class table
-- @name Telnet.environment
-- @field SEND 1
-- @field IS 0
Telnet.environment									= {}
Telnet.environment.SEND								= 1
Telnet.environment.IS								= 0

--- Contains textual representations of Telnet.command values.
-- @class table
-- @name Telnet.command.names
-- @field Telnet.command.IAC "IAC"
-- @field Telnet.command.DONT "DONT"
-- @field Telnet.command.DO "DO"
-- @field Telnet.command.WONT "WONT"
-- @field Telnet.command.WILL "WILL"
-- @field Telnet.command.SB "SB"
-- @field Telnet.command.GA "GA"
-- @field Telnet.command.EL "EL"
-- @field Telnet.command.EC "EC"
-- @field Telnet.command.SE "SE"
-- @field Telnet.command.EOR "EOR"
-- @field Telnet.command.ABORT "ABORT"
-- @field Telnet.command.SUSP "SUSP"
-- @field Telnet.command.xEOF "xEOF"
Telnet.command.names								= {}
Telnet.command.names[Telnet.command.IAC]			= "IAC"
Telnet.command.names[Telnet.command.DONT]			= "DONT"
Telnet.command.names[Telnet.command.DO]				= "DO"
Telnet.command.names[Telnet.command.WONT]			= "WONT"
Telnet.command.names[Telnet.command.WILL]			= "WILL"
Telnet.command.names[Telnet.command.SB]				= "SB"
Telnet.command.names[Telnet.command.GA]				= "GA"
Telnet.command.names[Telnet.command.EL]				= "EL"
Telnet.command.names[Telnet.command.EC]				= "EC"
Telnet.command.names[Telnet.command.SE]				= "SE"
Telnet.command.names[Telnet.command.EOR]			= "EOR"
Telnet.command.names[Telnet.command.ABORT]			= "ABORT"
Telnet.command.names[Telnet.command.SUSP]			= "SUSP"
Telnet.command.names[Telnet.command.xEOF]			= "xEOF"

--- Contains textual representations of Telnet.protocol values.
-- @class table
-- @name Telnet.protocol.names
-- @field Telnet.protocol.MCCP "MCCP"
-- @field Telnet.protocol.MCCP2 "MCCP2"
-- @field Telnet.protocol.MSSP "MSSP"
-- @field Telnet.protocol.MSDP "MSDP"
-- @field Telnet.protocol.TTYPE "TTYPE"
Telnet.protocol.names								= {}
Telnet.protocol.names[Telnet.protocol.MCCP]			= "MCCP"
Telnet.protocol.names[Telnet.protocol.MCCP2]		= "MCCP2"
Telnet.protocol.names[Telnet.protocol.MSSP]			= "MSSP"
Telnet.protocol.names[Telnet.protocol.MSDP] 		= "MSDP"
Telnet.protocol.names[Telnet.protocol.TTYPE] 		= "TTYPE"


--- Contains textual representations of Telnet.MSSP values.
-- @class table
-- @name Telnet.MSSP.names
-- @field Telnet.options.VAL "VAL"
-- @field Telnet.options.VAR "VAR"
Telnet.MSSP.names									= {}
Telnet.MSSP.names[Telnet.MSSP.VAL] 					= "VAL"
Telnet.MSSP.names[Telnet.MSSP.VAR] 					= "VAR"

--- Contains textual representations of Telnet.environment values.
-- @class table
-- @name Telnet.environment.names
-- @field Telnet.environment.SEND "SEND"
-- @field Telnet.environment.IS "IS"
Telnet.environment.names							= {}
Telnet.environment.names[Telnet.environment.SEND]	= "SEND"
Telnet.environment.names[Telnet.environment.IS]		= "IS"

--- Allows for quick reference to Telnet.command.names values.
-- @param option The option to retrieve the name of.
-- @return Name of the option.
function Telnet.command.name(option)
	return Telnet.command.names[option] or string.format("(%s)", tostring(option))
end

--- Returns a string with every Telnet.command value in the given string, separated by commas.
-- @param option The string to be named.
-- @return Formatted string of all option names.
function Telnet.command.nameAll(option)
	local msg
	for i=1, string.len(option) do
		msg = string.format("%s%s%s", msg or "", msg and "," or "", Telnet.command.name(string.byte(option, i)))
	end

	return msg
end

--- Allows for quick reference to Telnet.protocol.names values.
-- @param option The option to retrieve the name of.
-- @return Name of the option.
function Telnet.protocol.name(option)
	return Telnet.protocol.names[option] or string.format("(%s)", tostring(option))
end

--- Returns a string with every Telnet.protocol value in the given string, separated by commas.
-- @param option The string to be named.
-- @return Formatted string of all option names.
function Telnet.protocol.nameAll(option)
	local msg
	for i=1, string.len(option) do
		msg = string.format("%s%s%s", msg or "", msg and "," or "", Telnet.protocol.name(string.byte(option, i)))
	end

	return msg
end

--- Allows for quick reference to Telnet.MSSP.names values.
-- @param option The option to retrieve the name of.
-- @return Name of the option.
function Telnet.MSSP.name(option)
	return Telnet.MSSP.names[option] or string.format("(%s)", tostring(option))
end

--- Returns a string with every Telnet.MSSP value in the given string, separated by commas.
-- @param option The string to be named.
-- @return Formatted string of all option names.
function Telnet.MSSP.nameAll(option)
	local msg
	for i=1, string.len(option) do
		msg = string.format("%s%s%s", msg or "", msg and "," or "", Telnet.MSSP.name(string.byte(option, i)))
	end

	return msg
end

--- Allows for quick reference to Telnet.environment.names values.
-- @param option The option to retrieve the name of.
-- @return Name of the option.
function Telnet.environment.name(option)
	return Telnet.environment.names[option] or string.format("(%s)", tostring(option))
end

--- Returns a string with every Telnet.environment value in the given string, separated by commas.
-- @param option The string to be named.
-- @return Formatted string of all option names.
function Telnet.environment.nameAll(option)
	local msg
	for i=1, string.len(option) do
		msg = string.format("%s%s%s", msg or "", msg and "," or "", Telnet.environment.name(string.byte(option, i)))
	end

	return msg
end

_G.Telnet = Telnet

return Telnet
