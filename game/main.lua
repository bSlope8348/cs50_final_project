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

local victoryScreen = require("src.ui.victory")

local lume = require("lib.lume")

local pause = require("src.ui.pause")
local timerBox = require("src.ui.scoreBox")
local name = require("src.ui.name")
local levels = require("src.levels")

local walls, map, objects, myFont, playerName, timeCompleted, firstKey, notCompleted
local isPaused, key_map, victory, gDB, noKeyPressedYet, timer, timerRunning, startUp, rank, currentLevel
local playerID

local function escapeSQLString(str)
    return str:gsub("'", "''")  -- Double single quotes to escape them
end

local function updateTotalTimes(db, pid, pname)
	-- Check if player has completed all levels and update totals table
	if not db or not db:isopen() or not pid then return end

	local levelTimes = {}
	local hasAllLevels = true

	-- Get the best time for each level for this player
	for i = 1, #levels do
		local query = string.format(
			"SELECT MIN(time_completed) as best_time FROM log_level%d WHERE player_id = '%s' AND time_completed > 0 AND time_completed IS NOT NULL",
			i, pid
		)
		local bestTime = nil
		for row in db:nrows(query) do
			bestTime = row.best_time
			break
		end

		if bestTime then
			levelTimes[i] = bestTime
		else
			hasAllLevels = false
			break
		end
	end

	-- If player has completed all levels, update totals table
	if hasAllLevels then
		local totalTime = 0
		for i = 1, #levels do
			totalTime = totalTime + levelTimes[i]
		end

		-- Check if player already has a record in totals
		local existingQuery = string.format(
			"SELECT id FROM log_totals WHERE id = '%s'",
			pid
		)
		local hasRecord = false
		for row in db:nrows(existingQuery) do
			hasRecord = true
			break
		end

		if hasRecord then
			-- Update existing record if new total is better
			local updateQuery = string.format(
				"UPDATE log_totals SET name = '%s', total_time = %f, level1_time = %f, level2_time = %f, level3_time = %f, level4_time = %f, level5_time = %f, date_logged = %d WHERE id = '%s' AND (total_time IS NULL OR total_time > %f)",
				escapeSQLString(pname), totalTime, levelTimes[1], levelTimes[2], levelTimes[3], levelTimes[4], levelTimes[5], os.time(), pid, totalTime
			)
			db:execute(updateQuery)
		else
			-- Insert new record
			local insertQuery = string.format(
				"INSERT INTO log_totals (name, total_time, level1_time, level2_time, level3_time, level4_time, level5_time, date_logged) VALUES ('%s', %f, %f, %f, %f, %f, %f, %d)",
				escapeSQLString(pname), totalTime, levelTimes[1], levelTimes[2], levelTimes[3], levelTimes[4], levelTimes[5], os.time()
			)
			db:execute(insertQuery)
		end
	end
end

