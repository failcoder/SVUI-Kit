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
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.QuestTracker;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local ROW_WIDTH = 300;
local ROW_HEIGHT = 20;
local INNER_HEIGHT = ROW_HEIGHT - 4;
local LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
local LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;

local NO_ICON = SV.NoTexture;
local OBJ_ICON_ACTIVE = [[Interface\COMMON\Indicator-Yellow]];
local OBJ_ICON_COMPLETE = [[Interface\COMMON\Indicator-Green]];
local OBJ_ICON_INCOMPLETE = [[Interface\COMMON\Indicator-Gray]];
local LINE_ACHIEVEMENT_ICON = [[Interface\ICONS\Achievement_General]];
local MAX_OBJECTIVES_SHOWN = 8;
--[[ 
########################################################## 
SCRIPT HANDLERS
##########################################################
]]--
local RowButton_OnEnter = function(self, ...)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, ROW_HEIGHT)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("View this in the achievements window.")
	GameTooltip:Show()
end

local RowButton_OnLeave = function(self, ...)
	GameTooltip:Hide()
end

local ViewButton_OnClick = function(self, button)
	local achievementID = self:GetID();
	if(achievementID and (achievementID ~= 0)) then
		if(IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
			local achievementLink = GetAchievementLink(achievementID);
			if(achievementLink) then
				ChatEdit_InsertLink(achievementLink);
			end
		else
			CloseDropDownMenus();
			if(not AchievementFrame ) then
				AchievementFrame_LoadUI();
			end
			if(IsModifiedClick("QUESTWATCHTOGGLE") ) then
				AchievementObjectiveTracker_UntrackAchievement(_, achievementID);
			elseif(not AchievementFrame:IsShown()) then
				AchievementFrame_ToggleAchievementFrame();
				AchievementFrame_SelectAchievement(achievementID);
			else
				if(AchievementFrameAchievements.selection ~= achievementID) then
					AchievementFrame_SelectAchievement(achievementID);
				else
					AchievementFrame_ToggleAchievementFrame();
				end
			end
		end
	end
end
--[[ 
########################################################## 
TRACKER FUNCTIONS
##########################################################
]]--
local GetAchievementRow = function(self, index)
	if(not self.Rows[index]) then 
		local previousFrame = self.Rows[#self.Rows]
		local index = #self.Rows + 1;

		local anchorFrame;
		if(previousFrame and previousFrame.Objectives) then
			anchorFrame = previousFrame.Objectives;
		else
			anchorFrame = self.Header;
		end

		local row = CreateFrame("Frame", nil, self)
		row:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2);
		row:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -2);
		row:ModHeight(ROW_HEIGHT);

		row.Badge = CreateFrame("Frame", nil, row)
		row.Badge:SetPoint("TOPLEFT", row, "TOPLEFT", 2, -2);
		row.Badge:SetSize(INNER_HEIGHT, INNER_HEIGHT);
		row.Badge:SetStyle("Frame", "Lite")
		row.Badge.Icon = row.Badge:CreateTexture(nil,"OVERLAY")
		row.Badge.Icon:SetAllPoints(row.Badge);
		row.Badge.Icon:SetTexture(LINE_ACHIEVEMENT_ICON)
		row.Badge.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

		row.Header = CreateFrame("Frame", nil, row)
		row.Header:SetPoint("TOPLEFT", row.Badge, "TOPRIGHT", 2, 0);
		row.Header:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, 0);
		row.Header:ModHeight(INNER_HEIGHT);
		row.Header.Text = row.Header:CreateFontString(nil,"OVERLAY")
		row.Header.Text:SetFontObject(SVUI_Font_Quest);
		row.Header.Text:SetJustifyH('LEFT')
		row.Header.Text:SetTextColor(1,1,0)
		row.Header.Text:SetText('')
		row.Header.Text:SetPoint("TOPLEFT", row.Header, "TOPLEFT", 4, 0);
		row.Header.Text:SetPoint("BOTTOMRIGHT", row.Header, "BOTTOMRIGHT", 0, 0);

		row.Button = CreateFrame("Button", nil, row.Header)
		row.Button:SetAllPoints(row.Header);
		row.Button:SetStyle("LiteButton")
		row.Button:SetID(0)
		row.Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row.Button:SetScript("OnClick", ViewButton_OnClick)
		row.Button:SetScript("OnEnter", RowButton_OnEnter)
		row.Button:SetScript("OnLeave", RowButton_OnLeave)

		row.Objectives = MOD:NewObjectiveHeader(row);
		row.Objectives:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, 0);
		row.Objectives:SetPoint("TOPRIGHT", row, "BOTTOMRIGHT", 0, 0);
		row.Objectives:ModHeight(1);

		row.RowID = 0;
		self.Rows[index] = row;
		return row;
	end

	return self.Rows[index];
end

