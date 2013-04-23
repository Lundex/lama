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

--- Cloneable that manages user I/O.
-- @author milkmanjack
module("obj.Client", package.seeall)

local zlib							= require("zlib")
local Cloneable						= require("obj.Cloneable")

--- Cloneable that manages user I/O.
-- @class table
-- @name Client
-- @field socket The socket associated with this Client.
local Client						= Cloneable.clone()

-- runtime data
Client.socket						= nil

--- Contains all telnet protocol options on the client.
-- @class table
-- @name Client.options
Client.options						= nil

--- Contains currently flagged protocols that the Client wants to negotiate.
-- @class table
-- @name Client.options.WILL
--Client.options.WILL				= nil

--- Contains currently flagged protocols that the Client doesn't want to negotiate.
-- @class table
-- @name Client.options.WONT
--Client.options.WONT				= nil

--- Contains currently flagged options that the Client wants the Server to negotiate.
-- @class table
-- @name Client.options.DO
--Client.options.DO					= nil

--- Contains currently flagged options that the Client doesn't want the Server to negotiate.
-- @class table
-- @name Client.options.DONT
--Client.options.DONT				= nil

--- Contains terminal type information.
-- @class table
-- @name Client.options.TTYPE
-- @field type The type of terminal the client is using.
--Client.options.TTYPE				= nil

--- Contains MCCP2 zlib streams.
-- @class table
-- @name Client.options.MCCP2
-- @field inflater The zlib inflate input stream.
-- @field deflater The zlib deflate output stream.
-- @field deflateBuffer The buffer deflated output is stored in before being sent.

--- Associates a socket with the Client.
-- @param socket The socket to be associated.
function Client:initialize(socket)
	-- initialize options
	self.options						= {}
	self.options.WILL					= {}
	self.options.WONT					= {}
	self.options.DO						= {}
	self.options.DONT					= {}
	self.options.TTYPE					= {}
	self.options.TTYPE.type				= nil
	self.options.MCCP2					= {}
	self.options.MCCP2.inflater			= nil
	self.options.MCCP2.defelater		= nil
	self.options.MCCP2.deflateBuffer	= nil

	-- set sockets
	self:setSocket(socket)
	self:sendWill(Telnet.commands.MCCP2)
	self:sendDo(Telnet.commands.TTYPE)
	self:sendWill(Telnet.commands.MSSP)
end

--- Returns the string-value of the Client.
-- @return A string in the format of <tt>"client@&lt;client remote address&gt;"</tt>.
function Client:toString()
	if not self.socket then
		return "client@nil"
	end

	local addr, port = self:getAddress()
	return string.format("client@%s", addr or "unknown")
end

--- Pipe to socket's receive() function.
-- Telnet protocol processing is handled before values are returned.
-- @return If successful, returns the received pattern.<br/>In case of error, the method returns nil followed by an error message.
function Client:receive(pattern, prefix)
	local result, err, partial = self.socket:receive(pattern, prefix)

	-- parse IAC messages at the client level before passing off to whoever wants to know
	local found = string.find(partial, string.char(Telnet.commands.IAC))
	while found ~= nil do
		local command = string.byte(partial, found+1)
		local option = string.byte(partial, found+2)
		local current = found+2
		if command == Telnet.commands.WILL then
			self:onWill(option)

		elseif command == Telnet.commands.WONT then
			self:onWont(option)

		elseif command == Telnet.commands.DO then
			self:onDo(option)

		elseif command == Telnet.commands.DONT then
			self:onDont(option)

		elseif command == Telnet.commands.SB then
			-- check for subnegotiations that start with IAC SB and end with IAC SE
			local nextIACSE = string.find(partial, string.char(Telnet.commands.IAC, Telnet.commands.SE), current)
			if nextIACSE then
				self:onSubnegotiation(string.sub(partial, current, nextIACSE-1))
				current = nextIACSE+1
			end
		end

		-- string.format terminates on null char when displaying, which happens to be used in
		-- TTYPE negotiation (Telnet.commands.IS == 0 == null terminator).
		-- as such, use pure concatenation.
		partial = string.sub(partial, 1, found-1) .. string.sub(partial, current+1) -- strip IAC message from input
		found = string.find(partial, string.char(Telnet.commands.IAC))
	end
	return result, err, partial
end

--- Send an IAC WILL message with the given option.
-- @param op Option the Server supports and wants the Client to negotiate.
function Client:sendWill(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.WILL, op))
end

--- Send an IAC WONT message with the given option.
-- @param op Option the Server doesn't support and wants the Client not to negotiate.
function Client:sendWont(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.WONT, op))
end

--- Send an IAC DO message with the given option.
-- @param op Option the Server wants the Client to negotiate.
function Client:sendDo(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.DO, op))
end

--- Send an IAC DONT message with the given option.
-- @param op Option the Server doesn't wnat the Client to negotiate.
function Client:sendDont(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.DONT, op))
end

--- What to do when receiving an IAC WILL option.
-- @param op Option the Client wants to negotiate.
function Client:onWill(op)
	self.options.WILL[op] = true
	self.options.WONT[op] = false

	-- if they will negotiate terminal type, ask for it right away
	if op == Telnet.commands.TTYPE then
		self.options.TTYPE.enabled = true
		self:send(string.char(Telnet.commands.IAC, Telnet.commands.SB, Telnet.commands.TTYPE, Telnet.commands.SEND, Telnet.commands.IAC, Telnet.commands.SE))
	end
