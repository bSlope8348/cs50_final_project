--[[local Object = require "lib.classic"
local Laser = Object:extend()

function Laser:new(x, y)
	self.image = love.graphics.newImage("assets/kenney/PNG/Lasers/laserGreen10.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.x = x - self.width / 2
	self.y = y - self.height
	self.speed = 700
end

function Laser:update(dt)
	self.y = self.y - self.speed * dt

	if self.y < 0 then
		love.load()
	end
end

function Laser:draw()
	love.graphics.draw(self.image, self.x, self.y)
end

function Laser:checkCollision(obj)
    local self_left = self.x
    local self_right = self.x + self.width
    local self_top = self.y
    local self_bottom = self.y + self.height

    local obj_left = obj.x
    local obj_right = obj.x + obj.width
    local obj_top = obj.y
    local obj_bottom = obj.y + obj.height

	if self_right > obj_left
    and self_left < obj_right
    and self_bottom > obj_top
    and self_top < obj_bottom
	then
		self.dead = true
		if obj.speed > 0 then
			obj.speed = obj.speed + 50
		else
			obj.speed = obj.speed - 50
		end
	end
end

return Laser
]]
