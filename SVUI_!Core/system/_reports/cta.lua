--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################

STATS:Extend EXAMPLE USAGE: Reports:NewReportType(newStat,eventList,onEvents,update,click,focus,blur)

########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local error 	= _G.error;
local pcall 	= _G.pcall;
local assert 	= _G.assert;
local tostring 	= _G.tostring;
local tonumber 	= _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local Reports = SV.Reports;
--[[ 
########################################################## 
CALL TO ARMS STATS
##########################################################
]]--
local StatEvents = {"PLAYER_ENTERING_WORLD", "LFG_UPDATE_RANDOM_INFO"};

local tooltipString = ("%s: N/A"):format(BATTLEGROUND_HOLIDAY)
local currentObject;

local function formatCTAtext(tanks, heals, dps)
	local result = ""
	if tanks then
		result = result.."|TInterface\\AddOns\\SVUI_!Core\\assets\\textures\\default\\tank.tga:14:14|t" 
	end 
	if heals then
		result = result.."|TInterface\\AddOns\\SVUI_!Core\\assets\\textures\\default\\healer.tga:14:14|t" 
	end 
	if dps then
		result = result.."|TInterface\\AddOns\\SVUI_!Core\\assets\\textures\\default\\dps.tga:14:14|t" 
	end 
	return result 
end 

local function CTA_OnEvent(self, ...)
	local isTank = false;
	local isHeal = false;
	local isDPS = false;
	local isNormal = true;
	for r = 1, GetNumRandomDungeons()do 
		local id, name = GetLFGRandomDungeonInfo(r)
		for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, i)
			if eligible then
				isNormal = false 
			end 
			if eligible and forTank and itemCount > 0 then
				isTank = true;
			end 
			if eligible and forHealer and itemCount > 0 then
				isHeal = true;
			end 
			if eligible and forDamage and itemCount > 0 then
				isDPS = true;
			end
		end 
	end 
	if isNormal then
		self.text:SetText(tooltipString)
	else
		self.text:SetText(BATTLEGROUND_HOLIDAY..": "..formatCTAtext(isTank, isHeal, isDPS))
	end 
	currentObject = self 
end 

local function CTA_OnClick()
	ToggleFrame(LFDParentFrame)
end 

local function CTA_OnEnter(self)
	Reports:SetDataTip(self)
	local counter = 0;
	for r = 1, GetNumRandomDungeons()do
		local isTank = false;
		local isHeal = false;
		local isDPS = false;
		local isNormal = true;
		local id, name = GetLFGRandomDungeonInfo(r)
		for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, i)
			if eligible then
				isNormal = false 
			end 
			if eligible and forTank and itemCount > 0 then
				isTank = true;
			end 
			if eligible and forHealer and itemCount > 0 then
				isHeal = true;
			end 
			if eligible and forDamage and itemCount > 0 then
				isDPS = true;
			end 
		end
		if not isNormal then
			local text = formatCTAtext(isTank,isHeal,isDPS)
			if text ~= "" then
				Reports.ReportTooltip:AddDoubleLine(name..":", text, 1, 1, 1)
			end 
			if isTank or isHeal or isDPS then
				counter = counter + 1 
			end 
		end
	end 
	Reports:ShowDataTip()
end 

local CTAColorUpdate = function()
	local hexColor = SV:HexColor("highlight");
	tooltipString = ("%s: |cff%sN/A|r"):format(BATTLEGROUND_HOLIDAY, hexColor)
	if currentObject ~= nil then
		CTA_OnEvent(currentObject)
	end 
end 
SV.Events:On("MEDIA_COLORS_UPDATED", CTAColorUpdate, "CTAColorUpdates")

Reports:NewReportType('Call to Arms', StatEvents, CTA_OnEvent, nil, CTA_OnClick, CTA_OnEnter)