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
REFORGING MODR
##########################################################
]]--
local function ReforgingStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.reforge ~= true then return end 
	
	SV.API:Set("Window", ReforgingFrame, true)

	ReforgingFrame.ButtonFrame:RemoveTextures()
	ReforgingFrameReforgeButton:ClearAllPoints()
	ReforgingFrameReforgeButton:ModPoint("LEFT", ReforgingFrameRestoreButton, "RIGHT", 2, 0)
	ReforgingFrameReforgeButton:ModPoint("BOTTOMRIGHT", -3, 3)
	ReforgingFrame.RestoreMessage:SetTextColor(1, 1, 1)

	ReforgingFrameRestoreButton:RemoveTextures()
	ReforgingFrameReforgeButton:RemoveTextures()
	ReforgingFrameRestoreButton:SetStyle()
	ReforgingFrameReforgeButton:SetStyle()

	ReforgingFrame.ItemButton:RemoveTextures()
	ReforgingFrame.ItemButton:SetStyle("Item")
	ReforgingFrame.ItemButton.IconTexture:InsetPoints()
	hooksecurefunc("ReforgingFrame_Update", function(k)
		local w, x, u, y, z, A = GetReforgeItemInfo()
		if x then
			 ReforgingFrame.ItemButton.IconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		else
			 ReforgingFrame.ItemButton.IconTexture:SetTexture("")
		end 
	end)
	SV.API:Set("CloseButton", ReforgingFrameCloseButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ReforgingUI",ReforgingStyle)