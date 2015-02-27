--[[
##############################################################################
S V U I   By: Munglunch
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
DRESSUP MODR
##########################################################
]]--
local function DressUpStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.dressingroom ~= true then
		 return 
	end

	DressUpFrame:ModSize(500, 600)
	SV.API:Set("Window", DressUpFrame, true, true)

	DressUpModel:ClearAllPoints()
	DressUpModel:ModPoint("TOPLEFT", DressUpFrame, "TOPLEFT", 12, -76)
	DressUpModel:ModPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 36)

	DressUpModel:SetStyle("PatternModel")

	DressUpFrameCancelButton:ModPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 12)
	DressUpFrameCancelButton:SetStyle()

	DressUpFrameResetButton:ModPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -12, 0)
	DressUpFrameResetButton:SetStyle()

	SV.API:Set("CloseButton", DressUpFrameCloseButton, DressUpFrame.Panel)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(DressUpStyle)