--- Cloneable that processes fireable events.
-- @author milkmanjack
module("obj.Scheduler", package.seeall)

require("ext.table")
local Cloneable		= require("obj.Cloneable")

--- Cloneable that processes fireable Events.
-- @class table
-- @name Scheduler
local Scheduler		= Cloneable.clone()

--- Contains all of the Events a Scheduler has scheduled.
-- @class table
-- @name Scheduler.events
Scheduler.events	= nil

--- Creates a unique events table for each Scheduler.
function Scheduler:initialize()
	self.events = {}
end

--- Polls the Scheduler for Events waiting to fire.
-- @param timestamp	This is the current timestamp to compare to the destination timestamps.
function Scheduler:poll(timestamp)
	for i,v in table.safeIPairs(self.events) do
		if v:isReady(timestamp) then
			v:execute(timestamp)
			if v:isDone() then
				self:dequeue(v)
			end
		end
	end
end

--- Add an Event to the queue.
-- @param event The Event to queue.
function Scheduler:queue(event)
	table.insert(self.events, event)
end

--- Remove an event from the queue.
-- @param event	The even to deque.
function Scheduler:dequeue(event)
	for i,v in ipairs(self.events) do
		if v == event then
			table.remove(self.events, i)
		end
	end
end

--- Check if the Scheduler has Events waiting.
-- @return true if an Event is waiting.<br/> false otherwise.
function Scheduler:isWaiting()
	return #self.events > 0
end

--- Check if there are any Events ready to fire.
-- @param timestamp	This is the current timestamp to compare to the destination timestamps.
-- @return true if an Event is waiting to fire.<br/>false otherwise.
function Scheduler:isReady(timestamp)
	for i,v in ipairs(self.events) do
		if v:isReady(timestamp) then
			return true
		end
	end

	return false
end

--- Empties the Scheduler.
function Scheduler:clear()
	self.events = {}
end

return Scheduler
