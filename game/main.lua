local player, walls, map, box, objects

function love.load()
    Object = require "lib.classic"
    require "src.entity"
    require "src.player"
    require "src.wall"
	require "src.box"

    player = Player(100, 100)
    box = Box(400, 150)

    objects = {}
    table.insert(objects, player)
    table.insert(objects, box)
	
	walls = {}

    map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
        {1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
    }

    for i,v in ipairs(map) do
        for j,w in ipairs(v) do
            if w == 1 then
                table.insert(walls, Wall((j-1)*50, (i-1)*50))
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

		-- For each object check collision with every wall.
        for i,wall in ipairs(walls) do
            for j,object in ipairs(objects) do
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
	if key == "up" then
		player:jump()
	end
end
