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

local md5			= require("md5")
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
			if CharacterManager.characterNameTaken(input) then
				local mob = Mob:new()
				player:setMob(mob)
				local mob, location = CharacterManager.loadCharacter(input, mob)
				player.nanny.location = location
				player:setState(PlayerState.OLD_CHAR_PASSWORD)
				Nanny.askForOldPassword(player)
			else
				local mob = Mob:new()
				player:setMob(mob)
				mob:setName(name)
				mob:setKeywords(name)
				player:setState(PlayerState.NEW_CHAR_PASSWORD)
				Nanny.askForNewPassword(player, false)
			end
		end

	elseif player:getState() == PlayerState.OLD_CHAR_PASSWORD then
		if md5.sumhexa(input) ~= player.mob:getPassword() then
			player:sendMessage("That password doesn't match the old password!", MessageMode.FAILURE)
			player:unsetMob()
			player:setState(PlayerState.NAME)
			Nanny.askForName(player)
		else
			player:setState(PlayerState.MOTD)
			Nanny.MOTD(player)
		end

	elseif player:getState() == PlayerState.NEW_CHAR_PASSWORD then
		player.nanny.password = input
		player:setState(PlayerState.NEW_CHAR_PASSWORD_CONFIRM)
		Nanny.askForNewPassword(player, true)

	elseif player:getState() == PlayerState.NEW_CHAR_PASSWORD_CONFIRM then
		if input ~= player.nanny.password then
			player:sendMessage("Those passwords don't match!")
			Nanny.askForNewPassword(player, false)
			player:setState(PlayerState.NEW_CHAR_PASSWORD)
		else
			player.mob:setPassword(md5.sumhexa(player.nanny.password))
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
	if player.nanny.location then
		mob:move(player.nanny.location)
	else
		mob:setXYZLoc(1,1,1)
	end
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
	player:sendMessage(string.format("\nWelcome to %s, %s!", tostring(Game.getName()), tostring(player:getMob())))
	Game.announce(string.format("%s has joined!", tostring(player:getMob())), MessageMode.INFO, PlayerState.PLAYING)
end

--- Send the player off, announcing their departure.
-- @param player Player that is departing.
function Nanny.sendOff(player)
	player:sendMessage("Goodbye!")
	Game.announce(string.format("%s has left!", tostring(player:getMob())), MessageMode.INFO, PlayerState.PLAYING)
end	

--- Greets a connecting player and begins the logging in.<br/>
-- In the case of a hotboot greeting, merely puts the player back
-- in the game.
-- @param player Player to be greeted.
-- @param hotboot If true, greeting after a hotboot.
function Nanny.greet(player, hotboot)
	if hotboot then
		player:sendMessage("Welcome back!")
		player:setState(PlayerState.PLAYING)
	else
		player:sendMessage(Nanny.getGreeting())
		player:setState(PlayerState.NAME)
		Nanny.askForName(player)
	end
end

--- Asks for a name.
-- @param player Player to ask.
function Nanny.askForName(player)
	player:askQuestion("What is your name? ")
end

--- Ask for a new password.
-- @param player Player to ask.
function Nanny.askForNewPassword(player, confirm)
	if not confirm then
		player:askQuestion("New password: ")
	else
		player:askQuestion("Repeat password: ")
	end
end

--- Ask for the old password.
-- @param player Player to ask.
function Nanny.askForOldPassword(player)
	player:askQuestion("Password: ")
end

--- Tell the player the name length limits.
-- @param player Player to inform.
function Nanny.messageNameLengthLimit(player)
	player:sendMessage("Your name must be between 3 and 12 characters.", MessageMode.FAILURE)
end

--- Send the MOTD to the player.
-- @param player Player to be MOTDed.
function Nanny.MOTD(player)
	player:sendMessage("\n" .. Nanny.getMOTD())
	player:sendMessage("< PRESS ENTER >", nil, false)
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
