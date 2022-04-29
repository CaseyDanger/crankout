-- 400 x 240

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'CoreLibs/frameTimer'

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
	local padding = 5
	local displayWidth = pd.display.getWidth()
	local displayHeight = pd.display.getHeight()
	
	Wall( 0, 0, displayWidth, padding )
	Wall( 0, padding, padding, displayHeight - padding * 2 )
	Wall( displayWidth - padding, padding, padding, displayHeight- padding * 2 )
	Wall( 0, displayHeight - padding, displayWidth, padding )
end

function drawBricks()
	local windowWidthChunk = pd.display.getWidth() / 10
	local initX = windowWidthChunk
	local initY = 20
	for i = 1, 5 do
		local brickY = initY * i
		for j = 1, 8 do
			local brickX = initX * j
			Brick( brickX, brickY, 30, 5 )
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