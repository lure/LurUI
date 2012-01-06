--[[ 
	blocks repeating messages, allowing it appear with 1 min interval. 
	if not anti then return end
]] --
LurUI.antispam = {}
LurUI.antispam.spamtable = {}
LurUI.antispam.frame = CreateFrame("Frame")
LurUI.antispam.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
LurUI.antispam.frame.ZONE_CHANGED_NEW_AREA = function(self, ...)
	LurUI.antispam.spamtable = {}
end
LurUI.antispam.frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)

-- /run table.foreach(LurUI.antispam.spamtable, print) 
-- нужна хешмэп, где ключ это [час:минута], а значение - карта (key=реплика)
local function hook_addMessage(self, text, ...)
	if text:match("|Hchannel:channel") or text:match(":YELL|h") then 		
		local msg = text:match("]|h: (.+)") or text:match("|r]|h кричит: (.+)")	
		if msg then 
			msg = LurUI:trim(msg)
			local current = date("%H%M%S")
			local value = LurUI.antispam.spamtable[msg]
			if (not value) or ((current-value) > 120) then
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


