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

--- Singleton that provides the necessary operations for running the game.
-- @author milkmanjack
module("Game", package.seeall)

require("logging")
require("logging.file")
require("logging.console")
require("Nanny")
require("Telnet")
require("PlayerState")
require("GameState")
require("MessageMode")
require("Direction")
local Event			= require("obj.Event")
local Scheduler		= require("obj.Scheduler")
local Server		= require("obj.Server")
local Player		= require("obj.Player")
local Mob			= require("obj.Mob")
local Map			= require("obj.Map")
local CommandParser	= require("obj.CommandParser")

--- Singleton that provides the necessary operations for running the game.
-- @class table
-- @name Game
-- @field name The name we would like to be called.
-- @field version The version of this release.
-- @field defaultPort The port we'll use if one isn't provided.
-- @field state Our state. Always a member of the GameState table.
-- @field playerID Unique ID to be assigned to the next new Player.
-- @field server Server we're using.
-- @field scheduler Scheduler we're using.
-- @field parser CommandParser we're using.
-- @field map The Map we'll be using.
-- @field logger Logger that prints to the standard output.
-- @field fileLogger Logger that prints to the standard log file for this session.
-- @field commandLogger Logger that prints all command input to the standard command log file for this session.
local Game			= {}

-- game data
Game.name			= "lama"
Game.version		= "0.5a"
Game.defaultPort	= 8000

-- runtime data
Game.state			= GameState.NEW

Game.playerID		= 0
--- Contains all Players connected to the game.
-- @class table
-- @name Game.players
Game.players		= {}

Game.server			= nil
Game.scheduler		= nil
Game.map			= nil
Game.parser			= nil

Game.logger			= logging.console()
Game.fileLogger		= logging.file("log/%s.log", "%m%d%y")
Game.commandLogger	= logging.file("log/%s-commands.log", "%m%d%y")

-- log everything!
Game.fileLogger:setLevel(logging.DEBUG)
Game.commandLogger:setLevel(logging.DEBUG)

--- Open the game for play on the given port.
-- @param port The port to be hosted on. Defaults to Game.defaultPort{@link Game.defaultPort}.
-- @return true on success.<br/>false followed by an error otherwise.
function Game.openOnPort(port)
	port = port or Game.defaultPort
	Game.info(string.format("Preparing to host game server on port %d...", port))
	Game.server = Server:new()
	local _, err = Game.server:host(port)
	if not _ then
		return false, err
	end

	Game.onOpen()
	return true
end

--- Open the game for play on the given server.
-- @param server Server to be used by the Game as opposed to setting up a new one. Used when hotbooting.
-- @return true on success.<br/>false followed by an error otherwise.
function Game.openOnServer(server)
	Game.info("Preparing to host game on existing server.")
	Game.server = server
	Game.onOpen()
	return true
end

-- Specifies further action after opening the game.
function Game.onOpen()
	-- load the scheduler
	if not Game.scheduler then
		Game.scheduler = Scheduler:new()
		Game.info("Preparing scheduler...")
		Game.queue(Game.AcceptEvent:new(os.clock()))
		Game.queue(Game.PollEvent:new(os.clock()))
	end

	-- load the map
	if not Game.map then
		Game.map = Map:new()
		Game.info("Generating map...")
		Game.map:generate(100,100,1)
	end

	-- load the parser
	if not Game.parser then
		Game.parser = CommandParser:new()
	end

	-- finalize hotboot
	if Game.state == GameState.HOTBOOT then
		Game.onHotboot()
	end

	Game.setState(GameState.READY)
	Game.info("Game is ready for business...")
end

--- Shutdown the game.
-- @return true on success.<br/>false followed by an error otherwise.
function Game.shutdown()
	if not Game.isReady() then
		return false, "Game not running"
	end

	Game.info("Shutting down game...")
	for i,v in table.safeIPairs(Game:getPlayers()) do
		self:disconnectPlayer(v)
	end

	Game.setState(GameState.SHUTDOWN)
	Game.server:close()

	Game.info("Game is shutdown!")
	return true
