local pd <const> = playdate
local gfx <const> = pd.graphics

import 'block'

class("Wall").extends(Block)

function Wall:init( x, y, width, height )
	Wall.super.init( self, x, y, width, height )
end

function Wall:draw( x, y, width, height )
	local cx, cy, width, height = self:getCollideBounds()
	-- gfx.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(cx, cy, width, height)
end