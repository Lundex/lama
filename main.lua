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

function unloadPackages()
	package.loaded["Game"] = nil
	_G.Game = nil
	package.loaded["Nanny"] = nil
	_G.Nanny = nil
	package.loaded["Telnet"] = nil
	_G.Telnet = nil
	package.loaded["PlayerState"] = nil
	_G.PlayerState = nil
	package.loaded["GameState"] = nil
	_G.GameState = nil
	package.loaded["MessageMode"] = nil
	_G.MessageMode = nil
	package.loaded["Direction"] = nil
	_G.Direction = nil
	package.loaded["obj.Client"] = nil
	package.loaded["obj.Cloneable"] = nil
	package.loaded["obj.CommandParser"] = nil
	package.loaded["obj.Event"] = nil
	package.loaded["obj.Map"] = nil
	package.loaded["obj.MapObject"] = nil
	package.loaded["obj.MapTile"] = nil
	package.loaded["obj.Mob"] = nil
	package.loaded["obj.Player"] = nil
	package.loaded["obj.Scheduler"] = nil
	package.loaded["obj.Server"] = nil
end

function reloadPackages()
	unloadPackages()
	loadPackages()
end

-- load all game packages
loadPackages()

-- open the game for play
local port = tonumber(... or nil) -- first command-line argument to main.lua will be the port to host on
local _, err = Game.open(port)
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
		Game.info("*** Preserve old client sockets")
		local clientSockets = {}
		for i,v in table.safeIPairs(Game.getPlayers()) do
			Game.disconnectPlayer(v, true)
			table.insert(clientSockets, v:getClient():getSocket()) -- store sockets for later
		end

		Game.info("*** Preserve old server socket")
		local serverSocket = Game.server:getSocket()

		-- reload packages
		Game.info("*** Reload packages")
		reloadPackages()

		-- recreate Server with new Server object
		local Server = require("obj.Server")
		local Client = require("obj.Client")
		local server = Server:new()
		server:setSocket(serverSocket)
		Game.info("*** Reconnect old clients to new server")
		for i,v in ipairs(clientSockets) do
			-- recreate Client with new Client object
			local client = Client:new(v)
			server:connectClient(client, true)
		end

		-- update the new Game's state (we're hotbooting)
		Game.info("*** Informing new Game of hotboot status.")
		Game.setState(GameState.HOTBOOT)

		-- reopen the Game on the given server
		Game.info("*** Opening Game with reconstituted Server")
		Game.open(nil, server)
	end
end

print("Game closed.")
