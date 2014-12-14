--[[ 
* adds timestamp
* shortens channel names
* shows popup windows by right-click on timestamp in order to copy chat string
* replace url most of them) with link, which shows popup window on click
* P.S.: thanks to Borlox, who proved my guesses 
]]--

LurUI.garrison = {
	GarrisonLoaded = false,
	resLabel=nil,
	resIcon = nil,
}
local ui = LurUI.garrison

local function CreateUIString(x,y, text)
	local label = GarrisonLandingPage:CreateFontString(nil, "BORDER", "GameFontNormal")
	label:SetPoint("TOPLEFT", GarrisonLandingPage, "TOPLEFT", x, y)
	label:SetJustifyH("RIGHT")
	label:SetText(text)
	return label
end

local function CreateResTexture()
	local tex = GarrisonLandingPage:CreateTexture(nil, "BORDER")
	tex:SetSize(12,12)	
	tex:SetTexture(select(3, GetCurrencyInfo(GARRISON_CURRENCY)));
	return tex
end

hooksecurefunc("Garrison_LoadUI", function()
	if (not ui.GarrisonLoaded) then
		ui.GarrisonLoaded = true
		ui.resLabel = CreateUIString(80, -15, "0/0")
		ui.resIcon = CreateResTexture()
		ui.resIcon:SetPoint("LEFT", ui.resLabel, "RIGHT", 5, 0)
		
		GarrisonLandingPage:HookScript("OnUpdate", function(self, button)
			local _, CurrentAmount, _, _, _, totalMax, _ = GetCurrencyInfo(GARRISON_CURRENCY)
			ui.resLabel:SetText(CurrentAmount.."/"..totalMax)
		end)
	end
end)