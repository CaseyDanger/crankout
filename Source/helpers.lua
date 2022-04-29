Helpers = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local snd <const> = pd.sound

local function shake(shakeTimer)
	local dispY = ( shakeTimer.frame % 2 ) * 2
	pd.display.setOffset( 0, dispY )
end

function Helpers:screenShake(duration)
	duration = duration or 20
	local shakeTimer = pd.frameTimer.new(duration)
	shakeTimer.updateCallback = shake
end

