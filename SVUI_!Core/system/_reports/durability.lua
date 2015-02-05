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
local LSM = LibStub("LibSharedMedia-3.0")
local Reports = SV.Reports;
--[[ 
########################################################## 
DURABILITY STATS
##########################################################
]]--
local StatEvents = {"PLAYER_ENTERING_WORLD", "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"};

local hexColor = "FFFFFF"
local displayString = "%s: |cff%s%d%%|r";
local overall = 0;
local min, max, currentObject;
local equipment = {}
local inventoryMap = {
	["SecondaryHandSlot"] = L["Offhand"],
	["MainHandSlot"] = L["Main Hand"],
	["FeetSlot"] = L["Feet"],
	["LegsSlot"] = L["Legs"],
	["HandsSlot"] = L["Hands"],
	["WristSlot"] = L["Wrist"],
	["WaistSlot"] = L["Waist"],
	["ChestSlot"] = L["Chest"],
	["ShoulderSlot"] = L["Shoulder"],
	["HeadSlot"] = L["Head"]
}

local function Durability_OnEvent(self, ...)
	currentObject = self;
	overall = 100;
	if self.barframe:IsShown() then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
	end 
	for slot,name in pairs(inventoryMap)do 
		local slotID = GetInventorySlotInfo(slot)
		min,max = GetInventoryItemDurability(slotID)
		if min then
			equipment[name] = min / max * 100;
			if min / max * 100 < overall then
				overall = min / max * 100 
			end 
		end 
	end 
	self.text:SetFormattedText(displayString, DURABILITY, hexColor, overall)
end 

local function DurabilityBar_OnEvent(self, ...)
	currentObject = nil;
	overall = 100;
	if not self.barframe:IsShown() then 
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.Media.dock.durabilityLabel)
	end 
	for slot,name in pairs(inventoryMap)do 
		local slotID = GetInventorySlotInfo(slot)
		min,max = GetInventoryItemDurability(slotID)
		if min then 
			equipment[name] = min / max * 100;
			if min / max * 100 < overall then 
				overall = min / max * 100 
			end 
		end 
	end 
	local newRed = (100 - overall) * 0.01;
	local newGreen = overall * 0.01;
	self.barframe.bar:SetMinMaxValues(0, 100)
	self.barframe.bar:SetValue(overall)
	self.barframe.bar:SetStatusBarColor(newRed, newGreen, 0)
	self.text:SetText('')
end 

local function Durability_OnClick()
	ToggleCharacter("PaperDollFrame")
end 

local function Durability_OnEnter(self)
	Reports:SetDataTip(self)
	for name,amt in pairs(equipment)do
		Reports.ReportTooltip:AddDoubleLine(name, format("%d%%", amt),1, 1, 1, SV:ColorGradient(amt * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end 
	Reports:ShowDataTip()
end 

local DurColorUpdate = function()
	hexColor = SV:HexColor("highlight")
	if currentObject ~= nil then
		Durability_OnEvent(currentObject)
	end 
end 
SV.Events:On("MEDIA_COLORS_UPDATED", DurColorUpdate, "DurColorUpdates")

Reports:NewReportType("Durability", StatEvents, Durability_OnEvent, nil, Durability_OnClick, Durability_OnEnter)
Reports:NewReportType("Durability Bar", StatEvents, DurabilityBar_OnEvent, nil, Durability_OnClick, Durability_OnEnter)