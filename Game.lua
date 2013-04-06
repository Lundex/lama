--[[	Author:	Milkmanjack
		Date:	4/1/13
		Package that handles game processing.
]]

require("logging")
require("logging.file")
require("logging.console")
require("Nanny")
require("Telnet")
require("PlayerState")
require("GameState")
local Event			= require("obj.Event")
local Scheduler		= require("obj.Scheduler")
local Server		= require("obj.Server")
local Player		= require("obj.Player")
local Map			= require("obj.Map")
local Game			= {}

-- game data
Game.name			= "lama"
Game.version		= "0.0a"
Game.defaultPort	= 8000

-- runtime data
Game.state			= GameState.NEW
Game.scheduler		= nil
Game.server			= nil

Game.playerID		= 0
Game.players		= {}

Game.logger			= logging.console()
Game.logger:setLevel(logging.DEBUG)

Game.fileLogger		= logging.file("logs/%s.log", "%m%d%y")
Game.logger:setLevel(logging.DEBUG)

Game.commandLogger	= logging.file("logs/%s-commands.log", "%m%d%y")
Game.commandLogger:setLevel(logging.DEBUG)

Game.map			= nil

-- open the game for play
function Game.open(port)
	Game.info(string.format("Preparing to host game server on port %d...", port or Game.defaultPort))
	local server = Server:new()
	local _, err = server:host(port or Game.defaultPort)
	if not _ then
		return false, err
	end

	Game.server = server

	Game.info("Preparing scheduler...")
	Game.scheduler = Scheduler:new()
	Game.queue(Game.AcceptEvent:new(os.clock()))
	Game.queue(Game.PollEvent:new(os.clock()))
	Game.setState(GameState.READY)

	Game.info("Generating map...")
	Game.map = Map:new()
	Game.map:generate(100,100,1)

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
	Game.info("Shut down!")
end

--[[
	Update the game and poll the scheduler.
]]
function Game.update()
	Game.scheduler:poll(os.clock())
end

--[[
	Primary response to player connection.
	@param player	The player that has connected.
]]
function Game.connectPlayer(player)
	Game.onPlayerConnect(player)
	table.insert(Game.players, player)
end

--[[
	Secondary response to player connection.
	@param player	The player that has connected.
]]
function Game.onPlayerConnect(player)
	Game.info(string.format("Connected player %s!", tostring(player:getClient())))

	-- I'll streamline this later
	Nanny.greet(player)
end

--[[
	Primary response to player disconnection.
	@param player	The player that has disconnected.
]]
function Game.disconnectPlayer(player)
	table.removeValue(Game.players, player)
	Game.onPlayerDisconnect(player)
	Game.server:disconnectClient(player:getClient())
end

--[[
	Secondary response to disconnecting a player.
	@param player	The player that has idsconnected.
]]
function Game.onPlayerDisconnect(player)
	Game.info(string.format("Disconnected player %s!", tostring(player:getClient())))
	if player:getState() == PlayerState.PLAYING then
		Nanny.sendOff(player)
	end
end

--[[
	Response to player input.
	@param player	The player that has connected.
]]
function Game.onPlayerInput(player, input)
	Game.logCommand(player, input)

	-- for testing purposes (and convenience).
	if input == "quit" then
		Game.disconnectPlayer(player)
		return
	end

	-- in-between states
	if player:getState() ~= PlayerState.PLAYING then
		Nanny.process(player, input)
		return
	end

	-- talk and stuff
	Game.announce(string.format("%s: '%s'", tostring(player), input), PlayerState.PLAYING)
end

function Game.announce(message, minState)
	for i,v in ipairs(Game.getPlayers()) do
		if not minState or v:getState() >= minState then
			v:sendLine(message)
		end
	end
end

--[[
	Check if the game is ready to be played.
	@return true if the game's state is at GameState.READY.<br/>false otherwise.
]]
function Game.isReady()
	return Game.state == GameState.READY
end

--[[
	Set the game's state.
	@param state The state to be assigned.<br/>Valid states can be found in GameState.lua
]]
function Game.setState(state)
	Game.state = state
end

--[[
	Retreive the game's player list.
	@return List of players.
]]
function Game.getPlayers()
	return Game.players
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
	Get a unique player ID.
	@return A unique player ID.
]]
function Game.nextPlayerID()
	local id = Game.playerID
	Game.playerID = Game.playerID+1
	return id
end

-- shortcut for Game.scheduler:queue
function Game.queue(event)
	Game.scheduler:queue(event)
end

-- shortcut for Game.scheduler:deque
function Game.deque(event)
	Game.scheduler:deque(event)
end

-- logger shortcuts
function Game.log(level, message)
	Game.logger:log(level, message)
	Game.fileLogger:log(level, message)
end

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

function Game.logCommand(player, input)
	Game.commandLogger:info(tostring(player) .. ": '" .. input .. "'")
end
-- /logger shortcuts

--[[
	This event acts as the middle ground for client connections, accepting
	clients on behalf of the server, and informing the game about it.
]]
Game.AcceptEvent				= Event:clone()
Game.AcceptEvent.shouldRepeat	= true
Game.AcceptEvent.repeatMax		= 0
Game.AcceptEvent.repeatInterval	= 0.1

function Game.AcceptEvent:run()
	if not Game.isReady() or not Game.server:isHosted() then
		return
	end

	local client, err = Game.server:accept()
	if not client then
		return
	end

	local player = Player:new(client)
	Game.connectPlayer(player)
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
	if not Game.isReady() or not Game.server:isHosted() then
		return
	end

	if #Game.players < 1 then
		return
	end

	for i,v in table.safeIPairs(Game.players) do
		local client = v:getClient()
		local input, err, partial = client:receive("*a")
		if not input then
			if err == 'closed' then
				Game.disconnectPlayer(v)

			-- actual processing starts here because we're using the *a pattern for receive()
			-- this way we don't lose things like client negotiations
			-- though we don't support them right now anyway
			elseif partial ~= nil and string.len(partial) > 0 then
				local stripped = string.match(partial, "(.-)[\r?][\n?]")
				if stripped then
					Game.onPlayerInput(v, stripped)
				else
					Game.debug(string.format("bad input from %s: {%s}", tostring(v), partial))
				end
			end

		-- this is where we'd start normal processing if we used the socket's *l receive pattern.
		-- just here for posterity's sake right now.
		else
			Game.onPlayerInput(v, input)
		end
	end
end

-- assigns a global of the same name
-- this is so we only have to include it once.
_G.Game = Game

return Game
