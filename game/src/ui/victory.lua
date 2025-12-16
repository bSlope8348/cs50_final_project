-- TODO refactor ...LevelButtons from main.lua

local victory = {}

function victory.draw(rank, timeCompleted)	
	-- Semi-transparent overlay
	love.graphics.setColor(0, 0, 0, 0.85)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	-- Victory text
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf({{0.5, 1, 0.75}, "VICTORY!"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 150,
		love.graphics.getWidth(), "center", 0, 4, 4, love.graphics.getWidth() / 2, 0)
	love.graphics.printf({{1, 1, 0}, "Time: " .. string.format("%.2f", timeCompleted) .. " seconds"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,
		love.graphics.getWidth(), "center", 0, 2, 2, love.graphics.getWidth() / 2, 0)
	love.graphics.printf({{1, 1, 1}, "Your Rank: " .. rank}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 + 80,
		love.graphics.getWidth(), "center", 0, 1.5, 1.5, love.graphics.getWidth() / 2, 0)

	-- Draw buttons
	-- Next Level button
	if nextLevelButton.hover then
		love.graphics.setColor(0.3, 0.6, 0.3)
	else
		love.graphics.setColor(0.2, 0.5, 0.2)
	end
	love.graphics.rectangle("fill", nextLevelButton.x, nextLevelButton.y, nextLevelButton.width, nextLevelButton.height, 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", nextLevelButton.x, nextLevelButton.y, nextLevelButton.width, nextLevelButton.height, 10, 10)
	love.graphics.printf(nextLevelButton.text, nextLevelButton.x, nextLevelButton.y + 15, nextLevelButton.width, "center")

	-- Restart button
	if restartButton.hover then
		love.graphics.setColor(0.6, 0.3, 0.3)
	else
		love.graphics.setColor(0.5, 0.2, 0.2)
	end
	love.graphics.rectangle("fill", restartButton.x, restartButton.y, restartButton.width, restartButton.height, 10, 10)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", restartButton.x, restartButton.y, restartButton.width, restartButton.height, 10, 10)
	love.graphics.printf(restartButton.text, restartButton.x, restartButton.y + 15, restartButton.width, "center")
end

return victory
