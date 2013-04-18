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

--- Entry point for the game.
-- @author milkmanjack
-- module("main", package.seeall)

--- Loads all of the game packages.
function loadPackages()
	require("Game")
	require("Nanny")
	require("Telnet")
	require("PlayerState")
	require("GameState")
	require("MessageMode")
	require("Direction")
	require("obj.Client")
	require("obj.Cloneable")
	require("obj.CommandParser")
	require("obj.Event")
	require("obj.Map")
	require("obj.MapObject")
	require("obj.MapTile")
	require("obj.Mob")
	require("obj.Player")
	require("obj.Scheduler")
	require("obj.Server")
end

--- Unloads all of the game packages.
function unloadPackages()
	package.loaded["Game"]				= nil
	package.loaded["Nanny"]				= nil
	package.loaded["Telnet"]			= nil
	package.loaded["PlayerState"]		= nil
	package.loaded["GameState"]			= nil
	package.loaded["MessageMode"]		= nil
	package.loaded["Direction"]			= nil
	_G.Game								= nil -- unload globals
	_G.Nanny							= nil
	_G.Telnet							= nil
	_G.PlayerState						= nil
	_G.GameState						= nil
	_G.MessageMode						= nil
	_G.Direction						= nil
	package.loaded["obj.Client"]		= nil
	package.loaded["obj.Cloneable"]		= nil
	package.loaded["obj.CommandParser"]	= nil
	package.loaded["obj.Event"]			= nil
	package.loaded["obj.Map"]			= nil
	package.loaded["obj.MapObject"]		= nil
	package.loaded["obj.MapTile"]		= nil
	package.loaded["obj.Mob"]			= nil
	package.loaded["obj.Player"]		= nil
	package.loaded["obj.Scheduler"]		= nil
	package.loaded["obj.Server"]		= nil
end

--- Reloads all of the game packages.
function reloadPackages()
	unloadPackages()
	loadPackages()
end

-- load all game packages to start with
loadPackages()

-- open the game for play
local port = tonumber(... or nil) -- first command-line argument to main.lua will be the port to host on
local _, err = Game.openOnPort(port)
if not _ then
  Game.error("failed to open game: " .. err)
	os.exit(0)
end

-- primary game loop
while Game.isReady() do
	Game.update() -- updates the game in increments.
	socket.select(nil,nil,0.1) -- 1/10th second delay between cycles

	-- hotboot handled in game loop.
	if Game:getState() == GameState.HOTBOOT then
		Game.info("*** Hotbooting game...")

		-- disconnect players
		Game.info("*** Preserving old client sockets")
		local clientSockets = Game.server:getClientSockets()
		for i,v in ipairs(Game.getPlayers()) do
			if v:getState() == PlayerState.PLAYING then
				Game.info(string.format("*** %s preserved for hotboot.", tostring(v), v:getMob():getName()))
			else
				Game.info(string.format("*** %s preserved for hotboot.", tostring(v)))
			end

			v:sendLine("\n*** HOTBOOT ***\n") -- inform them of the hotboot
		end

		Game.info("*** Preserving old server socket")
		local serverSocket = Game.server:getSocket()

		-- in the future, you should save player characters here as normal.
		-- it's impossible to preserve mobs here, as there is too much
		-- data we need to transfer, so instead to reload the player character
		-- as normal.

		-- reload packages
		Game.info("*** Reload packages")
		reloadPackages() -- once this calls, Game no longer refers to the old Game.
		-- a new Game is loaded, along with a new everything else.

		-- recreate Server with new Server object
		local Server = require("obj.Server")
		local Client = require("obj.Client")

		-- reuse server socket
		Game.info("*** Recreate old server out of preserved socket.")
		local server = Server:new(serverSocket)

		-- we don't create new players here, because we're lacking Game data.
		-- we want the Map to be loaded and all that good stuff before we 
		Game.info("*** Recreate old clients, connect them to server")
		for i,v in ipairs(clientSockets) do
			server:connectClient(Client:new(v), true)
		end

		-- update the new Game's state (we're hotbooting)
		Game.info("*** Informing new Game of hotboot status.")
		Game.setState(GameState.HOTBOOT)

		-- reopen the Game on the new server
		Game.info("*** Opening Game with reconstituted Server")
		Game.openOnServer(server)
	end
end

print("Game closed.")
