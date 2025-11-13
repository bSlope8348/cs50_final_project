--[[local Object = require "lib.classic"
local Enemy = Object:extend()

function Enemy:new()
    self.image = love.graphics.newImage("assets/kenney/PNG/Enemies/enemyBlack4.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
    self.x = 100
    self.y = 10
    self.speed = 100
end

function Enemy:update(dt)
	self.x = self.x + self.speed * dt
    local window_width = love.graphics.getWidth()
	if self.x <= 0 then
		self.x = 0
		self.speed = -self.speed
	elseif self.x + self.image:getWidth() >= window_width then
		self.x = window_width - self.image:getWidth()
		self.speed = -self.speed
	end
end

function Enemy:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

return Enemy
]]
