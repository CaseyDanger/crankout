local pd <const> = playdate
local gfx <const> = pd.graphics
local snd <const> = pd.sound
local pnt <const> = playdate.geometry.point
local v2d <const> = pd.geometry.vector2D
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

import 'helpers'

local MIN_VELOCITY = 5

local dt = 0.05

class("Ball").extends(gfx.sprite)

function Ball:init( x, y, r, player )
	local diameter = r * 2
	self:moveTo( x, y )
	self:setSize( diameter, diameter )
	self:setCollideRect( 0, 0, diameter, diameter )
	self.position = pnt.new( x, y )
	self.velocity = v2d.new( 20, -60 )
	self.attached = false
	self.moveSpeed = MIN_VELOCITY
	self.player = player
end

function Ball:attachToPaddle()
	local px, py = self.player:getPosition()
	local xTarget = px + ( self.player.width / 2 )
	local yTarget = py
	self:moveTo( xTarget, yTarget )
	self:toggleCollision()
	self.attached = true
end

function Ball:draw()
	local cx, cy, width, height = self:getCollideBounds()
	local radius = width / 2
	local xTarget = radius
	local yTarget = radius
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(xTarget, yTarget, radius)
end

function Ball:attachedMove()
	local px, py = self.player:getPosition()
	local xTarget = px + ( self.player.width / 2 )
	local yTarget = py - 5
	self:moveTo( xTarget, yTarget )
end

function Ball:detachFromPaddle()
	self.attached = false
	-- self.player = nil
	self:toggleCollision()
end

function Ball:toggleCollision()
	local flag = not self:collisionsEnabled()
	self:setCollisionsEnabled( flag )
end

function Ball:collisionResponse( other )
	return gfx.sprite.kCollisionTypeBounce
end

function Ball:boop()
	local synth = snd.synth.new( snd.kWaveSine )
	synth:playNote( 'C#4', 1, 0.15 )
end

function Ball:beep()
	local synth = snd.synth.new( snd.kWaveSine )
	synth:playNote( 'Ab3', 1, 0.15 )
end

function Ball:update()
	Ball.super.update(self)
	
	local dx, dy = 0, 0
	
	if self.attached then
		self:attachedMove()
		if pd.buttonJustPressed( pd.kButtonA ) then
			self:detachFromPaddle()
		end
	else
		
		if pd.buttonJustPressed( pd.kButtonB ) then
			Helpers:screenShake(10)
			self.velocity = v2d.new( 20, -60 )
			self:attachToPaddle()
		end
		
		dx = self.velocity.x * dt
		dy = self.velocity.y * dt
		
		local velocityStep = self.velocity * dt
		self.position = self.position + velocityStep
		
		if dx ~= 0 or dy ~= 0 then
			local actualX, actualY, cols, cols_len = self:moveWithCollisions(self.x + dx, self.y + dy)
			for i=1, cols_len do
			  local col = cols[i]
				local paddleHit = col.other:isa(Player)
				local brickHit = col.other:isa(Brick)
				local xtraVelocity = 0
				
				if paddleHit then
					if self.player.velocity.x <= MIN_VELOCITY then
						xtraVelocity = max( self.velocity.x * 0.5, MIN_VELOCITY )
						velocityStep = self.velocity * dt
						self.position = self.position + velocityStep
					else
						xtraVelocity = abs( self.player.velocity.x / 2 )
						velocityStep = self.velocity * dt
						self.position = self.position + velocityStep
					end
				end
				
				if brickHit then
					col.other:hit(1)
				end
				
				if col.normal.x ~= 0 then -- hit something in the X direction
					self:beep()
					self.velocity.x = -(self.velocity.x + xtraVelocity)
				end
				
				if col.normal.y ~= 0 then -- hit something in the Y direction
					self:boop()
					self.velocity.y = -(self.velocity.y + xtraVelocity)
				end
			end
		end
		
	end
end