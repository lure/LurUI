
function OnLoad(self)
--	this:RegisterEvent("VARIABLES_LOADED");
  print("loaded");
  self:Show()
  print(self)
end

function onEvent(self, event, ...)
--	if (event == "VARIABLES_LOADED") then
--		SlashCmdList["SCH"] = Sch_SlashHandler;
--		SLASH_SCH1 = "/schcast";
--		DEFAULT_CHAT_FRAME:AddMessage("Pally assistant loaded");
--		DEFAULT_CHAT_FRAME:AddMessage("Usage: make a new macro and type \"/schcast (rep|grip)\" within");
--		return;
--	end
end


function Sch_SlashHandler(arg)
	arg = string.lower(arg);

	--- our target is empty?
	local targetName = UnitName("target");
	if (targetName == nil) then
		DEFAULT_CHAT_FRAME:AddMessage("Spell cant be cast: target is empty.");
		return;
	end

	--- Do not cast on friendly target
	if (UnitIsFriend("player","target")) then
		DEFAULT_CHAT_FRAME:AddMessage("Spell cant be cast: target is friendly");
		return;
	end

	local spell = "";
	local message = "";


	if (arg == "rep") then
		spell = "Покаяние";
		message = "Покаяние на " .. targetName;
	elseif (arg == "grip") then
		spell = "Хватка смерти";
		message = "Вы по процедурному вопросу, " .. targetName.."? Абаждите!";
	end

	--- what about the range?
	if (IsSpellInRange(spell,"target") == 1) then
		-- action is not on colldown
		local start, duration, enabled = GetSpellCooldown(spell);
		if (enabled == 0 and duration == 0 and start == 0) then
			CastSpellByName(spell);
			--- yell and raid warning, if we are on arena or in battleground
			local zone = select(2, IsInInstance());
			if (zone == "arena" or zone == "pvp") then
				SendChatMessage(message, "YELL");
				if (zone == "arena") then
					RaidNotice_AddMessage(RaidBossEmoteFrame, message, 1.0, 0.0, 0.0);
				end;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("Spell is still on CD");
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Spell cant be cast: " .. targetName .. " sanctuary or not in range.");
	end

end;