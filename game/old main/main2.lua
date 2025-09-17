--[[local Player = require "src.player"
local Enemy = require "src.enemy"
local Laser = require "src.laser"
local ScoreBox = require "src.ui.scoreBox"
local player1, enemy1, score1, score
local listOfLasers = {}

function love.load()
	player1 = Player()
	enemy1 = Enemy()
	listOfLasers = {}
	score = 0
	score1 = ScoreBox(10, enemy1.height + enemy1.y, score)
end

function love.update(dt)
	player1:update(dt)
	enemy1:update(dt)
	for i,v in ipairs(listOfLasers) do
		v:update(dt)
		v:checkCollision(enemy1)
		if v.dead then
			table.remove(listOfLasers, i)
			score = score + 1
		end
	end
	score1:update(dt, score)
end

function love.draw()
	player1:draw()
	enemy1:draw()
	for i,v in ipairs(listOfLasers) do
		v:draw()
	end
	score1:draw()
end

function love.keypressed(key)
	player1:keyPressed(key, listOfLasers)
end
]]
