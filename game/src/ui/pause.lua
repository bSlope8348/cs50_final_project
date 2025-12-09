local pause = {}
local isPaused

local saveCallback = nil
local loadCallback = nil
local fileName = "quicksave"

local resume = {}
local save = {}
local load = {}
local logs = {}
local restart = {}
local exit = {}
local close = {}
local colors = {resume, save, load, logs, restart, exit, close}

local results = {}
local showLogs = false

local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

-- Button dimensions
local buttonWidth = 300
local buttonHeight = 35
local buttonBufferX = 20  -- Width buffer
local buttonBufferY = 5   -- Height buffer (smaller to prevent overlap)

resume.height = screenHeight / 2 - 50
resume.width = buttonWidth
resume.x = screenWidth / 2 - buttonWidth / 2

save.height = screenHeight / 2
save.width = buttonWidth
save.x = screenWidth / 2 - buttonWidth / 2

load.height = screenHeight / 2 + 50
load.width = buttonWidth
load.x = screenWidth / 2 - buttonWidth / 2

logs.height = screenHeight / 2 + 100
logs.width = buttonWidth
logs.x = screenWidth / 2 - buttonWidth / 2

restart.height = screenHeight / 2 + 150
restart.width = buttonWidth
restart.x = screenWidth / 2 - buttonWidth / 2

exit.height = screenHeight / 2 + 200
exit.width = buttonWidth
exit.x = screenWidth / 2 - buttonWidth / 2

close.height = screenHeight / 2 + 300
close.width = buttonWidth
close.x = screenWidth / 2 - buttonWidth / 2

for i,v in ipairs(colors) do
	v.color = {1, 1, 1}
end

local clickHandled = false
local keyboardMode = true  -- Start in keyboard mode
local selectedIndex = 1    -- Start with Resume selected
local lastMouseX, lastMouseY = 0, 0

function pause.update(dt, db)
    local x, y = love.mouse.getPosition()
    local mouseDown = love.mouse.isDown(1)

	-- Detect mouse movement and switch to mouse mode
	if x ~= lastMouseX or y ~= lastMouseY then
		keyboardMode = false
		lastMouseX = x
		lastMouseY = y
	end

	-- Determine which button list to use
	local activeButtons = showLogs and {close} or {resume, save, load, logs, restart, exit}

	if keyboardMode then
		-- Keyboard mode: highlight selected button
		for i, v in ipairs(colors) do
			v.color = {1, 1, 1}  -- Reset all colors
		end
		if selectedIndex >= 1 and selectedIndex <= #activeButtons then
			activeButtons[selectedIndex].color = {0.25, 0.25, 1}
		end
	else
		-- Mouse mode: check hover for active buttons
		local hoveredButton = nil
		for i, v in ipairs(activeButtons) do
			local inXBounds = x >= (v.x - buttonBufferX) and x <= (v.x + v.width + buttonBufferX)
			local inYBounds = y >= (v.height - buttonBufferY) and y <= (v.height + buttonHeight + buttonBufferY)

			if inXBounds and inYBounds then
				v.color = {0.25, 0.25, 1}
				hoveredButton = v
				-- Update selectedIndex to match hovered button for keyboard mode switching
				selectedIndex = i
				if mouseDown and not clickHandled then
					if v == logs then
						logs.func(db)
						showLogs = true
						selectedIndex = 1  -- Reset to close button when logs open
						keyboardMode = true
					else
						v.func()
					end
					clickHandled = true
				end
			else
				v.color = {1, 1, 1}
			end
		end
	end

	if not mouseDown then
        clickHandled = false
    end
end

