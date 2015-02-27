--[[
##########################################################
S V U I   By: Munglunch
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
local tinsert   = _G.tinsert;
local tremove   = _G.tremove;
local wipe      = _G.wipe;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round, maxNum = math.abs, math.ceil, math.floor, math.round, math.max;
--[[ TABLE METHODS ]]--
local tsort, tcopy = table.sort, table.copy;
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
local QUEST_ROW_HEIGHT = ROW_HEIGHT + 2;
local INNER_HEIGHT = ROW_HEIGHT - 4;
local LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
local LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;
local OBJ_ICON_ACTIVE = [[Interface\COMMON\Indicator-Yellow]];
local OBJ_ICON_COMPLETE = [[Interface\COMMON\Indicator-Green]];
local OBJ_ICON_INCOMPLETE = [[Interface\COMMON\Indicator-Gray]];

local CACHED_QUESTS = {};
local QUESTS_BY_LOCATION = {};
local QUEST_HEADER_MAP = {};
local USED_QUESTIDS = {};
local TICKERS, ACTIVE_ITEMS, SWAP_ITEMS = {}, {}, {};
local CURRENT_MAP_ID = 0;
local WORLDMAP_UPDATE = false;

local DEFAULT_COLOR = {r = 1, g = 0.68, b = 0.1}

local QuestInZone = {
	[14108] = 541,
	[13998] = 11,
	[25798] = 61,
	[25799] = 61,
	[25112] = 161,
	[25111] = 161,
	[24735] = 201,
};
local ItemBlacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
};
--[[ 
########################################################## 
ITEM BAR/BUTTON CONSTRUCT
##########################################################
]]--
local ItemBar = _G["SVUI_QuestItemBar"];
ItemBar.Buttons = {};

local ItemBar_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED' and self.needsUpdate) then
        self:Update()
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end
ItemBar:SetScript('OnEvent', ItemBar_OnEvent);

local CreateQuestItemButton;
do
    --[[ HANDLERS ]]--

    local Button_UpdateCooldown = function(self)
        if(self:IsShown() and self.itemID) then
            local start, duration, enable = GetItemCooldown(self.itemID)
            if((start and start > 0) and (duration and duration > 0)) then
                self.Cooldown:SetCooldown(start, duration)
                self.Cooldown:Show()
            else
                self.Cooldown:Hide()
            end
        end
    end

    local Button_OnEnter = function(self)
        if(self.itemID) then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip:SetHyperlink(self.itemLink)
        end
        if(self.___overflow) then
            self:FadeIn()
        end
    end

    local Button_OnLeave = function(self)
    	GameTooltip_Hide()
        if(self.___overflow) then
            self:FadeOut()
        end
    end

    local Button_OnEvent = function(self, event)
        if(event == 'BAG_UPDATE_COOLDOWN') then
            self:UpdateCooldown()
        elseif(event == 'PLAYER_REGEN_ENABLED') then
            self:SetAttribute('item', self.attribute)
            self:UnregisterEvent(event)
            self:UpdateCooldown()
        --else
            --self:Update()
        end
    end

    local Button_SetItem = function(self, itemLink, texture, completed)
    	if(completed) then
    		self:ClearUsage()
    		return
    	end
        if(itemLink) then
            if(ACTIVE_ITEMS[itemLink] or ((itemLink == self.itemLink) and self:IsShown())) then
                return
            end
            ACTIVE_ITEMS[itemLink] = self:GetID();
            self.Icon:SetTexture(texture)
            self.itemID, self.itemName = string.match(itemLink, '|Hitem:(.-):.-|h%[(.+)%]|h')
            self.itemLink = itemLink

            if(ItemBlacklist[self.itemID]) then
                return
            end
            self:FadeIn()
        end

        if(InCombatLockdown()) then
            self.attribute = self.itemName
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:SetAttribute('item', self.itemName)
            self:UpdateCooldown()
        end

        return true
    end

    local Button_ClearItem = function(self)
        if(InCombatLockdown()) then
            self.attribute = nil;
            self:RegisterEvent('PLAYER_REGEN_ENABLED');
        else
            self:SetAttribute('item', nil)
        end
    end

    local Button_UpdateItem = function(self)
		local numItems = 0
		local shortestDistance = 62500
		local closestQuestLink, closestQuestTexture
		local activeQuestLink, activeQuestTexture

		for index = 1, GetNumQuestWatches() do
			local questID, _, questIndex, _, _, isComplete = GetQuestWatchInfo(index)
			if(questID and QuestHasPOIInfo(questID)) then
				local link, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questIndex)
				if(link) then
					local areaID = QuestInZone[questID]
					if questIndex == MOD.CurrentQuest then
						activeQuestLink = link
						activeQuestTexture = texture
					end
					if(areaID and areaID == GetCurrentMapAreaID()) then
						closestQuestLink = link
						closestQuestTexture = texture
					elseif(not isComplete or (isComplete and showCompleted)) then
						local distanceSq, onContinent = GetDistanceSqToQuest(questIndex)
						if(onContinent and distanceSq < shortestDistance) then
							shortestDistance = distanceSq
							closestQuestLink = link
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end

		if(closestQuestLink) then
			self:SetUsage(closestQuestLink, closestQuestTexture);
		elseif(activeQuestLink) then
			self:SetUsage(activeQuestLink, activeQuestTexture);
		end

		local name = self:GetName();
		if(numItems > 0 and not TICKERS[name]) then
			TICKERS[name] = C_Timer.NewTicker(30, function()
				self:Update()
			end)
		elseif(numItems == 0 and TICKERS[name]) then
			TICKERS[name]:Cancel()
			TICKERS[name] = nil
		end
	end

    --[[ METHOD ]]--

    CreateQuestItemButton = function(index)
    	local buttonName = "SVUI_QuestButton" .. index
        local itembutton = CreateFrame('Button', buttonName, UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate');
        itembutton:SetStyle("Outline");
        itembutton:ModSize(28, 28);
        itembutton:SetID(index);
        itembutton.___overflow = false;
        itembutton.SetUsage = Button_SetItem;
        itembutton.ClearUsage = Button_ClearItem;
        itembutton.Update = Button_UpdateItem;
        itembutton.UpdateCooldown = Button_UpdateCooldown;

        local Icon = itembutton:CreateTexture('$parentIcon', 'BACKGROUND')
        Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        Icon:SetAllPoints()
        itembutton.Icon = Icon

        local Cooldown = CreateFrame('Cooldown', '$parentCooldown', itembutton, 'CooldownFrameTemplate')
        Cooldown:ClearAllPoints()
        Cooldown:SetPoint('TOPRIGHT', -2, -3)
        Cooldown:SetPoint('BOTTOMLEFT', 2, 1)
        Cooldown:Hide()
        itembutton.Cooldown = Cooldown

        --RegisterStateDriver(itembutton, 'visible', '[petbattle] hide; show')
        itembutton:SetAttribute('type', 'item');
        itembutton:SetAttribute('_onattributechanged', [[
            if(name == 'item') then
                if(value and not self:IsShown()) then
                    self:Show()
                elseif(not value) then
                    self:Hide()
                end
            end
        ]]);

        itembutton:SetScript('OnEnter', Button_OnEnter);
        itembutton:SetScript('OnLeave', Button_OnLeave);

        itembutton:RegisterEvent('UPDATE_EXTRA_ACTIONBAR');
		itembutton:RegisterEvent('BAG_UPDATE_COOLDOWN');
		itembutton:RegisterEvent('BAG_UPDATE_DELAYED');
		itembutton:RegisterEvent('WORLD_MAP_UPDATE');
		itembutton:RegisterEvent('QUEST_LOG_UPDATE');
		itembutton:RegisterEvent('QUEST_POI_UPDATE');
        itembutton:SetScript('OnEvent', Button_OnEvent);

        return itembutton
    end

    function ItemBar:SetQuestItem(itemLink, texture, completed)
    	if(not itemLink) then return end
    	local savedIndex = ACTIVE_ITEMS[itemLink]
    	if(savedIndex and self.Buttons[savedIndex]) then
    		self.Buttons[savedIndex]:SetUsage(itemLink, texture, completed)
    		return
    	end

		local maxIndex = #self.Buttons;
		for i = 1, maxIndex do
			if(not self.Buttons[i]:GetAttribute('item')) then
	    		self.Buttons[i]:SetUsage(itemLink, texture, completed)
	    		return
	    	end
		end

		local index = maxIndex + 1
		self.Buttons[index] = CreateQuestItemButton(index)
		self.Buttons[index]:SetUsage(itemLink, texture, completed)
	end
end

function ItemBar:Reset()
	local maxIndex = #self.Buttons;
	for i = 1, maxIndex do
		local button = self.Buttons[i];
		button:ClearUsage();
	end
end

local function HideItemBarButtons()
	local maxIndex = #ItemBar.Buttons;
	for i = 1, maxIndex do
		local button = ItemBar.Buttons[i];
		button:FadeOut(0.1, 1, 0, true);
	end
	ItemBar:FadeOut(0.1, 1, 0, true)
end

local function ShowItemBarButtons()
	local maxIndex = #ItemBar.Buttons;
	for link, index in pairs(ACTIVE_ITEMS) do
		local button = ItemBar.Buttons[index];
		button:FadeIn();
	end
	ItemBar:FadeIn();
end

function ItemBar:Update()
	if(InCombatLockdown()) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.needsUpdate = true
		return
	end
	wipe(SWAP_ITEMS);
	local maxIndex = #self.Buttons;
	local firstButton = self.Buttons[1];
	local itemLink = firstButton.itemLink;
	if(itemLink and ACTIVE_ITEMS[itemLink]) then
		SWAP_ITEMS[itemLink] = 1
	end

	firstButton:ClearAllPoints();

	local a1, a2, x, y = "BOTTOM", "TOP", 0, 2;
	if(SV.db.QuestTracker.itemBarDirection == 'HORIZONTAL') then
		a1, a2, x, y = "LEFT", "RIGHT", 2, 0;
		firstButton:SetPoint("LEFT", self, "LEFT", 2, 0);
		if(SV.Tooltip and (not self.tipanchorchecked) and SV.Tooltip.Holder and SV.Tooltip.Holder.Grip and (not SV.Tooltip.Holder.Grip:HasMoved())) then
			SV.Tooltip.DefaultPadding = 56
			self.tipanchorchecked = true
		end
		-- if(SV.Tooltip and SV.Tooltip.Holder and SV.Tooltip.Holder.Grip) then
		-- 	print(SV.Tooltip.Holder.Grip:GetPoint())
		-- end
	else
		firstButton:SetPoint("TOP", self, "TOP", 0, -2);
	end

	local lastButton, totalShown, button = firstButton, 1;

	for i = 2, maxIndex do
		button = self.Buttons[i];
		itemLink = button.itemLink;

		button:ClearAllPoints();
		if(button:IsShown()) then
			totalShown = totalShown + 1;
			if(totalShown > 5) then
				if(totalShown == 6) then
					button:SetPoint(a1, firstButton, a2, x, y)
				else
					button:SetPoint(a1, lastButton, a2, x, y)
				end
				button.___overflow = true;
				button:FadeOut();
			else
				button:SetPoint(a2, lastButton, a1, x, -y)
				button.___overflow = false;
				button:FadeIn();
			end
			lastButton = button

			if(itemLink) then
				if(ACTIVE_ITEMS[itemLink]) then
					SWAP_ITEMS[itemLink] = i
				end
			else
				button:ClearUsage()
			end
		end
	end

	wipe(ACTIVE_ITEMS);
	for k,v in pairs(SWAP_ITEMS) do
		ACTIVE_ITEMS[k] = v
	end

	self.needsUpdate = nil
end
--[[ 
########################################################## 
QUEST CACHING
##########################################################
]]--
local function CacheQuestHeaders()
	wipe(QUEST_HEADER_MAP)

	local currentHeader = "Misc";
	local numEntries, numQuests = GetNumQuestLogEntries();

	for i = 1, numEntries do
		local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i);
		if(isHeader) then
			currentHeader = title;
		else
			QUEST_HEADER_MAP[questID] = currentHeader
		end
	end
