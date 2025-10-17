--[[local tilemap, image, width, height, quads, player, keyRed, has_red_key, doorRed, song, sfx
local isOpenSpace, keyAquired, doorAndKey

function love.load()
    image = love.graphics.newImage("assets/tileset.png")

    local image_width = image:getWidth()
    local image_height = image:getHeight()
    width = (image_width / 3) - 2
    height = (image_height / 2) - 2

    quads = {}

    for i=0,1 do
        for j=0,2 do
            table.insert(quads,
                love.graphics.newQuad(
                    1 + j * (width + 2),
                    1 + i * (height + 2),
                    width, height,
                    image_width, image_height))
        end
    end

	tilemap = {
		{1, 6, 6, 2, 1, 6, 6, 2, 1, 6, 6, 2, 1, 6, 6, 2},
		{3, 0, 0, 4, 5, 0, 0, 3, 3, 0, 0, 4, 5, 0, 0, 3},
		{3, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 3},
		{4, 2, 0, 0, 0, 0, 1, 5, 4, 2, 0, 0, 0, 0, 1, 5},
		{1, 5, 0, 0, 0, 0, 4, 2, 1, 5, 0, 0, 0, 0, 4, 2},
		{3, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 3},
		{3, 0, 0, 1, 2, 0, 0, 3, 3, 0, 0, 1, 2, 0, 0, 3},
		{4, 6, 6, 5, 4, 6, 6, 5, 4, 6, 6, 5, 4, 6, 6, 5}
	}

	--Create our player
    player = {
        image = love.graphics.newImage("assets/player.png"),
        tile_x = 2,
        tile_y = 2
    }

	--Create keys
	has_red_key = 0
	keyRed = {
		image = love.graphics.newImage("assets/kenney/PNG/Power-ups/powerupRed_star.png"),
		tile_x = 5,
		tile_y = 6
	}

	--Create Doors
	doorRed = {
		image = love.graphics.newImage("assets/kenney/PNG/Power-ups/powerupRed_star.png"),
		tile_x = 8,
		tile_y = 3
	}

	song = love.audio.newSource("assets/audio/song.ogg", "stream")
	song:setLooping(true)
	song:play()
	sfx = love.audio.newSource("assets/audio/sfx.ogg", "static")
end

function love.draw()
    for i,row in ipairs(tilemap) do
        for j,tile in ipairs(row) do
            if tile ~= 0 then
                --Draw the image
                love.graphics.draw(image, quads[tile], j * width, i * height)
            end 
        end
    end

	--Draw the player and multiply its tile position with the tiem width and height
	love.graphics.draw(player.image, player.tile_x * width, player.tile_y * height)

	--Draw key
	love.graphics.draw(keyRed.image, keyRed.tile_x * width, keyRed.tile_y * height)

	love.graphics.print("Keys Aquired:", 1 * width, 9.5 * height)

	--Draw door
	love.graphics.draw(doorRed.image, doorRed.tile_x * width, doorRed.tile_y * height, 0, 0.5, 0.5, -width/2, -height/2)
	love.graphics.draw(doorRed.image, (doorRed.tile_x + 1) * width, doorRed.tile_y * height, 0, 0.5, 0.5, -width/2, -height/2)
end

function love.keypressed(key)
	local x = player.tile_x
	local y = player.tile_y

	if key == "left" then 
		x = x - 1
	elseif key == "right" then
		x = x + 1
	elseif key == "up" then
		y = y - 1
	elseif key == "down" then
		y = y + 1
	end

    if isOpenSpace(x, y) then
        player.tile_x = x
        player.tile_y = y
	else
		sfx:play()
    end
	if keyAquired(x, y) then
		has_red_key = 1
		keyRed.tile_x = 1
		keyRed.tile_y = 10
	end
	if doorAndKey(x, y) then
		tilemap[doorRed.tile_y][doorRed.tile_x] = 0
		tilemap[doorRed.tile_y][doorRed.tile_x + 1] = 0
	end
end

function isOpenSpace(x, y)
    return tilemap[y][x] == 0
end

function keyAquired(x, y)
	if x == keyRed.tile_x and y == keyRed.tile_y then
		return true
	end
end

function doorAndKey(x, y)
	if x == doorRed.tile_x and y == doorRed.tile_y and has_red_key == 1 then
		return true
	end
end
]]
