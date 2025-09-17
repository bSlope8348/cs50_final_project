local mouse_x, mouse_y, dist, enemy
local getDistance

function love.load()
	enemy = {}
	enemy.image = love.graphics.newImage("assets/kenney/PNG/Enemies/enemyBlue1.png")
	enemy.origin_x = enemy.image:getWidth() / 2
	enemy.origin_y = enemy.image:getWidth() / 2
    enemy.x = 100
    enemy.y = 100
	enemy.angle = 0
	enemy.angle_offset = - math.pi / 2
    enemy.speed = 100
	enemy.attack_dist = 150
end

function love.update(dt)
	mouse_x, mouse_y = love.mouse.getPosition()

	enemy.angle = math.atan2(mouse_y - enemy.y, mouse_x - enemy.x)
	dist = getDistance(enemy.x, enemy.y, mouse_x, mouse_y)
	if dist <= enemy.attack_dist then
		enemy.x = enemy.x + enemy.speed * dt * math.cos(enemy.angle) * (dist/100)
		enemy.y = enemy.y + enemy.speed * dt * math.sin(enemy.angle) * (dist/100)
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)

	love.graphics.print("angle: " .. enemy.angle, 10, 10)
	love.graphics.print("distance: " .. dist, 10, 30)
	love.graphics.setColor(0, 0, 1)
	love.graphics.line(enemy.x, enemy.y, mouse_x, enemy.y)
    love.graphics.line(enemy.x, enemy.y, enemy.x, mouse_y)
	love.graphics.line(enemy.x, enemy.y, mouse_x, mouse_y)
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("line", enemy.x, enemy.y, enemy.attack_dist)
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("line", enemy.x, enemy.y, dist)

	love.graphics.draw(enemy.image, enemy.x, enemy.y, enemy.angle + enemy.angle_offset, 0.75, 0.75, enemy.origin_x, enemy.origin_y)

	love.graphics.circle("fill", mouse_x, mouse_y, 5)
end

function getDistance(x1, y1, x2, y2)
	local distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
	return distance
end
