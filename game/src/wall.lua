Wall = Entity:extend()

function Wall:new(x, y)
    Wall.super.new(self, x, y, "assets/wall23.png")
	self.strength = 100
end
