local Shape = require "src.shape"
local Circle = Shape:extend()

function Circle:new(x, y, radius, speed)
    Circle.super.new(self, x, y, speed)
    --A circle doesn't have a width or height. It has a radius.
    self.radius = radius
	self.speed = speed
end

function Circle:draw()
    love.graphics.circle("line", self.x, self.y, self.radius)
end

return Circle
