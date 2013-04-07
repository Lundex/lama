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

function CommandParser:parse(player, input)
	-- parsing goes here
	if string.find(input, "look") == 1 then
		local msg
		for i,v in ipairs(player:getMob():getLoc():getContents()) do
			local display
			if v:isCloneOf(Mob) then
				display = string.format("%s is here.", v:getName())
			else
				display = tostring(v)
			end

			msg = string.format("%s%s%s", msg or "", msg and "\n" or "", display or "?")
		end

		player:sendLine(msg)

	elseif string.find(input, "ooc") == 1 then
		local msg = string.sub(input, 5)
		Game.announce(string.format("%s OOC: '%s'", player:getMob():getName(), msg), PlayerState.PLAYING)
	end
end

function CommandParser:addCommand(command)
	table.insert(self.commands, command)
end

function CommandParser:removeCommand(command)
	table.removeValue(self.commands, command)
end

return CommandParser
