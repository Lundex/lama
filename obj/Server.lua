--- Cloneable that listens on a port and connects new Clients.
-- @author milkmanjack
module("obj.Server", package.seeall)

local socket	= require("socket")
local Cloneable	= require("obj.Cloneable")
local Client	= require("obj.Client")

--- Cloneable that listens on a port and connects new Clients.
-- @class table
-- @name Server
-- @field socket The socket associated with this Server.
local Server	= Cloneable.clone()

-- runtime data
Server.socket		= nil

--- Contains all of the Clients a Server is listening to.
-- @class table
-- @name Server.clients
Server.clients		= nil

--- Creates a unique clients table per Server.
function Server:initialize()
	self.clients = {}
end

--- Host the server.
-- @param port The port to host on.
-- @return true on success.<br/>false otherwise.
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

--- Close the Server.
-- @return true on success.<br/>false otherwise.
function Server:close()
	if not self:isHosted() then
		return false
	end

	self.socket:close()
	self.socket = nil
	return true
end

--- Attempt to accept a new Client.
-- @return true if a Client is accepted.<br/>false otherwise.
function Server:accept()
	if not self:isHosted() then
		return false
	end

	local socket, err = self.socket:accept()
	if not socket then
		return false, err
	end

	self:initializeClientSocket(socket)
	local client	= Client:new(socket)
	self:connectClient(client)

	return client
end

--- Start managing a Client.
-- @param client The Client to manage.
function Server:connectClient(client)
	table.insert(self.clients, client)
end

--- Stop managing a Client.
-- @param client The Client to stop managing.
function Server:disconnectClient(client)
	for i,v in ipairs(self.clients) do
		if v == client then
			table.remove(self.clients, i)
		end
	end

	client:getSocket():close()
end

--- Initialize the socket's settings for this Server.
-- By default, the Server socket is made to act asynchroniously,
-- with a 1/1000th second timeout for I/O operations.
-- @param socket The socket to initialize.
function Server:initializeServerSocket(socket)
	socket:settimeout(0.001)
end

--- Initialize the socket's settings for an incoming Client.
-- By default, the Client socket is made to act asynchroniously,
-- with a 1/1000th second timeout for I/O operations.
-- @param socket The socket to initialize.
function Server:initializeClientSocket(socket)
	socket:settimeout(0.001)
end

--- Check if the Server is hosted.
-- @return true if it is being hosted.<br/>false otherwise.
function Server:isHosted()
	return (self.socket ~= nil and self.socket:getsockname() ~= nil)
end

--- Return the Server's list of Clients.
-- @return The list of Clients.
function Server:getClients()
	return self.clients
end

return Server
