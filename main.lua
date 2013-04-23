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
module("main", package.seeall)

-- these are packages that should be ever-present and don't need reloading.
require("config") -- config is loaded separately, before everything else, and is not reloaded.
require("socket")
require("logging")
require("logging.file")
require("logging.console")

-- load zlib
print("MCCP?", config.MCCP2IsEnabled())
if config.MCCP2IsEnabled() then
	_G.zlib = require("zlib")
end

--- Loads all of the game packages.
function loadPackages()
	require("Nanny")
	require("Telnet")
	require("PlayerState")
	require("GameState")
	require("MessageMode")
	require("Direction")
	require("Game") -- make sure this is always loaded last.
end

--- Unloads all of the game packages.
function unloadPackages()
	-- unload globals
	_G.Game								= nil
	_G.Nanny							= nil
	_G.Telnet							= nil
	_G.PlayerState						= nil
	_G.GameState						= nil
	_G.MessageMode						= nil
	_G.Direction						= nil

	-- unload packages
	package.loaded["Game"]				= nil
	package.loaded["Nanny"]				= nil
	package.loaded["Telnet"]			= nil
	package.loaded["PlayerState"]		= nil
	package.loaded["GameState"]			= nil
	package.loaded["MessageMode"]		= nil
	package.loaded["Direction"]			= nil
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
local port = tonumber(... or nil)
local _, err = Game.openOnPort(port)
if not _ then
  Game.error("failed to open game: " .. err)
	os.exit(0)
end

-- primary game loop
while Game.isReady() do
	Game.update()
	socket.select(nil,nil,0.1)

	-- hotboot handled in game loop.
	if Game:getState() == GameState.HOTBOOT then
		Game.info("*** Hotbooting game...")

		-- disconnect players
		Game.info("*** Preserving old client sockets.")
		local clientSockets = Game.server:getClientSockets()
		for i,v in ipairs(Game.getPlayers()) do
			Game.info(string.format("*** Preserving %s for hotboot.", tostring(v)))
			v:sendLine("\n*** HOTBOOT ***\n") -- inform them of the hotboot
		end

		Game.info("*** Preserving old server socket.")
		local serverSocket = Game.server:getSocket()

		-- in the future, you should save player characters here as normal.
		-- it's impossible to preserve mobs here, as there is too much
		-- data we need to transfer, so instead save and reload the player
		-- character as normal.

		-- reload packages
		Game.info("*** Reloading packages")
		reloadPackages()
		-- Game no longer refers to the old Game from here on.
		-- A new Game has been loaded, along with a new everything else.

		-- recreate Server with new Server object
		local Server = require("obj.Server")
		local Client = require("obj.Client")

		-- reuse server socket
		Game.info("*** Recreating old Server out of preserved socket.")
		local server = Server:new(serverSocket)

		-- we don't create new players here, because we're lacking Game data.
		-- we want the Map to be loaded and all that good stuff before we 
		-- create the players.
		Game.info("*** Recreating old Clients and connecting them to recreated Server.")
		for i,v in ipairs(clientSockets) do
			server:connectClient(Client:new(v), true)
		end

		-- update the new Game's state (we're hotbooting)
		Game.info("*** Informing new Game of hotboot status.")
		Game.setState(GameState.HOTBOOT)

		-- reopen the Game on the new server
		Game.info("*** Opening Game with reconstituted Server.")
		Game.openOnServer(server)
	end
end

print("Game closed.")
