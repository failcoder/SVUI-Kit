--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.QuestTracker;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local ROW_WIDTH = 300;
local ROW_HEIGHT = 24;
local INNER_HEIGHT = ROW_HEIGHT - 4;
local LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
local LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;
local OBJ_ICON_ACTIVE = [[Interface\COMMON\Indicator-Yellow]];
local OBJ_ICON_COMPLETE = [[Interface\COMMON\Indicator-Green]];
local OBJ_ICON_INCOMPLETE = [[Interface\COMMON\Indicator-Gray]];
local DEFAULT_COLOR = {r = 1, g = 0.68, b = 0.1}
--[[ 
########################################################## 
SCRIPT HANDLERS
##########################################################
]]--
local ObjectiveTimer_OnUpdate = function(self, elapsed)
	local statusbar = self.Timer.Bar
	local timeNow = GetTime();
	local timeRemaining = statusbar.duration - (timeNow - statusbar.startTime);
	statusbar:SetValue(timeRemaining);
	if(timeRemaining < 0) then
		-- hold at 0 for a moment
		if(timeRemaining > -1) then
			timeRemaining = 0;
		else
			self:StopTimer();
		end
	end
	local r,g,b = MOD:GetTimerTextColor(statusbar.duration, statusbar.duration - timeRemaining)
	statusbar.Label:SetText(GetTimeStringFromSeconds(timeRemaining, nil, true));
	statusbar.Label:SetTextColor(r,g,b);
end

local ObjectiveProgressBar_OnEvent = function(self, event, ...)
	local statusbar = self.Progress.Bar;
	local percent = 100;
	if(not statusbar.finished) then
		percent = GetQuestProgressBarPercent(statusbar.questID);
	end
	statusbar:SetValue(percent);
	statusbar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
end

