local pd <const> = playdate
local gfx <const> = pd.graphics
local pnt <const> = playdate.geometry.point
local v2d <const> = pd.geometry.vector2D
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local defaultRadius = 1
local dt = 0.05
local MAX_VELOCITY = 600
local NORMAL_FRICTION = 0.8
local SKID_FRICTION = 0.7

class("Player").extends(gfx.sprite)

function Player:init( x, y, width, height )
	self:moveTo( x, y )
	self:setSize( width, height )
	self:setCenter( 0, 0 )
	self:setCollideRect( 0, 0, width, height )
	self._x = x
	self._y = y
	self.dx = 0
	self.dy = 0
	self._width = width
	self._height = height
	self.position = pnt.new( x, y )
	self.velocity = v2d.new( 0, 0 )
	self.moveSpeed = 20
	self.skidding = false
end

function Player:draw()
	local cx, cy, width, height = self:getCollideBounds()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRoundRect( 0, 0, width, height, defaultRadius )
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
	
	self.position.x += moveAmtAcc
	self.velocity.x = min( abs(moveAmtAcc), MAX_VELOCITY )

	print(self.velocity.x)

	local cols, cols_len
	self.position.x, self.position.y, cols, cols_len = self:moveWithCollisions( self.position )
	
	for i=1, cols_len do
		local c = cols[i]
		if c.other:isa(Wall) then
			-- self.position.x = actualX
		end
	end
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
	
end