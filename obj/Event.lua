--[[	Author:	Milkmanjack
		Date:	3/31/13
		It's an event. For an event scheduler. Duh.
]]

local Cloneable			= require("obj.Cloneable")
local Event				= Cloneable.clone()

-- event settings
Event.destination		= 0 -- a timestamp for some point in the future
Event.didRun			= false -- did this event run already?

-- repeating events
Event.shouldRepeat		= false -- should it repeat?
Event.currentRepeat		= 0 -- which cycle we're on
Event.repeatMax			= 0 -- how many times to repeat (0 is infinite)
Event.repeatInterval	= 0 -- what offset from previous execution to repeat

--[[
	This is just a shortcut for initializing a new event.
	This is to make it as easy as possible to create a new event.
	@param destination		Destination for the new event.
	@param fun				The function to be fired by the event.
	@param shouldRepeat		Should the event repeat?
	@param repeatMax		How many times?
	@param repeatInterval	How long between each repeat? (relative amount based on clock)
]]
function Event:initialize(destination, fun, shouldRepeat, repeatMax, repeatInterval)
	self.destination	= destination ~= nil and destination or self.destination
	self.run			= fun ~= nil and fun or self.run
	self.shouldRepeat	= shouldRepeat ~= nil and shouldRepeat or self.shouldRepeat
	self.repeatMax		= repeatMax ~= nil and repeatMax or self.repeatMax
	self.repeatInterval	= repeatInterval ~= nil and repeatInterval or self.repeatInterval
end

--[[
	Check if the event is ready to fire.
	@param timestamp	This is the current timestamp to compare to our destination timestamp.
]]
function Event:isReady(timestamp)
	-- is this event "done"?
	if self:isDone() then
		return false
	end

	-- have we reached our destination?
	if timestamp >= self.destination then
		return true
	end
end

--[[
	Will this event fire anymore?
]]
function Event:isDone()
	if self:hasRun() and not self:willRepeat() then
		return true
	end

	return false
end

--[[
	Has this event fired already?
	@return true if it has fired.<br/>false otherwise.
]]
function Event:hasRun()
	return self.didRun
end

--[[
	Will this event repeat (anymore)? Takes into consideration whether or not we
	have reached our repeat maximum (so it will return false if we have reached it).
	@return true if it will repeat.<br/>false otherwise.
]]
function Event:willRepeat()
	return self.shouldRepeat == true and (self.currentRepeat < self.repeatMax or self.repeatMax == nil or self.repeatMax == 0)
end

--[[
	The intended access point for running the event.
]]
function Event:execute()
	-- if it has not run yet, indicate it has
	if not self:hasRun() then
		self.didRun			= true

	-- if it has run, indicate this is a repeat
	else
		self.currentRepeat	= self.currentRepeat + 1
	end

	-- actual event processing
	self:run()

	-- prepare for the next repeation, if necessary
	if self:willRepeat() then
		self.destination = self.destination + self.repeatInterval
	end
end

return Event