end

--- What to do when receiving an IAC WONT option.
-- @param op Option the Client doesn't want to negotiate.
function Client:onWont(op)
	self.options.WONT[op] = true
	self.options.WILL[op] = false
end

--- What to do when receiving an IAC DO option.
-- @param op Option the Client wants the Server to negotiate.
function Client:onDo(op)
	-- process before setting DO
	if op == Telnet.commands.MCCP2 then
		self:send(string.char(Telnet.commands.IAC, Telnet.commands.SB, Telnet.commands.MCCP2, Telnet.commands.IAC, Telnet.commands.SE))

		-- all output from now on is deflated!
		self.options.MCCP2.deflateBuffer = {}
		self.options.MCCP2.deflater = zlib.deflate(function(data) table.insert(self.options.MCCP2.deflateBuffer, data) end)
	end

	self.options.DO[op] = true
	self.options.DONT[op] = false

	-- start doing MSSP negotiations
	if op == Telnet.commands.MSSP then
		self:MSSP(Telnet.commands.MSSP_VAR, "NAME", Telnet.commands.MSSP_VAL, "lama v0.6a-1", Telnet.commands.MSSP_VAR, "UPTIME", Telnet.commands.MSSP_VAL, os.time())
	end
end

--- What to do when receiving an IAC DONT option.
-- @param op Option the Client doesn't want the Server to negotiate.
function Client:onDont(op)
	self.options.DO[op] = false
	self.options.DONT[op] = true
end

--- What to do when receiving an IAC SE subnegotiation.
-- @param negotiation The entirety of the subnegotiation message.
function Client:onSubnegotiation(negotiation)
	-- TTYPE IS <type>
	if string.find(negotiation, string.char(Telnet.commands.TTYPE, Telnet.commands.IS)) == 1 then
		local type = string.sub(negotiation, 3)
		self.options.TTYPE.type = type
		Game.info(string.format("%s terminal type: '%s'", tostring(self), type))
	end
end

--- Check if we will negotiate the given option.
-- @return true if option is currently negotiated.<br/>false otherwise.
function Client:getWill(op)
	return self.options.WILL[op] == true
end

--- Check if we will not negotiate the given option.
-- @return true if option is currently not negotiated.<br/>false otherwise.
function Client:getWont(op)
	return self.options.WONT[op] == true
end

--- Check if the client expects us to negotiate this option.
-- @return true if option is currently negotiated.<br/>false otherwise.
function Client:getDo(op)
	return self.options.DO[op] == true
end

--- Check if the client expects us not to negotiate this option.
-- @return true if option is currently not negotiated.<br/>false otherwise.
function Client:getDont(op)
	return self.options.DONT[op] == true
end

-- send an MSSP negotiation.
function Client:MSSP(...)
	local packed = {...}
	local formatted = string.char(Telnet.commands.IAC, Telnet.commands.SB, Telnet.commands.MSSP)
	for i=1, #packed, 2 do
		local op = packed[i]
		local val = packed[i+1]
		formatted = string.format("%s%s%s", formatted, string.char(op), val)
	end

	formatted = string.format("%s%s", formatted, string.char(Telnet.commands.IAC, Telnet.commands.SE))

	self:send(formatted)
end

--- Pipe to socket's send() function.
-- @return If successful, returns number of bytes written.<br/>In case of error, the method returns nil followed by an error message, followed by the number of bytes that were written before failure.
function Client:send(data, i, j)
	if self:getDo(Telnet.commands.MCCP2) then
		-- write data to the deflate buffer
		self.options.MCCP.deflater:write(data)
		self.options.MCCP.deflater:flush()
		local compressed = table.concat(self.options.MCCP.deflateBuffer) -- get the string
		Game.debug(string.format("MCCP2 compression savings: %d", string.len(data)-string.len(compressed)))
		self.options.MCCP.deflateBuffer = {} -- prepare next buffer
		return self.socket:send(compressed,i,j)
	else
		return self.socket:send(data, i, j)
	end
end

--- Formats a string before sending it to the client.
-- @param str String to be sent.
-- @return result of self:send().
function Client:sendString(str)
	str = string.gsub(str or "", "\n", "\r\n")
	return self:send(str)
end

--- Sends the given string to the client followed by a linebreak.
-- @param str String to be sent.
-- @return result of self:sendString()
function Client:sendLine(str)
	self:sendString(string.format("%s%s", str or "", "\r\n"))
end

--- Close the client's socket.
function Client:close()
	return self.socket:close()
end

--- Manually assign socket.
-- @param socket Socket to assign.
function Client:setSocket(socket)
	self.socket = socket
end

--- Retreive the client's socket.
-- @return The Client's socket.</br>nil if no socket is attached.
function Client:getSocket()
	return self.socket
end

--- Retreive the client's remote address.
-- @return The client's remote address.
function Client:getAddress()
	return self.socket:getpeername()
end

--- Retreive the client's terminal type, if applicable.
-- @return A string representing the type of terminal.
function Client:getTerminalType()
	if not self:getWill(Telnet.commands.TTYPE) then
		return "TTYPE not supported"
	end

	return self.options.TTYPE.type or "waiting..."
end

return Client
