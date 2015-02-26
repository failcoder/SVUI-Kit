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
PETSTABLE MODR
##########################################################
]]--
local function PetStableStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.stable ~= true then return end 
	PetStableFrame:RemoveTextures()
	PetStableFrameInset:RemoveTextures()
	PetStableLeftInset:RemoveTextures()
	PetStableBottomInset:RemoveTextures()
	PetStableFrame:SetStyle("Frame", "Window")
	PetStableFrameInset:SetStyle("Frame", 'Inset')
	SV.API:Set("CloseButton", PetStableFrameCloseButton)
	PetStablePrevPageButton:SetStyle("Button")
	PetStableNextPageButton:SetStyle("Button")
	SV.API:Set("PageButton", PetStablePrevPageButton)
	SV.API:Set("PageButton", PetStableNextPageButton)
	for j = 1, NUM_PET_ACTIVE_SLOTS do
		 SV.API:Set("ItemButton", _G['PetStableActivePet'..j], true)
	end 
	for j = 1, NUM_PET_STABLE_SLOTS do
		 SV.API:Set("ItemButton", _G['PetStableStabledPet'..j], true)
	end 
	PetStableSelectedPetIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(PetStableStyle)