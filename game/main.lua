io.stdout:setvbuf("no")

local player, walls, map, objects, box

function love.load()
    Object = require "lib.classic"
    require "src.entity"
    require "src.player"
    require "src.wall"
	require "src.box"
	require "src.exit"
	require "src.floor"
	require "src.thruFloor"
	require "src.coin"

	objects = {}

	walls = {}

    map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,2,0,0,0,0,0,0,0,3,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,5,5,5,5,5,5,5,5,5,5,5,5,1},
        {1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,4,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,5,5,5,5,5,5,5,5,5,5,5,5,0,0,1},
        {1,0,0,0,0,0,0,7,0,0,0,0,0,0,0,1},
        {1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1}
    }

    for i,v in ipairs(map) do
        for j,w in ipairs(v) do
			local placement_x = (j-1)*80
			local placement_y = (i-1)*80
            if w == 1 then
                table.insert(walls, Wall(placement_x, placement_y))
            end 
			if w == 2 then
				table.insert(objects, Player(placement_x, placement_y))
			end
			if w == 3 then
				table.insert(walls, Exit(placement_x, placement_y))
			end
			if w == 4 then
				table.insert(objects, Box(placement_x, placement_y))
			end
			if w == 5 then
				table.insert(walls, Floor(placement_x, placement_y))
			end
			if w == 6 then
				table.insert(walls, ThruFloor(placement_x, placement_y))
			end
			if w == 7 then
				table.insert(objects, Coin(placement_x, placement_y))
			end
        end
    end
end

function love.update(dt)
    -- Update all the objects
    for i,v in ipairs(objects) do
        v:update(dt)
    end
	for i,v in ipairs(walls) do
        v:update(dt)
    end

    local loop = true
    local limit = 0

	while loop do
	    -- Set loop to false, if no collision happened it will stay false
        loop = false

		limit = limit + 1
		if limit > 1000 then
            -- Still not done at loop 100
            -- Break it because we're probably stuck in an endless loop.
			break
		end
		-- Coin collection and Exit transparency 
		for i = #objects, 1, -1 do
			if objects[i].remove == 1 then
				for j,w in ipairs(walls) do
					if w:is(Exit) then
						w.transparency = 1
					end
				end
				table.remove(objects, i)
			end
		end
		-- For each object, check ALL its collisions before moving to the next object
		for i, object in ipairs(objects) do
			-- Check against other objects
			for j, other in ipairs(objects) do
				if i ~= j then
					local collision = object:resolveCollision(other)
					if collision then
						loop = true
					end
				end
			end
			-- Check against walls
			for j, wall in ipairs(walls) do
				local collision = object:resolveCollision(wall)
				if collision then
					loop = true
				end
			end
		end

	end
end

function love.draw()
    -- Draw all the objects
    for i,v in ipairs(objects) do
        v:draw()
    end
    for i,v in ipairs(walls) do
        v:draw()
    end
end

function love.keypressed(key)
	for i,v in ipairs(objects) do
		if v:is(Player) then
			if key == "space" or key == "up" then
				v:jump()
			end
		end
	end
end
