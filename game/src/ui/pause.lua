local pause = {}
local isPaused

local resume = {}
local save = {}
local load = {}
local logs = {}
local restart = {}
local exit = {}
local colors = {resume, save, load, logs, restart, exit}

resume.height = love.graphics.getHeight() / 2 - 50
save.height = love.graphics.getHeight() / 2
load.height = love.graphics.getHeight() / 2 + 50
logs.height = love.graphics.getHeight() / 2 + 100
restart.height = love.graphics.getHeight() / 2 + 150
exit.height = love.graphics.getHeight() / 2 + 200
for i,v in ipairs(colors) do
	v.color = {1, 1, 1}
end

function pause.update(dt)
	isPaused = true
	local x, y = love.mouse.getPosition()
	for i,v in ipairs(colors) do
		if y < v.height + 50 and y > v.height then
			v.color = {0.25, 0.25, 1}
			if love.mouse.isDown(1) then
				v.func()
			end
		else
			v.color = {1, 1, 1}
		end
	end
end

function pause.draw()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Pause text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({{1, 0.25, 0.25}, "PAUSED"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 150, love.graphics.getWidth(), 
		"center", 0, 2, 2, love.graphics.getWidth() / 2, 0)
    love.graphics.printf({resume.color, "Resume"}, 0, resume.height, love.graphics.getWidth(), "center")
	love.graphics.printf({{1, 1, 1, 0.5}, "Save"}, 0, save.height, love.graphics.getWidth(), "center") --save.color,
	love.graphics.printf({{1, 1, 1, 0.5}, "Load"}, 0, load.height, love.graphics.getWidth(), "center") --load.color,
	love.graphics.printf({{1, 1, 1, 0.5}, "Logs"}, 0, logs.height, love.graphics.getWidth(), "center") --logs.color,
	love.graphics.printf({restart.color, "Restart"}, 0, restart.height, love.graphics.getWidth(), "center")
	love.graphics.printf({exit.color, "Exit"}, 0, exit.height, love.graphics.getWidth(), "center")
end

resume.func = function()
	isPaused = false
end

save.func = function()
	-- TODO
end

load.func = function()
	-- TODO
end

logs.func = function()
	-- TODO
end

restart.func = function()
	love.event.quit("restart")
end

exit.func = function()
	love.event.quit()
end

function pause.resume()
	return isPaused
end

return pause
