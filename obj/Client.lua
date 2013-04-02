--[[	Author:	Milkmanjack
		Date:	4/1/13
		Client for handling user I/O.
]]

local socket	= require("socket")
local Cloneable	= require("obj.Cloneable")
local Client	= Cloneable.clone()

-- runtime data
Client.socket	= nil

--[[
	Attaches a client socket to the client.
]]
function Client:initialize(socket)
	self.socket = socket
end

--[[
	Pipe to socket's receive() function.
	@return If successful, returns the received pattern.<br/>In case of error, the method returns nil followed by an error message.
]]
function Client:receive(pattern, prefix)
	return self.socket:receive(pattern, prefix)
end

--[[
	Close the client's socket.
]]
function Client:close()
	return self.socket:close()
end


--[[
	Retreive the client's socket.
	@return The client's socket.</br>nil if no socket is attached.
]]
function Client:getSocket()
	return self.socket
end

return Client
