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
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table; 
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local min 			= math.min;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetGarrison       	= _G.GetGarrison;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local hooksecurefunc     	= _G.hooksecurefunc;
--[[ 
########################################################## 
ADDON
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local MOD = SV.Dock;
local GarrisonData = {};
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local function GetDockCooldown(itemID)
	local start,duration = GetItemCooldown(itemID)
	local expires = duration - (GetTime() - start)
	if expires > 0.05 then 
		local timeLeft = 0;
		local calc = 0;
		if expires < 4 then
			return format("|cffff0000%.1f|r", expires)
		elseif expires < 60 then 
			return format("|cffffff00%d|r", floor(expires)) 
		elseif expires < 3600 then
			timeLeft = ceil(expires / 60);
			calc = floor((expires / 60) + .5);
			return format("|cffff9900%dm|r", timeLeft)
		elseif expires < 86400 then
			timeLeft = ceil(expires / 3600);
			calc = floor((expires / 3600) + .5);
			return format("|cff66ffff%dh|r", timeLeft)
		else
			timeLeft = ceil(expires / 86400);
			calc = floor((expires / 86400) + .5);
			return format("|cff6666ff%dd|r", timeLeft)
		end
	else 
		return "|cff6666ffReady|r"
	end 
end

local GarrisonButton_OnEvent = function(self, event, ...)
    if (event == "GARRISON_HIDE_LANDING_PAGE") then
        if(not InCombatLockdown() and SVUI_Garrison:IsShown()) then
        	SVUI_Garrison.Parent:SetWidth(SVUI_Garrison.Parent:GetWidth() - SVUI_Garrison:GetWidth())
        	SVUI_Garrison:Hide()
        end;
    elseif (event == "GARRISON_SHOW_LANDING_PAGE") then
    	if(not InCombatLockdown() and (not SVUI_Garrison:IsShown())) then
    		SVUI_Garrison.Parent:SetWidth(SVUI_Garrison.Parent:GetWidth() + SVUI_Garrison:GetWidth())
    		SVUI_Garrison:Show() 
    	end;
    end
    if((not SVUI_Garrison.StartAlert) or (not SVUI_Garrison.StopAlert)) then return end
    if ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
        SVUI_Garrison:StartAlert();
    elseif ( event == "GARRISON_BUILDING_ACTIVATED" or event == "GARRISON_ARCHITECT_OPENED") then
        SVUI_Garrison:StopAlert();
    elseif ( event == "GARRISON_MISSION_FINISHED" ) then
        SVUI_Garrison:StartAlert();
    elseif ( event == "GARRISON_MISSION_NPC_OPENED" ) then
        SVUI_Garrison:StopAlert();
    elseif (event == "GARRISON_INVASION_AVAILABLE") then
        SVUI_Garrison:StartAlert();
    elseif (event == "GARRISON_INVASION_UNAVAILABLE") then
        SVUI_Garrison:StopAlert();
    elseif (event == "SHIPMENT_UPDATE") then
        local shipmentStarted = ...;
        if (shipmentStarted) then
            SVUI_Garrison:StartAlert();
        end
    end
end

local function getColoredString(text, color)
	local hex = SV:HexColor(color)
	return ("|cff%s%s|r"):format(hex, text)
end

local function GetActiveMissions()
	wipe(GarrisonData)
	local hasMission = false

	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddLine("Active Missions", 1, 0.7, 0)

	for key,data in pairs(C_Garrison.GetInProgressMissions()) do
		GarrisonData[data.missionID] = {
			name = data.name,
			level = data.level,
			seconds = data.durationSeconds,
			timeLeft = data.timeLeft,
			completed = false,
			isRare = data.isRare,
			type = data.type,
		}
		hasMission = true
	end

	for key,data in pairs(C_Garrison.GetCompleteMissions()) do
		if(GarrisonData[data.missionID]) then
			GarrisonData[data.missionID].completed = true
		end
	end

	for key,data in pairs(GarrisonData) do
		local hex = data.isRare and "blue" or "green"
		local mission = ("%s|cff888888 - |r%s"):format(getColoredString(data.level, "yellow"), getColoredString(data.name, hex));
		local remaining
		if (data.completed) then
			remaining = L["Complete!"]
		else
			remaining = ("%s %s"):format(data.timeLeft, getColoredString(" ("..SV:ParseSeconds(data.seconds)..")", "lightgrey"))
		end

		GameTooltip:AddDoubleLine(mission, remaining, 0, 1, 0, 1, 1, 1)
		hasMission = true
	end

	if(not hasMission) then
		GameTooltip:AddLine("None", 1, 0, 0)
	end
end

local function GetBuildingData()
	local hasBuildings = false
	local now = time();

	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddLine("Buildings", 1, 0.7, 0)

	local buildings = C_Garrison.GetBuildings()
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID
		local plotID = buildings[i].plotID

		local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID)

		local building = '';
		local remaining

		if(isBuilding) then
			building = ("|cffFFFF00%s|r|cff888888 - |r|cffFF5500%s|r"):format(rank, name);
			local timeLeft = buildTime - (now - timeStart);
			if(canActivate or timeLeft < 0) then
				remaining = L["Complete!"]
			else
				remaining = ("Building %s"):format(getColoredString("("..SV:ParseSeconds(timeLeft)..")", "lightgrey"))
			end
			GameTooltip:AddDoubleLine(building, remaining, 0, 1, 0, 1, 1, 1)
		else
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(buildingID)
			if(shipmentsReady and shipmentsReady > 0) then
				building = ("|cffFFFF00%s|r|cff888888 - |r|cffFF5500%s|r"):format(rank, name);
				timeleftString = timeleftString or 'Unknown'
				remaining = ("Ready: %s, Next: %s"):format(getColoredString(shipmentsReady, "green"), getColoredString(timeleftString, "lightgrey"))
			elseif(timeleftString) then
				building = ("|cffFFFF00%s|r|cff888888 - |r|cffFF5500%s|r"):format(rank, name);
				remaining = ("Next: %s"):format(getColoredString(timeleftString, "lightgrey"))
			end
			GameTooltip:AddDoubleLine(building, remaining, 0, 1, 0, 1, 1, 1)
		end
		
		hasBuildings = true
	end

	if(not hasBuildings) then
		GameTooltip:AddLine("None", 1, 0, 0)
	end
end

local SetGarrisonTooltip = function(self)
	if(not InCombatLockdown()) then C_Garrison.RequestLandingPageShipmentInfo() end
	local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(824)
	local texStr = ("\124T%s:12\124t %d"):format(tex, amount)
	GameTooltip:AddDoubleLine(name, texStr, 0.23, 0.88, 0.27, 1, 1, 1)

	local text1 = self:GetAttribute("tipText")
	local text2 = self:GetAttribute("tipExtraText")
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("[Left-Click]", text1, 0, 1, 0, 1, 1, 1)
	if InCombatLockdown() then return end
	if(text2) then
		local remaining = GetDockCooldown(110560)
		GameTooltip:AddDoubleLine("[Right Click]", text2, 0, 1, 0, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Time Remaining"], remaining, 1, 1, 1, 0, 1, 1)
	end

	GetActiveMissions()
	GetBuildingData()
	if(SVUI_Garrison.StopAlert) then
		SVUI_Garrison:StopAlert()
	end
end

local function LoadToolBarGarrison()
	if((not SV.db.Dock.garrison) or MOD.GarrisonLoaded) then return end
	GarrisonLandingPageMinimapButton:FadeOut()
	if(InCombatLockdown()) then 
		MOD.GarrisonNeedsUpdate = true; 
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED"); 
		return 
	end

	local garrison = SV.Dock:SetDockButton("BottomLeft", L["Garrison Landing Page"], SV.Media.dock.garrisonToolIcon, nil, "SVUI_Garrison", SetGarrisonTooltip, "SecureActionButtonTemplate")
	garrison:SetAttribute("type1", "click")
	garrison:SetAttribute("clickbutton", GarrisonLandingPageMinimapButton)

	local garrisonStone = GetItemInfo(110560);
	if(garrisonStone and type(garrisonStone) == "string") then
		garrison:SetAttribute("tipExtraText", L["Garrison Hearthstone"])
		garrison:SetAttribute("type2", "macro")
		garrison:SetAttribute("macrotext", "/use [nomod] " .. garrisonStone)
	end

	GarrisonLandingPageMinimapButton:RemoveTextures()
	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetAllPoints(garrison)
	GarrisonLandingPageMinimapButton:SetNormalTexture("")
	GarrisonLandingPageMinimapButton:SetPushedTexture("")
	GarrisonLandingPageMinimapButton:SetHighlightTexture("")

	if(not GarrisonLandingPageMinimapButton:IsShown()) then
		garrison.Parent:SetWidth(garrison.Parent:GetWidth() - garrison:GetWidth())
		garrison:Hide()
	end

	garrison:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
	garrison:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
	garrison:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
	garrison:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	garrison:RegisterEvent("GARRISON_ARCHITECT_OPENED");
	garrison:RegisterEvent("GARRISON_MISSION_FINISHED");
	garrison:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	garrison:RegisterEvent("GARRISON_INVASION_AVAILABLE");
	garrison:RegisterEvent("GARRISON_INVASION_UNAVAILABLE");
	garrison:RegisterEvent("SHIPMENT_UPDATE");

	garrison:SetScript("OnEvent", GarrisonButton_OnEvent);
	C_Garrison.RequestLandingPageShipmentInfo();
	MOD.GarrisonLoaded = true
end
--[[ 
########################################################## 
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateGarrisonTool() 
	if((not SV.db.Dock.garrison) or self.GarrisonLoaded) then return end
	LoadToolBarGarrison()
end 

function MOD:LoadGarrisonTool()
	if((not SV.db.Dock.garrison) or self.GarrisonLoaded or (not GarrisonLandingPageMinimapButton)) then return end
	SV.Timers:ExecuteTimer(LoadToolBarGarrison, 5)
end