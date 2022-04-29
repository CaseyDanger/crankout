local pd <const> = playdate
local gfx <const> = pd.graphics

class('Block').extends(gfx.sprite)

function Block:init( x, y, width, height )
	self:moveTo( x, y )
	self:setSize( width, height )
	self:setCenter( 0, 0 )
	self:addSprite()
	self:setCollideRect( 0, 0, width, height )
end