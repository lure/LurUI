-- adds timestamp to every string except combat log 

local _G = getfenv(0)
local gsub = string.gsub
local pattern

local function formURL()

end


local function hook(self, text, ...)
	-- local fomattedText = text:gsub(pattern, reformatUrl)
	local timestamp = date("%H:%M:%S") 
	self:old_addMessage(timestamp.." "..text, ...)
end

for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then 
		local frame = _G["ChatFrame"..i]
		frame.old_addMessage = frame.AddMessage
		frame.AddMessage = hook 
	end
end