end

--- Hotboot the game.
-- The Game and all of the pertinent data will be recycled during a hotboot, so don't worry too much.
-- The main focus is on preserving the server socket, client sockets, and player mobs.
-- @return true on success.<br/>false followed by an error otherwise.
function Game.hotboot()
	Game.info("*** Preparing for hotboot...")
	Game.setState(GameState.HOTBOOT)
	return true
end

--- Specifies further action for a hotboot.
-- By the time this calls, the server has been reestablished and
-- clients have been reconnected to the server, but no players have
-- been reconstituted yet. As such, we need to create players and
-- reload their mobs.
-- @return true on success.<br/>false followed by an error otherwise.
function Game.onHotboot()
	Game.info("Reconnecting old players...")
	for i,v in ipairs(Game.server:getClients()) do
		local player = Player:new(v)
		player:setID(Game.nextPlayerID())
		Game.connectPlayer(player, true)

		-- creates a new mob for the player, for now.
		-- future implementations should probably load the saved
		-- version of the player's character.
		local mob = Mob:new()
		mob:moveToMap(Game.map)
		mob:setXYZLoc(1,1,1)
		player:setMob(mob)
	end
end

--- Updates the game as necessary. Things like updating the scheduler and such.
function Game.update()
	Game.scheduler:poll(os.clock())
end

--- Connects a Player.<br/>
-- Calls Game.onPlayerConnect(player) before adding to players list.
-- @param player The Player to be connected.
-- @param hotboot If true, player is reconnecting after hotboot.
function Game.connectPlayer(player, hotboot)
	Game.onPlayerConnect(player, hotboot)
	table.insert(Game.players, player)
end

--- Specifies further actions for a connecting Player.
-- @param player The Player connecting.
-- @param hotboot If true, player is reconnecting after hotboot.
function Game.onPlayerConnect(player, hotboot)
	if hotboot then
		Game.info(string.format("*** Reconnecting %s after hotboot.", tostring(player)))
	else
		Game.info(string.format("Connected %s!", tostring(player:getClient())))
	end

	Nanny.greet(player, hotboot)
end

--- Disconnect a Player.<br/>
-- Calls Game.onPlayerDisconnect(player) before removing from players list or destroying client.
-- @param player The Player to be disconnected.
function Game.disconnectPlayer(player)
	Game.onPlayerDisconnect(player) -- disconnect the player
	table.removeValue(Game.players, player) -- remove from players list (no longer recognized as a player)

	-- if they're not playing yet, then disconnect them.
	-- otherwise, only disconnect if it's not a hotboot.
	if player:getState() ~= PlayerState.PLAYING then
		Game.server:disconnectClient(player:getClient()) -- kill the client
	end
end

--- Specifies further actions for a disconnecting Player.
-- @param player The Player disconnecting.
function Game.onPlayerDisconnect(player)
	Game.info(string.format("Disconnected %s!", tostring(player)))

	if player:getState() == PlayerState.PLAYING then
		Nanny.logout(player)
	end
end


--- Determine what to do with input given by a Player.
-- @param player The Player providing the input.
-- @param input The input to be processed.
function Game.onPlayerInput(player, input)
	Game.logCommand(player, input)

	-- this assumes that there will be echoing at some stage
	-- in the future, only do this if we know there will be echoing
	player:clearMessageMode()

	-- in-between states
	if player:getState() ~= PlayerState.PLAYING then
		Nanny.process(player, input)
		return
	end

	-- command parsing for in-game players
	Game.parser:parse(player, player:getMob(), input)
end

--- Set the Game's state.
-- @param state The state to be assigned.<br/>Must be a valid member of GameState.
function Game.setState(state)
	Game.state = state
end

