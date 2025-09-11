function love.load()
	listOfRectangles = {}
end

function createRect()
    rect = {}
    rect.x = 100
    rect.y = 100
    rect.width = 70
    rect.height = 90
	rect.speed = 200
	table.insert(listOfRectangles, rect)
end

function love.keypressed(key)
	if key == "space" then
		createRect()
	end
end

function love.update(dt)
	for i,rec in ipairs(listOfRectangles) do
		rec.x = rec.x + rec.speed * dt
	end
end

function love.draw()
	for i,rec in ipairs(listOfRectangles) do
		love.graphics.rectangle("line", rec.x, rec.y, rec.width, rec.height)
	end
end
