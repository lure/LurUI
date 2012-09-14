--[[ 
SpellBookFrame TOPLEFT nil TOPLEFT 258.99477022264 -73.789704451551

SpellBookFrame *
CharacterFrame   *
QuestLogFrame  *
PVPFrame *
PVEFrame *
MerchantFrame *
GossipFrame  *
BankFrame *

PlayerTalentFrame  -
AchievementFrame -
GuildFrame  -
PetJournal  -
EncounterJournal -
AuctionFrame -
ClassTrainerFrame -
GuildBankFrame -

/run point, relativeTo, relativePoint, xOfs, yOfs = GetMouseFocus():GetPoint() print(relativeTo:GetName())
/run local f=GetMouseFocus() print(f:GetName(), f:GetPoint())

frameToMove:CreateTitleRegion():SetAllPoints()
frameToMove:SetUserPlaced(true)
]]--


--local waitframe = CreateFrame("Frame", nil, UIParent)

-- this is a coordinate constant. Handled frames are always mounted ro UIparent with specifed points
local FRAMEPOINT  = "TOPLEFT"
local PARENTFRAME = UIParent
local PARENTPOINT = "BOTTOMLEFT"

local function LM_OnDragStart(self, ...)
	self:StartMoving(...)
	self.LM_custom=true
end

local function LM_OnDragStop(self, ...)
	self:StopMovingOrSizing(...)
	self:LM_SavePosition()
end

local function LM_SetPoint(self, ...)
	if (self.LM_custom) then
		self:LM_hook_SetPoint(FRAMEPOINT, PARENTFRAME, PARENTPOINT, self.LM_X, self.LM_Y)  
	else
		self:LM_hook_SetPoint(...)
	end
end 

local function LM_SavePosition(self, ...)
	self.LM_X = self:GetLeft()	
	self.LM_Y = self:GetTop()
end

local function LM_OnShow(self, ...)
	if(self.LM_custom) then 
		self:LM_hook_SetPoint(FRAMEPOINT, PARENTFRAME, PARENTPOINT, self.LM_X, self.LM_Y)
	end
	self:LM_hook_OnShow(...)
end

local function mountFrame(frame)
	if (frame and (not frame.LM_mounted)) then
		if (frame ~= WorldFrame) then 
			frame:SetMovable(true)
			frame:EnableMouse(true)
			frame:RegisterForDrag("LeftButton")
			frame:SetClampedToScreen(true)
			-- doesn't really work
			frame:SetUserPlaced(true)
			frame.ignoreFramePositionManager=true
			
			frame:SetScript("OnDragStart", LM_OnDragStart)
			frame:SetScript("OnDragStop", LM_OnDragStop)
			
			frame.LM_hook_OnShow = frame:GetScript("OnShow")
			frame:SetScript("OnShow", LM_OnShow)
			
			frame.LM_hook_SetPoint = frame.SetPoint
			frame.SetPoint = LM_SetPoint
			
			--add save position function pointer
			frame.LM_SavePosition = LM_SavePosition;
			frame.LM_mounted = true 
		else
			print("Cant make movable WorldFrame - it is base of WoW frames")
		end
	else		
		print("Selected frame is nil, sorry")
	end
end

local function mountFrames()
	local frames = {
		[SpellBookFrame]=true,
		[CharacterFrame]=true,
		[QuestLogFrame]=true,
		[PVPFrame]=true,
		[PVEFrame]=true,
		[MerchantFrame]=true,
		[GossipFrame]=true,
		[BankFrame]=true,
		[FriendsFrame]=true,
	}
	
	for f in pairs(frames) do
		mountFrame(f)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
frame.PLAYER_ENTERING_WORLD = function(self, ...)
	mountFrames()
	hooksecurefunc("PetJournal_LoadUI", function() mountFrame(PetJournalParent) end); 
	hooksecurefunc("TalentFrame_LoadUI", function() mountFrame(PlayerTalentFrame) end); 
	hooksecurefunc("EncounterJournal_LoadUI", function() mountFrame(EncounterJournal) end); 
	hooksecurefunc("AchievementFrame_LoadUI", function() mountFrame(AchievementFrame) end); 
	hooksecurefunc("GuildFrame_LoadUI", function() mountFrame(GuildFrame) end); 
	hooksecurefunc("AuctionFrame_LoadUI", function() mountFrame(AuctionFrame) end); 
	hooksecurefunc("Calendar_LoadUI", function() mountFrame(CalendarFrame) end);
end





--[[

ToggleCalendar
ToggleGlyphFrame
ToggleGuildFinder

ToggleTimeManager

var result =".";
var regex = /^Toggle.+/; 
$(".mw-content-ltr ul li").each(function (){
    var tx = $(this).text();
    if(tx.match(regex)){
		result += tx +"\n";
    } 
 })
$(".atflb").append("<textarea>"+result+"</textarea>");
]]--
