--[[
	Adds 'get all' button

	если вызывается из фрейма - значит не ждать, а брать вещь и вызывать себя же
	при вызове из себя же
]] --

local currentMail, totalCount, totalMoney, lastMoney, lastAttach = 0, 0, 0, 0;
local slotsExists = true;
local inprogress = false;
local chosen = "all"
local selectedID = {}
local mailID = 0;

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
        getAllMail()
    end;
end)

-- [[ hooking MailFrame ]]--
hooksecurefunc(MailFrame, "Hide", function()
    if (inprogress) then
        printMoney(totalMoney)
    end
    inprogress = false;
    clearSelectedID()
end)

hooksecurefunc("InboxFrame_Update", function()
    local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY);
    for i = 1, 7 do
        _G["MailItem" .. i].checkBox:SetChecked(selectedID[index + i] == 1);
    end
end)


-- [[ adding a button to MailFrame ]] --
mailButton = CreateFrame("Button", nil, InboxFrame, "OptionsButtonTemplate")
mailButton:SetPoint("TOPRIGHT", -41, -41)
mailButton:SetText("Get mail")
mailButton:SetScript("OnClick", function()
    if (not inprogress) then
        chosen = UIDropDownMenu_GetText(PostalMailTypes)

        inprogress = true;
        currentMail, totalMoney, lastMoney, lastAttach, totalCount = 0, 0, 0, 0, 0;
        mailID, _ = GetInboxNumItems();

        print("you got " .. mailID .. " letters in your box")
        getAllMail();
    end;
end)

function getAllMail()
    if mailID > 0 then
        local sender, subj, msgMoney, CODAmount, _, msgItemCount = select(3, GetInboxHeaderInfo(mailID))

        if ((msgItemCount or msgMoney > 0) and checkAH(sender) and checkSelected()) then
            if (CODAmount == 0) then
            -- looting if there are no COD
                if ((lastMoney > 0 and lastMoney == msgMoney) or lastAttach == msgItemCount) then
                -- wait longer cos money has not been looted yet
                    return waitframe:Show();
                end

                if (currentMail ~= mailID) then
                    print("Processing: " .. subj .. " " .. getMoneyString(parseMoney(msgMoney)))
                    totalCount = totalCount + 1;
                    currentMail = mailID
                end

                if (msgMoney > 0) then
                    lastMoney = msgMoney
                    totalMoney = totalMoney + msgMoney
                    TakeInboxMoney(mailID); -- забираем деньги, ибо остальное подождёт
                    return waitframe:Show();
                end

                if (msgItemCount and slotsExists) then
                    local itemLink = GetInboxItemLink(msgItemCount)
                    if (getFreeInventoryNum(itemLink) > 0) then
                        lastAttach = msgItemCount
                        TakeInboxItem(mailID, msgItemCount);
                        return waitframe:Show();
                    else
                        print("no more room in inventory, items will be skipped.")
                        slotsExists = false;
                        mailID = mailID - 1;
                        return getAllMail();
                    end
                end
            else
                print("This letter contains COD for " .. parseMoney(CODAmount) .. ". So we skipped it")
                mailID = mailID - 1;
                getAllMail();
            end
        else
            lastAttach = 0;
            lastMoney = 0;
            mailID = mailID - 1;
            getAllMail();
        end
    else
        inprogress = false;
        printMoney(totalMoney)
    end
end

function printMoney(money)
    print("POSTAL: Total amount = [ " .. getMoneyString(parseMoney(money)) .. " ], total letters = " .. totalCount)
end

-- true if (only  H letters are permitted and this one is from AH) or (any letters are permitted)
function checkAH(sender)
    return (chosen ~= "auction") or (GetInboxInvoiceInfo(mailID) ~= nil or (sender:match("^Аукционный дом.+") ~= nil))
end

function checkSelected()
    local result = (chosen ~= "selected") or (selectedID[mailID] ~= 0)
    selectedID[mailID] = 0

    return result;
end


function getMoneyString(gold, silver, copper)
    return string.format("%dg %ds %dc", gold, silver, copper)
end

function parseMoney(money)
    local msgGold = math.floor(money / 10000)
    local msgSilver = math.floor((money - msgGold * 10000) / 100)
    local msgCopper = money - (msgGold * 10000) - (msgSilver * 100)
    return msgGold, msgSilver, msgCopper;
end

function clearSelectedID()
    for i = 1, INBOXITEMS_TO_DISPLAY do
        selectedID[i] = 0
    end
end

-- [[ DROP DOWN MENU ]] --
-- moving MailItemFrames to the right by 20px. Some lines below they are shortened by that 20px
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
        selectedID[_G["MailItem" .. i .. "Button"].index] = self:GetChecked() and 1 or 0
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
        info = UIDropDownMenu_CreateInfo()
        info.text = k
        info.value = v
        info.func = function(self) UIDropDownMenu_SetSelectedID(PostalMailTypes, self:GetID()) end
        UIDropDownMenu_AddButton(info, level)
    end
end


-- Adding the button  http://wowprogramming.com/forums/development/159
local mailType = CreateFrame("Frame", "PostalMailTypes", InboxFrame, "UIDropDownMenuTemplate")
mailType:SetPoint("TOPRIGHT", -120, -39)
UIDropDownMenu_Initialize(PostalMailTypes, initialize)
UIDropDownMenu_SetWidth(PostalMailTypes, 80);
UIDropDownMenu_SetButtonWidth(PostalMailTypes, 124)
UIDropDownMenu_SetSelectedID(PostalMailTypes, 1)
UIDropDownMenu_SetText(PostalMailTypes, items["all"])
UIDropDownMenu_JustifyText(PostalMailTypes, "LEFT")