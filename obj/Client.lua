--[[	Author:	Milkmanjack
		Date:	4/1/13
		Client for handling user I/O.
]]

local socket		= require("socket")
local ClientState	= require("ClientState")
local Cloneable		= require("obj.Cloneable")
local Client		= Cloneable.clone()

-- runtime data
Client.state	= ClientState.NEW
Client.id		= nil -- ID for this client. generally on a per-server basis.
Client.socket	= nil

--[[
	Attaches a client socket to the client.
]]
function Client:initialize(socket, id)
	self.socket	= socket
	self.id		= id
end

--[[
	String identifier for clients.
]]
function Client:toString()
	if not self.socket then
		return string.format("{client#%d@nil}", self.id or -1)
	end

	local addr, port = self.socket:getpeername()
	return string.format("{client#%d@%s}", self.id or -1, addr)
end

--[[
	Pipe to socket's receive() function.
	@return If successful, returns the received pattern.<br/>In case of error, the method returns nil followed by an error message.
]]
function Client:receive(pattern, prefix)
	return self.socket:receive(pattern, prefix)
end

--[[
	Pipe to socket's send() function.
	@return If successful, returns number of bytes written.<br/>In case of error, the method returns nil followed by an error message, followed by the number of bytes that were written before failure.
]]
function Client:send(data, i, j)
	return self.socket:send(data, i, j)
end

function Client:sendString(str)
	str = string.gsub(str, "\n", "\r\n")
	self:send(str)
end

--[[
	Sends the given string to the client followed by a linebreak.
]]
function Client:sendLine(str)
	self:sendString(string.format("%s%s", str, "\r\n"))
end

--[[
	Close the client's socket.
]]
function Client:close()
	return self.socket:close()
end

--[[
	Set the client's state.
	@param state The state to be assigned.<br/>Valid states can be found in ClientState.lua
]]
function Client:setState(state)
	self.state = state
end

--[[
	Retreive the client's socket.
	@return The client's socket.</br>nil if no socket is attached.
]]
function Client:getSocket()
	return self.socket
end

--[[
	Retreive the client's state.
	@return The client's state.<br/>Valid states can be found in ClientState.lua
]]
function Client:getState()
	return self.state
end

--[[
	Retreive the client's remote address.
	@return The client's remote address.
]]
function Client:getAddress()
	return self.socket:getpeername()
end

return Client
