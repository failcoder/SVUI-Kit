--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local string    = _G.string;
local math      = _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local join, len = string.join, string.len;
--[[ MATH METHODS ]]--
local min = math.min;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local LSM = LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local MOD = SV:NewPackage("Reports", L["Informative Panels"]);

MOD.ReportHolders = {};
MOD.HolderLookup = {};
MOD.ReportTypes = {};
MOD.ReportTooltip = CreateFrame("GameTooltip", "SVUI_ReportTooltip", UIParent, "GameTooltipTemplate");
MOD.BGHolders = {};

local PVP_INFO_SORTING = {
	{"Honor", "Kills", "Assists"}, 
	{"Damage", "Healing", "Deaths"}
};
local PVP_INFO_LOOKUP = {
	["Name"] = {1, NAME}, 
	["Kills"] = {2, KILLS},
	["Assists"] = {3, PET_ASSIST},
	["Deaths"] = {4, DEATHS},
	["Honor"] = {5, HONOR},
	["Faction"] = {6, FACTION},
	["Race"] = {7, RACE},
	["Class"] = {8, CLASS},
	["Damage"] = {10, DAMAGE},
	["Healing"] = {11, SHOW_COMBAT_HEALING},
	["Rating"] = {12, BATTLEGROUND_RATING},
	["Changes"] = {13, RATING_CHANGE},
	["Spec"] = {16, SPECIALIZATION}
};
local DIRTY_LIST = true;
--[[ 
########################################################## 
LOCALIZED GLOBALS
##########################################################
]]--
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
--[[ 
########################################################## 
LOCAL VARIABLES
##########################################################
]]--
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local BGStatString = "%s: %s"
local myName = UnitName("player");
local myClass = select(2,UnitClass("player"));
local classColor = RAID_CLASS_COLORS[myClass];
local SCORE_CACHE = {};
local hexHighlight = "FFFFFF";
local StatMenuListing = {}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local UpdateAnchor = function()
	local backdrops, width, height = SV.db.Reports.backdrop
	for _, parent in ipairs(MOD.ReportHolders) do
		local point1, point2, x, y = "LEFT", "RIGHT", 4, 0;
		local slots = parent.Stats.Slots
		local numPoints = #slots
		if(parent.Stats.Orientation == "VERTICAL") then
			width = parent:GetWidth() - 4;
			height = parent:GetHeight() / numPoints - 4;

			point1, point2, x, y = "TOP", "BOTTOM", 0, -4
		else
			width = parent:GetWidth() / numPoints - 4;
			height = parent:GetHeight() - 4;
			if(backdrops) then
				height = height + 6
			end
		end

		for i = 1, numPoints do 
			slots[i]:ModWidth(width)
			slots[i]:ModHeight(height)
			if(i == 1) then 
				slots[i]:ModPoint(point1, parent, point1, x, y)
			else
				slots[i]:ModPoint(point1, slots[i - 1], point2, x, y)
			end
		end 
	end 
end

local _hook_TooltipOnShow = function(self)
	self:SetBackdrop({
		bgFile = SV.BaseTexture, 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		edgeSize = 1
		})
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetBackdropBorderColor(0, 0, 0)
end 

local function TruncateString(value)
	if value >= 1e9 then 
		return ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
	elseif value >= 1e6 then 
		return ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
	elseif value >= 1e3 or value <= -1e3 then 
		return ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
	else 
		return value 
	end 
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:SetDataTip(stat)
	local parent = stat:GetParent()
	MOD.ReportTooltip:Hide()
	MOD.ReportTooltip:SetOwner(parent, parent.Stats.TooltipAnchor)
	MOD.ReportTooltip:ClearLines()
	GameTooltip:Hide()
end

function MOD:SetBrokerTip(stat)
	local parent = stat:GetParent()
	MOD.ReportTooltip:Hide()
	MOD.ReportTooltip:SetOwner(parent, "ANCHOR_CURSOR")
	MOD.ReportTooltip:ClearLines()
	GameTooltip:Hide()
end

