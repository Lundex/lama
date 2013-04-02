--[[	Author:	Milkmanjack
		Date:	3/31/13
		It's a scheduler. Duh.
]]

require("ext.table")
local Cloneable		= require("obj.Cloneable")
local Scheduler		= Cloneable.clone()

-- scheduler settings
Scheduler.events	= nil

--[[
	Creates a unique events table for each scheduler.
]]
function Scheduler:initialize()
	self.events = {}
end

--[[
	Polls the scheduler for events waiting to fire.
	@param timestamp	This is the current timestamp to compare to the destination timestamps.
]]
function Scheduler:poll(timestamp)
	for i,v in table.safeIPairs(self.events) do
		if v:isReady(timestamp) then
			v:execute()
			if v:isDone() then
				self:dequeue(v)
			end
		end
	end
end

--[[
	Add an event to the queue.
	@param event	The even to queue.
]]
function Scheduler:queue(event)
	table.insert(self.events, event)
end

--[[
	Remove an event from the queue.
	@param event	The even to deque.
]]
function Scheduler:dequeue(event)
	for i,v in ipairs(self.events) do
		if v == event then
			table.remove(self.events, i)
		end
	end
end

--[[
	The scheduler has events waiting.
	@return true if an event is waiting.<br/> false otherwise.
]]
function Scheduler:isWaiting()
	return #self.events > 0
end

--[[
	Are there any events ready to fire?
	@param timestamp	This is the current timestamp to compare to the destination timestamps.
]]
function Scheduler:isReady(timestamp)
	for i,v in ipairs(self.events) do
		if v:isReady(timestamp) then
			return true
		end
	end

	return false
end

-- empties the scheduler
function Scheduler:clear()
	self.events = {}
end

return Scheduler
