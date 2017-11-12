--[[
	Adds 'get all' button

	если вызывается из фрейма - значит не ждать, а брать вещь и вызывать себя же
	при вызове из себя же
  ]] --
  
-- control variables
local lastMail, lastMoney, lastItemCount, attachIndex = 0, 0, 0, 0,0
local mailID, lastMailCount = 0, 0

--statistic
local totalCount, startMoney, totalMoney = 0, 0, 0

-- behaviour variables 
local slotsExists = true
local inprogress = false
local chosen = "all"
local selectedID = {}

-- [[ WaitForSingleObject from ThreadAPI imitation ]] --
local waitframe = CreateFrame("Frame", nil, UIParent)
waitframe:Hide();
waitframe:SetScript("OnShow", function(self)
    self.timer = 0.5;
end)

waitframe:SetScript("OnUpdate", function(self, elapsed)
    self.timer = self.timer - elapsed;
    if (self.timer < 0) then
        self:Hide();
        self:getAllMail();
    end;
end)

local function letterIsNotFinished()
	return ((lastMoney > 0 and lastMoney == msgMoney) or (lastItemCount > 0 and lastItemCount == msgItemCount))
end

local function nextLetter()
	lastItemCount = 0;
	lastMoney = 0;
	mailID = mailID - 1;
	waitframe:getAllMail();
end

local function ShowMessage(...)
	print(...)
end

local function printMoney(money)
    print("POSTAL: Total amount = [ " .. GetCoinTextureString(money) .. " ], total letters = " .. totalCount)
end

-- true if (only  H letters are permitted and this one is from AH) or (any letters are permitted)
local function checkAH(sender)
    return (chosen == "auction") and
            (GetInboxInvoiceInfo(mailID) ~= nil or (sender and sender:match("^Аукционный дом.+") ~= nil))
end

local function checkSelected() 
    return (chosen == "selected") and selectedID[mailID] and (selectedID[mailID] ~= 0)
end

local function clearSelectedID()
    for i = 1, INBOXITEMS_TO_DISPLAY do
        selectedID[i] = 0
    end
end

function waitframe:getAllMail()
	-- special part for "selected" mail
	if (mailID > 0 and checkSelected() and (lastMailCount ~= GetInboxNumItems())) then
		-- this is not the first iteration, so we have to go one letter down, because 
		-- disappeared letter made previous one going down 
		if (lastMailCount ~= 0) then
			selectedID[mailID] = 0		
			mailID = mailID - 1
		end
				
		-- listing ID while it is not selected one
		while (selectedID[mailID] ~= 1 and mailID > 0) do
			mailID = mailID - 1 
		end			
	end
		
    if mailID > 0 then
		local sender, subj, msgMoney, CODAmount, _, msgItemCount = select(3, GetInboxHeaderInfo(mailID))
        if ((msgItemCount or msgMoney > 0) and (checkAH(sender) or checkSelected() or (chosen == "all"))) then
            if (CODAmount == 0) then
            -- looting if there are no COD
                if ((lastMail == mailID) and letterIsNotFinished()) then
					-- wait longer cos money has not been looted yet
					ShowMessage("waiting longer")
                    return waitframe:Show();
                end

                if (lastMail ~= mailID) then
					lastMailCount = GetInboxNumItems()
                    ShowMessage("Processing: " .. subj .. " " .. LurUI:moneyToString(msgMoney))
					attachIndex = ATTACHMENTS_MAX_RECEIVE  -- sometimes attachments have index with gaps, i.e. [1]=ore [2]=egg [3]=nil [4]=ore
					lastItemCount = (msgItemCount) and msgItemCount or 0
                    totalCount = totalCount + 1
                    lastMail = mailID
                end

                if (msgMoney > 0) then
                    lastMoney = msgMoney
                    totalMoney = totalMoney + msgMoney
                    TakeInboxMoney(mailID); -- забираем деньги, ибо остальное подождёт
                    return waitframe:Show();
                end

                if (msgItemCount and slotsExists) then
					while not GetInboxItemLink(mailID, attachIndex) and attachIndex > 0 do
						attachIndex = attachIndex - 1 
					end		
					if (attachIndex == 0 and msgItemCount) then
						ShowMessage(string.format("Letter with index %d subj '%s' is broken and skipped.", mailID, subj))
						return nextLetter()
					end
					
                    local itemLink = GetInboxItemLink(mailID, attachIndex)
                    if (LurUI:getFreeInventoryNum(itemLink) > 0) then
                        lastItemCount = msgItemCount
                        TakeInboxItem(mailID, attachIndex);
                        return waitframe:Show();
                    else
                        ShowMessage("no more room in inventory, items will be skipped.")
                        slotsExists = false;
						return nextLetter()
                    end
                end
            else
                ShowMessage("This letter contains COD for " .. moneyToString(CODAmount) .. ". So we skipped it")
                return nextLetter()
            end
        else
			selectedID[mailID] = 0
			return nextLetter()
        end
    else
		waitframe:Hide()
        inprogress = false;
		clearSelectedID()
        printMoney(GetMoney() - startMoney)
    end
