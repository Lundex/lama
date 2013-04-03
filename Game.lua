--[[	Author:	Milkmanjack
		Date:	4/1/13
		Singleton that handles game logic.
]]

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

-- open the game for play
function Game:open(port)
	local _, err = Game.server:host(port or Game.defaultPort)
	if not _ then
		return false, err
	end

	Game:queue(Game.AcceptEvent:new(os.clock()))
	Game:queue(Game.PollEvent:new(os.clock()))
	Game:setState(GameState.READY)
	return true
end

-- close the game for play
function Game:shutdown()
	for i,v in ipairs(self.server:getClients()) do
		v:sendLine("The game is now closed! Get over it!")
	end

	Game:setState(GameState.SHUTDOWN)
	Game.server:close()
	Game.scheduler:clear()
end

--[[
	Update the game and poll the scheduler.
]]
function Game:update()
	Game.scheduler:poll(os.clock())
end

-- shortcut for Game.scheduler:queue
function Game:queue(event)
	Game.scheduler:queue(event)
end

-- shortcut for Game.scheduler:deque
function Game:deque(event)
	Game.scheduler:deque(event)
end

function Game:onClientConnect(client)
	print("Connected client " .. tostring(client))
	for i,v in ipairs(self.server:getClients()) do
		v:sendLine(tostring(client) .. " has connected!")
	end
end

function Game:onClientDisconnect(client)
	print("Disconnected client " .. tostring(client))
	for i,v in ipairs(self.server:getClients()) do
		v:sendLine(tostring(client) .. " has left!")
	end
end

function Game:onClientInput(client, input)
	for i,v in ipairs(self.server:getClients()) do
		v:sendLine(tostring(client) .. ": " .. input)
	end
end

--[[
	Set the game's state.
	@param state The state to be assigned.<br/>Valid states can be found in GameState.lua
]]
function Game:setState(state)
	self.state = state
end

--[[
	Retreive the game's state.
	@return The game's state.<br/>Valid states can be found in GameState.lua
]]
function Game:getState()
	return self.state
end

--[[
	Check if the game is ready to be played.
	@return true if the game's state is at GameState.READY.<br/>false otherwise.
]]
function Game:isReady()
	return self.state == GameState.READY
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

	Game:onClientConnect(client)
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
				Game.server:disconnectClient(v)
				Game:onClientDisconnect(v)

			-- actual processing starts here because we're using the *a pattern for receive()
			-- this way we don't lose things like client negotiations
			-- though we don't support them right now anyway
			elseif partial ~= nil and string.len(partial) > 0 then
				local stripped = string.match(partial, "(.+)\n")
				if stripped then
					Game:onClientInput(v, stripped)
				else
					print("bad input from " .. tostring(v) .. ": " .. partial)
				end
			end

		-- this is where we'd start normal processing if we used the socket's *l receive pattern.
		-- just here for posterity's sake right now.
		else
			Game:onClientInput(v, input)
		end
	end
end

return Game
