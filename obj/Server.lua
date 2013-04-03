--[[	Author:	Milkmanjack
		Date:	4/1/13
		Server for listening for connections and processing I/O.
]]

local socket	= require("socket")
local Cloneable	= require("obj.Cloneable")
local Client	= require("obj.Client")
local Server	= Cloneable.clone()

-- runtime data
Server.clientID		= 0 -- ID for next client.
Server.socket		= nil
Server.clients		= nil

--[[
	Creates a unique clients table per Server.
]]
function Server:initialize()
	self.clients = {}
end

--[[
	Host the server.
	@param port	The port to host on.
	@return true on success.<br/>false otherwise.
]]
function Server:host(port)
	local socket = socket.tcp()

	-- bind it to the port
	_, err = socket:bind("*", port, 3)
	if not _ then
		return false, err
	end

	-- begin listening
	local _, err = socket:listen(3)
	if not _ then
		return false, err
	end

	self:initializeServerSocket(socket)
	self.socket = socket

	return true
end

--[[
	Close the server.
]]
function Server:close()
	if not self:isHosted() then
		return false
	end

	self.socket:close()
	self.socket = nil
	return true
end

--[[
	Attempt to accept a new client.
	@return true if a client is accepted.<br/>false otherwise.
]]
function Server:accept()
	if not self:isHosted() then
		return false
	end

	local socket, err = self.socket:accept()
	if not socket then
		return false, err
	end

	self:initializeClientSocket(socket)
	local id		= self.clientID
	self.clientID	= self.clientID + 1
	local client	= Client:new(socket, id)
	self:connectClient(client)

	return client
end

--[[
	Start managing a client.
	@param client	The client to manage.
]]
function Server:connectClient(client)
	table.insert(self.clients, client)
end

--[[
	Stop managing a client.
	@param client	The client to stop managing.
]]
function Server:disconnectClient(client)
	for i,v in table.safeIPairs(self.clients) do
		if v == client then
			table.remove(self.clients, i)
		end
	end
end

--[[
	Initialize the socket's settings for this server.
	@param socket The socket to initialize.
]]
function Server:initializeServerSocket(socket)
	socket:settimeout(0.001)
end

--[[
	Initialize the socket's settings for an incoming client.
	@param socket The socket to initialize.
]]
function Server:initializeClientSocket(socket)
	socket:settimeout(0.001)
end

--[[
	Check if the server is being hosted.
	@return true if it is being hosted.<br/>false otherwise.
]]
function Server:isHosted()
	return (self.socket ~= nil and self.socket:getsockname() ~= nil)
end

--[[
	Return the server's list of clients.
	@return the list of clients.
]]
function Server:getClients()
	return self.clients
end

return Server
