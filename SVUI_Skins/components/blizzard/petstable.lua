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
	PetStableFrameInset:SetStyle("!_Frame", 'Inset')
	MOD:ApplyCloseButtonStyle(PetStableFrameCloseButton)
	PetStablePrevPageButton:SetStyle("Button")
	PetStableNextPageButton:SetStyle("Button")
	MOD:ApplyPaginationStyle(PetStablePrevPageButton)
	MOD:ApplyPaginationStyle(PetStableNextPageButton)
	for j = 1, NUM_PET_ACTIVE_SLOTS do
		 MOD:ApplyItemButtonStyle(_G['PetStableActivePet'..j], true)
	end 
	for j = 1, NUM_PET_STABLE_SLOTS do
		 MOD:ApplyItemButtonStyle(_G['PetStableStabledPet'..j], true)
	end 
	PetStableSelectedPetIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(PetStableStyle)