Exit = Entity:extend()

function Exit:new(x, y)
    Exit.super.new(self, x, y, "assets/environment/tile_exclamation.png")
	self.strength = 100
	self.weight = 0
	self.transparency = 0.5
end

function Exit:draw()
	love.graphics.setColor(1, 1, 1, self.transparency)
    love.graphics.draw(self.image, self.x, self.y)
	love.graphics.setColor(1, 1, 1, 1)
end

function Exit:checkResolve(e, direction)
	if e:is(Player) and e.hasCoin == 1 then
		print("WINNER!")
		return false
	end
	if self.transparency == 0.5 then
		return false
	end
    return true
end