end

local function UpdateCachedQuests(needsSorting)
	local s = 62500;
	local c = 0;
	local li = 0;
	local HeadersCached = false;

	wipe(QUESTS_BY_LOCATION)

	for i = 1, GetNumQuestWatches() do
		local questID, _, questLogIndex, numObjectives, _, completed, _, _, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);
		if(questID) then  -- and (not USED_QUESTIDS[questID])
			local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questLogIndex)
			local link, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
			if(not CACHED_QUESTS[questID]) then
				CACHED_QUESTS[questID] = {i, title, level, texture, questID, questLogIndex, numObjectives, duration, elapsed, completed, questType, link};
			else
				CACHED_QUESTS[questID][1] = i;	            -- args: quest watch index
				CACHED_QUESTS[questID][2] = title;	        -- args: quest title
				CACHED_QUESTS[questID][3] = level;	        -- args: quest level
				CACHED_QUESTS[questID][4] = texture;	    -- args: quest item icon
				CACHED_QUESTS[questID][5] = questID;	    -- args: quest id
				CACHED_QUESTS[questID][6] = questLogIndex;	-- args: quest log index
				CACHED_QUESTS[questID][7] = numObjectives;	-- args: quest objective count
				CACHED_QUESTS[questID][8] = duration;		-- args: quest timer duration
				CACHED_QUESTS[questID][9] = elapsed;		-- args: quest timer elapsed
				CACHED_QUESTS[questID][10] = completed;		-- args: quest is completed
				CACHED_QUESTS[questID][11] = questType;	    -- args: quest type
				CACHED_QUESTS[questID][12] = link;	        -- args: quest item link
			end

			if(questID == MOD.ActiveQuestID) then
				MOD:UpdateActiveObjective('FORCED_UPDATE')
			end

			if(not QUEST_HEADER_MAP[questID] and (not HeadersCached)) then
				CacheQuestHeaders()
				HeadersCached = true
			end

			local header = QUEST_HEADER_MAP[questID] or "Misc"

			tinsert(QUESTS_BY_LOCATION, {distanceSq, header, questID});
		end
	end

	tsort(QUESTS_BY_LOCATION, function(a,b) 
		if(a[2] and b[2]) then
			return a[2] < b[2] 
		else
			return false
		end
	end);

	tsort(QUESTS_BY_LOCATION, function(a,b) 
		if(a[1] and b[1]) then
			return a[1] < b[1] 
		else
			return false
		end
	end);
