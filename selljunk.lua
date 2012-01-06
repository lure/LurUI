--[[
* Adds a button "sell junk" to every merchant window. 
* Pressing tat button playr are able to sell all grey-quality items from his backpacks
]]--
LurUI.SellJunk = {
	vendorAvailable		= false,
	amount 				= 0,
	count				= 0
	}
local lurui = LurUI.SellJunk
local RESUMETEMPLATE = "SELLJUNK: Sold %s item(s) for %s"

local function sellJunk()
   lurui.count = 0
   lurui.amount= 0
	
	for container = 0, NUM_BAG_SLOTS do
		numSlots = GetContainerNumSlots(container)		
		for slot = 1, numSlots do
		
			if (not lurui.vendorAvailable) then 
				return 
			end
						
			_, count, _, _, _, _, link = GetContainerItemInfo(container, slot)
			if (link) then 
				_, _, quality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(link)
			end
			
			if (link and quality == 0) then
				lurui.amount = lurui.amount + (vendorPrice * count)
				lurui.count = lurui.count + 1				
				UseContainerItem(container, slot)					
			end
		end	
	end
	
	print(RESUMETEMPLATE:format(lurui.count, LurUI:moneyToString(lurui.amount)))
end

-- [[ hooking MailFrame ]]--
hooksecurefunc(MerchantFrame, "Show", function()
   lurui.vendorAvailable = true;
end)
hooksecurefunc(MerchantFrame, "Hide", function()
   lurui.vendorAvailable = false;
   lurui.count = 0
   lurui.amount= 0
end)

SellButton = CreateFrame("Button", nil, MerchantFrame, "OptionsButtonTemplate")
SellButton:SetPoint("TOPRIGHT", -42, -48)
SellButton:SetText("Sell junk")
SellButton:SetScript("OnClick", function()
	sellJunk()
end)

-- 20:10:47 The escaped link is:  |cff9d9d9d|Hitem:3300:0:0:0:0:0:0:1501976576:47:0|h[Кроличья лапка]|h|r 