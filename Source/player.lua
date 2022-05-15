local pd <const> = playdate
local gfx <const> = pd.graphics
local pnt <const> = pd.geometry.point
local v2d <const> = pd.geometry.vector2D
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local af = pd.geometry.affineTransform.new()
local defaultRadius = 1
local dt = 0.06
local MAX_VELOCITY = 600
local NORMAL_FRICTION = 0.8
local SKID_FRICTION = 0.7

class("Player").extends(gfx.sprite)

function Player:init( x, y, width, height )
	self:moveTo( x, y )
	self:setSize( width, 100 )
	self:setCenter( 0.5, 1 )
	self._x = x
	self._y = y
	self.dx = 0
	self.dy = 0
	self._width = width
	self._height = height
	self.position = pnt.new( x, y )
	self.velocity = v2d.new( 0, 0 )
	self.paddleRect = pd.geometry.rect.new( ( ( self.width / 2 ) - ( width / 2 ) ), self.height - height, width, height )
	self:setCollideRect( self.paddleRect )
	self.paddle = pd.geometry.lineSegment.new( width / 2, self.height / 2, width / 2, self.height - height )
	self.paddleAxis = pnt.new( width / 2, self.height - height )
	self.moveSpeed = 20
	self.skidding = false
end

function Player:draw()
	local cx, cy, width, height = self:getCollideBounds()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRoundRect( self.paddleRect, defaultRadius )
	-- gfx.setLineWidth(1)
	-- gfx.setLineCapStyle(gfx.kLineCapStyleRound)
	-- gfx.drawLine( self.paddle )
end

function Player:updatePositionDpad()
	if pd.buttonIsPressed( pd.kButtonRight ) then
		self.velocity.x = min(self.velocity.x + self.moveSpeed, MAX_VELOCITY) 
		if pd.buttonJustPressed( pd.kButtonRight ) then
			if self.velocity.x < -self.moveSpeed then
				self.skidding = true
			else
				self.skidding = false
			end
		end
	elseif pd.buttonIsPressed( pd.kButtonLeft ) then
		self.velocity.x = max(self.velocity.x - self.moveSpeed, -MAX_VELOCITY)
		if pd.buttonJustPressed( pd.kButtonLeft ) then
			if self.velocity.x > self.moveSpeed then
				self.skidding = true
			else
				self.skidding = false
			end
		end
	end
	
	local cols, cols_len
	self.position.x, self.position.y, cols, cols_len = self:moveWithCollisions( self.position )

	for i=1, cols_len do
		local c = cols[i]
		if c.other:isa(Wall) then
			self.velocity.x = 0
		end
	end
end

function Player:updatePositionWithCrank()
	local moveAmt, moveAmtAcc = pd.getCrankChange()
	
	self.velocity.x += moveAmt
	-- local velocityStep = self.velocity.x * dt
	local velocityStep = self.velocity.x * dt
	self.position.x = self.position.x + velocityStep
	
	-- self.velocity.x = min( abs(moveAmt), MAX_VELOCITY )


	local cols, cols_len
	self.position.x, self.position.y, cols, cols_len = self:moveWithCollisions( self.position )
	
	for i=1, cols_len do
		local c = cols[i]
		if c.other:isa(Ball) then
			print( c.touch )
		end
	end
end

function Player:rotatePaddle()
	local moveAmt, moveAmtAcc = pd.getCrankChange()
	af:reset()
	af:rotate( moveAmt, self.paddleAxis )
	af:transformLineSegment( self.paddle )
	self:markDirty()
end

function Player:getPaddleHitPoint( ballPoint )
	local pSide
	local pStart = self.position.x - ( self.width / 2 )
	local pSegLength = self.width / 3
	local pLeft = { segStart = pStart, segEnd = pStart + pSegLength }
	local pMid = { segStart = pLeft.segEnd, segEnd = pLeft.segEnd + pSegLength }
	local pRight = { segStart = pMid.segEnd, segEnd = pMid.segEnd + pSegLength }
	
	if ballPoint.x >= pLeft.segStart and ballPoint.x <= pLeft.segEnd then
		pSide = "left"
	elseif ballPoint.x >= pMid.segStart and ballPoint.x <= pMid.segEnd then
		pSide = "middle"
	elseif ballPoint.x >= pRight.segStart and ballPoint.x <= pRight.segEnd then
		pSide = "right"	
	end
	print( pSide )
end

function Player:update()
	Player.super.update(self)
	
	if pd.isCrankDocked() then
		if self.skidding == true then
			self.velocity.x = self.velocity.x * SKID_FRICTION
		else
			self.velocity.x = self.velocity.x * NORMAL_FRICTION
		end
		
		if abs(self.velocity.x) < 10 then
			self.skidding = false
			self.velocity.x = 0
		end
		
		local velocityStep = self.velocity.x * dt
		self.position.x = self.position.x + velocityStep
		
		self:updatePositionDpad()
	else
		self:updatePositionWithCrank()
	end
	
	if self.skidding == true then
		self.velocity.x = self.velocity.x * SKID_FRICTION
	else
		self.velocity.x = self.velocity.x * NORMAL_FRICTION
	end
	
	-- if abs(self.velocity.x) < 10 then
	-- 	self.skidding = false
	-- 	self.velocity.x = 0
	-- end
	
	-- local velocityStep = self.velocity.x * dt
	-- self.position.x = self.position.x + velocityStep
	
	-- self:updatePositionDpad()
	-- self:rotatePaddle()
	
end