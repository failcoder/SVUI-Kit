--[[
##############################################################################
S V U I   By: Munglunch
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
local format = string.format;
local gsub = string.gsub;
--MATH
local math          = _G.math;
local min         = math.min
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local Reports = SV.Reports;
--[[ 
########################################################## 
EXPERIENCE STATS
##########################################################
]]--
local StatEvents = {"PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "DISABLE_XP_GAIN", "ENABLE_XP_GAIN", "UPDATE_EXHAUSTION"};

local function FormatExp(value, maxValue)
	local trunc, calc;
    if value >= 1e9 then
        trunc = ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e6 then 
        trunc = ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e3 or value <= -1e3 then 
        trunc = ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
    else 
        trunc = value
    end
    if((value > 0) and (maxValue > 0)) then
    	calc = (value / maxValue) * 100
    else
    	calc = maxValue
    end
    return trunc, calc
end

local function FetchExperience()
	local xp = UnitXP("player")
	if((not xp) or (xp <= 0)) then
		xp = 1
	end

	local mxp = UnitXPMax("player")
	if((not mxp) or (mxp <= 0)) then
		mxp = 1
	end

	local exp = GetXPExhaustion()
	if(not exp) then
		exp = 0
	end

	return xp,mxp,exp
end

local function Experience_OnEvent(self, ...)
	if self.barframe:IsShown()then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
	end 
	
	local XP, maxXP, exhaust = FetchExperience()
	local string1, calc1 = FormatExp(XP, maxXP);
	local text = "";

	if(exhaust > 0) then
		local string2, calc2 = FormatExp(exhaust, maxXP);
		text = format("%s - %d%% R:%s [%d%%]", string1, calc1, string2, calc2)
	else
		text = format("%s - %d%%", string1, calc1)
	end

	self.text:SetText(text)
end 

local function ExperienceBar_OnEvent(self, ...)
	if (not self.barframe:IsShown())then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.experienceLabel)
	end
	if not self.barframe.bar.extra:IsShown() then
		self.barframe.bar.extra:Show()
	end 
	local bar = self.barframe.bar;
	local XP, maxXP, exhaust = FetchExperience()

	bar:SetMinMaxValues(0, maxXP)
	bar:SetValue(XP)
	bar:SetStatusBarColor(0, 0.5, 1)
	
	if(exhaust > 0) then
		local exhaust_value = min(XP + exhaust, maxXP);
		bar.extra:SetMinMaxValues(0, maxXP)
		bar.extra:SetValue(exhaust_value)
		bar.extra:SetStatusBarColor(0.8, 0.5, 1)
		bar.extra:SetAlpha(0.5)
	else
		bar.extra:SetMinMaxValues(0, 1)
		bar.extra:SetValue(0)
	end 
	self.text:SetText("")
end 

local function Experience_OnEnter(self)
	Reports:SetDataTip(self)
	local XP, maxXP, exhaust = FetchExperience()
	Reports.ReportTooltip:AddLine(L["Experience"])
	Reports.ReportTooltip:AddLine(" ")

	if((XP > 0) and (maxXP > 0)) then
		local calc1 = (XP / maxXP) * 100;
		local remaining = maxXP - XP;
		local r_percent = (remaining / maxXP) * 100;
		local r_bars = r_percent / 5;
		Reports.ReportTooltip:AddDoubleLine(L["XP:"], (" %d  /  %d (%d%%)"):format(XP, maxXP, calc1), 1, 1, 1)
		Reports.ReportTooltip:AddDoubleLine(L["Remaining:"], (" %d (%d%% - %d "..L["Bars"]..")"):format(remaining, r_percent, r_bars), 1, 1, 1)
		if(exhaust > 0) then
			local _, calc2 = FormatExp(exhaust, maxXP);
			Reports.ReportTooltip:AddDoubleLine(L["Rested:"], format(" + %d (%d%%)", exhaust, calc2), 1, 1, 1)
		end
	end
	Reports:ShowDataTip()
end

Reports:NewReportType("Experience", StatEvents, Experience_OnEvent, nil, nil, Experience_OnEnter)
Reports:NewReportType("Experience Bar", StatEvents, ExperienceBar_OnEvent, nil, nil, Experience_OnEnter)