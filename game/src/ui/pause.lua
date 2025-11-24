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

resume.height = screenHeight / 2 - 50
save.height = screenHeight / 2
load.height = screenHeight / 2 + 50
logs.height = screenHeight / 2 + 100
restart.height = screenHeight / 2 + 150
exit.height = screenHeight / 2 + 200
close.height = screenHeight / 2 + 300
for i,v in ipairs(colors) do
	v.color = {1, 1, 1}
end

local clickHandled = false

function pause.update(dt, db)
	isPaused = true
    local x, y = love.mouse.getPosition()
    local mouseDown = love.mouse.isDown(1)
	for i,v in ipairs(colors) do
		if y < v.height + 50 and y > v.height then
			v.color = {0.25, 0.25, 1}
			if mouseDown and not clickHandled then
				if v == logs then
					logs.func(db)
					showLogs = true
				else
					v.func()
				end
				clickHandled = true
			end
		else
			v.color = {1, 1, 1}
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
