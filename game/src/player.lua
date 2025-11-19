Player = Entity:extend()

function Player:new(x, y)
    Player.super.new(self, x, y, "assets/character/alienBeige_square.png")
	self.strength = 10
	self.weight = 400
	self.canJump = false
	self.speed = 300
	self.hasCoin = 0
end

function Player:update(dt)
    -- It's important that we do this before changing the position
    Player.super.update(self, dt)

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    end

	if self.last.y ~= self.y then
		self.canJump = false
	end
end

function Player:jump()
	if self.canJump then
		self.gravity = -500
		self.canJump = false
	end
end

function Player:collide(e, direction)
    Player.super.collide(self, e, direction)
    if direction == "bottom" then
        self.canJump = true
    end
end

function Player:checkResolve(e, direction)
    if e:is(ThruFloor) then
        if direction == "top" then
            return true
        else
            return false
        end
    end
	if e:is(Coin) then
		print("Coin Collected")
		e.remove = 1
		self.hasCoin = 1
		self.image = love.graphics.newImage("assets/character/alienYellow_square.png")
		return false
	end
    return true
end
