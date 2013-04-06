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
		player:setMob(Mob:new(input))
		player:setState(PlayerState.MOTD)
		Nanny.MOTD(player)

	elseif player:getState() == PlayerState.MOTD then
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
end

--[[
	Ask the player for a name.
	@param player	The player to ask.
]]
function Nanny.askForName(player)
	player:sendString("What is your name? ")
end

--[[
	Tell them their name input was invalid.
	@param player	The player to message.
]]
function Nanny.messageNameIsInvalid(player)
	player:sendLine("It was a rhetorical question!")
end

function Nanny.introduce(player)
	player:sendLine(string.format("Welcome to %s, %s!", tostring(package.loaded.Game.getName()), tostring(player.mob)))
	Game.announce(string.format("%s has joined!", tostring(player)))
end

function Nanny.sendOff(player)
	player:sendLine("Goodbye!")
	Game.announce(string.format("%s has left!", tostring(player)))
end	

function Nanny.MOTD(player)
	player:sendLine(Nanny.getMOTD())
end

function Nanny.getMOTD()
	return "\n\[WELCOME TO MFin' LAMA\]\n<hit enter>"
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