end

local function UpdateCachedDistance()
	local s = 62500;
	wipe(QUESTS_BY_LOCATION)
	local HeadersCached = false;
	for questID,questData in pairs(CACHED_QUESTS) do
		local questLogIndex = questData[6];
		local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
		if(not QUEST_HEADER_MAP[questID] and (not HeadersCached)) then
			CacheQuestHeaders()
			HeadersCached = true
		end
		local header = QUEST_HEADER_MAP[questID] or "Misc"
		tinsert(QUESTS_BY_LOCATION, {distanceSq, header, questID});
	end

	tsort(QUESTS_BY_LOCATION, function(a,b) 
		if(a[2] and b[2]) then
			return a[2] < b[2] 
		else
			return false
		end
	end);

	tsort(QUESTS_BY_LOCATION, function(a,b) 
		if(a[1] and b[1]) then
			return a[1] < b[1] 
		else
			return false
		end
	end);
end

local function AddCachedQuest(questLogIndex)
	local HeadersCached = false;
	if(questLogIndex) then  -- and (not USED_QUESTIDS[questID])
		local i = GetQuestWatchIndex(questLogIndex)
		if(i) then
			local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
			local questID, _, _, numObjectives, _, completed, _, _, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(i);

			if(not CACHED_QUESTS[questID]) then
				local title, level, suggestedGroup = GetQuestLogTitle(questLogIndex)
				local link, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				local mapID, floorNumber = 0,0
				if(not WorldMapFrame:IsShown()) then
					mapID, floorNumber = GetQuestWorldMapAreaID(questID)
				else
					WORLDMAP_UPDATE = true;
				end

				CACHED_QUESTS[questID] = {i, title, level, texture, questID, questLogIndex, numObjectives, duration, elapsed, completed, questType, link};

				if(not QUEST_HEADER_MAP[questID] and (not HeadersCached)) then
					CacheQuestHeaders()
					HeadersCached = true
				end
				local header = QUEST_HEADER_MAP[questID] or "Misc"
				tinsert(QUESTS_BY_LOCATION, {distanceSq, header, questID});

				tsort(QUESTS_BY_LOCATION, function(a,b) 
					if(a[2] and b[2]) then
						return a[2] < b[2] 
					else
						return false
					end
				end);

				tsort(QUESTS_BY_LOCATION, function(a,b) 
					if(a[1] and b[1]) then
						return a[1] < b[1] 
					else
						return false
					end
				end);
			end

			return questID;
		end
	end

	return false;
