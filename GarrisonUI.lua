--[[ 
Note: most of the code provided by Blizzard. I had to rename some variables to avoid clash with global names.
-- GarrisonMissionFrame.MissionTab.MissionList.listScroll.buttons[1]._threat.bg:SetTexture("Interface\FriendsFrame\UI-Toast-FriendOnlineIcon");
-- GarrisonLandingPageReportListListScrollFrameButton1
]]--
local ui = LurUI.garrison

hooksecurefunc("Garrison_LoadUI", function()
	if (not ui.ThreatsHooked) then
		ui.ThreatsHooked = true
		hooksecurefunc("GarrisonMissionList_Update", ui.LUR_Garrison);
		hooksecurefunc(GarrisonMissionFrame.MissionTab.MissionList.listScroll, "update", ui.LUR_Garrison);
		hooksecurefunc("GarrisonMissionButton_SetRewards", ui.LUR_GShowRewardAmount);
		
		--[[ Landing page (called by minimap button)]]
		hooksecurefunc("GarrisonLandingPageReportList_UpdateAvailable", ui.LUR_Landing);
		hooksecurefunc("GarrisonLandingPageReportList_Update", ui.LUR_Landing);
	end
end);

function LurUI.garrison.LUR_Garrison(id_provider)
	local self = GarrisonMissionFrame.MissionTab.MissionList;
	
	local scrollFrame = self.listScroll;
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];		
		if not button._threat then
			button._threat = CreateFrame("Frame", nil, button, "LurThreatsFrame");
			button._threat:SetScale(0.8);
		end
		if (button:IsVisible()) then
			local threat =  button._threat;
			ui.LUR_BuildThreatsFrame(threat, button.info, button.info.numFollowers);
			threat:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -2);
			threat:Show();
		end;
	end
end

function LurUI.garrison.LUR_GShowRewardAmount(self, rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		for id, reward in pairs(rewards) do
			local Reward = self.Rewards[index];
			if (not reward.itemID)then
				if (reward.currencyID == 0) and (reward.quantity) then
					Reward.Quantity:SetText(reward.quantity/10000);
				elseif (reward.followerXP) then
					Reward.Quantity:SetText(reward.followerXP);
				end
				Reward.Quantity:Show();
			elseif(reward.itemID ~= 120205 and not Reward.Quantity:IsVisible()) then
				Reward.Quantity:SetText(select(4, GetItemInfo(reward.itemID)));
				Reward.Quantity:Show();
			end
			index = index + 1; 
		end
	end
end

--numFollowers  /dump C_Garrison.GetMissionInfo(120)
function LurUI.garrison.LUR_BuildThreatsFrame(frame, mission)
	local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies = C_Garrison.GetMissionInfo(mission.missionID);
	local numThreats = 0;
	frame.EnvIcon:SetTexture(environmentTexture);
	for i = 1, #enemies do
		local enemy = enemies[i];
		for id, mechanic in pairs(enemy.mechanics) do
			numThreats = numThreats + 1;
			local threatFrame = frame.Threats[numThreats];
			if ( not threatFrame ) then
				threatFrame = CreateFrame("Frame", nil, frame, "LurCounterTemplate");
				threatFrame:SetPoint("LEFT", frame.Threats[numThreats - 1], "RIGHT", 10, 0);
				tinsert(frame.Threats, threatFrame);
			end
			threatFrame.Icon:SetTexture(mechanic.icon);
			threatFrame:Show();
			frame.FollowerCount:SetText(mission.numFollowers);
		end
	end
	for i = numThreats + 1, #frame.Threats do
		frame.Threats[i]:Hide();
	end
	frame:SetWidth(24 + numThreats * 30);
	frame:SetHeight(26);	-- minimum height
end

--[[ LANDING ]]
function LurUI.garrison.LUR_Landing()
	local missions = nil;
	if (GarrisonLandingPageReport.selectedTab == GarrisonLandingPageReport.Available) then
		missions = GarrisonLandingPageReport.List.AvailableItems;
	else
		missions = GarrisonLandingPageReport.List.items;
	end;
	
	if (missions and #missions > 0) then
		local scrollFrame = GarrisonLandingPageReport.List.listScroll;
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		local buttons = scrollFrame.buttons;
		local numButtons = #buttons;
		for i = 1, numButtons do
			local button = buttons[i];
			local index = offset + i;
			if (index > #missions) then
				return;
			end
			
			local mission = missions[index];
			if not button._threat then
				button._threat = CreateFrame("Frame", nil, button, "LurThreatsFrame");
				button._threat:SetScale(0.8);
			end
			
			-- Buildings exists in list too and they have no mission ID
			if (button:IsVisible() ) then
				local threat =  button._threat;
				if (mission and mission.missionID and not mission.isComplete) then
					ui.LUR_BuildThreatsFrame(threat, mission);
					threat:SetPoint("TOPLEFT", button, "TOPLEFT", 220, -32);
					threat:Show();
				else
					threat:Hide();
				end

				--Reward display
				local rewardIndex = 1;
				-- Buildings exists in list too and they have no mission ID
				if (mission.rewards) then
					for id, reward in pairs(mission.rewards) do
						local Reward = button.Rewards[rewardIndex];
						if (not reward.itemID)then
							if (reward.currencyID == 0) and (reward.quantity) then
								Reward.Quantity:SetText(reward.quantity/10000);
							elseif (reward.followerXP) then
								Reward.Quantity:SetText(reward.followerXP);
							end
							Reward.Quantity:Show();
						elseif(reward.itemID ~= 120205 and not Reward.Quantity:IsVisible()) then
							Reward.Quantity:SetText(select(4, GetItemInfo(reward.itemID)));
							Reward.Quantity:Show();
						end
						
						rewardIndex = rewardIndex + 1;
					end
				end
			end
			
		end
	end
end