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
local string 	= _G.string;
--[[ STRING METHODS ]]--
local match, sub, join = string.match, string.sub, string.join;
local max = math.max;
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
local StatEvents = {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', "PLAYER_LEAVE_COMBAT", 'PLAYER_REGEN_DISABLED', 'UNIT_PET'};

local PlayerEvents = {["SPELL_HEAL"] = true, ["SPELL_PERIODIC_HEAL"] = true}
local playerID = UnitGUID('player')
local petID
local healTotal, totalHeal, totalOverHeal, lastHealAmount = 0, 0, 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local hexColor = "FFFFFF";
local displayString = "|cff%s%.1f|r";
local dpsString = "%s |cff00CCFF%s|r";

local join = string.join
local max = math.max

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
	totalHeal = 0
	totalOverHeal = 0
	lastHealAmount = 0
end

local function GetHPS(self)
	if healTotal == 0 or combatTime == 0 then
		self.text:SetText(dpsString:format(L["HPS"], "..PAUSED"))
		self.TText = "No Healing Done"
		self.TText2 = "Surely there is someone \nwith an ouchie somewhere!"
	else
		local HPS = (healTotal) / (combatTime)
		self.text:SetFormattedText(displayString, hexColor, HPS)
		self.TText = "HPS:"
		self.TText2 = HPS
	end
end

local function HPS_OnClick(self)
	Reset()
	GetHPS(self)
end

local function HPS_OnEnter(self)
	Reports:SetDataTip(self)
	Reports.ReportTooltip:AddDoubleLine("Healing Total:", totalHeal, 1, 1, 1)
	Reports.ReportTooltip:AddDoubleLine("OverHealing Total:", totalOverHeal, 1, 1, 1)
	Reports.ReportTooltip:AddLine(" ", 1, 1, 1)
	Reports.ReportTooltip:AddDoubleLine(self.TText, self.TText2, 1, 1, 1)
	Reports.ReportTooltip:AddLine(" ", 1, 1, 1)
	Reports.ReportTooltip:AddDoubleLine("[Click]", "Clear HPS", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end

local function HPS_OnEvent(self, event, ...)
	lastPanel = self
	
	if event == "PLAYER_ENTERING_WORLD" then
		playerID = UnitGUID('player')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then --time since the last segment
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local newTime, event, _, srcGUID, _, _, _, _, _, _, _, _, _, test, lastHealAmount, overHeal = ...
		if not PlayerEvents[event] then return end
		if(srcGUID == playerID or srcGUID == petID) then
			if timeStamp == 0 then timeStamp = newTime end
			lastSegment = timeStamp
			combatTime = newTime - timeStamp
			healTotal = healTotal + (lastHealAmount - overHeal)
			totalHeal = totalHeal + lastHealAmount
			totalOverHeal = totalOverHeal + overHeal
		end
	elseif event == UNIT_PET then
		petID = UnitGUID("pet")
	end
	
	GetHPS(self)
end

local HPSColorUpdate = function()
	hexColor = SV:HexColor("highlight");
	if lastPanel ~= nil then
		HPS_OnEvent(lastPanel)
	end
end

SV.Events:On("SHARED_MEDIA_UPDATED", HPSColorUpdate, "HPSColorUpdates")
Reports:NewReportType('HPS', StatEvents, HPS_OnEvent, nil, HPS_OnClick, HPS_OnEnter)