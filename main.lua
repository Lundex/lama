--- Entry point for the game.
-- @author milkmanjack
module("main", package.seeall)

require("Game")
local _, err = Game.open()
if not _ then
  Game.error("failed to open game: " .. err)
	os.exit(0)
end

while Game.isReady() do
	Game.update()
end
