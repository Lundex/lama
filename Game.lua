--[[	Author:	Milkmanjack
		Date:	4/1/13
		Singleton that handles game logic.
]]

require("logging")
require("logging.file")
require("logging.console")
local Event			= require("obj.Event")
local Scheduler		= require("obj.Scheduler")
local Server		= require("obj.Server")
local GameState		= require("GameState")
local Game			= {}

-- game data
Game.name			= "lama"
Game.version		= "0.0a"
Game.defaultPort	= 8000

-- runtime data
Game.state			= GameState.NEW
Game.scheduler		= Scheduler:new()
Game.server			= Server:new()

Game.logger			= logging.console()
Game.logger:setLevel(logging.DEBUG)

Game.fileLogger		= logging.file("logs/%s.log", "%m%d%y")
Game.logger:setLevel(logging.DEBUG)

Game.commandLogger	= logging.file("logs/%s-commands.log", "%m%d%y")
Game.commandLogger:setLevel(logging.DEBUG)

-- open the game for play
function Game.open(port)
	Game.info("Preparing to host server on port " .. (port or Game.defaultPort) .. "...")
	local _, err = Game.server:host(port or Game.defaultPort)
	if not _ then
		return false, err
	end

	Game.info("Preparing necessary scheduler events...")
	Game.queue(Game.AcceptEvent:new(os.clock()))
	Game.queue(Game.PollEvent:new(os.clock()))
	Game.setState(GameState.READY)
	Game.info("Game is ready for business...")
	return true
end

-- close the game for play
function Game.shutdown()
	Game.info("Shutting down game...")
	for i,v in ipairs(Game.server:getClients()) do
		v:sendLine("The game is now closed! Get over it!")
	end

	Game.setState(GameState.SHUTDOWN)
	Game.server:close()
	Game.scheduler:clear()
	Game.info("Game has been shut down!")
end

--[[
	Update the game and poll the scheduler.
]]
function Game.update()
	Game.scheduler:poll(os.clock())
end

-- shortcut for Game.scheduler:queue
function Game.queue(event)
	Game.scheduler:queue(event)
end

-- shortcut for Game.scheduler:deque
function Game.deque(event)
	Game.scheduler:deque(event)
end

function Game.log(level, message)
	Game.logger:log(level, message)
	Game.fileLogger:log(level, message)
end

-- logger shortcuts
function Game.debug(message)
	Game.logger:debug(message)
	Game.fileLogger:debug(message)
end

function Game.info(message)
	Game.logger:info(message)
	Game.fileLogger:info(message)
end

function Game.warn(message)
	Game.logger:warn(message)
	Game.fileLogger:warn(message)
end

function Game.error(message)
	Game.logger:error(message)
	Game.fileLogger:error(message)
end

function Game.fatal(message)
	Game.logger:fatal(message)
	game.fileLogger:fatal(message)
end

function Game.logCommand(client, input)
	Game.commandLogger:info(tostring(client) .. ": '" .. input .. "'")
end
-- /logger shortcuts

--[[
	Response to connecting a client.
	@param client	The client that has connected.
]]
function Game.onClientConnect(client)
	Game.info("Connected client " .. tostring(client))
	client:sendLine("Welcome to " .. Game.getName() .. " v" .. Game.getVersion() .."!")
	for i,v in ipairs(Game.server:getClients()) do
		if v ~= client then
			v:sendLine(tostring(client) .. " has connected!")
		end
	end
end

--[[
	Response to disconnecting a client.
	@param client	The client that has idsconnected.
]]
function Game.onClientDisconnect(client)
	Game.info("Disconnected client " .. tostring(client))
	client:sendLine("Goodbye!")
	for i,v in ipairs(Game.server:getClients()) do
		if v ~= client then
			v:sendLine(tostring(client) .. " has left!")
		end
	end
end

--[[
	Response to client input.
	@param client	The client that has connected.
]]
function Game.onClientInput(client, input)
	Game.logCommand(client, input)
	if input == "quit" then
		Game.onClientDisconnect(client)
		Game.server:disconnectClient(client)
		return
	end

	for i,v in ipairs(Game.server:getClients()) do
		v:sendLine(tostring(client) .. ": " .. input)
	end
end

--[[
	Set the game's state.
	@param state The state to be assigned.<br/>Valid states can be found in GameState.lua
]]
function Game.setState(state)
	Game.state = state
end

--[[
	Retreive the game's name.
	@return The name of the game.
]]
function Game.getName()
	return Game.name
end

--[[
	Retreive the game's version.
	@return The version of the game.
]]
function Game.getVersion()
	return Game.version
end

--[[
	Retreive the game's state.
	@return The game's state.<br/>Valid states can be found in GameState.lua
]]
function Game.getState()
	return Game.state
end

--[[
	Check if the game is ready to be played.
	@return true if the game's state is at GameState.READY.<br/>false otherwise.
]]
function Game.isReady()
	return Game.state == GameState.READY
end

--[[
	This event acts as the middle ground for client connections, accepting
	clients on behalf of the server, and informing the game about it.
]]
Game.AcceptEvent				= Event:clone()
Game.AcceptEvent.shouldRepeat	= true
Game.AcceptEvent.repeatMax		= 0
Game.AcceptEvent.repeatInterval	= 0.1

function Game.AcceptEvent:run()
	if not Game.server:isHosted() then
		return
	end

	local client, err = Game.server:accept()
	if not client then
		return
	end

	Game.onClientConnect(client)
end


--[[
	This event acts as the middle ground for client input, polling clients
	from the server for input and informing the game about it.

	Also is the starting point for destroying clients that have disconnected
	and cannot be reached.
]]
Game.PollEvent					= Event:clone()
Game.PollEvent.shouldRepeat		= true
Game.PollEvent.repeatMax		= 0
Game.PollEvent.repeatInterval	= 0.1

function Game.PollEvent:run()
	if not Game.server:isHosted() then
		return
	end

	if #Game.server:getClients() < 1 then
		return
	end

	for i,v in table.safeIPairs(Game.server:getClients()) do
		local input, err, partial = v:receive("*a")
		if not input then
			if err == 'closed' then
				Game.onClientDisconnect(v)
				Game.server:disconnectClient(v)

			-- actual processing starts here because we're using the *a pattern for receive()
			-- this way we don't lose things like client negotiations
			-- though we don't support them right now anyway
			elseif partial ~= nil and string.len(partial) > 0 then
				local stripped = string.match(partial, "(.+)[\r?][\n?]")
				if stripped then
					Game.onClientInput(v, stripped)
				else
					Game.debug("bad input from " .. tostring(v) .. ": " .. partial)
				end
			end

		-- this is where we'd start normal processing if we used the socket's *l receive pattern.
		-- just here for posterity's sake right now.
		else
			Game.onClientInput(v, input)
		end
	end
end

return Game