function MOD:PrependDataTip()
	MOD.ReportTooltip:AddDoubleLine("[Alt + Click]", "Swap Stats", 0, 1, 0, 0.5, 1, 0.5)
	MOD.ReportTooltip:AddLine(" ")
end

function MOD:ShowDataTip(noSpace)
	if(not noSpace) then
		MOD.ReportTooltip:AddLine(" ")
	end
	MOD.ReportTooltip:AddDoubleLine("[Alt + Click]", "Swap Stats", 0, 1, 0, 0.5, 1, 0.5)
	MOD.ReportTooltip:Show()
end

local function GetDataSlot(parent, index)
	if(not parent.Stats.Slots[index]) then
		local GlobalName = parent:GetName() .. 'StatSlot' .. index;

		local slot = CreateFrame("Button", GlobalName, parent);
		slot:RegisterForClicks("AnyUp")


		slot.barframe = CreateFrame("Frame", nil, slot)
		
		if(SV.db.Reports.backdrop) then
			slot.barframe:ModPoint("TOPLEFT", slot, "TOPLEFT", 24, -2)
			slot.barframe:ModPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -2, 2)
			slot:SetStyle(parent.Stats.templateType, parent.Stats.templateName)
		else
			slot.barframe:ModPoint("TOPLEFT", slot, "TOPLEFT", 24, 2)
			slot.barframe:ModPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2)
			slot.barframe.bg = slot.barframe:CreateTexture(nil, "BORDER")
			slot.barframe.bg:InsetPoints(slot.barframe, 2, 2)
			slot.barframe.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
			slot.barframe.bg:SetGradient(unpack(SV.Media.gradient.dark))
		end

		slot.barframe:SetFrameLevel(slot:GetFrameLevel()-1)
		slot.barframe:SetBackdrop({
			bgFile = [[Interface\BUTTONS\WHITE8X8]], 
			edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\GLOW]], 
			tile = false, 
			tileSize = 0, 
			edgeSize = 2, 
			insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
		slot.barframe:SetBackdropColor(0, 0, 0, 0.5)
		slot.barframe:SetBackdropBorderColor(0, 0, 0, 0.8)

		slot.barframe.icon = CreateFrame("Frame", nil, slot.barframe)
		slot.barframe.icon:ModPoint("TOPLEFT", slot, "TOPLEFT", 0, 6)
		slot.barframe.icon:ModPoint("BOTTOMRIGHT", slot, "BOTTOMLEFT", 26, -6)
		slot.barframe.icon.texture = slot.barframe.icon:CreateTexture(nil, "OVERLAY")
		slot.barframe.icon.texture:InsetPoints(slot.barframe.icon, 2, 2)
		slot.barframe.icon.texture:SetTexture(SV.NoTexture)

		slot.barframe.bar = CreateFrame("StatusBar", nil, slot.barframe)
		slot.barframe.bar:InsetPoints(slot.barframe, 2, 2)
		slot.barframe.bar:SetStatusBarTexture(SV.Media.bar.default)
			
		slot.barframe.bar.extra = CreateFrame("StatusBar", nil, slot.barframe.bar)
		slot.barframe.bar.extra:SetAllPoints()
		slot.barframe.bar.extra:SetStatusBarTexture(SV.Media.bar.default)
		slot.barframe.bar.extra:Hide()

		slot.barframe:Hide()

		slot.textframe = CreateFrame("Frame", nil, slot)
		slot.textframe:SetAllPoints(slot)
		slot.textframe:SetFrameStrata(parent.Stats.textStrata)

		slot.text = slot.textframe:CreateFontString(nil, "OVERLAY", nil, 7)
		slot.text:SetAllPoints()

		SV:FontManager(slot.text, "data")
		if(SV.db.Reports.backdrop) then
			slot.text:SetShadowColor(0, 0, 0, 0.5)
			slot.text:SetShadowOffset(2, -4)
		end

		slot.SlotKey = i;
		slot.TokenKey = 738;
		slot.MenuList = {};
		slot.TokenList = {};

		parent.Stats.Slots[index] = slot;
		return slot;
	end

	return parent.Stats.Slots[index];
end  

