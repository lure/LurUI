--[[ 
	blocks repeating messages, allowing it appear with 1 min interval. 
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
LurUI.antispam.hook = function(self, text, ...)
	--self:LurUI_ASAddMessage(text:gsub("|","||"), ...) 

	local msg = text:match("]|h: (.+)") or text:match(":YELL|h")
	
	if msg then 
		msg = LurUI:trim(msg)
		local current = date("%H%M%S")
		local value = LurUI.antispam.spamtable[msg]
		
		if (not value) or ((current-value) > 120) then
			LurUI.antispam.spamtable[msg] = current
			self:LurUI_ASAddMessage(text, ...)
		end		
	end	
	
	if not msg then 
		self:LurUI_ASAddMessage(text, ...)
	end

end


for i = 1, NUM_CHAT_WINDOWS do
  if (i ~= 2) then
    local frame = _G["ChatFrame" .. i]
    frame.LurUI_ASAddMessage= frame.AddMessage
    frame.AddMessage = LurUI.antispam.hook 
  end
end

