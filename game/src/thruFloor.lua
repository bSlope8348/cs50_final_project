ThruFloor = Entity:extend()

function ThruFloor:new(x, y)
    Wall.super.new(self, x, y, "assets/environment/tile_half.png")
	self.strength = 100
	self.weight = 0
end

--[[function ThruFloor:checkResolve(e, direction)
    if e:is(Player) then
        if direction == "left" or direction == "right" then
            return true
        else
            return false
        end
    end
    return true
end
]]
