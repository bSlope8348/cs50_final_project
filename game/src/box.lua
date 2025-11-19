Box = Entity:extend()

function Box:new(x, y)
    Box.super.new(self, x, y, "assets/object/elementMetal011.png")
end
