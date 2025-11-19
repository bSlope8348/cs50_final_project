Floor = Entity:extend()

function Floor:new(x, y)
    Wall.super.new(self, x, y, "assets/environment/tile.png")
	self.strength = 100
	self.weight = 0
end
