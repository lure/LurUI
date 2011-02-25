--[[
	Adds 'get all' button
	
	если вызывается из фрейма - значит не ждать, а брать вещь и вызывать себя же 
	при вызове из себя же 
]]--
 
local currentMail, totalMoney, lastMoney, lastAttach = 0, 0, 0, 0;
local slotsExists = true; 
local inprogress = false;

--имитация WaitForSingleObject из ThreadAPI
local waitframe = CreateFrame("Frame",nil,UIParent)
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

hooksecurefunc(MailFrame, "Hide", function()
	if (inprogress) then 
		printMoney(totalMoney)
	end
	inprogress = false;
	currentMail, totalMoney, lastMoney, lastAttach = 0, 0, 0, 0;
end)

 
mailButton = CreateFrame("Button", nil, InboxFrame, "OptionsButtonTemplate")
mailButton:SetPoint("TOPRIGHT", -41, -40)
mailButton:SetText("Get all")
mailButton:SetScript("OnClick", function()
	if (not inprogress) then 
		inprogress = true;
		currentMail, totalMoney, lastMoney, lastAttach = 0, 0, 0, 0; 
		mailID = GetInboxNumItems();
		print("you got "..mailID.." mails in your box")
		getAllMail(false);
	end;
end)

function getAllMail()
	if mailID > 0 then		
		local subj, msgMoney, CODAmount, _, msgItemCount = select(4, GetInboxHeaderInfo(mailID))
		if (msgItemCount or msgMoney > 0) then
			if (CODAmount == 0) then
				-- looting if there are no COD 
				if ((lastMoney > 0 and lastMoney == msgMoney) or lastAttach == msgItemCount) then 
					-- wait longer cos money has not been looted yet
					return waitframe:Show();
				end
				
				if (msgMoney > 0) then
					lastMoney = msgMoney
					totalMoney = totalMoney + msgMoney
					print("Processing: " .. subj .. " " .. getMoneyString(parseMoney(msgMoney)))
					TakeInboxMoney(mailID); -- забираем деньги, ибо остальное подождёт
					return waitframe:Show();
				end
				
				if (msgItemCount and slotsExists) then
					local itemLink = GetInboxItemLink(msgItemCount)
					if ( getFreeInventoryNum(itemLink) > 0) then 
						lastAttach = msgItemCount
						TakeInboxItem(mailID, msgItemCount);
						return waitframe:Show();
					else
						print("no more room in inventory, items will be skipped.")
						slotsExists = false;
						mailID = mailID -1;
						return getAllMail();
					end
				end
			else 
				print("This letter contains COD for "..parseMoney(CODAmount)..". So we skipped it")
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
	print("Total amount = "..getMoneyString(parseMoney(money)))
end

function getMoneyString(gold, silver, copper) 	
	return gold.."g "..silver.."s "..copper.."c"
end

function parseMoney(money)
	local msgGold = math.floor(money / 10000)
	local msgSilver = math.floor((money - msgGold * 10000)/100)
	local msgCopper = money - (msgGold * 10000) - (msgSilver*100)
	return msgGold, msgSilver, msgCopper;
end 