--- Announce something to connecting Players.<br/>
-- This is mostly temporary, but I'm leaving it in now for testing purposes.<br/>
-- More reasonable implementation later.
-- @param message The message to be announced.
-- @param mode The mode of the message.<br/>Must be a valid member of MessageMode.
-- @param minState The state a Player must be at to see the message (or "higher").
function Game.announce(message, mode, minState)
	for i,v in ipairs(Game.getPlayers()) do
		if not minState or v:getState() >= minState then
			v:sendMessage(message, mode)
		end
	end
end

--- Check if the Game is ready to be played.
-- return true if the game's state is at GameState.READY.<br/>false otherwise.
function Game.isReady()
	return Game.state == GameState.READY
end

--- Retreive the Game's name.
-- @return The name of the Game.
function Game.getName()
	return Game.name
end

--- Retreive the Game's version.
-- @return The version of the Game.
function Game.getVersion()
	return Game.version
end

--- Retreive the Game's state.
-- @return The Game's state.<br/>Must be a valid member of GameState.
function Game.getState()
	return Game.state
end

--- Get a unique player ID.
-- @return A unique player ID.
function Game.nextPlayerID()
	local id = Game.playerID
	Game.playerID = Game.playerID+1
	return id
end


--- Retreive the Game's players list.
-- @return Player list.
function Game.getPlayers()
	return Game.players
end

--- Shortcut for Game.scheduler:queue(event)
-- @param event Event to queue.
function Game.queue(event)
	Game.scheduler:queue(event)
end

--- Shortcut for Game.scheduler:deque(event)
-- @param event Event to deque.
function Game.deque(event)
	Game.scheduler:deque(event)
end

--- Shortcut to Game.logger:log(level,message)
-- @param level Level of this log.
-- @param message Message to be logged.
function Game.log(level, message)
	Game.logger:log(level, message)
	Game.fileLogger:log(level, message)
end

--- Shortcut to Game.logger:debug(message)
-- @param message Message to be logged as debug.
function Game.debug(message)
	Game.logger:debug(message)
	Game.fileLogger:debug(message)
end

--- Shortcut to Game.logger:info(message)
-- @param message Message to be logged as info.
function Game.info(message)
	Game.logger:info(message)
	Game.fileLogger:info(message)
end

--- Shortcut to Game.logger:warn(message)
-- @param message Message to be logged as warn.
function Game.warn(message)
	Game.logger:warn(message)
	Game.fileLogger:warn(message)
end

--- Shortcut to Game.logger:error(message)
-- @param message Message to be logged as error.
function Game.error(message)
	Game.logger:error(message)
	Game.fileLogger:error(message)
end

--- Shortcut to Game.logger:fatal(message)
-- @param message Message to be logged as fatal.
function Game.fatal(message)
	Game.logger:fatal(message)
	game.fileLogger:fatal(message)
end

--- Logs Player input.
-- @param player The Player giving input.
-- @param input The input the Player gave.
function Game.logCommand(player, input)
	Game.commandLogger:info(tostring(player) .. ": '" .. input .. "'")
end

--- This Event acts as the middle ground for client connections, accepting clients on behalf of the server, and informing the game about it.<br/>
-- Game.PollEvent and Game.AcceptEvent are mandatory events that must be part of the Game scheduler.
-- @class table
-- @name Game.AcceptEvent
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


--- This Event acts as the middle ground for client input, polling clients from the server for input and informing the game about it.<br/>
-- Also the starting point for destroying clients that have disconnected and cannot be reached.<br/>
-- Game.PollEvent and Game.AcceptEvent are mandatory events that must be part of the Game scheduler.
-- @class table
-- @name Game.PollEvent
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
				-- this is essentially an iterator that'll traverse an entire
				-- input string if it spans multiple lines, sending each one to
				-- Game.onPlayerInput().
				-- it's kinda tacky.
				local multiple = string.gmatch(partial, "(.-)[\r?][\n?]")
				local first = multiple()
				if first then
					Game.onPlayerInput(v, first)
					for cmd in multiple do
						Game.onPlayerInput(v, cmd)
					end
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

_G.Game = Game

return Game