end
--[[ 
########################################################## 
SCRIPT HANDLERS
##########################################################
]]--
local BadgeButton_OnEnter = function(self, ...)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, ROW_HEIGHT)
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Click to track this quest.")
	GameTooltip:Show()
end

local RowButton_OnEnter = function(self, ...)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, ROW_HEIGHT)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("[Left-Click]", "View the log entry for this quest.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[Right-Click]", "Remove this quest from the tracker.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[SHIFT+Click]", "Show this quest on the map.", 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local AnyButton_OnLeave = function(self, ...)
	GameTooltip:Hide()
end

local TimerBar_OnUpdate = function(self, elapsed)
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
	self.Timer.TimeLeft:SetText(GetTimeStringFromSeconds(timeRemaining, nil, true));
	self.Timer.TimeLeft:SetTextColor(r,g,b);
end

local ActiveButton_OnClick = function(self, button)
	local rowIndex = self:GetID();
	if(rowIndex and (rowIndex ~= 0)) then
		local questID, _, questLogIndex, numObjectives, requiredMoney, completed, startEvent, isAutoComplete, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(rowIndex);
		if(questID) then
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questLogIndex)
			local icon = self.Icon:GetTexture()
			SetSuperTrackedQuestID(questID);
			MOD.Headers["Active"]:Set(title, level, icon, questID, questLogIndex, numObjectives, duration, elapsed, isComplete);
		end
	end
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
--[[ 
########################################################## 
TRACKER FUNCTIONS
##########################################################
]]--
local StartTimer = function(self, duration, elapsed)
	local timeNow = GetTime();
	local startTime = timeNow - elapsed;
	local timeRemaining = duration - startTime;

	self.Timer:ModHeight(INNER_HEIGHT);
	self.Timer:FadeIn();
	self.Timer.Bar.duration = duration or 1;
	self.Timer.Bar.startTime = startTime;
	self.Timer.Bar:SetMinMaxValues(0, self.Timer.Bar.duration);
	self.Timer.Bar:SetValue(timeRemaining);
	self.Timer.TimeLeft:SetText(GetTimeStringFromSeconds(duration, nil, true));
	self.Timer.TimeLeft:SetTextColor(MOD:GetTimerTextColor(duration, duration - timeRemaining));

	self:SetScript("OnUpdate", TimerBar_OnUpdate);
end

local StopTimer = function(self)
	self.Timer:SetHeight(1);
	self.Timer:SetAlpha(0);
	self.Timer.Bar.duration = 1;
	self.Timer.Bar.startTime = 0;
	self.Timer.Bar:SetMinMaxValues(0, self.Timer.Bar.duration);
	self.Timer.Bar:SetValue(0);
	self.Timer.TimeLeft:SetText('');
	self.Timer.TimeLeft:SetTextColor(1,1,1);

	self:SetScript("OnUpdate", nil);
end

