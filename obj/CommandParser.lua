--[[	Author:	Milkmanjack
		Date:	4/7/13
		Parses commands on behalf of the user.
]]

local Cloneable		= require("obj.Cloneable")
local Mob			= require("obj.Mob")
local CommandParser	= Cloneable.clone()

-- runtime data
CommandParser.commands	= nil -- list of commands we recognize

function CommandParser:initialize()
	self.commands = {}
end

-- this is all hard-coded just because I'm too lazy to make real commands right now.
function CommandParser:parse(player, mob, input)
	-- parsing goes here
	if string.find("north", input) == 1 then
		if mob:step(Direction.NORTH) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("south", input) == 1 then
		if mob:step(Direction.SOUTH) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("east", input) == 1 then
		if mob:step(Direction.EAST) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("west", input) == 1 then
		if mob:step(Direction.WEST) then
			mob:showRoom()
		else
			player:sendMessage("Alas, you cannot go that way.", MessageMode.FAILURE)
		end

	elseif string.find("who", input) == 1 then
		local msg = "\[ Connected Players ]"
		for i,v in ipairs(Game:getPlayers()) do
			msg = string.format("%s\n-> %s", msg, tostring(v))
		end

		player:sendMessage(msg)

	elseif string.find("look", input) == 1 then
		player:getMob():showRoom()

	elseif string.find(input, "ooc") == 1 then
		local msg = string.sub(input, 5)
		Game.announce(string.format("%s OOC: '%s'", mob:getName(), msg), MessageMode.CHAT, PlayerState.PLAYING)
	end
end

function CommandParser:addCommand(command)
	table.insert(self.commands, command)
end

function CommandParser:removeCommand(command)
	table.removeValue(self.commands, command)
end

return CommandParser