function pause.draw()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Pause text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({{1, 0.25, 0.25}, "PAUSED"}, screenWidth / 2, screenHeight / 2 - 150, screenWidth, 
		"center", 0, 2, 2, screenWidth / 2, 0)
    love.graphics.printf({resume.color, "Resume"}, 0, resume.height, screenWidth, "center")
	love.graphics.printf({save.color, "Save"}, 0, save.height, screenWidth, "center")
	love.graphics.printf({load.color, "Load"}, 0, load.height, screenWidth, "center")
	love.graphics.printf({logs.color, "Top Scores"}, 0, logs.height, screenWidth, "center")
	love.graphics.printf({restart.color, "Restart"}, 0, restart.height, screenWidth, "center")
	love.graphics.printf({exit.color, "Exit"}, 0, exit.height, screenWidth, "center")

	if showLogs then
		love.graphics.setColor(0, 0, 0, 0.9)
    	love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf({{.25, 1, 0.25}, "Top Scores"}, screenWidth / 2, screenHeight / 2 - 375, screenWidth, 
			"center", 0, 2, 2, screenWidth / 2, 0)
		love.graphics.printf("Rank:", 0, screenHeight / 2 - 300, screenWidth - 900, "center")
		love.graphics.printf("Name:", 0, screenHeight / 2 - 300, screenWidth - 600, "center")
		love.graphics.printf("Time Completed:", 0, screenHeight / 2 - 300, screenWidth-200, "center")
		love.graphics.printf("First Move:", 0, screenHeight / 2 - 300, screenWidth+200, "center")
		love.graphics.printf("Date:", 0, screenHeight / 2 - 300, screenWidth + 600, "center")
		for i,row in ipairs(results) do
			love.graphics.printf(i, 0, screenHeight / 2 - 250 + (i-1) * 50, screenWidth - 900, "center")
			for key, value in pairs(row) do
				if key == "name" then
					local str = value
					local limited = str:sub(1, 20)
					love.graphics.printf(limited, 0, screenHeight / 2 - 250 + (i-1) * 50, screenWidth - 600, "center")
				elseif key == "time_completed" then
					local formatted = string.format("%.4f sec", value)
					love.graphics.printf(formatted, 0, screenHeight / 2 - 250 + (i-1) * 50, screenWidth - 200, "center")
				elseif key == "first_key_used" then
					love.graphics.printf(value, 0, screenHeight / 2 - 250 + (i-1) * 50, screenWidth + 200, "center")
				elseif key == "date_logged" then
					love.graphics.printf(os.date("%Y-%m-%d %H:%M:%S", value), 0, screenHeight / 2 - 250 + (i-1) * 50, screenWidth+600, "center")
				end
			end
		end
		love.graphics.printf({close.color, "Close"}, 0, screenHeight / 2 + 300, screenWidth, "center")
	end
end

resume.func = function()
	isPaused = false
end

save.func = function()
	pause.save()
end

load.func = function()
	if love.filesystem.getInfo(fileName .. ".txt") then
		pause.load()
	end
end

logs.func = function(db)
	if db and db:isopen() then
		local query = "SELECT * FROM log WHERE time_completed > 0 AND time_completed IS NOT NULL ORDER BY time_completed ASC LIMIT 10;"
		results = {}
		for row in db:nrows(query) do
			table.insert(results, row)
		end
	end
end

restart.func = function()
	love.event.quit("restart")
end

exit.func = function()
	love.event.quit()
end

close.func = function()
	showLogs = false
end

function pause.keypressed(key, db)
	-- Determine which button list is active
	local activeButtons = showLogs and {close} or {resume, save, load, logs, restart, exit}

	if key == "up" then
		keyboardMode = true
		selectedIndex = selectedIndex - 1
		if selectedIndex < 1 then
			selectedIndex = #activeButtons
		end
	elseif key == "down" then
		keyboardMode = true
		selectedIndex = selectedIndex + 1
		if selectedIndex > #activeButtons then
			selectedIndex = 1
		end
	elseif key == "return" or key == "space" then
		-- Activate selected button
		if selectedIndex >= 1 and selectedIndex <= #activeButtons then
			local selectedButton = activeButtons[selectedIndex]
			if selectedButton == logs then
				logs.func(db)
				showLogs = true
				selectedIndex = 1  -- Reset to close button when logs open
			elseif selectedButton == close then
				close.func()
				selectedIndex = 1  -- Reset to resume when closing logs
			else
				selectedButton.func()
			end
		end
	end
end

function pause.reset()
	-- Reset to keyboard mode with Resume selected when opening pause menu
	keyboardMode = true
	selectedIndex = 1
	showLogs = false
	isPaused = true  -- Set pause state when opening menu
end

function pause.resume()
	return isPaused
end

-- callbacks to main.lua save and load
function pause.setSaveLoadCallbacks(saveFn, loadFn)
    saveCallback = saveFn
    loadCallback = loadFn
end

function pause.save()
    -- Just call main's save function
	if saveCallback then
		saveCallback(fileName)
	end
end

function pause.load()
    -- Just call main's load function
	if loadCallback then
		loadCallback(fileName)
	end
end

return pause