local GetQuestRow = function(self, index)
	if(not self.Rows[index]) then 
		local previousFrame = self.Rows[#self.Rows]
		local index = #self.Rows + 1;
		local yOffset = -3;

		local anchorFrame;
		if(previousFrame and previousFrame.Objectives) then
			anchorFrame = previousFrame.Objectives;
			yOffset = -6;
		else
			anchorFrame = self.Header;
		end

		local row = CreateFrame("Frame", nil, self)
		row:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, yOffset);
		row:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, yOffset);
		row:ModHeight(QUEST_ROW_HEIGHT);

		row.Badge = CreateFrame("Frame", nil, row)
		row.Badge:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0);
		row.Badge:ModSize(QUEST_ROW_HEIGHT, QUEST_ROW_HEIGHT);
		row.Badge:SetStyle("Transparent")

		row.Badge.Icon = row.Badge:CreateTexture(nil,"OVERLAY")
		row.Badge.Icon:SetAllPoints(row.Badge);
		row.Badge.Icon:SetTexture(MOD.media.incompleteIcon)
		row.Badge.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

		row.Badge.Button = CreateFrame("Button", nil, row.Badge)
		row.Badge.Button:SetAllPoints(row.Badge);
		row.Badge.Button:SetStyle("Lite")
		row.Badge.Button:SetID(0)
		row.Badge.Button.Icon = row.Badge.Icon;
		row.Badge.Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row.Badge.Button:SetScript("OnClick", ActiveButton_OnClick)
		row.Badge.Button:SetScript("OnEnter", BadgeButton_OnEnter)
		row.Badge.Button:SetScript("OnLeave", AnyButton_OnLeave)

		row.Header = CreateFrame("Frame", nil, row)
		row.Header:SetPoint("TOPLEFT", row, "TOPLEFT", (QUEST_ROW_HEIGHT + 6), 0);
		row.Header:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, 0);
		row.Header:ModHeight(INNER_HEIGHT);

		row.Header.Level = row.Header:CreateFontString(nil,"OVERLAY")
		row.Header.Level:SetFontObject(SVUI_Font_Quest_Number);
		row.Header.Level:SetJustifyH('RIGHT')
		row.Header.Level:SetText('')
		row.Header.Level:SetPoint("TOPRIGHT", row.Header, "TOPRIGHT", -4, 0);
		row.Header.Level:SetPoint("BOTTOMRIGHT", row.Header, "BOTTOMRIGHT", -4, 0);

		row.Header.Text = row.Header:CreateFontString(nil,"OVERLAY")
		row.Header.Text:SetFontObject(SVUI_Font_Quest);
		row.Header.Text:SetJustifyH('LEFT')
		row.Header.Text:SetTextColor(1,1,0)
		row.Header.Text:SetText('')
		row.Header.Text:SetPoint("TOPLEFT", row.Header, "TOPLEFT", 4, 0);
		row.Header.Text:SetPoint("BOTTOMRIGHT", row.Header.Level, "BOTTOMLEFT", 0, 0);

		row.Header.Zone = row:CreateFontString(nil,"OVERLAY")
		row.Header.Zone:SetAllPoints(row);
		row.Header.Zone:SetFontObject(SVUI_Font_Quest);
		row.Header.Zone:SetJustifyH('LEFT')
		row.Header.Zone:SetTextColor(0.75,0.25,1)
		row.Header.Zone:SetText("")

		row.Button = CreateFrame("Button", nil, row.Header)
		row.Button:SetAllPoints(row.Header);
		row.Button:SetStyle("Lite")
		row.Button:SetID(0)
		row.Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		row.Button:SetScript("OnClick", ViewButton_OnClick);
		row.Button:SetScript("OnEnter", RowButton_OnEnter)
		row.Button:SetScript("OnLeave", AnyButton_OnLeave)

		row.Timer = CreateFrame("Frame", nil, row)
		row.Timer:ModPoint("TOPLEFT", row, "BOTTOMLEFT", 0, 4);
		row.Timer:ModPoint("TOPRIGHT", row, "BOTTOMRIGHT", 0, 4);
		row.Timer:ModHeight(INNER_HEIGHT);

		row.Timer.Bar = CreateFrame("StatusBar", nil, row.Timer);
		row.Timer.Bar:ModPoint("TOPLEFT", row.Timer, "TOPLEFT", 4, -2);
		row.Timer.Bar:ModPoint("BOTTOMRIGHT", row.Timer, "BOTTOMRIGHT", -4, 2);
		row.Timer.Bar:SetStatusBarTexture(SV.media.statusbar.default)
		row.Timer.Bar:SetStatusBarColor(0.5,0,1) --1,0.15,0.08
		row.Timer.Bar:SetMinMaxValues(0, 1)
		row.Timer.Bar:SetValue(0)
		
		local bgFrame = CreateFrame("Frame", nil, row.Timer.Bar)
		bgFrame:InsetPoints(row.Timer.Bar, -2, -2)
		bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)
		
		bgFrame.bg = bgFrame:CreateTexture(nil, "BACKGROUND")
		bgFrame.bg:SetAllPoints(bgFrame)
		bgFrame.bg:SetTexture(SV.media.statusbar.default)
	  	bgFrame.bg:SetVertexColor(0,0,0,0.5)

		local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
		borderB:SetTexture(0,0,0)
		borderB:SetPoint("BOTTOMLEFT")
		borderB:SetPoint("BOTTOMRIGHT")
		borderB:SetHeight(2)

		local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
		borderT:SetTexture(0,0,0)
		borderT:SetPoint("TOPLEFT")
		borderT:SetPoint("TOPRIGHT")
		borderT:SetHeight(2)

		local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
		borderL:SetTexture(0,0,0)
		borderL:SetPoint("TOPLEFT")
		borderL:SetPoint("BOTTOMLEFT")
		borderL:SetWidth(2)

		local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
		borderR:SetTexture(0,0,0)
		borderR:SetPoint("TOPRIGHT")
		borderR:SetPoint("BOTTOMRIGHT")
		borderR:SetWidth(2)

		row.Timer.TimeLeft = row.Timer.Bar:CreateFontString(nil,"OVERLAY");
		row.Timer.TimeLeft:InsetPoints(row.Timer.Bar);
		row.Timer.TimeLeft:SetFontObject(SVUI_Font_Quest_Number);
		row.Timer.TimeLeft:SetTextColor(1,1,1)
		row.Timer.TimeLeft:SetText('')

		row.Timer:SetHeight(1);
		row.Timer:SetAlpha(0);

		row.StartTimer = StartTimer;
		row.StopTimer = StopTimer;

		row.Objectives = MOD:NewObjectiveHeader(row);
		row.Objectives:SetPoint("TOPLEFT", row.Timer, "BOTTOMLEFT", 0, 0);
		row.Objectives:SetPoint("TOPRIGHT", row.Timer, "BOTTOMRIGHT", 0, 0);
		row.Objectives:SetHeight(1);

		row.RowID = 0;
		self.Rows[index] = row;
		return row;
	end

	return self.Rows[index];
