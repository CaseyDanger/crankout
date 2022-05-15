local pd <const> = playdate
local gfx <const> = pd.graphics
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local brickImageTable = gfx.imagetable.new('img/brick')

import 'block'
import 'animations'

class('Brick').extends(Block)

function Brick:init( x, y, width, height, health )
	Brick.super.init( self, x, y, width, height )
	
	self:setImage( brickImageTable:getImage(1) )
	self.health = health or 3
	self.initHealth = self.health
	self.dither = 0
end

function Brick:draw()
	-- local cx, cy, width, height = self:getCollideBounds()
	-- gfx.setColor( gfx.kColorBlack )
	-- gfx.setDitherPattern( self.dither )
	-- gfx.fillRoundRect( cx, cy, width, height, 1 )
end

function Brick:hit( damage )
	self.health -= damage
	self.dither = abs( self.health / self.initHealth - 1 )
	self:markDirty()
	if self.health <= 0 then
		self:clearCollideRect()
		self:remove()
	end
end

local function blinkEyes( blinkTimer )
	blinkTimer.brickInstance:setImage( brickImageTable:getImage( blinkSequence[blinkTimer.frame] ) )
end

function Brick:blinkAnimation( brick, delay )
	local blinkTimer = pd.frameTimer.new( #blinkSequence )
	blinkTimer.delay = delay * 30
	blinkTimer.brickInstance = brick
	blinkTimer.updateCallback = blinkEyes
end