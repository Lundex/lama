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

local Cloneable		= require("obj.Cloneable")

--- Cloneable that manages user I/O.
-- @class table
-- @name Client
-- @field socket The socket associated with this Client.
local Client		= Cloneable.clone()

-- runtime data
Client.socket					= nil

--- Contains all telnet protocol options on the client.
-- @class table
-- @name Client.options
Client.options					= {}

--- Contains terminal type information.
-- @class table
-- @name Client.options.TTYPE
-- @field enabled Is TTYPE negotiation enabled?
-- @field type The type of terminal the client is using.

--- Associates a socket with the Client.
-- @param socket The socket to be associated.
function Client:initialize(socket)
	-- initialize TTYPE options
	self.options				= {}
	self.options.TTYPE			= {}
	self.options.TTYPE.enabled	= false
	self.options.TTYPE.type		= nil

	-- set sockets
	self:setSocket(socket)
	self:IACDo(Telnet.commands.TTYPE)
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
			current = current + 1
			self:getIACWill(option)

		elseif command == Telnet.commands.WONT then
			current = current + 1
			self:getIACWont(option)

		elseif command == Telnet.commands.DO then
			current = current + 1
			self:getIACDo(option)

		elseif command == Telnet.commands.DONT then
			current = current + 1
			self:getIACDont(option)

		elseif command == Telnet.commands.SB then
			-- check for subnegotiations that start with IAC SB and end with IAC SE
			local nextIACSE = string.find(partial, string.char(Telnet.commands.IAC, Telnet.commands.SE), current)
			if nextIACSE then
				self:getIACNegotiation(string.sub(partial, current, nextIACSE-1))
				current = nextIACSE+1
			end
		end

		partial = string.format("%s%s", string.sub(partial, 1, found-1), string.sub(partial, current+1))
		found = string.find(partial, string.char(Telnet.commands.IAC))
	end

	return result, err, partial
end

--- Send an IAC WILL message with the given option.
-- @param op Option to tell the client you will do.
function Client:IACWill(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.WILL, op))
end

--- Send an IAC WONT message with the given option.
-- @param op Option to tell the you won't do.
function Client:IACWont(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.WONT, op))
end

--- Send an IAC DO message with the given option.
-- @param op Option to tell the client you'll do.
function Client:IACDo(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.DO, op))
end

--- Send an IAC DONT message with the given option.
-- @param op Option to tell the client you won't do.
function Client:IACDont(op)
	self:send(string.char(Telnet.commands.IAC, Telnet.commands.DONT, op))
end

--- What to do when receiving an IAC WILL option.
-- @param op Option received.
function Client:onIACWill(op)
	if op == Telnet.commands.TTYPE then
		self.options.TTYPE.enabled = true
		self:send(string.char(Telnet.commands.IAC, Telnet.commands.SB, Telnet.commands.TTYPE, Telnet.commands.SEND, Telnet.commands.IAC, Telnet.commands.SE))
	end
end

--- What to do when receiving an IAC WONT option.
-- @param op Option received.
function Client:onIACWont()
end

--- What to do when receiving an IAC DO option.
-- @param op Option received.
function Client:onIACDo()
end

--- What to do when receiving an IAC DONT option.
-- @param op Option received.
function Client:onIACDont()
end

--- What to do when receiving an IAC SE negotiation.
-- @param negotiation The entirety of the negotiation message.
function Client:onIACNegotiation(negotiation)
	-- TTYPE IS <type>
	if string.find(negotiation, string.char(Telnet.commands.TTYPE, Telnet.commands.IS)) == 1 then
		local version = string.sub(negotiation, 3)
		self.options.TTYPE.version = version
		Game.info(string.format("%s terminal type: '%s'", tostring(self), version))
	end
end

--- Pipe to socket's send() function.
-- @return If successful, returns number of bytes written.<br/>In case of error, the method returns nil followed by an error message, followed by the number of bytes that were written before failure.
function Client:send(data, i, j)
	return self.socket:send(data, i, j)
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

function Client:getClientType()
	if self.options.TTYPE.enabled == true and self.options.TTYPE.type == nil then
		return "forthcoming..."
	end

	return self.options.TTYPE.type
end

--- Retreive the client's remote address.
-- @return The client's remote address.
function Client:getAddress()
	return self.socket:getpeername()
end

return Client