local SetAchievementRow = function(self, index, title, details, icon, achievementID)
	index = index + 1;
	icon = icon or LINE_ACHIEVEMENT_ICON;

	local fill_height = 0;
	local shown_objectives = 0;
	local objective_rows = 0;

	local row = self:Get(index);
	row.RowID = achievementID
	row.Header.Text:SetText(title)
	row.Badge.Icon:SetTexture(icon);
	row.Badge:SetAlpha(1);
	row.Button:Enable();
	row.Button:SetID(achievementID);
	row:ModHeight(ROW_HEIGHT);
	row:FadeIn();
	row.Header:FadeIn();

	local objective_block = row.Objectives;
	local subCount = GetAchievementNumCriteria(achievementID);

	for i = 1, subCount do
		local description, category, completed, quantity, totalQuantity, _, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievementID, i);
		if(not ((not completed) and (shown_objectives > MAX_OBJECTIVES_SHOWN))) then
			if(shown_objectives == MAX_OBJECTIVES_SHOWN and subCount > (6)) then
				shown_objectives = shown_objectives + 1;
			else
				if(description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR) then
					if(string.find(strlower(quantityString), "interface\\moneyframe")) then
						description = quantityString.."\n"..description;
					else
						description = string.gsub(quantityString, " / ", "/").." "..description;
					end
				else
					if(category == CRITERIA_TYPE_ACHIEVEMENT and assetID) then
						_, description = GetAchievementInfo(assetID);
					end
				end
				shown_objectives = shown_objectives + 1;					
			end
			if((not completed) and description and description ~= '') then
				fill_height = fill_height + (INNER_HEIGHT + 2);
				objective_rows = objective_block:SetInfo(objective_rows, description, completed)
				if(duration and elapsed and elapsed < duration) then
					fill_height = fill_height + (INNER_HEIGHT + 2);
					objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
				end
			end
		end
	end

	if(objective_rows > 0) then
		objective_block:ModHeight(fill_height);
		objective_block:FadeIn();
	end

	fill_height = fill_height + (ROW_HEIGHT + 2);

	return index, fill_height;
end

local RefreshAchievements = function(self, event, ...)
	local list = { GetTrackedAchievements() };
	local fill_height = 0;
	local rows = 0;

	if(#list > 0) then
		for i = 1, #list do
			local achievementID = list[i];
			local _, title, _, completed, _, _, _, details, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
			if(not wasEarnedByMe) then
				local add_height = 0;
				rows, add_height = self:Set(rows, title, details, icon, achievementID)
				fill_height = fill_height + add_height
			end
		end
	end

	if(rows == 0 or (fill_height <= 1)) then
		self:SetHeight(1);
		self.Header.Text:SetText('');
		self.Header:SetAlpha(0);
		self:SetAlpha(0);
	else
		self:ModHeight(fill_height + 2);
		self.Header.Text:SetText(TRACKER_HEADER_ACHIEVEMENTS);
		self:FadeIn();
		self.Header:FadeIn();
	end
end

local ResetAchievementBlock = function(self)
	for x = 1, #self.Rows do
		local row = self.Rows[x]
		if(row) then
			row.RowID = 0;
			row.Header.Text:SetText('');
			row.Header:SetAlpha(0);
			row.Button:Disable();
			row.Button:SetID(0);
			row.Badge.Icon:SetTexture(NO_ICON);
			row.Badge:SetAlpha(0);
			row:SetHeight(1);
			row:SetAlpha(0);
			row.Objectives:Reset();
		end
	end
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateAchievements(event, ...)
	self.Headers["Achievements"]:Reset()
	self.Headers["Achievements"]:Refresh(event, ...)
	self:UpdateDimensions();
end

local function UpdateAchievementLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeAchievements()
	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;

    local achievements = CreateFrame("Frame", nil, scrollChild)
    achievements:SetWidth(ROW_WIDTH);
	achievements:ModHeight(ROW_HEIGHT);
	achievements:SetPoint("TOPLEFT", self.Headers["Quests"], "BOTTOMLEFT", 0, -6);

	achievements.Header = CreateFrame("Frame", nil, achievements)
	achievements.Header:SetPoint("TOPLEFT", achievements, "TOPLEFT", 2, -2);
	achievements.Header:SetPoint("TOPRIGHT", achievements, "TOPRIGHT", -2, -2);
	achievements.Header:ModHeight(INNER_HEIGHT);

	achievements.Header.Text = achievements.Header:CreateFontString(nil,"OVERLAY")
	achievements.Header.Text:SetPoint("TOPLEFT", achievements.Header, "TOPLEFT", 2, 0);
	achievements.Header.Text:SetPoint("BOTTOMLEFT", achievements.Header, "BOTTOMLEFT", 2, 0);
	achievements.Header.Text:SetFontObject(SVUI_Font_Quest_Header);
	achievements.Header.Text:SetJustifyH('LEFT')
	achievements.Header.Text:SetTextColor(0.28,0.75,1)
	achievements.Header.Text:SetText(TRACKER_HEADER_ACHIEVEMENTS)

	achievements.Header.Divider = achievements.Header:CreateTexture(nil, 'BACKGROUND');
	achievements.Header.Divider:SetPoint("TOPLEFT", achievements.Header.Text, "TOPRIGHT", -10, 0);
	achievements.Header.Divider:SetPoint("BOTTOMRIGHT", achievements.Header, "BOTTOMRIGHT", 0, 0);
	achievements.Header.Divider:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\DROPDOWN-DIVIDER]]);

	achievements.Rows = {};

	achievements.Get = GetAchievementRow;
	achievements.Set = SetAchievementRow;
	achievements.Refresh = RefreshAchievements;
	achievements.Reset = ResetAchievementBlock;

	self.Headers["Achievements"] = achievements;

	self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE", self.UpdateAchievements);
	self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED", self.UpdateAchievements);

	self.Headers["Achievements"]:Refresh()

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateAchievementLocals, "UpdateAchievementLocals");
end