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
PETITIONFRAME MODR
##########################################################
]]--
local function PetitionFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.petition ~= true then
		return 
	end

	MOD:ApplyWindowStyle(PetitionFrame, nil, true)
	PetitionFrameInset:Die()

	PetitionFrameSignButton:SetStylePanel("Button")
	PetitionFrameRequestButton:SetStylePanel("Button")
	PetitionFrameRenameButton:SetStylePanel("Button")
	PetitionFrameCancelButton:SetStylePanel("Button")

	MOD:ApplyCloseButtonStyle(PetitionFrameCloseButton)

	PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	PetitionFrameCharterName:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	PetitionFrameMasterName:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

	for i=1, 9 do
		local frameName = ("PetitionFrameMemberName%d"):format(i)
		local frame = _G[frameName];
		if(frame) then
			frame:SetTextColor(1, 1, 1)
		end
	end 

	PetitionFrameInstructions:SetTextColor(1, 1, 1)
	
	PetitionFrameRenameButton:ModPoint("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
	PetitionFrameRenameButton:ModPoint("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(PetitionFrameStyle)