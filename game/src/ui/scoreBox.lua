local Object = require "lib.classic"
local ScoreBox = Object:extend()

function ScoreBox:new(x, y, score, title, units)
	self.score = score
	self.title =  title
	self.units = units
    self.x = x
    self.y = y
	self.width = 400
	self.height = 40
	love.graphics.setFont (love.graphics.newFont (30))
	self.font = love.graphics.getFont()
	self.text= love.graphics.newText(self.font, tostring(self.title) .. string.format("%07.2f", self.score) .. tostring(self.units))
end

function ScoreBox:update(dt, score)
	self.score = score
	self.text= love.graphics.newText(self.font, tostring(self.title) .. string.format("%07.2f", self.score) .. tostring(self.units))
end

function ScoreBox:draw()
    love.graphics.setColor(0, 0, 0, 0.85)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.text, self.x + 10, self.y + 5)
end

return ScoreBox
