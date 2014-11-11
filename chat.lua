--[[ 
* adds timestamp
* shortens channel names
* shows popup windows by right-click on timestamp in order to copy chat string
* replace url most of them) with link, which shows popup window on click
* P.S.: thanks to Borlox, who proved my guesses 
]]-- 

-- adding my EditPopupDialog to global table
-- http://www.wowwiki.com/Creating_simple_pop-up_dialog_boxes
-- http://www.wowinterface.com/forums/showthread.php?t=34994
-- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/StaticPopup.lua
local _
StaticPopupDialogs["CHAT_LINK"] = {
  preferredIndex = 3, -- avoids BlizzardUI glyph taint. http://forums.wowace.com/showthread.php?p=320956 
  --preferredIndex = STATICPOPUP_NUMDIALOGS may be used instead. It defined in BlizzardUI/FrameXML/StaticPopup.lua
  text = "LurUI: 'ctrl+c' to copy or 'esc' to exit",
  button1 = "ok",
  hasEditBox=true,
  editBoxWidth = 350,
  EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

LurUI.chat = {
	urlPattern = "[hHwWfF][tTwW][tTwWpP][%.pP:]%S+%.[%w%d%?/;=:_%-%%%&#]+",

	timePattern = "^([%d:]+[ AaPpMm]*)",
	timeTemplate = "|HL_CPY|h%s|h",

	channelPattern = "^([%d:]*%s?[AaPpMm]*%s?)|Hchannel:([%a_]+:?%d?)|h(%b[])|h",
	channelTemplate = "%s|Hchannel:%s|h[%s]|h",

	URL = "L_URL",
	URLTEMPLATE = "|cffffd000|HL_URL:%s|h%s|h|r",
	COPY="L_CPY",
	TIMESTAMPFORMAT = "%H:%M:%S ",
}

LurUI.chat.SHORTAGE = {
	["channel:1"] = "1",
	["channel:2"] = "2",
	["channel:3"] = "3",
	["channel:4"] = "4",
	["channel:5"] = "5",
	
	["CHANNEL:1"] = "1",
	["CHANNEL:2"] = "2",
	["CHANNEL:3"] = "3",
	["CHANNEL:4"] = "4",
	["CHANNEL:5"] = "5",
	
	["GUILD"] = "G",
	 
	["PARTY"] = "P",
	["[Лидер группы]"] = "PL",
	
	["[Поле боя]"] = "BG",	
	["[Лидер поля боя]"] = "BGL",
	["[Лидер подземелья]"] = "RL",

	
	["RAID"] ="R",
	["[Лидер рейда]"]="RL",
	["[Подземелье]"]="D",
}

-- converts "http://ya.ru" to {@link http://www.wowwiki.com/ItemLink}
local function formUrlLink(text)
  return string.format(LurUI.chat.URLTEMPLATE, text, text)
end

local function formTimeURL(timeText)
	if (not timeText or strlen(timeText) < 2) then
		timeText = "*"
	end
	return LurUI.chat.timeTemplate:format(timeText)
end

local lcons = LurUI.chat
local shortage = LurUI.chat.SHORTAGE;
local function formChannelName(timeText, text, modif)
	local value = shortage[modif] and shortage[modif] or shortage[text]
	--ChatFrame1:old_addMessage(value.."<>".. text.."<>".. modif)
	if (value ~= nil) then
		return string.format(lcons.channelTemplate, timeText, text, value)
	end
end

LurUI.chat.ShowPopup = function(text)
    local popup = StaticPopup_Show("CHAT_LINK")
    popup.editBox:SetText(text)
    popup.editBox:HighlightText()
    popup.editBox:SetFocus()
end

local function hook_addMessage(self, text, ...) 
	-- |Hchannel:channel:1|h[1. Общий: Бесплодные земли]|h|Hplayer:[Солта]
	-- |Hchannel:INSTANCE_CHAT|h[Подземелье]|h |Hplayer:Солта-СтражСмерти:2937:INSTANCE_CHAT|h[|cffffffffДобров|r]|h: 1 8 16  
	local fomattedText = text:gsub(lcons.channelPattern, formChannelName)
  
	if (CHAT_TIMESTAMP_FORMAT) then
		if (fomattedText:match(lcons.timePattern)) then
			fomattedText = fomattedText:gsub(lcons.timePattern, formTimeURL)
		else
			fomattedText = lcons.timeTemplate:format(BetterDate(CHAT_TIMESTAMP_FORMAT, time()))..fomattedText
		end
	else
		fomattedText = lcons.timeTemplate:format(BetterDate(lcons.TIMESTAMPFORMAT, time()))..fomattedText
	end
	
	fomattedText = fomattedText:gsub(lcons.urlPattern, formUrlLink)
	self:old_addMessage(fomattedText, ...)
end

--[[ 
TAINT: http://forums.wowace.com/showthread.php?t=20217
source: http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/ChatFrame.xml
local real_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;

function ChatFrame_OnHyperlinkShow(self, link, text, button)
  local urltype, urllink = link:match("(%a+):(.+)")
  if (urltype == LurUI.chat.URL) then
    LurUI.chat.ShowPopup (urllink)
  elseif (link == LurUI.chat.COPY) then
    local hyperbutton = GetMouseFocus();
	if (hyperbutton:IsObjectType("HyperLinkButton") and "RightButton" == button) then
		local _, fontstring = hyperbutton:GetPoint(1)
		if(fontstring:IsObjectType("FontString")) then
			LurUI.chat.ShowPopup (fontstring:GetText())
		end
	end
  else
    real_OnHyperlinkShow(self, link, text, button)
  end
end
]]--

-- we have to hook this function since the default ChatFrame code assumes 
-- that all links except for player and channel links are valid arguments for this function
local old = ItemRefTooltip.SetHyperlink 
function ItemRefTooltip:SetHyperlink(link, ...)
	local lnk = link:sub(0, 5)
	if (lnk == lcons.URL) or (lnk == lcons.COPY) then
		return
	end
	return old(self, link, ...)
end

local function LUR_OnHyperlinkClick(self, link, string, button, ...)
	local linkType = strsplit(":", link)
	if (linkType == lcons.URL) then
		local urltype, urllink = link:match("(%a+):(.+)")
		lcons.ShowPopup(urllink)
	end
	if (linkType == lcons.COPY)then
		local hyperbutton = GetMouseFocus(); 
		if (hyperbutton:IsObjectType("HyperLinkButton") and "RightButton" == button) then
			local _, fontstring = hyperbutton:GetPoint(1)
			if(fontstring:IsObjectType("FontString")) then
				lcons.ShowPopup (fontstring:GetText())		
			end		
		end
	end		
end

for i = 1, NUM_CHAT_WINDOWS do
	if (i ~= 2) then
		local frame = _G["ChatFrame" .. i]
		frame.old_addMessage = frame.AddMessage
		frame.AddMessage = hook_addMessage		
		frame:HookScript("OnHyperlinkClick", LUR_OnHyperlinkClick)
	end
end