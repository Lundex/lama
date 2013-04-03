local Game = require("Game")
local _, err = Game:open()
if not _ then
	print("Failed to host world:", err)
	return
end

print("Hosting game server on port " .. Game.defaultPort .. ".")
while Game:isReady() do
	Game:update()
end
