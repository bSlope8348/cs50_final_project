--[[local r1, r2
local Rectangle = require "src.rectangle"

local function checkCollision(a, b)
    local a_left = a.x
    local a_right = a.x + a.width
    local a_top = a.y
    local a_bottom = a.y + a.height

	local b_left = b.x
    local b_right = b.x + b.width
    local b_top = b.y
    local b_bottom = b.y + b.height

    return  a_right > b_left
        and a_left < b_right
        and a_bottom > b_top
        and a_top < b_bottom
end

function love.load()
    --Create 2 rectangles
    r1 = Rectangle(10, 100, 100, 100)

    r2 = Rectangle(200, 120, 150, 120)
end

function love.update(dt)
	if not checkCollision(r1, r2) then
		r1.speed = 200
		r2.speed = 100
	else
		r1.speed = 100
		r2.speed = 50
	end
	r1:update(dt, r1.speed)
	r2:update(dt, r2.speed)
end

function love.draw()
    local mode
    if checkCollision(r1, r2) then
        mode = "fill"
    else
        mode = "line"
    end
	love.graphics.setColor(1, 0, 0)
	r1:draw(mode)
	love.graphics.setColor(0, 0, 1)
	r2:draw(mode)
	love.graphics.setColor(1, 1, 1)
end
]]