end

local SetQuestRow = function(self, index, watchIndex, title, level, icon, questID, questLogIndex, subCount, duration, elapsed, completed, questType)
	if(not watchIndex) then
		return index,0
	end
	index = index or #self.Rows
	index = index + 1;

	local fill_height = 0;
	local iscomplete = true;
	local objective_rows = 0;
	local row = self:Get(index);

	if(not icon) then
		icon = completed and MOD.media.completeIcon or MOD.media.incompleteIcon
	end
	local color = DEFAULT_COLOR
	if(level and type(level) == 'number') then
		color = GetQuestDifficultyColor(level);
	end

	row.Header:SetAlpha(1);
	row.Header.Zone:SetText('')
	row.Header.Level:SetTextColor(color.r, color.g, color.b)
	row.Header.Level:SetText(level)
	row.Header.Text:SetTextColor(color.r, color.g, color.b)
	row.Header.Text:SetText(title)
	row.Badge.Icon:SetTexture(icon);
	row.Badge.Button:Enable();
	row.Badge.Button:SetID(watchIndex);
	row.Badge:SetAlpha(1);
	row.Button:SetAlpha(1);
	row.Button:Enable();
	row.Button:SetID(questLogIndex);
	row:ModHeight(QUEST_ROW_HEIGHT);
	row:FadeIn();

	local objective_block = row.Objectives;
	objective_block:Reset();

	for i = 1, subCount do
		local description, category, objective_completed = GetQuestObjectiveInfo(questID, i);
		if not objective_completed then iscomplete = false end
		if(description) then
			fill_height = fill_height + (INNER_HEIGHT + 4);
			objective_rows = objective_block:SetInfo(objective_rows, description, objective_completed);
		end
	end

	if(duration) then
		if(elapsed and elapsed < duration) then
			fill_height = fill_height + (INNER_HEIGHT + 4);
			row:StartTimer(duration, elapsed)
		end
	end

	if(objective_rows > 0) then
		objective_block:ModHeight(fill_height);
		objective_block:FadeIn();
	end

	fill_height = fill_height + (QUEST_ROW_HEIGHT + 6);

	return index, fill_height;
end

local SetZoneHeader = function(self, index, zoneName)
	index = index + 1;
	local row = self:Get(index);
	row.Header.Level:SetText('');
	row.Header.Text:SetText('');
	row.Badge.Icon:SetTexture("");
	row.Badge.Button:SetID(0);
	row.Badge:SetAlpha(0);
	row.Button:SetID(0);
	row.Button:Disable();
	row.Button:SetAlpha(0);
	row.Badge.Button:Disable();
	row.Header.Zone:SetTextColor(1,0.31,0.1)
	row.Header.Zone:SetText(zoneName);
	row:ModHeight(ROW_HEIGHT);
	row:SetAlpha(1);

	local objective_block = row.Objectives;
	objective_block:Reset();
	return index, zoneName;
end

