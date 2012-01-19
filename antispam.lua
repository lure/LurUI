--[[ 
	blocks repeating messages, allowing it appear with 1 min interval. 
]] --
LurUI.antispam = {}
local player = UnitName("player")
LurUI.antispam.player = "|Hplayer:"..player..":"
LurUI.antispam.spamtable = {}
LurUI.antispam.TIMEDELTA = 120  -- time in seconds
LurUI.antispam.frame = CreateFrame("Frame")
LurUI.antispam.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
LurUI.antispam.frame.ZONE_CHANGED_NEW_AREA = function(self, ...)
	LurUI.antispam.spamtable = {}
end
LurUI.antispam.frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-- Here we maintain the hashmap where key is a text and value - it's timestamp.
-- copy this to chat to see stored messages /run table.foreach(LurUI.antispam.spamtable, print) 
local function hook_addMessage(self, text, ...)
	if text:match(LurUI.antispam.player) then 
		self:LurUI_ASAddMessage(text, ...)	
		return 
	end

	if text:match("|Hchannel:channel") or text:match(":YELL|h") then 		
		local msg = text:match("]|h: (.+)") or text:match("|r]|h кричит: (.+)")	
		if msg then 
			msg = LurUI:trim(msg)
			local current = time()
			local value = LurUI.antispam.spamtable[msg]
			if (not value) or ((current-value) > LurUI.antispam.TIMEDELTA) then
				LurUI.antispam.spamtable[msg] = current
				self:LurUI_ASAddMessage(text, ...)
			end		
		end	
	else 
		self:LurUI_ASAddMessage(text, ...)			
	end
end

local frame = _G["ChatFrame1"]
frame.LurUI_ASAddMessage=frame.AddMessage
frame.AddMessage = hook_addMessage

--[[
|Hlcopy|h01:45:04|h |Hchannel:channel:4|h[4]|h |Hplayer:Онеоне:817:CHANNEL:4|h[|cff0070ddОнеоне|r]|h: |TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|t|TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|tВ статик ДД10 3\8 Хм (рт пн-чт с 20.45-00) нид: ШП 390+ил - вступление в гильдию(25лвл) |TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|t™
]]--