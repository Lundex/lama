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

--- Singleton that contains enum-styled values for Player.messageMode.
-- @author milkmanjack
module("MessageMode", package.seeall)

--- Singleton that contains enum-styled values for Player.messageMode.
-- @class table
-- @name MessageMode
-- @field GENERAL General messages.
-- @field CHAT Character communication.
-- @field ANNOUNCEMENT Critical game updates.
-- @field INFO Informational updates that don't fit in other categories. e.g. spell fizzling.
-- @field QUESTION Mode for questions. Questions generally don't end with a linebreak, so this might be useful in the future.
-- @field MOVEMENT Movement updates.
-- @field COMBAT Combat updates.
-- @field FAILURE Error messages.
local MessageMode							= {}
MessageMode.GENERAL							= 0 -- miscellaneous messages
MessageMode.CHAT							= 1 -- chatting
MessageMode.ANNOUNCEMENT					= 2 -- game updates (logins, deaths, other stuff)
MessageMode.INFO							= 3
MessageMode.QUESTION						= 4 -- questions
MessageMode.MOVEMENT						= 5 -- movement updates (people moving, you moving, information about the rooms you enter)
MessageMode.COMBAT							= 6 -- combat updates (attacking one another, dodging, using skills, etc...)
MessageMode.FAILURE							= 7 -- a failure message!

--- Contains textual representations of MessageMode enums.
-- @class table
-- @name MessageMode.names
-- @field MessageMode.GENERAL "general"
-- @field MessageMode.CHAT "chat"
-- @field MessageMode.ANNOUNCEMENT "announcement"
-- @field MessageMode.INFO "info"
-- @field MessageMode.FAILURE "failure"
-- @field MessageMode.QUESTION "question"
-- @field MessageMode.MOVEMENT "movement"
-- @field MessageMode.COMBAT "combat"
MessageMode.names							= {}
MessageMode.names[MessageMode.GENERAL]		= "general"
MessageMode.names[MessageMode.CHAT]			= "chat"
MessageMode.names[MessageMode.ANNOUNCEMENT]	= "announcement"
MessageMode.names[MessageMode.INFO]			= "info"
MessageMode.names[MessageMode.FAILURE]		= "failure"
MessageMode.names[MessageMode.QUESTION]		= "question"
MessageMode.names[MessageMode.MOVEMENT]		= "movement"
MessageMode.names[MessageMode.COMBAT]		= "combat"

--- Allows for quick reference to MessageMode.names enums.
-- @param state The state to retrieve the name of.
-- @return Name of the state.
function MessageMode.name(state)
	return MessageMode.names[state]
end

_G.MessageMode = MessageMode

return MessageMode
