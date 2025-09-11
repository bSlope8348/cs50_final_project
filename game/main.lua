require("src.example")
--require("lib.tick")
local tick = require "lib.tick"
local x = 30
local y = 50
function love.load()
	
	drawRectangle = false
	tick.delay(function () drawRectangle = true end , 2)
	ListOfRectangles = {}

end

function createRect()
    local rect = {}
    rect.x = 100
    rect.y = 100
    rect.width = 70
    rect.height = 90
	rect.speed = 200
	table.insert(ListOfRectangles, rect)
end

function love.keypressed(key)
	if key == "space" then
		createRect()
	end
	    --If space is pressed then..
    if key == "space" then
        --x and y become a random number between 100 and 500
        x = math.random(100, 500)
        y = math.random(100, 500)
    end
end

function love.update(dt)
	tick.update(dt)
	for i,rec in ipairs(ListOfRectangles) do
		rec.x = rec.x + rec.speed * dt
	end
end

function love.draw()
	love.graphics.rectangle("line", x, y, 100, 100)
	if drawRectangle then
    	love.graphics.rectangle("fill", 100, 100, 300, 200)
    end
	for i,rec in ipairs(ListOfRectangles) do
		love.graphics.rectangle("line", rec.x, rec.y, rec.width, rec.height)
	end
end

