-- adds timestamp to every string except combat log 
local _G = getfenv(0)
local pattern = "[hHwWfF][tTwW][tTwWpP][%.pP:]%S+%.[%w%d]+"
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


-- converts "http://ya.ru" to {@link http://www.wowwiki.com/ItemLink}
local function formUrlLink(text)
  return "|cffffd000|H" .. URLCONST .. ":" .. text .. "|h" .. text .. "|h|r"
end

local function hook_addMessage(self, text, ...)
  local fomattedText = text:gsub(pattern, formUrlLink)
  local timestamp = date("%H:%M:%S")
  self:old_addMessage(timestamp .. " " .. fomattedText, ...)
end

-- source: http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/ChatFrame.xml
local real_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
function ChatFrame_OnHyperlinkShow(self, link, text, button)
  local urltype, urllink = link:match("(%a+):(.+)")
  print(urltype, urllink, text)
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
