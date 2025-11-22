io.stdout:setvbuf("no")

require("lib/sqlite3")
Object = require "lib.classic"
require "src.entity"
require "src.player"
require "src.wall"
require "src.box"
require "src.exit"
require "src.floor"
require "src.thruFloor"
require "src.coin"

local pause = require("src/ui/pause")
local timerBox = require("src/ui/scoreBox")
local name = require("src/ui/name")

local walls, map, objects, myFont, playerName, timeCompleted, firstKey, notCompleted
local isPaused, key_map, victory, gDB, noKeyPressedYet, timer, timerRunning, startUp


function love.load()
	startUp = false
	timer = 0
	timerRunning = false
	noKeyPressedYet = true
	playerName = ""
	timeCompleted = 0
	firstKey = ""
	notCompleted = true
    --create/open game loggin database
    gDB = sqlite3.open("db/gameDB.db")
	if gDB then
		local query = 
			"CREATE TABLE IF NOT EXISTS log (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, time_completed REAL, first_key_used TEXT, date_logged INTEGER);"
		gDB:execute(query)
	end
	
	myFont = love.graphics.newFont(30)
	love.graphics.setFont(myFont)

	victory = false
	isPaused = false
	key_map = {
  		F4 = function()
    		love.event.quit()
  		end,
  		escape = function()
    		isPaused = not isPaused
  		end
	}

	objects = {}
	walls = {}

    map = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,2,0,0,0,0,0,0,0,3,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,5,5,5,5,5,5,5,5,5,5,5,5,1},
        {1,0,6,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,4,0,0,0,7,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
        {1,5,5,5,5,5,5,5,5,5,5,5,5,0,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
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
				table.insert(objects, Exit(placement_x, placement_y))
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

	timerBox:new(20, 20, timer, "Time: ", " seconds")

end

function love.update(dt)
	if not startUp then
		name.update(dt)
		playerName = name.submittedName()
		print(playerName)
		if name.ready() then
			startUp = true
		end
		print(startUp)
		return
	end

	if isPaused then
		pause.update(dt)
		isPaused = pause.resume()
		return
  	end

	if timerRunning then
		timer = timer + dt
	end

	timerBox:update(dt, timer)

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
				for j,w in ipairs(objects) do
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
	for i,v in ipairs(objects) do
		if v:is(Exit) then
			victory = v.victory
			if victory and notCompleted then
				timeCompleted = timer
				if gDB and gDB:isopen() then
					local query = string.format(
						"INSERT INTO log (name, time_completed, first_key_used, date_logged) VALUES ('%s', %f, '%s', %d)",
						playerName, timeCompleted, firstKey, os.time()
						)
					gDB:execute(query)
					gDB:close()
				end
				notCompleted = false
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

	timerBox:draw()

	if victory then
		-- Semi-transparent overlay
    	love.graphics.setColor(0, 0, 0, 0.85)
    	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	    -- Victory text
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf({{0.5, 1, 0.75}, "WINNER!"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 150, love.graphics.getWidth(), "center", 0, 4, 4, love.graphics.getWidth() / 2, 0)
		love.graphics.printf({{1, 1, 0}, "Time: " .. string.format("%.2f", timeCompleted) .. " seconds"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center", 0, 2, 2, love.graphics.getWidth() / 2, 0)
	end
	
	if not startUp then
		name.draw()
	end
	
	if isPaused then
		pause.draw()
	end
end

function love.keypressed(key)
	if noKeyPressedYet and startUp then
		noKeyPressedYet = false
		firstKey = key
		timerRunning = true
	end

	for i,v in ipairs(objects) do
		if v:is(Player) then
			if key == "space" or key == "up" then
				v:jump()
			end
		end
	end

	if key_map[key] then
    	key_map[key]()
  	end
end

function love.focus(f)
	if not f then
		isPaused = true
	end
end

function love.quit()
	if gDB and gDB:isopen() then
    	gDB:close()
	end
end
