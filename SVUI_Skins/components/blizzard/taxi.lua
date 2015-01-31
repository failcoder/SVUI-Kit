--[[
##############################################################################
M O D K I T   By: S.Jackson
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
TAXIFRAME MODR
##########################################################
]]--
local function TaxiStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.taxi ~= true then
		 return 
	end

	MOD:ApplyWindowStyle(TaxiFrame)
	
	--TaxiRouteMap:SetStylePanel("Frame", "Blackout")
	--TaxiRouteMap.Panel:WrapPoints(TaxiRouteMap, 4, 4)
	
	MOD:ApplyCloseButtonStyle(TaxiFrame.CloseButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(TaxiStyle)