﻿--[[ 
* adds timestamp
* shortens channel names
* shows popup windows by right-click on timestamp in order to copy chat string
* replace url most of them) with link, which shows popup window on click
P.S.: thanks to Borlox, who proved my guesses 
]]-- 


local _G = getfenv(0)
-- Approach below doesnt work: no pcre compatible regular expressions
-- local pattern = "((www|ftp|mailto|https|callto)\://)?(www\.)?[\d\w-_/\.]+\.[\w\d]+"
local urlPattern = "[hHwWfF][tTwW][tTwWpP][%.pP:]%S+%.[%w%d%?/;=:_%-%%%&#]+"
local channelPattern = "^|Hchannel:(%a+:?%d?)|h(%b[])|h"
local URLCONST = "URL"
local COPYCONST="|Hlcopy|h%s|h %s"

-- adding my EditPopupDialog to global table
-- http://www.wowwiki.com/Creating_simple_pop-up_dialog_boxes
-- http://www.wowinterface.com/forums/showthread.php?t=34994
-- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/StaticPopup.lua
StaticPopupDialogs["CHAT_LINK"] = {
  text = "'ctrl+c' to copy or 'esc' to exit",
  button1 = "ok",
  hasEditBox=true,
  editBoxWidth = 350,
  EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

LurUI.chat = {}
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
	
	["RAID"] ="R",
	["[Лидер рейда]"]="RL",
}

-- converts "http://ya.ru" to {@link http://www.wowwiki.com/ItemLink}
local function formUrlLink(text)
  return string.format("|cffffd000|H%s:%s|h%s|h|r", URLCONST, text, text)
end

local function formChannelName(text, modif)
  -- |Hchannel:channel:1|h[1. Общий: Бесплодные земли]|h|Hplayer:[Солта]
	-- print(text.." "..modif)
	local shortage = LurUI.chat.SHORTAGE;
	local value = shortage[modif] and shortage[modif] or shortage[text]
	if (value ~= nil) then
		return string.format("|Hchannel:%s|h[%s]|h", text, value)
	end
end

LurUI.chat.ShowPopup = function(text)
    local popup = StaticPopup_Show("CHAT_LINK")
    popup.editBox:SetText(text)
    popup.editBox:HighlightText()
    popup.editBox:SetFocus()
end

local function hook_addMessage(self, text, ...) 
  local fomattedText = text:gsub(channelPattern, formChannelName)
  fomattedText = fomattedText:gsub(urlPattern, formUrlLink)
  fomattedText = COPYCONST:format(date("%H:%M:%S"), fomattedText)
  self:old_addMessage(fomattedText, ...)
end

-- source: http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/ChatFrame.xml
local real_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;

function ChatFrame_OnHyperlinkShow(self, link, text, button)
  local urltype, urllink = link:match("(%a+):(.+)")
  if (urltype == URLCONST) then
    LurUI.chat.ShowPopup (urllink)
  elseif (link == "lcopy") then
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



for i = 1, NUM_CHAT_WINDOWS do
  if (i ~= 2) then
    local frame = _G["ChatFrame" .. i]
    frame.old_addMessage = frame.AddMessage
    frame.AddMessage = hook_addMessage
  end
end

