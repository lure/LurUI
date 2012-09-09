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

-- [[ hooking MailFrame ]]--
hooksecurefunc(MerchantFrame, "Show", function()
   lurui.vendorAvailable = true;
end)
hooksecurefunc(MerchantFrame, "Hide", function()
   lurui.vendorAvailable = false;
end)

-- Moves localized repair string to bottom a bit
MerchantRepairText:SetPoint("BOTTOMLEFT", 14, 35)
local SellButton = CreateFrame("Button", "MerchantFrameSellJunkButton", MerchantFrame, "OptionsButtonTemplate")
SellButton:SetPoint("TOPRIGHT",  -200, -32)
SellButton:SetText("Sell junk")
SellButton:SetWidth(75)
SellButton:SetScript("OnClick", function()
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
	
	print(RESUMETEMPLATE:format(lurui.count, GetCoinTextureString(lurui.amount)))
end)
--[[
SellButton:SetMovable(true)
SellButton:EnableMouse(true)
SellButton:RegisterForDrag("LeftButton")
SellButton:SetScript("OnDragStart", MerchantFrameSellJunkButton.StartMoving)
SellButton:SetScript("OnDragStop", MerchantFrameSellJunkButton.StopMovingOrSizing)
/run local f=GetMouseFocus() print(f:GetName(), f:GetPoint())
]]--