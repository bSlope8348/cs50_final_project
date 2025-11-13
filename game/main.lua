local player, wall, boxes, boxCount, objects

function love.load()
    Object = require "lib.classic"
    require "src.entity"
    require "src.player"
    require "src.wall"
	require "src.box"

    player = Player(100, 100)
    wall = Wall(200, 100)

	boxes = {}
	boxCount = 5
	for i=1,boxCount do
		table.insert(boxes, Box(300, 110+(i-1)*50))
	end

	objects = {}
    table.insert(objects, player)
    table.insert(objects, wall)
	for i=1,boxCount do
		table.insert(objects, boxes[i])
	end
end

function love.update(dt)
    -- Update all the objects
    for i,v in ipairs(objects) do
        v:update(dt)
    end

    local loop = true
    local limit = 0

	while loop do
	    -- Set loop to false, if no collision happened it will stay false
        loop = false

		limit = limit + 1
		if limit > 100 then
            -- Still not done at loop 100
            -- Break it because we're probably stuck in an endless loop.
			break
		end

		-- Go through all the objects (except the last)
		for i=1,#objects-1 do
			-- Go through all the objects starting from the position i + 1
			for j=i+1,#objects do
				local collision = objects[i]:resolveCollision(objects[j])
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
end