local RefreshQuests = function(self, event, ...)
	local rows = 0;
	local fill_height = 0;
	local zone = 0;

	for i = 1, #QUESTS_BY_LOCATION do
		local zoneName = QUESTS_BY_LOCATION[i][2]
		local questID = QUESTS_BY_LOCATION[i][3]
		local quest = CACHED_QUESTS[questID]
		if(quest) then
			if(quest[2] and quest[2] ~= '') then
				local add_height = 0;
				if(zone ~= zoneName) then
					rows, zone = self:SetZone(rows, zoneName);
					fill_height = fill_height + QUEST_ROW_HEIGHT;
				end
				rows, add_height = self:Set(rows, unpack(quest))
				fill_height = fill_height + add_height;
				if(quest[12]) then
					ItemBar:SetQuestItem(quest[12], quest[4], quest[10])
				end
			end
		end
	end

	if(rows == 0 or (fill_height <= 1)) then
		self:SetHeight(1);
		self:SetAlpha(0);
	else
		self:ModHeight(fill_height + 2);
		self:FadeIn();
	end

	ItemBar:Update()
end

local AddOneQuest = function(self, questID)
	local rows = 0;
	if(questID) then
		local fill_height = self:GetHeight();
		local quest = CACHED_QUESTS[questID];
		if(quest[2] and quest[2] ~= '') then
			local add_height = 0;
			rows, add_height = self:Set(rows, unpack(quest))
			fill_height = fill_height + add_height;
			if(quest[12]) then
				ItemBar:SetQuestItem(quest[12], quest[4], quest[10])
			end
		end

		self:ModHeight(fill_height + 2);
	end

	ItemBar:Update()
end

local ResetQuestBlock = function(self)
	if(not self:IsVisible()) then return end
	for x = 1, #self.Rows do
		local row = self.Rows[x]
		if(row) then
			row.Header.Text:SetText('');
			row.Header:SetAlpha(0);
			row.Header.Zone:SetText('');
			row.Button:SetID(0);
			row.Button:Disable();
			row.Badge.Button:SetID(0);
			row.Badge.Icon:SetTexture("");
			row.Badge:SetAlpha(0);
			row.Badge.Button:Disable();
			row:SetHeight(1);
			row:SetAlpha(0);
			row.Objectives:Reset();
		end
	end
	UpdateCachedQuests();
end

local LiteResetQuestBlock = function(self)
	for x = 1, #self.Rows do
		local row = self.Rows[x]
		if(row) then
			row.Objectives:Reset(true);
		end
	end
end

local _hook_WorldMapFrameOnHide = function()
	if(not WORLDMAP_UPDATE) then return end
	MOD.Headers["Quests"]:Reset()
	MOD.Headers["Quests"]:Refresh()
	MOD:UpdateDimensions();
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateObjectives(event, ...)
	if(not self.Headers["Quests"]:IsVisible()) then return end
	if(event == "ZONE_CHANGED_NEW_AREA") then
		if(not WorldMapFrame:IsShown() and GetCVarBool("questPOI")) then
			SetMapToCurrentZone();
			CURRENT_MAP_ID = GetCurrentMapAreaID();
			UpdateCachedDistance();
			self.Headers["Quests"]:LiteReset()
			self.Headers["Quests"]:Refresh(event, ...)
		end
	elseif(event == "ZONE_CHANGED") then
		local inMicroDungeon = IsPlayerInMicroDungeon();
		if(inMicroDungeon ~= self.inMicroDungeon) then
			if(not WorldMapFrame:IsShown() and GetCVarBool("questPOI")) then
				SetMapToCurrentZone();
				CURRENT_MAP_ID = GetCurrentMapAreaID();
				UpdateCachedDistance();
				self.Headers["Quests"]:LiteReset()
				self.Headers["Quests"]:Refresh(event, ...)
			end
			self.inMicroDungeon = inMicroDungeon;
		end
	else
		if(event == "QUEST_ACCEPTED" or event == "QUEST_WATCH_LIST_CHANGED") then
			local questLogIndex, questID, isTracked;
			if(event == "QUEST_ACCEPTED") then
				questLogIndex, questID = ...;
				if(AUTO_QUEST_WATCH == "1") then
					AddQuestWatch(questLogIndex);
					QuestSuperTracking_OnQuestTracked(questID);
				end
				local addedQuest = AddCachedQuest(questLogIndex)
				if(addedQuest) then
					self.Headers["Quests"]:AddQuest(addedQuest)
					self:UpdateDimensions();
				end
			elseif(event == "QUEST_WATCH_LIST_CHANGED") then
				questID, isTracked = ...;
				if(questID) then
					local questLogIndex = GetQuestLogIndexByID(questID)
					if(isTracked) then
						local addedQuest = AddCachedQuest(questLogIndex)
						self.Headers["Quests"]:AddQuest(addedQuest)
					else
						CACHED_QUESTS[questID] = nil;
						self:CheckActiveQuest(questID);
						self.Headers["Quests"]:Reset();
						self.Headers["Quests"]:Refresh(event, ...)
					end
					self:UpdateDimensions();
				end
			end
		elseif(event == "QUEST_TURNED_IN") then
			local questID, XP, Money = ...
			if(IsQuestTask(questID)) then
				self:CacheBonusObjective(event, ...);
			end
			if(CACHED_QUESTS[questID]) then
				CACHED_QUESTS[questID] = nil;
				self:CheckActiveQuest(questID);
				ItemBar:Reset();
				self.Headers["Quests"]:Reset();
				self.Headers["Quests"]:Refresh(event, ...);
				self:UpdateDimensions();
			end
		elseif(event == "QUEST_LOG_UPDATE") then
			self.Headers["Quests"]:Reset();
			self.Headers["Quests"]:Refresh(event, ...)
			self:UpdateBonusObjective(event, ...);
			self:UpdateDimensions();
		else
			self:UpdateBonusObjective(event, ...)
		end
	end
