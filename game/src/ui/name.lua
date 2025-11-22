local name = {}

local playerName = ""
local ready = false
----------------------------------------------------------------------
local InputField = require("lib/InputField")

local FONT_SIZE        = 20
local FONT_LINE_HEIGHT = 1

local FIELD_TYPE = "normal" -- Possible values: normal, password, multiwrap, multinowrap

local FIELD_OUTER_WIDTH  = 300
local FIELD_OUTER_HEIGHT = 40
local FIELD_PADDING      = 10
local FIELD_OUTER_X      = love.graphics.getWidth() / 2 - FIELD_OUTER_WIDTH / 2
local FIELD_OUTER_Y      = love.graphics.getHeight() / 2 - 75

local FIELD_INNER_X      = FIELD_OUTER_X + FIELD_PADDING
local FIELD_INNER_Y      = FIELD_OUTER_Y + FIELD_PADDING
local FIELD_INNER_WIDTH  = FIELD_OUTER_WIDTH  - 2*FIELD_PADDING
local FIELD_INNER_HEIGHT = FIELD_OUTER_HEIGHT - 2*FIELD_PADDING

local BLINK_INTERVAL  = 0.90

local theFont = love.graphics.newFont(FONT_SIZE)
theFont:setLineHeight(FONT_LINE_HEIGHT)

local field = InputField(playerName, FIELD_TYPE)
field:setFont(theFont)
field:setDimensions(FIELD_INNER_WIDTH, FIELD_INNER_HEIGHT)

function love.textinput(text)
	field:textinput(text)
end

function love.mousepressed(mx, my, mbutton, pressCount)
	field:mousepressed(mx-FIELD_INNER_X, my-FIELD_INNER_Y, mbutton, pressCount)
end

function love.mousemoved(mx, my, dx, dy)
	field:mousemoved(mx-FIELD_INNER_X, my-FIELD_INNER_Y)
end

function love.mousereleased(mx, my, mbutton, pressCount)
	field:mousereleased(mx-FIELD_INNER_X, my-FIELD_INNER_Y, mbutton)
end
-----------------------------------------

local submit = {}
local clear = {}
local fields = {submit, clear}

submit.height = love.graphics.getHeight() / 2
clear.height = love.graphics.getHeight() / 2 + 50

for i,v in ipairs(fields) do
	v.color = {1, 1, 1}
end

function name.update(dt)
	----------------------------
	field:update(dt)
	---------------------------

	local x, y = love.mouse.getPosition()
	for i,v in ipairs(fields) do
		if y < v.height + 50 and y > v.height then
			v.color = {0.25, 0.25, 1}
			if love.mouse.isDown(1) then
				v.func()
			end
		else
			v.color = {1, 1, 1}
		end
	end
end

function name.draw()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- name text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({"Enter Name:"}, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 150, love.graphics.getWidth(), 
		"center", 0, 2, 2, love.graphics.getWidth() / 2, 0)
	love.graphics.printf({submit.color, "Submit"}, 0, submit.height, love.graphics.getWidth(), "center")
	love.graphics.printf({clear.color, "Clear"}, 0, clear.height, love.graphics.getWidth(), "center")

	-----------------------------------------------------
	-- Input field.
	love.graphics.setScissor(FIELD_OUTER_X, FIELD_OUTER_Y, FIELD_OUTER_WIDTH, FIELD_OUTER_HEIGHT)

	-- Background.
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", FIELD_OUTER_X, FIELD_OUTER_Y, FIELD_OUTER_WIDTH, FIELD_OUTER_HEIGHT)

	-- Selection.
	love.graphics.setColor(.2, .2, 1)
	for _, selectionX, selectionY, selectionWidth, selectionHeight in field:eachSelection() do
		love.graphics.rectangle("fill", FIELD_INNER_X+selectionX, FIELD_INNER_Y+selectionY, selectionWidth, selectionHeight)
	end

	-- Text.
	love.graphics.setFont(theFont)
	love.graphics.setColor(0, 0, 0)
	for _, lineText, lineX, lineY in field:eachVisibleLine() do
		love.graphics.print(lineText, FIELD_INNER_X+lineX, FIELD_INNER_Y+lineY)
	end

	-- Cursor.
	local cursorWidth = 2
	local cursorX, cursorY, cursorHeight = field:getCursorLayout()
	local alpha = ((field:getBlinkPhase() / BLINK_INTERVAL) % 1 < .5) and 1 or 0
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.rectangle("fill", FIELD_INNER_X+cursorX-cursorWidth/2, FIELD_INNER_Y+cursorY, cursorWidth, cursorHeight)

	love.graphics.setScissor()

	love.graphics.setColor(1, 1, 1)
	-------------------------------------------------------
end

function name.submittedName()
	return playerName
end

function name.ready()
	return ready
end

submit.func = function()
	playerName = field.text
	ready = true
end

clear.func = function()
	-- TODO
end

return name
