require("lib.sqlite3")

Object = require("lib.classic")

require("src.entity")
require("src.player")
require("src.wall")
require("src.box")
require("src.exit")
require("src.floor")
require("src.thruFloor")
require("src.coin")

local lume = require("lib.lume")

local pause = require("src.ui.pause")
local timerBox = require("src.ui.scoreBox")
local name = require("src.ui.name")

local walls, map, objects, myFont, playerName, timeCompleted, firstKey, notCompleted
local isPaused, key_map, victory, gDB, noKeyPressedYet, timer, timerRunning, startUp, rank

local function escapeSQLString(str)
    return str:gsub("'", "''")  -- Double single quotes to escape them
end

local function saveGame(slotName)
    local saveData = {
        timer = timer,
        timerRunning = timerRunning,
        victory = victory,
        playerName = playerName,
        firstKey = firstKey,
        noKeyPressedYet = noKeyPressedYet,
		timeCompleted = timeCompleted,
		startUp = startUp,
		notCompleted = notCompleted,
        objects = {},  -- serialize object positions/states
        -- walls = {},    -- if needed
    }

    -- Serialize objects
    for i, obj in ipairs(objects) do
		if obj:is(Player) then
			table.insert(saveData.objects, {
				type = "Player",
				x = obj.x,
				y = obj.y,
				canJump = obj.canJump,
				hasCoin = obj.hasCoin,
				image_path = obj.image_path
			})
		elseif obj:is(Box) then
			table.insert(saveData.objects, {
				type = "Box",
				x = obj.x,
				y = obj.y
			})
		elseif obj:is(Coin) then
			table.insert(saveData.objects, {
				type = "Coin",
				x = obj.x,
				y = obj.y
			})
		elseif obj:is(Exit) then
			table.insert(saveData.objects, {
				type = "Exit",
				x = obj.x,
				y = obj.y,
				transparency = obj.transparency,
				victory = obj.victory
			})
		end
    end

    local serialized = lume.serialize(saveData)
	love.filesystem.write(slotName .. ".txt", serialized)
end

local function loadGame(slotName)
	if love.filesystem.getInfo(slotName .. ".txt") then
		local file = love.filesystem.read(slotName .. ".txt")
		local saveData = lume.deserialize(file)

		timer = saveData.timer
		timerRunning = saveData.timerRunning
		victory = saveData.victory
		playerName = saveData.playerName
        firstKey = saveData.firstKey
        noKeyPressedYet = saveData.noKeyPressedYet
		timeCompleted = saveData.timeCompleted
		startUp = saveData.startUp
		notCompleted = saveData.notCompleted
		-- restore all states...

		-- Recreate objects
		objects = {}
		for i, data in ipairs(saveData.objects) do
			if data.type == "Player" then
				local player = Player(data.x, data.y)
				player.canJump = data.canJump
				player.hasCoin = data.hasCoin
				player.image_path = data.image_path
				player.image = love.graphics.newImage(player.image_path)
				table.insert(objects, player)
			elseif data.type == "Box" then
				table.insert(objects, Box(data.x, data.y))
			elseif data.type == "Coin" then
				table.insert(objects, Coin(data.x, data.y))
			elseif data.type == "Exit" then
				local exit = Exit(data.x, data.y)
				exit.transparency = data.transparency
				exit.victory = data.victory
				table.insert(objects, exit)
			end
		end
	end
end

function love.load()
	love.keyboard.setKeyRepeat(true)

	startUp = false
	timer = 0
	timerRunning = false
	noKeyPressedYet = true
	playerName = ""
	timeCompleted = 0
	firstKey = ""
	notCompleted = true
    rank = 0
	--create/open game loggin database
	local saveDir = love.filesystem.getSaveDirectory()
    gDB = sqlite3.open(saveDir .. "/gameDB.db")
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
  		f4 = function()
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

	pause.setSaveLoadCallbacks(saveGame, loadGame)
end

function love.update(dt)
	if isPaused then
		pause.update(dt, gDB)
		isPaused = pause.resume()
		return
  	end

	if not startUp then
		name.update(dt)
		playerName = name.submittedName()
		if name.ready() then
			startUp = true
		end
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
					local iQuery = string.format(
						"INSERT INTO log (name, time_completed, first_key_used, date_logged) VALUES ('%s', %f, '%s', %d)",
						escapeSQLString(playerName), timeCompleted, escapeSQLString(firstKey), os.time()
					)
					gDB:execute(iQuery)

					local rQuery = string.format(
						"SELECT COUNT(*) as rank FROM log WHERE time_completed > 0 AND time_completed < %f AND time_completed IS NOT NULL",
						timeCompleted
					)
					rank = 0
					for row in gDB:nrows(rQuery) do
						rank = row.rank + 1
						break  -- Only one row expected
					end
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
		love.graphics.printf({{0.5, 1, 0.75}, "WINNER!"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 150, 
			love.graphics.getWidth(), "center", 0, 4, 4, love.graphics.getWidth() / 2, 0)
		love.graphics.printf({{1, 1, 0}, "Time: " .. string.format("%.2f", timeCompleted) .. " seconds"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 
			love.graphics.getWidth(), "center", 0, 2, 2, love.graphics.getWidth() / 2, 0)
		love.graphics.printf({{1, 1, 1}, "Your Rank: " .. rank}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 100, 
			love.graphics.getWidth(), "center", 0, 1.5, 1.5, love.graphics.getWidth() / 2, 0)
	end

	if not startUp then
		name.draw()
	end

	if isPaused then
		pause.draw()
	end
end

function love.keypressed(key, scancode, isRepeat)
    if not startUp then
        name.keypressed(key, isRepeat)
		return
    end
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

function love.textinput(text)
    if not startUp then
        name.textinput(text)
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
