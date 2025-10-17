--[[Object = require "lib.classic"

Circle = Object:extend()

function Circle:new()
    self.x = 100
    self.y = 100
end

function Circle:draw(offset)
    love.graphics.circle("fill", self.x + offset, self.y, 25)
end

function love.load()
    circle = Circle()
end

function love.draw()
    circle:draw(10)
    circle:draw(70)
    circle:draw(140)
    circle:draw(210)
end
]]
