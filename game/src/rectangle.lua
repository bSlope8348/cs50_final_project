local Shape = require "src.shape"
local Rectangle = Shape:extend()

function Rectangle:new(x, y, width, height, speed)
	Rectangle.super.new(self, x, y, speed)
    self.width = width
    self.height = height
	self.speed =  speed
end

function Rectangle:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return Rectangle
