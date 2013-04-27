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
require("lfs")
require("lxp")
require("socket")
require("logging")
require("logging.file")
require("logging.console")

-- load zlib
print("MCCP2?", config.MCCP2IsEnabled())
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
	require("CharacterManager")
	require("Game") -- make sure this is always loaded last.
end

--- Unloads all of the game packages.<br/>
-- I can probably fix this up in the future so that obj.* packages are
-- removed automatically instead of having to go through all this.
function unloadPackages()
	-- unload globals
	_G.Game									= nil
	_G.Nanny								= nil
	_G.Telnet								= nil
	_G.PlayerState							= nil
	_G.GameState							= nil
	_G.MessageMode							= nil
	_G.Direction							= nil
	_G.CharacterManager						= nil

	-- unload packages
	package.loaded["Game"]					= nil
	package.loaded["Nanny"]					= nil
	package.loaded["Telnet"]				= nil
	package.loaded["PlayerState"]			= nil
	package.loaded["GameState"]				= nil
	package.loaded["MessageMode"]			= nil
	package.loaded["Direction"]				= nil
	package.loaded["CharacterManager"]		= nil

	-- unload obj.* packages
	for i,v in pairs(package.loaded) do
		if string.find(i, "obj.") == 1 then
			package.loaded[i] = nil
		end
	end
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
local _, err = Game.openOnPort(port or config.getDefaultPort())
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

		local playerID = Game.playerID

		-- disconnect and preserve players
		local preservedData = {}
		for i,v in ipairs(Game.getPlayers()) do
			-- kill players that are out of game
			if v:getState() ~= PlayerState.PLAYING then
				v:sendLine("\n*** HOTBOOT IN PROGRESS!!! ***\n*** COME BACK LATER! ***\n")
				Game.disconnectPlayer(v)

			-- preserve players that are in-game
			else
				local client, mob = v:getClient(), v:getMob()
				CharacterManager.saveCharacter(mob) -- save the mob

				-- compile this player's relevant data
				local data = {}
				data.id = v:getID()
				data.socket = client:getSocket()
				data.options = client.options
				data.name = mob:getName()
				table.insert(preservedData, data)

				-- let the player know what's up.
				Game.info(string.format("*** Preserved %s for hotboot.", tostring(v)))
				v:sendLine("\n*** HOTBOOT ***\n") -- inform them of the hotboot
			end
		end

		local serverSocket = Game.server:getSocket()

		-- reload packages
		reloadPackages()
		-- Game no longer refers to the old Game from here on.
		-- A new Game has been loaded, along with a new everything else.

		-- grab Server package, load old game data.
		local Server = require("obj.Server")
		Game.playerID = playerID

		-- re-run the game, recover from hotboot
		local server = Server:new(serverSocket)
		Game.setState(GameState.HOTBOOT)
		Game.openOnServer(server)
		Game.recoverFromHotboot(preservedData)
	end
end

print("Game closed.")
