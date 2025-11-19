Coin = Entity:extend()

function Coin:new(x, y)
    Coin.super.new(self, x, y, "assets/object/tile_coin.png")
	self.weight = 0
	self.remove = 0
end
