--[[
##########################################################
S V U I   By: Munglunch
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
local Quit         			= _G.Quit;
local Logout         		= _G.Logout;
local ReloadUI         		= _G.ReloadUI;
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetProfessions       	= _G.GetProfessions;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local hooksecurefunc     	= _G.hooksecurefunc;
local GetSpecialization    	= _G.GetSpecialization;
local GetNumSpecGroups    	= _G.GetNumSpecGroups;
local GetActiveSpecGroup    = _G.GetActiveSpecGroup;
local SetActiveSpecGroup    = _G.SetActiveSpecGroup;
local GetSpecializationInfo = _G.GetSpecializationInfo;
--[[ 
########################################################## 
ADDON
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L

local MOD = SV.Dock;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local HEARTH_SPELLS = {556,50977,18960,126892}

local function GetMacroCooldown(itemID)
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

local SetHearthTooltip = function(self)
	local text1 = self:GetAttribute("tipText")
	local text2 = self:GetAttribute("tipExtraText")
	GameTooltip:AddDoubleLine("[Left-Click]", text1, 0, 1, 0, 1, 1, 1)
	if InCombatLockdown() then return end
	local remaining = GetMacroCooldown(6948)
	GameTooltip:AddDoubleLine(L["Time Remaining"], remaining, 1, 1, 1, 0, 1, 1)
	if(text2) then
		GameTooltip:AddLine(" ", 1, 1, 1)
		GameTooltip:AddDoubleLine("[Right Click]", text2, 0, 1, 0, 1, 1, 1)
	end
end

local SpecSwap_OnClick = function(self)
	if InCombatLockdown() then return end
	local current = GetActiveSpecGroup()
	if(current == 2) then
		SetActiveSpecGroup(1)
	else
		SetActiveSpecGroup(2)
	end
end

local SetSpecSwapTooltip = function(self)
	local currentGroup = GetActiveSpecGroup()
	local currentSpec = GetSpecialization(false, false, currentGroup);
	local text1 = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
	local otherGroup = 1;
	local activeText = "Active Spec";
	local otherText = "Inactive Spec";
	if(currentGroup == 1) then
		otherGroup = 2
		activeText = "Inactive Spec";
		otherText = "Active Spec";
	end
	local otherSpec = GetSpecialization(false, false, otherGroup);
	local text2 = otherSpec and select(2, GetSpecializationInfo(otherSpec)) or "None"
	GameTooltip:AddDoubleLine("[Click]", "Swap Active Spec", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine(activeText, text1, 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine(otherText, text2, 1, 0.5, 0, 1, 1, 1)
end

local PowerButton_OnClick = function(self, button)
	if(button == "RightButton" and IsShiftKeyDown()) then
		Quit()
	elseif(IsShiftKeyDown()) then
		ReloadUI()
	else
		Logout()
	end
end

local SetPowerButtonTooltip = function(self)
	GameTooltip:AddDoubleLine("[Click]", "Log Out", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("[SHIFT + Left Click]", "Reload", 1, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("[SHIFT + Right Click]", "Exit Game", 1, 0.5, 0, 1, 1, 1)
end

local function LoadMiscTools()
	if(MOD.MiscToolsLoaded) then return end

	if(InCombatLockdown()) then 
		MOD.MiscNeedsUpdate = true; 
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED"); 
		return 
	end

	-- HEARTH BUTTON
	if(SV.db.Dock.dockTools.hearth) then
		local hearthStone = GetItemInfo(6948);
		if(hearthStone and type(hearthStone) == "string") then
			local hearth = SV.Dock:SetDockButton("BottomLeft", L["Hearthstone"], SV.media.dock.hearthIcon, nil, "SVUI_Hearth", SetHearthTooltip, "SecureActionButtonTemplate")
			hearth.Icon:SetTexCoord(0,0.5,0,1)
			hearth:SetAttribute("type1", "macro")
			hearth:SetAttribute("macrotext1", "/use [nomod]" .. hearthStone)
			local hasRightClick = false;
			for i = 1, #HEARTH_SPELLS do
				if(IsSpellKnown(HEARTH_SPELLS[i])) then
					local rightClickSpell = GetSpellInfo(HEARTH_SPELLS[i])
					hearth:SetAttribute("tipExtraText", rightClickSpell)
					hearth:SetAttribute("type2", "macro")
					hearth:SetAttribute("macrotext2", "/use [nomod] " .. rightClickSpell)
					hasRightClick = true;
				end
			end
		end
	end

	-- SPEC BUTTON
	if(SV.db.Dock.dockTools.specswap) then
		local numSpecGroups = GetNumSpecGroups()
		if(numSpecGroups and numSpecGroups == 2) then
			local specSwap = SV.Dock:SetDockButton("BottomLeft", L["Spec Swap"], SV.media.dock.specSwapIcon, SpecSwap_OnClick, "SVUI_SpecSwap", SetSpecSwapTooltip)
		end
	end

	-- POWER BUTTON
	if(SV.db.Dock.dockTools.power) then
		local power = SV.Dock:SetDockButton("BottomLeft", L["Power Button"], SV.media.dock.powerIcon, PowerButton_OnClick, "SVUI_PowerButton", SetPowerButtonTooltip)
	end

	MOD.MiscToolsLoaded = true
end
--[[ 
########################################################## 
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateMiscTools() 
	if(self.MiscToolsLoaded) then return end
	LoadMiscTools()
end 

function MOD:LoadAllMiscTools()
	if(self.MiscToolsLoaded) then return end
	SV.Timers:ExecuteTimer(LoadMiscTools, 5)
end