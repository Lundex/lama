local Map		= require("obj.Map")
local MapTile	= require("obj.MapTile")
local Mob		= require("obj.Mob")
local worldmap	= Map:new()

worldmap:setProportions(10,10,10)

for x=1, 10 do
	for y=1, 10 do
		for z=1, 10 do
			local grass = MapTile:new()
			grass:setName("a grass plain")
			grass:setDescription("A vast empty field extends forever, nothing but lush foliage.")
			worldmap:setTile(grass, x, y, z)
		end
	end
end

-- test mob
local mob = Mob:new()
mob:setName("Sodapopinsky")
mob:setKeywords("Sodapopinsky")
mob:moveToMap(worldmap)
mob:setXYZLoc(1,1,1)

return worldmap
