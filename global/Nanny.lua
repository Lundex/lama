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

--- Singleton that contains necessary processes for connecting new players,
-- as well as processing their input during these stages.
-- @author milkmanjack
module("Nanny", package.seeall)

local Mob			= require("obj.Mob")

--- Singleton that contains necessary processes for connecting new players,
-- as well as processing their input during these stages.
-- @class table
-- @name Nanny
local Nanny			= {}

--- Processes input from a player.
-- @param player The player to process.
-- @param input The input to process.
function Nanny.process(player, input)
	if player:getState() == PlayerState.NAME then
		local name = CharacterManager.legalizeName(input)
		if string.len(input) < 3 or string.len(input) > 12 then
			Nanny.messageNameLengthLimit(player)
			Nanny.askForName(player)
		else
			local mob = Mob:new()

			-- load saved character
			if CharacterManager.characterNameTaken(name) then
				CharacterManager.loadCharacter(name, mob)

			-- create new character
			else
				mob:setName(name)
				CharacterManager.saveCharacter(mob)
			end

			player:setMob(mob)
			player:setState(PlayerState.MOTD)
			Nanny.MOTD(player)
		end

	elseif player:getState() == PlayerState.MOTD then
		Nanny.login(player)
	end
end

--- Transitions from "logging in" to being "logged in."
-- Assigns a player ID, introduces the player to the world, and so on.
-- @param player Player that is logging in.
function Nanny.login(player)
	local mob = player:getMob()
	player:setID(Game.nextPlayerID()) -- now that they're finally playing
	Nanny.introduce(player)

	Game.info(string.format("%s has joined.", tostring(player), tostring(mob)))

	-- move our mob to starting point
	mob:moveToMap(Game.map)
	mob:setXYZLoc(1,1,1)
	player:getMob():showRoom()

	-- introduce us
	player:setState(PlayerState.PLAYING) -- we're playing
end

--- Transitions from being "logged in" to being "logged out."
-- Announces the player's exit, removes the mob from the map, and so on.
-- @param player Player that is logging out.
function Nanny.logout(player)
	player:setState(PlayerState.DISCONNECTING) -- we are disconnecting

	local mob = player:getMob()
	Nanny.sendOff(player)

	Game.info(string.format("%s has left.", tostring(player), tostring(mob)))

	-- remove their mob from the map
	mob:moveToMap(nil)
end

--- Introduce the player to the world.
-- @param player Player to introduce.
function Nanny.introduce(player)
	player:sendMessage(string.format("\nWelcome to %s, %s!", tostring(Game.getName()), tostring(player:getMob())), MessageMode.GENERAL)
	Game.announce(string.format("%s has joined!", tostring(player:getMob())), MessageMode.INFO, PlayerState.PLAYING)
end

--- Send the player off, announcing their departure.
-- @param player Player that is departing.
function Nanny.sendOff(player)
	player:sendLine("Goodbye!")
	Game.announce(string.format("%s has left!", tostring(player:getMob())), MessageMode.INFO, PlayerState.PLAYING)
end	

--- Greets a connecting player and begins the logging in.<br/>
-- In the case of a hotboot greeting, merely puts the player back
-- in the game.
-- @param player Player to be greeted.
-- @param hotboot If true, greeting after a hotboot.
function Nanny.greet(player, hotboot)
	if hotboot then
		player:sendLine("Welcome back!")
		player:setState(PlayerState.PLAYING)
	else
		player:sendLine(Nanny.getGreeting())
		player:setState(PlayerState.NAME)
		player:sendLine()
		Nanny.askForName(player)
	end
end

--- Asks for a name.
-- @param player Player to ask.
function Nanny.askForName(player)
	player:askQuestion("What is your name? ")
end

--- Tell the player the name length limits.
-- @param player Player to inform.
function Nanny.messageNameLengthLimit(player)
	player:sendMessage("Your name must be between 3 and 12 characters.", MessageMode.FAILURE)
end

--- Send the MOTD to the player.
-- @param player Player to be MOTDed.
function Nanny.MOTD(player)
	player:sendMessage("\n" .. Nanny.getMOTD(), MessageMode.GENERAL)
	player:sendMessage("< PRESS ENTER >", MessageMode.GENERAL, false)
end

--- Retreive the text to be used as the MOTD.
-- @return The MOTD!
function Nanny.getMOTD()
	return "\[THIS IS THE MESSAGE OF THE DAY\]"
end

--- Get the greeting message. By default, refers to "txt/GREETING". If not found, returns generic credits.
-- @return The message.
function Nanny.getGreeting()
	-- use contents of txt/GREETING for our greeting, if available.
	local file = io.open("txt/GREETING", "r")
	if file then
		local txt = file:read("*a")
		local formatted = string.format(txt, Game.getName(), Game.getVersion(), Game.getDevelopers())
		return formatted
	end

	-- generic greeting
	return string.format([[%s (%s)
    by %s

Developed in
    Lua 5.2]], Game.getName(), Game.getVersion(), Game.getDevelopers())

end

_G.Nanny = Nanny

return Nanny