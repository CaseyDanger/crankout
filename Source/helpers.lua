Helpers = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local snd <const> = pd.sound

local function shake( shakeTimer )
	local dispY = ( shakeTimer.frame % 2 ) * 2
	pd.display.setOffset( 0, dispY )
end

function Helpers:screenShake( duration )
	duration = duration or 20
	local shakeTimer = pd.frameTimer.new( duration )
	shakeTimer.updateCallback = shake
end

function Helpers:getJSONTableFromFile( filepath )
	local rawJsonData = nil
	local f = pd.file.open( filepath )
	
	if f then
		local s = playdate.file.getSize( filepath )
		rawJsonData = f:read( s )
		f:close()
		
		if not rawJsonData then
			print('ERROR LOADING DATA for ' .. filepath)
			return nil
		end
	end
	
	local jsonTable = json.decode( rawJsonData )
	
	if not jsonTable then
		print('ERROR PARSING JSON DATA for ' .. filepath)
		return nil
	end
	
	return jsonTable
end