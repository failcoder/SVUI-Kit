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
REFORGING MODR
##########################################################
]]--
local function ReforgingStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.reforge ~= true then return end 
	
	MOD:ApplyWindowStyle(ReforgingFrame, true)

	ReforgingFrame.ButtonFrame:RemoveTextures()
	ReforgingFrameReforgeButton:ClearAllPoints()
	ReforgingFrameReforgeButton:ModPoint("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
	ReforgingFrameReforgeButton:ModPoint("BOTTOMRIGHT", -3, 3)
	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1)

	ReforgingFrameRestoreButton:RemoveTextures()
	ReforgingFrameReforgeButton:RemoveTextures()
	ReforgingFrameRestoreButton:SetStylePanel("Button")
	ReforgingFrameReforgeButton:SetStylePanel("Button")

	ReforgingFrame.ItemButton:RemoveTextures()
	ReforgingFrame.ItemButton:SetStylePanel("Slot")
	ReforgingFrame.ItemButton.IconTexture:InsetPoints()
	hooksecurefunc("ReforgingFrame_Update", function(k)
		local w, x, u, y, z, A = GetReforgeItemInfo()
		if x then
			 ReforgingFrame.ItemButton.IconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		else
			 ReforgingFrame.ItemButton.IconTexture:SetTexture(0,0,0,0)
		end 
	end)
	MOD:ApplyCloseButtonStyle(ReforgingFrameCloseButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ReforgingUI",ReforgingStyle)