local function saveGame(slotName)
    local saveData = {
        timer = timer,
        timerRunning = timerRunning,
        victory = victory,
        playerName = playerName,
        playerID = playerID,
        firstKey = firstKey,
        noKeyPressedYet = noKeyPressedYet,
		timeCompleted = timeCompleted,
		startUp = startUp,
		notCompleted = notCompleted,
		currentLevel = currentLevel,
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
		playerID = saveData.playerID
        firstKey = saveData.firstKey
        noKeyPressedYet = saveData.noKeyPressedYet
		timeCompleted = saveData.timeCompleted
		startUp = saveData.startUp
		notCompleted = saveData.notCompleted
		currentLevel = saveData.currentLevel or 1
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

local function loadLevel(levelNum)
	-- Clear existing entities
	objects = {}
	walls = {}

	-- Reset game state
	timer = 0
	timerRunning = false
	noKeyPressedYet = true
	victory = false
	notCompleted = true
	timeCompleted = 0
	firstKey = ""

	-- Set current level
	currentLevel = levelNum

	-- Load the level map
	if levels[levelNum] then
		map = levels[levelNum].map
	else
		-- If level doesn't exist, loop back to level 1
		currentLevel = 1
		map = levels[1].map
	end

	-- Parse map and create entities
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
end

function love.load()
	love.keyboard.setKeyRepeat(true)

	startUp = false
	playerName = ""
    rank = 0

	--create/open game loggin database
	local saveDir = love.filesystem.getSaveDirectory()
    gDB = sqlite3.open(saveDir .. "/gameDB.db")
	if gDB then
		-- Create totals table for players who complete all levels
		local totalsQuery =
			"CREATE TABLE IF NOT EXISTS log_totals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, total_time REAL, level1_time REAL, level2_time REAL, level3_time REAL, level4_time REAL, level5_time REAL, date_logged INTEGER);"
		gDB:execute(totalsQuery)
		-- Create a table for each level
		for i = 1, #levels do
			local query = string.format(
				"CREATE TABLE IF NOT EXISTS log_level%d (id INTEGER PRIMARY KEY AUTOINCREMENT, player_id INTEGER NOT NULL, name TEXT, time_completed REAL, first_key_used TEXT, date_logged INTEGER, FOREIGN KEY(player_id) REFERENCES log_totals(id));",
				i
			)
			gDB:execute(query)
		end
	end

	myFont = love.graphics.newFont(30)
	love.graphics.setFont(myFont)

	isPaused = false
	key_map = {
  		f4 = function()
    		love.event.quit()
  		end,
  		escape = function()
    		isPaused = not isPaused
			if isPaused then
				pause.reset()  -- Reset to keyboard mode when opening pause menu
				pause.setCurrentLevel(currentLevel)  -- Pass current level to pause menu
			end
  		end
	}

	-- Load level 1
	loadLevel(1)

	timerBox:new(20, 20, timer, "Time: ", " seconds")

	pause.setSaveLoadCallbacks(saveGame, loadGame)

	-- Initialize name screen to keyboard mode
	name.reset()
end

function love.update(dt)
	if isPaused then
		pause.update(dt, gDB)
		isPaused = pause.resume()
		return
  	end

	if not startUp then
		if gDB and gDB:isopen() then
			name.update(dt)
			playerName = name.submittedName()
			if name.ready() then
				-- Insert new record
				local insertQuery = string.format(
					"INSERT INTO log_totals (name, date_logged) VALUES ('%s', %d)",
					escapeSQLString(playerName), os.time()
				)
				gDB:execute(insertQuery)

				-- Get id
				playerID = gDB:last_insert_rowid()
				startUp = true
			end
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
					-- Insert into the appropriate level table
					local tableName = "log_level" .. currentLevel
					local iQuery = string.format(
						"INSERT INTO %s (player_id, name, time_completed, first_key_used, date_logged) VALUES ('%s', '%s', %f, '%s', %d)",
						tableName, playerID, escapeSQLString(playerName), timeCompleted, escapeSQLString(firstKey), os.time()
					)
					gDB:execute(iQuery)
					-- Calculate rank for this level
					local rQuery = string.format(
						"SELECT COUNT(*) as rank FROM %s WHERE time_completed > 0 AND time_completed < %f AND time_completed IS NOT NULL",
						tableName, timeCompleted
					)
					rank = 0
					for row in gDB:nrows(rQuery) do
						rank = row.rank + 1
						break  -- Only one row expected
					end

					-- Update total times if player has completed all levels
					updateTotalTimes(gDB, playerID, playerName)
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
		victoryScreen.draw(rank, timeCompleted)
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

	-- Handle pause menu keyboard navigation
	if isPaused then
		pause.keypressed(key, gDB)
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
		pause.reset()
		pause.setCurrentLevel(currentLevel)
	end
end

function love.quit()
	if gDB and gDB:isopen() then
    	gDB:close()
	end
end

function love.mousemoved(x, y, dx, dy)
	if not startUp then
		name.mousemoved(x, y, dx, dy)
		return
	end

	if victory then
		victoryScreen.mousemoved(x, y)
	end
end

function love.mousepressed(x, y, button)
	if not startUp then
		name.mousepressed(x, y, button)
		return
	end

	if victory then
		local action = victoryScreen.mousepressed(x, y, button, currentLevel, #levels)
		if action == "next" then
			-- Load next level
			if currentLevel < #levels then
				loadLevel(currentLevel + 1)
			else
				-- Loop back to level 1
				loadLevel(1)
			end
		elseif action == "restart" then
			-- Restart current level
			loadLevel(currentLevel)
		end
	end
end

function love.mousereleased(x, y, button)
	if not startUp then
		name.mousereleased(x, y, button)
		return
	end
end
