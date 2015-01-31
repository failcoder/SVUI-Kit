--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
OUTFITTER
##########################################################
]]--
local function StyleOutfitter()
	assert(OutfitterFrame, "AddOn Not Loaded")
	
	CharacterFrame:HookScript("OnShow", function(self) PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -14, 0) end)
	OutfitterFrame:HookScript("OnShow", function(self) 
		MOD:ApplyFrameStyle(OutfitterFrame)
		OutfitterFrameTab1:ModSize(60, 25)
		OutfitterFrameTab2:ModSize(60, 25)
		OutfitterFrameTab3:ModSize(60, 25)
		OutfitterMainFrame:RemoveTextures(true)
		for i = 0, 13 do
			if _G["OutfitterItem"..i.."OutfitSelected"] then 
				_G["OutfitterItem"..i.."OutfitSelected"]:SetStylePanel("Button")
				_G["OutfitterItem"..i.."OutfitSelected"]:ClearAllPoints()
				_G["OutfitterItem"..i.."OutfitSelected"]:ModSize(16)
				_G["OutfitterItem"..i.."OutfitSelected"]:ModPoint("LEFT", _G["OutfitterItem"..i.."Outfit"], "LEFT", 8, 0)
			end
		end
	end)
	OutfitterMainFrameScrollbarTrench:RemoveTextures(true)
	OutfitterFrameTab1:ClearAllPoints()
	OutfitterFrameTab2:ClearAllPoints()
	OutfitterFrameTab3:ClearAllPoints()
	OutfitterFrameTab1:ModPoint("TOPLEFT", OutfitterFrame, "BOTTOMRIGHT", -65, -2)
	OutfitterFrameTab2:ModPoint("LEFT", OutfitterFrameTab1, "LEFT", -65, 0)
	OutfitterFrameTab3:ModPoint("LEFT", OutfitterFrameTab2, "LEFT", -65, 0)
	OutfitterFrameTab1:SetStylePanel("Button")
	OutfitterFrameTab2:SetStylePanel("Button")
	OutfitterFrameTab3:SetStylePanel("Button")
	MOD:ApplyScrollFrameStyle(OutfitterMainFrameScrollFrameScrollBar)
	MOD:ApplyCloseButtonStyle(OutfitterCloseButton)
	OutfitterNewButton:SetStylePanel("Button")
	OutfitterEnableNone:SetStylePanel("Button")
	OutfitterEnableAll:SetStylePanel("Button")
	OutfitterButton:ClearAllPoints()
	OutfitterButton:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", 26, -2)
	OutfitterButton:SetHighlightTexture(nil)
	OutfitterSlotEnables:SetFrameStrata("HIGH")
	OutfitterEnableHeadSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableNeckSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableShoulderSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableBackSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableChestSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableShirtSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableTabardSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableWristSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableMainHandSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableSecondaryHandSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableHandsSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableWaistSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableLegsSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableFeetSlot:SetStylePanel("Checkbox", true)
	OutfitterEnableFinger0Slot:SetStylePanel("Checkbox", true)
	OutfitterEnableFinger1Slot:SetStylePanel("Checkbox", true)
	OutfitterEnableTrinket0Slot:SetStylePanel("Checkbox", true)
	OutfitterEnableTrinket1Slot:SetStylePanel("Checkbox", true)
	OutfitterItemComparisons:SetStylePanel("Button")
	OutfitterTooltipInfo:SetStylePanel("Button")
	OutfitterShowHotkeyMessages:SetStylePanel("Button")
	OutfitterShowMinimapButton:SetStylePanel("Button")
	OutfitterShowOutfitBar:SetStylePanel("Button")
	OutfitterAutoSwitch:SetStylePanel("Button")
	OutfitterItemComparisons:ModSize(20)
	OutfitterTooltipInfo:ModSize(20)
	OutfitterShowHotkeyMessages:ModSize(20)
	OutfitterShowMinimapButton:ModSize(20)
	OutfitterShowOutfitBar:ModSize(20)
	OutfitterAutoSwitch:ModSize(20)
	OutfitterShowOutfitBar:ModPoint("TOPLEFT", OutfitterAutoSwitch, "BOTTOMLEFT", 0, -5)
	OutfitterEditScriptDialogDoneButton:SetStylePanel("Button")
	OutfitterEditScriptDialogCancelButton:SetStylePanel("Button")
	MOD:ApplyScrollFrameStyle(OutfitterEditScriptDialogSourceScriptScrollBar)
	MOD:ApplyFrameStyle(OutfitterEditScriptDialogSourceScript,"Transparent")
	MOD:ApplyFrameStyle(OutfitterEditScriptDialog)
	MOD:ApplyCloseButtonStyle(OutfitterEditScriptDialog.CloseButton)
	MOD:ApplyTabStyle(OutfitterEditScriptDialogTab1)
	MOD:ApplyTabStyle(OutfitterEditScriptDialogTab2)
end
MOD:SaveAddonStyle("Outfitter", StyleOutfitter)