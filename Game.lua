--[[	Author:	Milkmanjack
		Date:	4/1/13
		Singleton that handles game logic.
]]

local Event			= require("obj.Event")
local Scheduler		= require("obj.Scheduler")
local Server		= require("obj.Server")
local Game			= {}

-- game data
Game.name			= "lama"
Game.version		= "0.0a"
Game.defaultPort	= 8000

-- runtime data
Game.scheduler		= Scheduler:new()
Game.server			= Server:new()

-- begin hosting
function Game:host(port)
	local _, err = Game.server:host(port or Game.defaultPort)
	Game.scheduler:queue(Game.AcceptEvent:new(os.clock()))
	Game.scheduler:queue(Game.PollEvent:new(os.clock()))
end

-- stop hosting
function Game:close()
	Game.server:close()
	Game.scheduler:clear()
end

--[[
	Update the game and poll the scheduler.
]]
function Game:update()
	Game.scheduler:poll(os.clock())
end

function Game:onClientConnect(client)
	print(os.clock(), "connection", client:getSocket():getpeername())
end

function Game:onClientDisconnect(client)
	print(os.clock(), "disconnection", client:getSocket():getpeername())
end

function Game:onClientInput(client, input)
	print(os.clock(), "from", client:getSocket():getpeername(), "'" .. input .."'")
end

-- EVENTS
Game.AcceptEvent				= Event:clone()
Game.AcceptEvent.shouldRepeat	= true
Game.AcceptEvent.repeatMax		= 0
Game.AcceptEvent.repeatInterval	= 0.1
function Game.AcceptEvent:run()
	if not Game.server:isHosted() then
		return
	end

	local _, err = Game.server:accept()
	if not _ then
		return
	end

	Game:onClientConnect(_)
end

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
		local _, err, partial = v:receive("*l")
		if not _ then
			if err == 'closed' then
				Game.server:disconnectClient(v)
				Game:onClientDisconnect(v)
			end
		else
			Game:onClientInput(v, _)
		end
	end
end

return Game
