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
	--self:LurUI_ASAddMessage(text, ...) --text:gsub("|","||")
	local n = select('#', ...)
	local t = {...}
	
	local channelMsg = false
	text:gsub("]|h: (.+)", function(w)
		w = LurUI.func.trim(w)
		channelMsg = true
		local current = date("%H%M%S")
		local value = LurUI.antispam.spamtable[w]
		
		if (not value) or ((current-value) > 60) then
			LurUI.antispam.spamtable[w] = current
			self:LurUI_ASAddMessage(text, unpack(t, 1, n))
		end		
	end)
	if (not channelMsg) then 
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

