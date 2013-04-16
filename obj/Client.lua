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

local socket		= require("socket")
local Cloneable		= require("obj.Cloneable")

--- Cloneable that manages user I/O.
-- @class table
-- @name Client
-- @field socket The socket associated with this Client.
local Client		= Cloneable.clone()

-- runtime data
Client.socket	= nil

--- Associates a socket with the Client.
-- @param socket The socket to be associated.
function Client:initialize(socket)
	self:setSocket(socket)
end

--- Returns the string-value of the Client.
-- @return A string in the format of <tt>"client@@&lt;client remote address&gt;"</tt>.
function Client:toString()
	if not self.socket then
		return "client@nil"
	end

	local addr, port = self:getAddress()
	return string.format("client@%s", addr or "unknown")
end

--- Pipe to socket's receive() function.
-- @return If successful, returns the received pattern.<br/>In case of error, the method returns nil followed by an error message.
function Client:receive(pattern, prefix)
	return self.socket:receive(pattern, prefix)
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

--- Retreive the client's remote address.
-- @return The client's remote address.
function Client:getAddress()
	return self.socket:getpeername()
end

return Client