end

-- [[ adding a button to MailFrame ]] --
local mailButton = CreateFrame("Button", nil, InboxFrame, "OptionsButtonTemplate")
mailButton:SetPoint("TOPRIGHT", -60, -30)
mailButton:SetText("Get mail")
mailButton:SetScript("OnClick", function()
    if (not inprogress) then
        inprogress = true;
        chosen = Lib_UIDropDownMenu_GetText(PostalMailTypes)

        mailID, _ = GetInboxNumItems()		
        ShowMessage("POSTAL: you've got " .. mailID .. " letters")
		
		startMoney = GetMoney() 
        lastMail, totalMoney, lastMoney = 0, 0, 0, 0
		attachIndex, lastItemCount, totalCount = 0, 0, 0
		lastMailCount = 0 
		
        waitframe:getAllMail();
    end
end)

-- [[ DROP DOWN MENU ]] --
-- moving MailItemFrames to the right by 20px. All MailItems below are shortened by the same 20px
_G["MailItem1"]:SetPoint("TOPLEFT", 48, -80)

-- adding checkbox
for i = 1, 7 do
    local mailItemFrame = _G["MailItem" .. i]
    mailItemFrame:SetWidth(mailItemFrame:GetWidth() - 20)
    local checkBox = CreateFrame("CheckButton", nil, mailItemFrame, "UICheckButtonTemplate")
    checkBox:SetWidth(20)
    checkBox:SetHeight(20)
    checkBox:SetPoint("TOPLEFT", -23, -10)

    checkBox:SetScript("OnClick", function(self, button, down)
        local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + i;
        if (index > GetInboxNumItems()) then
            self:SetChecked(false)
            return;
        end
		-- _G["MailItem" .. i .. "Button"].index
        selectedID[index] = self:GetChecked() and 1 or 0
    end)
    mailItemFrame.checkBox = checkBox;
end

local items = {
    ["all"] = "all",
    ["auction"] = "auction",
    ["selected"] = "selected"
}

local function initialize(self, level)
    local info
    for k, v in pairs(items) do
        info = Lib_UIDropDownMenu_CreateInfo()
        info.text = k
        info.value = v
        info.func = function(self) Lib_UIDropDownMenu_SetSelectedID(PostalMailTypes, self:GetID()) end
        Lib_UIDropDownMenu_AddButton(info, level)
    end
end

-- Adding the button  http://wowprogramming.com/forums/development/159
local mailType = CreateFrame("Frame", "PostalMailTypes", InboxFrame, "Lib_UIDropDownMenuTemplate")
mailType:SetPoint("RIGHT", mailButton, "LEFT", -2, -2)
Lib_UIDropDownMenu_Initialize(PostalMailTypes, initialize)
Lib_UIDropDownMenu_SetWidth(PostalMailTypes, 80);
Lib_UIDropDownMenu_SetButtonWidth(PostalMailTypes, 124)
Lib_UIDropDownMenu_SetSelectedID(PostalMailTypes, 1)
Lib_UIDropDownMenu_SetText(PostalMailTypes, items["all"])
Lib_UIDropDownMenu_JustifyText(PostalMailTypes, "LEFT")

-- [[ hooking MailFrame ]]--
hooksecurefunc(MailFrame, "Hide", function()
    if (inprogress) then
		mailID = 0;
		waitframe:Hide();
        printMoney(GetMoney() - startMoney)
    end
    inprogress = false;
    clearSelectedID()
end)

hooksecurefunc("InboxFrame_Update", function()
    local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY)
	local count = GetInboxNumItems() 
    for i = 1, 7 do
		local cb = _G["MailItem" .. i].checkBox
		if ((index + i) <= count) then 		
			cb:Show()
		else 
			cb:Hide() 
		end		
        cb:SetChecked(selectedID[index + i] == 1)
    end
end)

--[[ 
	создаем коллекцию фреймов, содержащих письма, которые нужно собрать
		1 берем первое письмо по индексу, работаем с ним до тех пор, пока фрейм сохраненный не перстанет быть равным текущему фрему , взятому по индексу 
		2 как только фреймРабочий~=фрейм[текущий] смещаемся на следующий фрейм
		3 идти на 1
]]--