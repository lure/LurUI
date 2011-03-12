--[[ 	
	Adds player's coordinates to the map
]]--

local coord = WorldMapFrame:CreateFontString()
coord:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -400, 11)
coord:SetHeight(10)
coord:SetWidth(400)
coord:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, MONOCHROME")


WorldMapFrame:HookScript("OnUpdate", function(self, button)
        local px, py = roundCoords(GetPlayerMapPosition("player"))
		local mx, my = GetMouseCoord()
        mx = mx > 0 and string.format("%02.1f", mx) or "00.0"
        my = my > 0 and  string.format("%02.1f", my)  or "00.0"
        local playerCoords = string.format("you = %02.1f / %02.1f mouse = %s / %s", px, py, mx, my)
		coord:SetText(playerCoords)
    end)

	
function GetMouseCoord()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()	
	local adjustedX = (x/scale - (centerX - width / 2)) / width
	local adjustedY = (centerY + (height/2) - y / scale) / height  

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <=1 and adjustedY <=1) then
		adjustedX = adjustedX * 100
		adjustedY = adjustedY * 100
	else 
		adjustedX = 0
		adjustedY = 0
	end
		
	return adjustedX, adjustedY
end


function roundCoords(varx, vary)
	varx = math.floor(varx * 1000 + 0.5)/10
	vary = math.floor(vary * 1000 + 0.5)/10	
	return varx, vary
end