function MOD:NewReportType(newStat, eventList, onEvents, update, click, focus, blur, init)
	if not newStat then return end 
	self.ReportTypes[newStat] = {}
	tinsert(StatMenuListing, newStat)
	if type(eventList) == "table" then 
		self.ReportTypes[newStat]["events"] = eventList;
		self.ReportTypes[newStat]["event_handler"] = onEvents 
	end 
	if update and type(update) == "function" then 
		self.ReportTypes[newStat]["update_handler"] = update 
	end 
	if click and type(click) == "function" then 
		self.ReportTypes[newStat]["click_handler"] = click 
	end 
	if focus and type(focus) == "function" then 
		self.ReportTypes[newStat]["focus_handler"] = focus 
	end 
	if blur and type(blur) == "function" then 
		self.ReportTypes[newStat]["blur_handler"] = blur 
	end 
	if init and type(init) == "function" then 
		self.ReportTypes[newStat]["init_handler"] = init 
	end 
end

do
	local Stat_OnLeave = function()
		MOD.ReportTooltip:Hide()
	end

	local Parent_OnClick = function(self, button)
		if IsAltKeyDown() then
			SV.Dropdown:Open(self, self.MenuList);
		elseif(self.onClick) then
			self.onClick(self, button);
		end
	end

	local function _load(parent, name, config)
		parent.StatParent = name

		if config["init_handler"]then 
			config["init_handler"](parent)
		end

		if config["events"]then 
			for _, event in pairs(config["events"])do 
				parent:RegisterEvent(event)
			end 
		end 

		if config["event_handler"]then 
			parent:SetScript("OnEvent", config["event_handler"])
			config["event_handler"](parent, "SVUI_FORCE_RUN")
		end 

		if config["update_handler"]then 
			parent:SetScript("OnUpdate", config["update_handler"])
			config["update_handler"](parent, 20000)
		end 

		if config["click_handler"]then
			parent.onClick = config["click_handler"]
		end
		parent:SetScript("OnClick", Parent_OnClick)

		if config["focus_handler"]then 
			parent:SetScript("OnEnter", config["focus_handler"])
		end 

		if config["blur_handler"]then 
			parent:SetScript("OnLeave", config["blur_handler"])
		else 
			parent:SetScript("OnLeave", Stat_OnLeave)
		end

		parent:Show()
	end

	local BG_OnUpdate = function(self)
		local scoreString;
		local scoreindex = self.scoreindex;
		local scoreType = self.scoretype;
		local scoreCount = GetNumBattlefieldScores()
		for i = 1, scoreCount do
			SCORE_CACHE = {GetBattlefieldScore(i)}
			if(SCORE_CACHE[1] and SCORE_CACHE[1] == myName and SCORE_CACHE[scoreindex]) then
				scoreString = TruncateString(SCORE_CACHE[scoreindex])
				self.text:SetFormattedText(BGStatString, scoreType, scoreString)
				break 
			end 
		end 
	end

	local BG_OnEnter = function(self)
		MOD:SetDataTip(self)
		local bgName;
		local mapToken = GetCurrentMapAreaID()
		local r, g, b;
		if(classColor) then
			r, g, b = classColor.r, classColor.g, classColor.b
		else
			r, g, b = 1, 1, 1
		end

		local scoreCount = GetNumBattlefieldScores()

		for i = 1, scoreCount do 
			bgName = GetBattlefieldScore(i)
			if(bgName and bgName == myName) then 
				MOD.ReportTooltip:AddDoubleLine(L["Stats For:"], bgName, 1, 1, 1, r, g, b)
				MOD.ReportTooltip:AddLine(" ")
				if(mapToken == 443 or mapToken == 626) then 
					MOD.ReportTooltip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Flags Returned"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 482) then 
					MOD.ReportTooltip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				elseif(mapToken == 401) then 
					MOD.ReportTooltip:AddDoubleLine(L["Graveyards Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Graveyards Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Towers Assaulted"], GetBattlefieldStatData(i, 3), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Towers Defended"], GetBattlefieldStatData(i, 4), 1, 1, 1)
				elseif(mapToken == 512) then 
					MOD.ReportTooltip:AddDoubleLine(L["Demolishers Destroyed"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Gates Destroyed"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 540 or mapToken == 736 or mapToken == 461) then 
					MOD.ReportTooltip:AddDoubleLine(L["Bases Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Bases Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 856) then 
					MOD.ReportTooltip:AddDoubleLine(L["Orb Possessions"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ReportTooltip:AddDoubleLine(L["Victory Points"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 860) then 
					MOD.ReportTooltip:AddDoubleLine(L["Carts Controlled"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				end 
				break 
			end 
		end 
		MOD:ShowDataTip()
	end

	local ForceHideBGStats;
	local BG_OnClick = function()
		ForceHideBGStats = true;
		MOD:UpdateAllReports()
		SV:AddonMessage(L["Battleground statistics temporarily hidden, to show type \"/sv bg\" or \"/sv pvp\""])
	end

	local function setMenuLists()
		local anchorTable = MOD.ReportHolders;
		local statMenu = StatMenuListing;

		tsort(statMenu)

		for place, parent in ipairs(anchorTable) do
			local slots = parent.Stats.Slots;
			local numPoints = #slots;
			for i = 1, numPoints do 
				local subList = twipe(slots[i].MenuList)
				tinsert(subList,{text = NONE, func = function() MOD:ChangeDBVar("", i, "holders", place); MOD:UpdateAllReports() end});
				for _,name in pairs(statMenu) do
					tinsert(subList,{text = name, func = function() MOD:ChangeDBVar(name, i, "holders", place); MOD:UpdateAllReports() end});
				end
			end
		end

		DIRTY_LIST = false;
	end 

	function MOD:UpdateAllReports()
		if(DIRTY_LIST) then setMenuLists() end
		
		local instance, groupType = IsInInstance()
		local anchorTable = MOD.ReportHolders
		local reportTable = MOD.ReportTypes
		local db = SV.db.Reports
		local allowPvP = (db.battleground and not ForceHideBGStats) or false

		for reportIndex, parent in ipairs(anchorTable) do
			local slots = parent.Stats.Slots;
			local numPoints = #slots;
			local pvpIndex = parent.Stats.BGStats;
			local pvpSwitch = (allowPvP and pvpIndex and (MOD.BGHolders[pvpIndex] == reportIndex))

			for i = 1, numPoints do
				local pvpTable = (pvpSwitch and PVP_INFO_SORTING[pvpIndex]) and PVP_INFO_SORTING[pvpIndex][i]
				local slot = slots[i];

				slot:UnregisterAllEvents()
				slot:SetScript("OnUpdate", nil)
				slot:SetScript("OnEnter", nil)
				slot:SetScript("OnLeave", nil)
				slot:SetScript("OnClick", nil)
				slot.text:SetText(nil)

				if slot.barframe then 
					slot.barframe:Hide()
				end 

				slot:Hide()

				if(pvpTable and ((instance and groupType == "pvp") or parent.lockedOpen)) then
					slot.scoreindex = PVP_INFO_LOOKUP[pvpTable][1]
					slot.scoretype = PVP_INFO_LOOKUP[pvpTable][2]
					slot:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
					slot:SetScript("OnEvent", BG_OnUpdate)
					slot:SetScript("OnEnter", BG_OnEnter)
					slot:SetScript("OnLeave", Stat_OnLeave)
					slot:SetScript("OnClick", BG_OnClick)

					BG_OnUpdate(slot)

					slot:Show()
				else 
					for name, config in pairs(reportTable) do
						for panelIndex, panelData in pairs(db.holders) do 
							if(panelData and type(panelData) == "table") then 
								if(panelIndex == reportIndex and panelData[i] and panelData[i] == name) then 
									_load(slot, name, config)
								end 
							elseif(panelData and type(panelData) == "string" and panelData == name) then 
								_load(slot, name, config) 
							end 
						end
					end 
				end 
			end
		end

		if ForceHideBGStats then ForceHideBGStats = nil end

		local baseWidth, dockHeight = SV.Dock.BottomCenter:GetSize()
		local dockWidth = baseWidth * 0.5;
		MOD.ReportGroup1:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup2:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup3:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup4:SetSize(dockWidth, dockHeight);
	end
end

local currentIndex = 1;

function MOD:NewHolder(parent, maxCount, tipAnchor, pvpSet, customTemplate, isVertical)
	DIRTY_LIST = true
	local parentName = parent:GetName();

	self.ReportHolders[currentIndex] = parent;
	parent.Stats = {};
	parent.Stats.Slots = {};
	parent.Stats.Orientation = isVertical and "VERTICAL" or "HORIZONTAL";
	parent.Stats.TooltipAnchor = tipAnchor or "ANCHOR_CURSOR";
	if(pvpSet) then
		parent.Stats.BGStats = pvpSet;
		self.BGHolders[pvpSet] = currentIndex;
	end

	local point1, point2, x, y = "LEFT", "RIGHT", 4, 0;
	if(isVertical) then
		point1, point2, x, y = "TOP", "BOTTOM", 0, -4;
	end

	if(customTemplate) then
		parent.Stats.templateType = "!_Frame"
		parent.Stats.templateName = customTemplate
		parent.Stats.textStrata = "LOW"
	else
		parent.Stats.templateType = "DockButton";
		parent.Stats.templateName = "DockButton";
		parent.Stats.textStrata = "MEDIUM";
	end

	for i = 1, maxCount do
		local slot = GetDataSlot(parent, i)
		if(i == 1) then 
			parent.Stats.Slots[i]:ModPoint(point1, parent, point1, x, y)
		else
			parent.Stats.Slots[i]:ModPoint(point1, parent.Stats.Slots[i - 1], point2, x, y)
		end
	end

	parent:SetScript("OnSizeChanged", UpdateAnchor);

	if(not SV.db.Reports.holders[currentIndex]) then
		SV.db.Reports.holders[currentIndex] = {};
        for i = 1, maxCount do
        	SV.db.Reports.holders[currentIndex][i] = "None"
        end
	end

	currentIndex = currentIndex + 1;

	UpdateAnchor(parent);
end

local function SlashPvPStats()
	MOD.ForceHideBGStats = nil;
	MOD:UpdateAllReports()
	SV:AddonMessage(L['Battleground statistics will now show again if you are inside a battleground.'])
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:SetAccountantData(dataType, cacheType, defaultValue)
	self.Accountant[dataType] = self.Accountant[dataType] or {};
	local cache = self.Accountant[dataType];
	if(not cache[playerName] or type(cache[playerName]) ~= cacheType) then
		cache[playerName] = defaultValue;
	end
end 

function MOD:Load()
	local baseWidth, dockHeight = SV.Dock.BottomCenter:GetSize()
	local dockWidth = baseWidth * 0.5;

	hexHighlight = SV:HexColor("highlight") or "FFFFFF"
	local hexClass = classColor.colorStr
	BGStatString = "|cff" .. hexHighlight .. "%s: |c" .. hexClass .. "%s|r";

	local accountant = Librarian("Registry"):NewGlobal("Accountant")
	accountant[playerRealm] = accountant[playerRealm] or {};
	self.Accountant = accountant[playerRealm];

	--BOTTOM CENTER BARS
	local bottomLeft = CreateFrame("Frame", "SVUI_ReportsGroup1", SV.Dock.BottomCenter)
	bottomLeft:SetSize(dockWidth, dockHeight)
	bottomLeft:SetPoint("BOTTOMLEFT", SV.Dock.BottomCenter, "BOTTOMLEFT", 0, 0)
	SV:NewAnchor(bottomLeft, L["Data Reports 1"])
	self:NewHolder(bottomLeft, 3, "ANCHOR_CURSOR")

	local bottomRight = CreateFrame("Frame", "SVUI_ReportsGroup2", SV.Dock.BottomCenter)
	bottomRight:SetSize(dockWidth, dockHeight)
	bottomRight:SetPoint("BOTTOMRIGHT", SV.Dock.BottomCenter, "BOTTOMRIGHT", 0, 0)
	SV:NewAnchor(bottomRight, L["Data Reports 2"])
	self:NewHolder(bottomRight, 3, "ANCHOR_CURSOR")
	--SV:ManageVisibility(self.BottomCenter)

	--TOP CENTER BARS
	local topLeft = CreateFrame("Frame", "SVUI_ReportsGroup3", SV.Dock.TopCenter)
	topLeft:SetSize(dockWidth, dockHeight)
	topLeft:SetPoint("TOPLEFT", SV.Dock.TopCenter, "TOPLEFT", 0, 0)

	SV:NewAnchor(topLeft, L["Data Reports 3"])
	self:NewHolder(topLeft, 3, "ANCHOR_CURSOR", 1)

	local topRight = CreateFrame("Frame", "SVUI_ReportsGroup4", SV.Dock.TopCenter)
	topRight:SetSize(dockWidth, dockHeight)
	topRight:SetPoint("TOPRIGHT", SV.Dock.TopCenter, "TOPRIGHT", 0, 0)

	SV:NewAnchor(topRight, L["Data Reports 4"])
	self:NewHolder(topRight, 3, "ANCHOR_CURSOR", 2)

	self.ReportGroup1 = bottomLeft;
	self.ReportGroup2 = bottomRight;
	self.ReportGroup3 = topLeft;
	self.ReportGroup4 = topRight;

	SV:ManageVisibility(self.TopCenter)
	
	-- self.ReportTooltip:SetParent(SV.Screen)
	self.ReportTooltip:SetFrameStrata("DIALOG")
	self.ReportTooltip:HookScript("OnShow", _hook_TooltipOnShow)

	if(LDB) then
	  	for dataName, dataObj in LDB:DataObjectIterator() do

		    local OnEnter, OnLeave, OnClick, lastObj;

		    if dataObj.OnTooltipShow then 
		      	function OnEnter(self)
					dataObj.OnTooltipShow(GameTooltip)
					-- GameTooltip:SetBackdropColor(0, 0, 0, 1)
					-- if(GameTooltip.SuperBorder) then
					-- 	GameTooltip.SuperBorder:SetBackdropColor(0, 0, 0, 0.8)
					-- end
				end
		    end

		    if dataObj.OnEnter then 
		      	function OnEnter(self)
					dataObj.OnEnter(self)
					-- GameTooltip:SetBackdropColor(0, 0, 0, 1)
					-- if(GameTooltip.SuperBorder) then
					-- 	GameTooltip.SuperBorder:SetBackdropColor(0, 0, 0, 0.8)
					-- end
				end
		    end

		    if dataObj.OnLeave then 
				function OnLeave(self)
					MOD.ReportTooltip:Hide()
					dataObj.OnLeave(self)
				end 
		    end

		    if dataObj.OnClick then
		    	function OnClick(self, button)
			      	dataObj.OnClick(self, button)
			    end
			end

			local function textUpdate(event, name, key, value, dataobj)
				if value == nil or (len(value) > 5) or value == 'n/a' or name == value then
					lastObj.text:SetText(value ~= 'n/a' and value or name)
				else
					lastObj.text:SetText(name..': '.. '|cff' .. hexHighlight ..value..'|r')
				end
			end

		    local function OnEvent(self)
				lastObj = self;
				LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..dataName.."_text", textUpdate)
				LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..dataName.."_value", textUpdate)
				LDB.callbacks:Fire("LibDataBroker_AttributeChanged_"..dataName.."_text", dataName, nil, dataObj.text, dataObj)
		    end

		    MOD:NewReportType(dataName, {"PLAYER_ENTERING_WORLD"}, OnEvent, nil, OnClick, OnEnter, OnLeave)
	  	end
	end

	self:UpdateAllReports()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllReports");

	SV.Events:On("DOCKS_UPDATED", MOD.UpdateAllReports, "RefreshReports");

	local slashDesc = L['Battleground statistics will now show again if you are inside a battleground.']
	SV:AddSlashCommand("bg", slashDesc, SlashPvPStats);
	SV:AddSlashCommand("pvp", slashDesc, SlashPvPStats);
end