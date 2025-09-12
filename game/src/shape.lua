local Object = require "lib.classic"
local Shape = Object:extend()

function Shape:new(x, y)
    self.x = x
    self.y = y
end

function Shape:update(dt, speed)
    self.x = self.x + speed * dt
end

return Shape
