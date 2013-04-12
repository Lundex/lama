--- Entry point for the game.
-- @author milkmanjack
-- module("main", package.seeall)
require("Game")

-- open the game for play
local port = tonumber(... or nil) -- first command-line argument to main.lua will be the port to host on
local _, err = Game.open(port)
if not _ then
  Game.error("failed to open game: " .. err)
	os.exit(0)
end

-- primary game loop
while Game.isReady() do
	Game.update() -- updates the game in increments.
	socket.select(nil,nil,0.1) -- 1/10th second delay between cycles
end
