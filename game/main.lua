local jumps, currentFrame, image, maxJumps,	frame_width, frame_height, width, height

function love.load()
	image = love.graphics.newImage('assets/jumps/jump_border.png')
	jumps = {}
	frame_width = 117 --image:getWidth() / 3
	frame_height = 233 --image:getHeight() / 2
	width = image:getWidth()
	height = image:getHeight()
	maxJumps = 5
	for i=0,1 do
		for j=0,2 do
			table.insert(jumps, love.graphics.newQuad(1 + j * (frame_width + 2), 1 + i * (frame_height + 2), frame_width, frame_height, width, height))
			if #jumps == maxJumps then
				break
			end
		end
	end
	currentFrame = 1
end

function love.update(dt)
	currentFrame = currentFrame + dt * 10
	if currentFrame >= 6 then
		currentFrame = 1
	end
end

function love.draw()
	love.graphics.draw(image, jumps[math.floor(currentFrame)], 100, 100)
end
