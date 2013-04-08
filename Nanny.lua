--[[	Author:	Milkmanjack
		Date:	4/4/13
		Package that handles processing of new players.
]]

local Mob			= require("obj.Mob")
local Nanny			= {}

--[[
	Processes input from a player.
	@param player	The player to process.
	@param input	The input to process.
]]
function Nanny.process(player, input)
	if player:getState() == PlayerState.NAME then
		if string.len(input) < 3 or string.len(input) > 12 then
			Nanny.messageNameLengthLimit(player)
			Nanny.askForName(player)
		else
			local mob = Mob:new()
			mob:setName(input)
			player:setMob(mob)
			player:setState(PlayerState.MOTD)
			Nanny.MOTD(player)
		end

	elseif player:getState() == PlayerState.MOTD then
		Nanny.login(player)
	end
end

function Nanny.login(player)
	local mob = player:getMob()
	player:setID(Game.nextPlayerID()) -- now that they're finally playing
	Nanny.introduce(player)

	-- move our mob to starting point
	mob:moveToMap(Game.map)
	mob:setXYZLoc(1,1,1)
	player:getMob():showRoom()

	-- introduce us
	player:setState(PlayerState.PLAYING) -- we're playing
end

function Nanny.logout(player)
	local mob = player:getMob()
	Nanny.sendOff(player)

	-- remove their mob from the map
	mob:moveToMap(nil)

	player:setState(PlayerState.DISCONNECTING) -- we are disconnecting
end

function Nanny.askForName(player)
	player:askQuestion("What is your name? ")
end

function Nanny.messageNameLengthLimit(player)
	player:sendMessage("Your name must be between 3 and 12 characters.", MessageMode.FAILURE)
end

-- this occurs before the player is considered an active player
function Nanny.introduce(player)
	player:sendMessage(string.format("\nWelcome to %s, %s!", tostring(Game.getName()), tostring(player)), MessageMode.GENERAL)
	Game.announce(string.format("%s has joined!", tostring(player)), MessageMode.INFO, PlayerState.PLAYING)
end

-- this occurs after the player is disconnected
function Nanny.sendOff(player)
	player:sendLine("\n!Goodbye!")
	Game.announce(string.format("%s has left!", tostring(player)), MessageMode.INFO, PlayerState.PLAYING)
end	

function Nanny.MOTD(player)
	player:sendMessage("\n" .. Nanny.getMOTD(), MessageMode.GENERAL)
	player:sendMessage("< PRESS ENTER >", MessageMode.GENERAL, false)
end

function Nanny.getMOTD()
	return "\[THIS IS THE MESSAGE OF THE DAY\]"
end

--[[
	Greet the player.
	@param player	The player to message.
]]
function Nanny.greet(player)
	player:sendLine(Nanny.getGreeting())
	player:setState(PlayerState.NAME)
	player:sendLine()
	Nanny.askForName(player)
end

--[[
	Get the greeting message.
	@return The message.
]]
function Nanny.getGreeting()
	return [[milkmanjack@home ~>
$ cd /projects/lama

milkmanjack@home ~/projects/lama>
$ lua
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> dofile("Game.lua")
> =Game.version
0.0a
> =Game.name
lama
> Game.open()
...]]
end

_G.Nanny = Nanny

return Nanny
