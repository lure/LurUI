-- adds timestamp to every string except combat log 
local _G = getfenv(0)
local urlPattern = "[hHwWfF][tTwW][tTwWpP][%.pP:]%S+%.[%w%d]+"
local channelPattern = "^%[%w+:?%]"
local URLCONST = "URL"

-- doesnt work, no pcre compatible regular expressions
-- local pattern = "((www|ftp|mailto|https|callto)\://)?(www\.)?[\d\w-_/\.]+\.[\w\d]+"


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

local SHORTAGE = {
	["channel:1"] = "[1]",
	["channel:2"] = "[2]",
	["channel:3"] = "[3]",
	["channel:4"] = "[4]",
	["channel:5"] = "[5]",
	
	["CHANNEL:1"] = "[1]",
	["CHANNEL:2"] = "[2]",
	["CHANNEL:3"] = "[3]",
	["CHANNEL:4"] = "[4]",
	["CHANNEL:5"] = "[5]",
	
	["[Группа]"] = "[P]",
	["[Лидер группы]"] = "[PL]",
	
	["[Поле боя]"] = "BG",	
	["[Лидер поля боя]"] = "[BGL]",
	["[Рейд]"] ="[R]",
	["[Лидер рейда]"]="[RL]",
	
	["[Гильдия]"] ="[G]"
}

-- converts "http://ya.ru" to {@link http://www.wowwiki.com/ItemLink}
local function formUrlLink(text)
  return "|cffffd000|H" .. URLCONST .. ":" .. text .. "|h" .. text .. "|h|r"
end

function formChannelName(text)
--	print (text)
	
  -- print(urltype) -- channel 
  -- print(urllink) -- PARTY  channel:1
  -- print("text=".. text) -- Лидер группы
  -- print("link=".. link) -- Лидер группы
  
  -- if (urltype == "channel") then
	-- local value = SHORTAGE[urllink]
	-- if (value ~= nil) then
		-- real_OnHyperlinkShow(self, link, value, button)
		-- print(" got:"..value)
	-- end;
	
	-- real_OnHyperlinkShow(self, link, text, button)	

end

local function hook_addMessage(self, text, ...)
  --formChannelName(text)  
  local fomattedText = text:gsub(urlPattern, formUrlLink)
  fomattedText = fomattedText:gsub(channelPattern, formChannelName)
  
  local timestamp = date("%H:%M:%S")
  self:old_addMessage(timestamp .. " " .. fomattedText, ...)
end

-- source: http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/ChatFrame.xml
local real_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
function ChatFrame_OnHyperlinkShow(self, link, text, button)
  local urltype, urllink = link:match("(%a+):(.+)")

  if (urltype == URLCONST) then
    local popup = StaticPopup_Show("CHAT_LINK")
    popup.editBox:SetText(urllink)
    popup.editBox:HighlightText()
    popup.editBox:SetFocus()
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
  
