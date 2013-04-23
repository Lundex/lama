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

--- Configuration table for the Server.
-- @author milkmanjack
module("config", package.seeall)

--- Configuration table for the Server.
-- @class table
-- @name config
-- @field enableMCCP2 Should MCCP2 be enabled?
local config		= {}
config.enableMCCP2	= false

--- Check if MCCP is enabled.
-- @return true of MCCP is enabled.<br/>false otherwise.
function config.MCCP2IsEnabled()
	return config.enableMCCP2 == true
end

_G.config = config

return config