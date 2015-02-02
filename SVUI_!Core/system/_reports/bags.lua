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
BAG STATS
##########################################################
]]--
local StatEvents = {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"};
local hexColor = "FFFFFF"
local bags_text = "%s|cff%s%d / %d|r";
local currentObject;

local function bags_events(this, e, ...)
	local f, g, h = 0, 0, 0;
	currentObject = this;
	for i = 0, NUM_BAG_SLOTS do 
		f, g = f + GetContainerNumFreeSlots(i),
		g + GetContainerNumSlots(i)
	end 
	h = g - f;
	this.text:SetFormattedText(bags_text, L["Bags"]..": ", hexColor, h, g)
end 

local function bags_click()
	ToggleAllBags()
end 

local function bags_focus(this)
	Reports:SetDataTip(this)
	for i = 1, MAX_WATCHED_TOKENS do 
		local l, m, n, o, p = GetBackpackCurrencyInfo(i)
		if l and i == 1 then 
			Reports.ReportTooltip:AddLine(CURRENCY)
			Reports.ReportTooltip:AddLine(" ")
		end 
		if l and m then 
			Reports.ReportTooltip:AddDoubleLine(l, m, 1, 1, 1)
		end 
	end 
	Reports:ShowDataTip()
end 

local BagsColorUpdate = function()
	hexColor = SV:HexColor("highlight")
	if currentObject ~= nil then
		bags_events(currentObject)
	end 
end 

SV.Events:On("MEDIA_COLORS_UPDATED", "BagsColorUpdates", BagsColorUpdate)
Reports:NewReportType("Bags", StatEvents,	bags_events, nil, bags_click, bags_focus);