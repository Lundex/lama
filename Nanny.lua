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

	-- move our mob to starting point
	mob:moveToMap(Game.map)
	mob:setXYZLoc(1,1,1)
	player:sendLine(string.format("%s\
%s\n", mob:getLoc():getName(), mob:getLoc():getDescription()))

	-- introduce us
	Nanny.introduce(player)
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
	player:sendString("What is your name? ")
end

function Nanny.messageNameInvalid(player)
	player:sendLine("It was a rhetorical question!")
end

function Nanny.messageNameLengthLimit(player)
	player:sendLine("Your name must be between 3 and 12 characters.")
end

-- this occurs before the player is players
function Nanny.introduce(player)
	player:sendLine(string.format("Welcome to %s, %s!", tostring(Game.getName()), tostring(player)))
	Game.announce(string.format("%s has joined!", tostring(player)), PlayerState.PLAYING)
end

-- this occurs after the player is disconnected
function Nanny.sendOff(player)
	player:sendLine("Goodbye!")
	Game.announce(string.format("%s has left!", tostring(player)), PlayerState.PLAYING)
end	

function Nanny.MOTD(player)
	player:sendLine("")
	player:sendLine(Nanny.getMOTD())
	player:sendLine("")
	player:sendString("< PRESS ENTER >")
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
	Nanny.askForName(player)
end

--[[
	Get the greeting message.
	@return The message.
]]
function Nanny.getGreeting()
	return "      __            /^\\\
    .'  \\          / :.\\\
   /     \\         | :: \\\
  /   /.  \\       / ::: |\
 |    |::. \\     / :::'/\
 |   / \\::. |   / :::'/\
 `--`   \\'  `~~~ ':'/`\
         /         (\
        /   0 _ 0   \\\
      \\/     \\_/     \\/ Welcome to\
    -== '.'   |   '.' ==-     lama v0.0a!\
      /\\    '-^-'    /\\\
        \\   _   _   /\
       .-`-((\\o/))-`-.\
  _   /     //^\\\\     \\   _\
.\"o\".(    , .:::. ,    ).\"o\".\
|o  o\\\\    \\:::::/    //o  o|\
 \\    \\\\   |:::::|   //    /\
  \\    \\\\__/:::::\\__//    /\
   \\ .:.\\  `':::'`  /.:. /\
    \\':: |_       _| ::'/\
 jgs `---` `\"\"\"\"\"` `---`"
end

_G.Nanny = Nanny

return Nanny
