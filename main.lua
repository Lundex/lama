local Game = require("Game")
local _, err = Game:host()
if not _ then
	print("Failed to host world:", err)
	return
end

print("Hosting game server on port " .. Game.defaultPort .. ".")
while true do
	Game:update()
end
