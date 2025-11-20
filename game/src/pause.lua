local pause = {}
local isPaused

local resume = {}
local save = {}
local load = {}
local exit = {}
local colors = {resume, save, load, exit}

resume.height = love.graphics.getHeight() / 2 - 50
save.height = love.graphics.getHeight() / 2
load.height = love.graphics.getHeight() / 2 + 50
exit.height = love.graphics.getHeight() / 2 + 100
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
	love.graphics.printf({save.color, "Save"}, 0, save.height, love.graphics.getWidth(), "center")
	love.graphics.printf({load.color, "Load"}, 0, load.height, love.graphics.getWidth(), "center")
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

exit.func = function()
	love.event.quit()
end

function pause.resume()
	return isPaused
end

return pause
