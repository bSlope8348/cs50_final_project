local Object = require "lib.classic"
local ScoreBox = Object:extend()

function ScoreBox:new(x, y, score)
	self.score = score
    self.x = x
    self.y = y
	self.width = 100
	self.height = 80
	love.graphics.setFont (love.graphics.newFont (50))
	self.font = love.graphics.getFont()
	self.text= love.graphics.newText(self.font, tostring(self.score))
end

function ScoreBox:update(dt, score)
	self.score = score
	self.text= love.graphics.newText(self.font, tostring(self.score))
end

function ScoreBox:draw()
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.draw(self.text, self.x + 10, self.y + 10)
end

return ScoreBox
