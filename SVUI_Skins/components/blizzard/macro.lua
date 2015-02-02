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
HELPERS
##########################################################
]]--
local MacroButtonList = {
	"MacroSaveButton", "MacroCancelButton", "MacroDeleteButton", "MacroNewButton", "MacroExitButton", "MacroEditButton", "MacroFrameTab1", "MacroFrameTab2", "MacroPopupOkayButton", "MacroPopupCancelButton"
}
local MacroButtonList2 = {
	"MacroDeleteButton", "MacroNewButton", "MacroExitButton"
}
--[[ 
########################################################## 
MACRO UI MODR
##########################################################
]]--
local function MacroUIStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.macro ~= true then return end

	MOD:ApplyWindowStyle(MacroFrame, true)

	MOD:ApplyCloseButtonStyle(MacroFrameCloseButton)
	MOD:ApplyScrollFrameStyle(MacroButtonScrollFrameScrollBar)
	MOD:ApplyScrollFrameStyle(MacroFrameScrollFrameScrollBar)
	MOD:ApplyScrollFrameStyle(MacroPopupScrollFrameScrollBar)

	MacroFrame:ModWidth(360)

	local parentStrata = MacroFrame:GetFrameStrata()
	local parentLevel = MacroFrame:GetFrameLevel()

	for i = 1, #MacroButtonList do
		local button = _G[MacroButtonList[i]]
		if(button) then
			button:SetFrameStrata(parentStrata)
			button:SetFrameLevel(parentLevel + 1)
			button:RemoveTextures()
			button:SetStyle("Button", false, 1, 1, 1)
		end
	end 

	for i = 1, #MacroButtonList2 do
		local button = _G[MacroButtonList2[i]]
		if(button) then
			local a1,p,a2,x,y = button:GetPoint()
			button:SetPoint(a1,p,a2,x,-25)
		end
	end 

	local firstTab
	for i = 1, 2 do
		local tab = _G[("MacroFrameTab%d"):format(i)]
		if(tab) then
			tab:ModHeight(22)
			if(i == 1) then
				tab:ModPoint("TOPLEFT", MacroFrame, "TOPLEFT", 85, -39)
				firstTab = tab
			elseif(firstTab) then
				tab:ModPoint("LEFT", firstTab, "RIGHT", 4, 0)
			end
		end
	end 

	MacroFrameText:SetFont(SV.Media.font.default, 10, "OUTLINE")
	MacroFrameTextBackground:RemoveTextures()
	MacroFrameTextBackground:SetStyle("Frame", 'Transparent')

	MacroPopupFrame:RemoveTextures()
	MacroPopupFrame:SetStyle("Frame", 'Transparent')

	MacroPopupScrollFrame:RemoveTextures()
	MacroPopupScrollFrame:SetStyle("Frame", "Pattern")
	MacroPopupScrollFrame.Panel:ModPoint("TOPLEFT", 51, 2)
	MacroPopupScrollFrame.Panel:ModPoint("BOTTOMRIGHT", -4, 4)
	MacroPopupEditBox:SetStyle("Editbox")
	MacroPopupNameLeft:SetTexture(0,0,0,0)
	MacroPopupNameMiddle:SetTexture(0,0,0,0)
	MacroPopupNameRight:SetTexture(0,0,0,0)

	MacroFrameInset:Die()

	MacroButtonContainer:RemoveTextures()
	MOD:ApplyScrollFrameStyle(MacroButtonScrollFrame)
	MacroButtonScrollFrame:SetStyle("!_Frame", "Inset")

	MacroPopupFrame:HookScript("OnShow", function(c)
		c:ClearAllPoints()
		c:ModPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 5, -2)
	end)

	MacroFrameSelectedMacroButton:SetFrameStrata(parentStrata)
	MacroFrameSelectedMacroButton:SetFrameLevel(parentLevel + 1)
	MacroFrameSelectedMacroButton:RemoveTextures()
	MacroFrameSelectedMacroButton:SetStyle("ActionSlot")
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	MacroFrameSelectedMacroButtonIcon:InsetPoints()

	MacroEditButton:ClearAllPoints()
	MacroEditButton:ModPoint("BOTTOMLEFT", MacroFrameSelectedMacroButton.Panel, "BOTTOMRIGHT", 10, 0)

	MacroFrameCharLimitText:ClearAllPoints()
	MacroFrameCharLimitText:ModPoint("BOTTOM", MacroFrameTextBackground, -25, -35)

	for i = 1, MAX_ACCOUNT_MACROS do 
		local button = _G["MacroButton"..i]
		if(button) then
			button:RemoveTextures()
			button:SetStyle("ActionSlot")

			local icon = _G["MacroButton"..i.."Icon"]
			if(icon) then
				icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				icon:InsetPoints()
				icon:SetDrawLayer("OVERLAY")
			end

			local popup = _G["MacroPopupButton"..i]
			if(popup) then
				popup:RemoveTextures()
				popup:SetStyle("Button")
				popup:SetBackdropColor(0, 0, 0, 0)

				local popupIcon = _G["MacroPopupButton"..i.."Icon"]
				if(popupIcon) then
					popupIcon:InsetPoints()
					popupIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				end
			end 
		end  
	end 
end 

--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_MacroUI", MacroUIStyle)