end

local function UpdateQuestLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
	QUEST_ROW_HEIGHT = ROW_HEIGHT + 2;
end

local ticker;
local _hook_QuestDock_OnShow = function(self)
	if(not self:IsShown()) then return end
	if(not ticker) then
		ticker = SV.Timers:ExecuteTimer(ShowItemBarButtons, 1)
	end
	MOD.Headers["Quests"]:Reset()
	MOD.Headers["Quests"]:Refresh()
end

local _hook_QuestDock_OnHide = function(self)
	if(self:IsShown()) then return end
	if(ticker) then
		SV.Timers:RemoveTimer(ticker)
		ticker = nil
	end
	HideItemBarButtons()
end

function MOD:InitializeQuests()
	ItemBar:ClearAllPoints();
	ItemBar:SetParent(SV.Screen);
	if(SV.db.QuestTracker.itemBarDirection == 'HORIZONTAL') then
		ItemBar:ModPoint("BOTTOMLEFT", SV.Dock.BottomRight, "TOPLEFT", 0, 4);
		ItemBar:SetWidth(SV.Dock.BottomRight:GetWidth());
		ItemBar:SetHeight(32);
	else
		ItemBar:ModPoint("TOPRIGHT", SV.Dock.BottomRight, "TOPLEFT", -4, 0);
		ItemBar:SetWidth(32);
		ItemBar:SetHeight(SV.Dock.BottomRight:GetHeight());
	end

	SV:NewAnchor(ItemBar, L["Quest Items"]);
	for i = 1, 5 do
		ItemBar.Buttons[i] = CreateQuestItemButton(i)
	end

	self.Docklet:HookScript("OnShow", _hook_QuestDock_OnShow)
	self.Docklet:HookScript("OnHide", _hook_QuestDock_OnHide)

	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;
	local quests = CreateFrame("Frame", nil, scrollChild)
	quests:SetWidth(ROW_WIDTH);
	quests:ModHeight(ROW_HEIGHT);
	quests:SetPoint("TOPLEFT", self.Headers["Bonus"], "BOTTOMLEFT", 0, -4);
	--quests:SetStyle()

	quests.Header = CreateFrame("Frame", nil, quests)
	quests.Header:SetPoint("TOPLEFT", quests, "TOPLEFT", 2, -2);
	quests.Header:SetPoint("TOPRIGHT", quests, "TOPRIGHT", -2, -2);
	quests.Header:ModHeight(INNER_HEIGHT);

	quests.Header.Text = quests.Header:CreateFontString(nil,"OVERLAY")
	quests.Header.Text:SetPoint("TOPLEFT", quests.Header, "TOPLEFT", 2, 0);
	quests.Header.Text:SetPoint("BOTTOMLEFT", quests.Header, "BOTTOMLEFT", 2, 0);
	quests.Header.Text:SetFontObject(SVUI_Font_Quest_Header);
	quests.Header.Text:SetJustifyH('LEFT')
	quests.Header.Text:SetTextColor(0.28,0.75,1)
	quests.Header.Text:SetText(TRACKER_HEADER_QUESTS)

	quests.Header.Divider = quests.Header:CreateTexture(nil, 'BACKGROUND');
	quests.Header.Divider:SetPoint("TOPLEFT", quests.Header.Text, "TOPRIGHT", -10, 0);
	quests.Header.Divider:SetPoint("BOTTOMRIGHT", quests.Header, "BOTTOMRIGHT", 0, 0);
	quests.Header.Divider:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\DROPDOWN-DIVIDER]]);

	quests.Rows = {};

	quests.Get = GetQuestRow;
	quests.Set = SetQuestRow;
	quests.SetZone = SetZoneHeader;
	quests.Refresh = RefreshQuests;
	quests.AddQuest = AddOneQuest;
	quests.Reset = ResetQuestBlock;
	quests.LiteReset = LiteResetQuestBlock;

	self.Headers["Quests"] = quests;

	self:RegisterEvent("QUEST_LOG_UPDATE", self.UpdateObjectives);
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", self.UpdateObjectives);
	self:RegisterEvent("QUEST_ACCEPTED", self.UpdateObjectives);	
	self:RegisterEvent("QUEST_POI_UPDATE", self.UpdateObjectives);
	self:RegisterEvent("QUEST_TURNED_IN", self.UpdateObjectives);

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.UpdateObjectives);
	self:RegisterEvent("ZONE_CHANGED", self.UpdateObjectives);

	--ItemBar:Reset();
	CacheQuestHeaders()
	self.Headers["Quests"]:Reset()
	self.Headers["Quests"]:Refresh()

	WorldMapFrame:HookScript("OnHide", _hook_WorldMapFrameOnHide)
	ItemBar:Show()

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateQuestLocals, true);
end