local ActiveButton_OnEnter = function(self, ...)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, ROW_HEIGHT)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("[Left-Click]", "View the log entry for this quest.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[Right-Click]", "Remove this quest from the tracker.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[SHIFT+Click]", "Show this quest on the map.", 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local ActiveButton_OnLeave = function(self, ...)
	GameTooltip:Hide()
end

local ActiveButton_OnClick = function(self, button)
	MOD.Headers["Active"]:Unset();
end

local ViewButton_OnClick = function(self, button)
	local questIndex = self:GetID();
	if(questIndex and (questIndex ~= 0)) then
		local questID = select(8, GetQuestLogTitle(questIndex));
		if(IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
			local questLink = GetQuestLink(questIndex);
			if(questLink) then
				ChatEdit_InsertLink(questLink);
			end
		elseif(questID and IsShiftKeyDown()) then
			QuestMapFrame_OpenToQuestDetails(questID);
		elseif(questID and button ~= "RightButton") then
			CloseDropDownMenus();
			if(IsQuestComplete(questID) and GetQuestLogIsAutoComplete(questIndex)) then
				AutoQuestPopupTracker_RemovePopUp(questID);
				ShowQuestComplete(questIndex);
			else
				QuestLogPopupDetailFrame_Show(questIndex);
			end
		elseif(questID) then
			RemoveQuestWatch(questIndex);
			if(questID == superTrackedQuestID) then
				QuestSuperTracking_OnQuestUntracked();
			end
		end
	end
end

local CloseButton_OnEnter = function(self)
    self:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local CloseButton_OnLeave = function(self)
    self:SetBackdropBorderColor(0,0,0,1)
end
--[[ 
########################################################## 
TRACKER FUNCTIONS
##########################################################
]]--
local UnsetActiveData = function(self, bypass)
	local block = self.Block;
	block:SetHeight(1);
	block.Header.Text:SetText('');
	block.Header.Level:SetText('');
	block.Badge.Icon:SetTexture(0,0,0,0);
	block.Button:SetID(0);
	self.ActiveQuestID = 0;
	MOD.ActiveQuestID = self.ActiveQuestID;
	MOD.CurrentQuest = 0;
	block.Objectives:Reset();
	self:SetHeight(1);
	block:SetAlpha(0);
	self:SetAlpha(0);
	-- if(MOD.QuestItem and MOD.QuestItem:IsShown()) then
	-- 	MOD.QuestItem.CurrentQuest = 0;
	-- 	MOD.QuestItem.Artwork:SetTexture(SV.NoTexture);
	-- 	MOD.QuestItem:ClearUsage();
	-- end
	if(not bypass and MOD.Headers["Quests"]) then
		MOD:UpdateObjectives('FORCED_UPDATE')
	end
end

local SetActiveData = function(self, title, level, icon, questID, questLogIndex, numObjectives, duration, elapsed, isComplete)
	self.ActiveQuestID = questID;
	MOD.ActiveQuestID = self.ActiveQuestID;
	local fill_height = 0;
	local objective_rows = 0;
	local block = self.Block;

	local color = DEFAULT_COLOR
	if(level and type(level) == 'number') then
		color = GetQuestDifficultyColor(level);
	end
	block.Header.Level:SetTextColor(color.r, color.g, color.b);
	block.Header.Level:SetText(level);
	block.Header.Text:SetText(title);
	block.Button:SetID(questLogIndex);

	MOD.CurrentQuest = questLogIndex;

	local objective_block = block.Objectives;
	objective_block:Reset();
	for i = 1, numObjectives do
		local description, category, completed = GetQuestObjectiveInfo(questID, i);
		if(not completed) then isComplete = false end
		if(duration and elapsed and (elapsed < duration)) then
			objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		elseif(description and description ~= '') then
			objective_rows = objective_block:SetInfo(objective_rows, description, completed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
	end

	if(objective_rows > 0) then
		objective_block:ModHeight(fill_height);
		objective_block:FadeIn();
		fill_height = fill_height + ((INNER_HEIGHT + 4) + (LARGE_INNER_HEIGHT));
	else
		fill_height = fill_height + LARGE_INNER_HEIGHT + 12;
	end

	block:ModHeight(fill_height);

	MOD.Docklet.ScrollFrame.ScrollBar:SetValue(0);

	if(isComplete) then
		icon = MOD.media.completeIcon;
	else
		icon = icon or MOD.media.incompleteIcon;
	end
	block.Badge.Icon:SetTexture(icon);

	if(block.Badge.PostUpdate) then
		block.Badge:PostUpdate(questID)
	end

	self:RefreshHeight()
end

local RefreshActiveHeight = function(self)
	if(self.ActiveQuestID == 0) then
		self:Unset()
	else
		self:FadeIn();
		self.Block:FadeIn();
		self:SetHeight(self.Block:GetHeight())
	end
end

local RefreshActiveObjective = function(self, event, ...)
	-- print('<-----ACTIVE')
	-- print(event)
	-- print(...)
	if(event) then 
		if(event == 'ACTIVE_QUEST_LOADED') then
			self.ActiveQuestID = 0;
			self:Set(...)
		elseif(event == 'SUPER_TRACKED_QUEST_CHANGED') then
			local questID = ...;
			if(questID and questID ~= self.ActiveQuestID) then
				local questLogIndex = GetQuestLogIndexByID(questID)
				if(questLogIndex) then
					local questWatchIndex = GetQuestWatchIndex(questLogIndex)
					if(questWatchIndex) then
						local title, level, suggestedGroup = GetQuestLogTitle(questLogIndex)
						local questID, _, questLogIndex, numObjectives, requiredMoney, completed, startEvent, isAutoComplete, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex);
						self:Set(title, level, nil, questID, questLogIndex, numObjectives, duration, elapsed, hasLocalPOI)
					end
				end
			end
		elseif(event == 'FORCED_UPDATE') then
			local questID = self.ActiveQuestID;
			if(questID and questID ~= 0) then
				local questLogIndex = GetQuestLogIndexByID(questID)
				if(questLogIndex) then
					local questWatchIndex = GetQuestWatchIndex(questLogIndex)
					if(questWatchIndex) then
						local title, level, suggestedGroup = GetQuestLogTitle(questLogIndex)
						local questID, _, questLogIndex, numObjectives, requiredMoney, completed, startEvent, isAutoComplete, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex);
						self:Set(title, level, nil, questID, questLogIndex, numObjectives, duration, elapsed, hasLocalPOI)
					end
				end
			end
		end
	end
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:CheckActiveQuest(questID, ...)
	if(questID and self.Headers["Active"].ActiveQuestID == questID) then
		self.Headers["Active"]:Unset(true);
	else
		local currentQuestIndex = self.CurrentQuest;
		if(currentQuestIndex and (currentQuestIndex ~= 0)) then
			local questLogIndex = select(5, ...);
			if(questLogIndex and (questLogIndex == currentQuestIndex)) then
				self.Headers["Active"]:Set(...);
				return true;
			end
		end
	end
	return false;
end

function MOD:UpdateActiveObjective(event, ...)
	self.Headers["Active"]:Refresh(event, ...)
	self:UpdateDimensions();
end

local function UpdateActiveLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeActive()
	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;

	local active = CreateFrame("Frame", nil, scrollChild)
    active:SetWidth(ROW_WIDTH);
	active:SetHeight(1);
	active:SetPoint("TOPLEFT", self.Headers["Popups"], "BOTTOMLEFT", 0, 0);

	local block = CreateFrame("Frame", nil, active)
	block:ModPoint("TOPLEFT", active, "TOPLEFT", 2, -4);
	block:ModPoint("TOPRIGHT", active, "TOPRIGHT", -2, -4);
	block:ModHeight(LARGE_INNER_HEIGHT);

	block.Button = CreateFrame("Button", nil, block)
	block.Button:ModPoint("TOPLEFT", block, "TOPLEFT", 0, 0);
	block.Button:ModPoint("BOTTOMRIGHT", block, "BOTTOMRIGHT", 0, 8);
	block.Button:SetStyle("DockButton")
	block.Button:SetPanelColor("gold")
	block.Button:SetID(0)
	block.Button.Parent = active;
	block.Button:SetScript("OnClick", ViewButton_OnClick)
	block.Button:SetScript("OnEnter", ActiveButton_OnEnter)
	block.Button:SetScript("OnLeave", ActiveButton_OnLeave)

	block.CloseButton = CreateFrame("Button", nil, block.Button, "UIPanelCloseButton")
	block.CloseButton:RemoveTextures()
	block.CloseButton:SetStyle("Button", nil, 1, -7, -7, nil, "red")
	block.CloseButton:SetFrameLevel(block.Button:GetFrameLevel() + 4)
	block.CloseButton:SetNormalTexture(SV.Media.icon.close)
    block.CloseButton:HookScript("OnEnter", CloseButton_OnEnter)
    block.CloseButton:HookScript("OnLeave", CloseButton_OnLeave)
	block.CloseButton:ModPoint("TOPRIGHT", block.Button, "TOPRIGHT", 4, 4);
	block.CloseButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	block.CloseButton.Parent = active;
	block.CloseButton:SetScript("OnClick", ActiveButton_OnClick)

	block.Badge = CreateFrame("Frame", nil, block.Button)
	block.Badge:ModPoint("TOPLEFT", block.Button, "TOPLEFT", 4, -4);
	block.Badge:ModSize((LARGE_INNER_HEIGHT - 4), (LARGE_INNER_HEIGHT - 4));
	block.Badge:SetStyle("!_Frame", "Inset")

	block.Badge.Icon = block.Badge:CreateTexture(nil,"OVERLAY")
	block.Badge.Icon:InsetPoints(block.Badge);
	block.Badge.Icon:SetTexture(MOD.media.incompleteIcon)
	block.Badge.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	block.Header = CreateFrame("Frame", nil, block)
	block.Header:SetPoint("TOPLEFT", block.Badge, "TOPRIGHT", 4, 0);
	block.Header:SetPoint("TOPRIGHT", block.Button, "TOPRIGHT", -24, -4);
	block.Header:ModHeight(INNER_HEIGHT - 2);
	block.Header:SetStyle("Frame")

	block.Header.Level = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Level:SetFontObject(SVUI_Font_Quest);
	block.Header.Level:SetJustifyH('LEFT')
	block.Header.Level:SetText('')
	block.Header.Level:ModPoint("TOPLEFT", block.Header, "TOPLEFT", 4, 0);
	block.Header.Level:ModPoint("BOTTOMLEFT", block.Header, "BOTTOMLEFT", 4, 0);

	block.Header.Text = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Text:SetFontObject(SVUI_Font_Quest);
	block.Header.Text:SetJustifyH('LEFT')
	block.Header.Text:SetTextColor(1,1,0)
	block.Header.Text:SetText('')
	block.Header.Text:ModPoint("TOPLEFT", block.Header.Level, "TOPRIGHT", 4, 0);
	block.Header.Text:ModPoint("BOTTOMRIGHT", block.Header, "BOTTOMRIGHT", 0, 0);

	block.Details = CreateFrame("Frame", nil, block.Header)
	block.Details:ModPoint("TOPLEFT", block.Header, "BOTTOMLEFT", 0, -2);
	block.Details:ModPoint("TOPRIGHT", block.Header, "BOTTOMRIGHT", 0, -2);

	if(SV.AddQuestCompass) then
		block.Details:ModHeight(INNER_HEIGHT - 4);
		SV:AddQuestCompass(block, block.Badge)
		block.Badge.Compass.Range:ClearAllPoints()
		block.Badge.Compass.Range:ModPoint("TOPLEFT", block.Details, "TOPLEFT", 4, 0);
		block.Badge.Compass.Range:ModPoint("BOTTOMLEFT", block.Details, "BOTTOMLEFT", 4, 0);
		block.Badge.Compass.Range:SetJustifyH("LEFT");
	else
		block.Details:ModHeight(1);
	end

	block.Objectives = MOD:NewObjectiveHeader(block);
	block.Objectives:ModPoint("TOPLEFT", block.Details, "BOTTOMLEFT", 0, -2);
	block.Objectives:ModPoint("TOPRIGHT", block.Details, "BOTTOMRIGHT", 0, -2);
	block.Objectives:ModHeight(1);

	active.Block = block;

	active.ActiveQuestID = 0;
	active.Set = SetActiveData;
	active.Unset = UnsetActiveData;
	active.Refresh = RefreshActiveObjective;
	active.RefreshHeight = RefreshActiveHeight;

	self.Headers["Active"] = active;

	self.Headers["Active"]:RefreshHeight()

	self.ActiveQuestID = self.Headers["Active"].ActiveQuestID;

	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", self.UpdateActiveObjective);

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateActiveLocals, "UpdateActiveLocals");
end