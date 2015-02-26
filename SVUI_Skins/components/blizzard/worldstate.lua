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
WORLDSTATE MODR
##########################################################
]]--
local function WorldStateStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.bgscore ~= true then return end 
	WorldStateScoreScrollFrame:RemoveTextures()
	WorldStateScoreFrame:RemoveTextures()
	WorldStateScoreFrame:SetStyle("Frame", "Window")
	SV.API:Set("CloseButton", WorldStateScoreFrameCloseButton)
	SV.API:Set("ScrollFrame", WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreFrameInset:SetAlpha(0)
	WorldStateScoreFrameLeaveButton:SetStyle("Button")
	for b = 1, 3 do 
		SV.API:Set("Tab", _G["WorldStateScoreFrameTab"..b])
	end 
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(WorldStateStyle)