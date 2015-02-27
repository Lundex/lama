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

--- Package loader functions.
-- @author milkmanjack

--- Loads all of the game packages.<br/>
-- This only loads the singletons, as they provide the functionality for
-- the rest of the game, and therefore will load the packages as needed.
function loadPackages()
	require("global.Nanny")
	require("global.Telnet")
	require("global.PlayerState")
	require("global.GameState")
	require("global.MessageMode")
	require("global.Direction")
	require("global.Color")
	require("global.Attribute")
	require("global.DatabaseManager")
	require("global.Game") -- make sure this is always loaded last.
	-- the Game package requires other packages that require the
	-- other singletons, so always load it last.
end

--- Unloads all of the game packages.
function unloadPackages()
	-- unload globals
	_G.Game										= nil
	_G.Nanny									= nil
	_G.Telnet									= nil
	_G.PlayerState								= nil
	_G.GameState								= nil
	_G.MessageMode								= nil
	_G.Direction								= nil
	_G.Color									= nil
	_G.Attribute								= nil
	_G.DatabaseManager							= nil

	-- unload packages
	package.loaded["global.Game"]				= nil
	package.loaded["global.Nanny"]				= nil
	package.loaded["global.Telnet"]				= nil
	package.loaded["global.PlayerState"]		= nil
	package.loaded["global.GameState"]			= nil
	package.loaded["global.MessageMode"]		= nil
	package.loaded["global.Direction"]			= nil
	package.loaded["global.Color"]				= nil
	package.loaded["global.Attribute"]			= nil
	package.loaded["global.DatabaseManager"]	= nil

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
