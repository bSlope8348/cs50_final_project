Box = Entity:extend()

function Box:new(x, y)
    Box.super.new(self, x, y, "assets/box.png")
	self.strength = 0
end
