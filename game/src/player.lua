local Object = require "lib.classic"
local Player = Object:extend()
local Laser = require "src.laser"

function Player:new()
	self.image = love.graphics.newImage("assets/kenney/PNG/playerShip1_red.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
    self.x = 300
    self.y = love.graphics.getHeight() - 10 - self.height
    self.speed = 500
end

function Player:update(dt)
	if love.keyboard.isDown("left") then
		self.x = self.x - self.speed * dt
	elseif love.keyboard.isDown("right") then
		self.x = self.x + self.speed * dt
	end

	local window_width = love.graphics.getWidth()

	if self.x <= 0 then
		self.x = 0
	elseif self.x + self.image:getWidth() >= window_width then
		self.x = window_width - self.image:getWidth()
	end
end

function Player:draw()
    love.graphics.draw(self.image, self.x,	self.y)
end

function Player:keyPressed(key, list)
	if key == "space" then
		table.insert(list, Laser(self.x + self.image:getWidth()/2, self.y))
	end
end

return Player
