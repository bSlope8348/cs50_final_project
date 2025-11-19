Exit = Entity:extend()

function Exit:new(x, y)
    Box.super.new(self, x, y, "assets/environment/tile_exclamation.png")
	self.strength = 100
	self.weight = 0
end
