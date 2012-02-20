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

local YELLPATTERN = CHAT_YELL_GET:format("|r]|h").."(.+)" --"|r]|h кричит: (.+)"

-- Here we maintain the hashmap where key is a text and value - it's timestamp.
-- copy this to chat to see stored messages /run table.foreach(LurUI.antispam.spamtable, print) 
local function hook_addMessage(self, text, ...)
	if text:match(LurUI.antispam.player) then 
		self:LurUI_ASAddMessage(text, ...)	
		return 
	end
	if text:match("|Hchannel:channel") or text:match(":YELL|h") then 		
		local msg = text:match("]|h: (.+)") or text:match(YELLPATTERN)	
		if msg then 
			msg = msg:gsub("[%s%c%z%p]","") -- removing any spaces %W does not work as WoW LUA doesn't support UTF8
			msg = msg:gsub("|T%S+|t", "") -- removing raid target icons
			msg = msg:upper()  -- uppercase it
			
			local current = time()
			local value = LurUI.antispam.spamtable[msg]
			if (not value) or ((current-value) > LurUI.antispam.TIMEDELTA) then
				LurUI.antispam.spamtable[msg] = current
				local txt = text:gsub("|T%S+|t", "")
				self:LurUI_ASAddMessage(txt, ...)
			end		
		end	
	else		
		self:LurUI_ASAddMessage(text, ...)			
	end
end

local frame = _G["ChatFrame1"]
frame.LurUI_ASAddMessage=frame.AddMessage
frame.AddMessage = hook_addMessage

local function myChatFilter(self, event, msg, author, ...)
	
	--if author == LurUI.antispam.player then
		print(false, msg, author, ...)
		return false, event, msg, author, ... 
	--end
	--[[
	local text = msg:gsub("%s", "")
	local current = time()
	local value = LurUI.antispam.spamtable[text]
	if (not value) or ((current - value.timestamp) > LurUI.antispam.TIMEDELTA) then
		LurUI.antispam.spamtable[text].timestamp = current
		LurUI.antispam.spamtable[text].frame = self:GetName()
		return false, msg, author, ... 
	else 
		return true
	end
	]]--
end
--ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
--ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", myChatFilter)
--ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", myChatFilter)




--[[
|Hlcopy|h01:45:04|h |Hchannel:channel:4|h[4]|h |Hplayer:Онеоне:817:CHANNEL:4|h[|cff0070ddОнеоне|r]|h: |TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|t|TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|tВ статик ДД10 3\8 Хм (рт пн-чт с 20.45-00) нид: ШП 390+ил - вступление в гильдию(25лвл) |TInterface\TargetingFrame\UI-RaidTargetingIcon_1:0|t™
]]--