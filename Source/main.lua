-- 400 x 240

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'CoreLibs/frameTimer'
import 'CoreLibs/animation'

import "animations"
import "player"
import "ball"
import "wall"
import "brick"

local pd <const> = playdate
local gfx <const> = pd.graphics

gfx.setBackgroundColor(gfx.kColorWhite)
gfx.clear()

function initialize()
	createWindowBounds()
	drawBricks()
	local playerInstance = Player( 200, 225, 50, 5 )
	local ballInstance = Ball( 0, 0, 3, playerInstance )
	playerInstance:add()
	ballInstance:attachToPaddle()
	ballInstance:add()
end

function createWindowBounds()
	local padding = 15
	local displayWidth = pd.display.getWidth()
	local displayHeight = pd.display.getHeight()
	
	Wall( 0, 0, displayWidth, padding ) -- Top Wall
	Wall( 0, padding, padding, displayHeight - padding ) -- Left Wall
	Wall( displayWidth - padding, padding, padding, displayHeight- padding ) -- Right Wall
	-- Wall( 0, displayHeight - padding, displayWidth, padding ) -- Bottom Wall
end

function drawBricks()
	local windowWidthChunk = pd.display.getWidth() / 10
	local initX = windowWidthChunk
	local initY = 20
	local initHealth = 6
	for i = 1, 5 do
		local brickY = initY * i
		local brickHealth = 1
		for j = 1, 8 do
			local brickX = initX * j
			local tf = {true, false}
			local applyAnimation = tf[ math.random(1, 2) ]
			local currBrick = Brick( brickX, brickY, 35, 13, brickHealth )
			if applyAnimation then
				Animations:blinkAnimation( currBrick, math.random(1, 10) )
			end
		end
	end
end

initialize()

function pd.update()
	gfx.sprite.update()
	pd.timer.updateTimers()
	pd.frameTimer.updateTimers()
	pd.drawFPS(0,0)
end