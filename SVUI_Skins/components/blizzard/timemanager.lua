--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
TIMEMANAGER MODR
##########################################################
]]--
local function TimeManagerStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.timemanager ~= true then
		 return 
	end 
	
	MOD:ApplyWindowStyle(TimeManagerFrame, true)

	MOD:ApplyCloseButtonStyle(TimeManagerFrameCloseButton)
	TimeManagerFrameInset:Die()
	MOD:ApplyDropdownStyle(TimeManagerAlarmHourDropDown, 80)
	MOD:ApplyDropdownStyle(TimeManagerAlarmMinuteDropDown, 80)
	MOD:ApplyDropdownStyle(TimeManagerAlarmAMPMDropDown, 80)
	TimeManagerAlarmMessageEditBox:SetStyle("Editbox")
	TimeManagerAlarmEnabledButton:SetStyle("Checkbox")
	TimeManagerMilitaryTimeCheck:SetStyle("Checkbox")
	TimeManagerLocalTimeCheck:SetStyle("Checkbox")
	TimeManagerStopwatchFrame:RemoveTextures()
	TimeManagerStopwatchCheck:SetStyle("!_Frame", "Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
	TimeManagerStopwatchCheck:GetNormalTexture():InsetPoints()
	local sWatch = TimeManagerStopwatchCheck:CreateTexture(nil, "OVERLAY")
	sWatch:SetTexture(1, 1, 1, 0.3)
	sWatch:ModPoint("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
	sWatch:ModPoint("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
	TimeManagerStopwatchCheck:SetHighlightTexture(sWatch)

	StopwatchFrame:RemoveTextures()
	StopwatchFrame:SetStyle("Frame", 'Transparent')
	StopwatchFrame.Panel:ModPoint("TOPLEFT", 0, -17)
	StopwatchFrame.Panel:ModPoint("BOTTOMRIGHT", 0, 2)

	StopwatchTabFrame:RemoveTextures()
	
	MOD:ApplyCloseButtonStyle(StopwatchCloseButton)
	MOD:ApplyPaginationStyle(StopwatchPlayPauseButton)
	MOD:ApplyPaginationStyle(StopwatchResetButton)
	StopwatchPlayPauseButton:ModPoint("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	StopwatchResetButton:ModPoint("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TimeManager",TimeManagerStyle)