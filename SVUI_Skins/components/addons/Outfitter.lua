--[[
##########################################################
S V U I   By: Munglunch
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
		SV.API:Set("Frame", OutfitterFrame)
		OutfitterFrameTab1:ModSize(60, 25)
		OutfitterFrameTab2:ModSize(60, 25)
		OutfitterFrameTab3:ModSize(60, 25)
		OutfitterMainFrame:RemoveTextures(true)
		for i = 0, 13 do
			if _G["OutfitterItem"..i.."OutfitSelected"] then 
				_G["OutfitterItem"..i.."OutfitSelected"]:SetStyle()
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
	OutfitterFrameTab1:SetStyle()
	OutfitterFrameTab2:SetStyle()
	OutfitterFrameTab3:SetStyle()
	SV.API:Set("ScrollFrame", OutfitterMainFrameScrollFrameScrollBar)
	SV.API:Set("CloseButton", OutfitterCloseButton)
	OutfitterNewButton:SetStyle()
	OutfitterEnableNone:SetStyle()
	OutfitterEnableAll:SetStyle()
	OutfitterButton:ClearAllPoints()
	OutfitterButton:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", 26, -2)
	OutfitterButton:SetHighlightTexture(nil)
	OutfitterSlotEnables:SetFrameStrata("HIGH")
	OutfitterEnableHeadSlot:SetStyle()
	OutfitterEnableNeckSlot:SetStyle()
	OutfitterEnableShoulderSlot:SetStyle()
	OutfitterEnableBackSlot:SetStyle()
	OutfitterEnableChestSlot:SetStyle()
	OutfitterEnableShirtSlot:SetStyle()
	OutfitterEnableTabardSlot:SetStyle()
	OutfitterEnableWristSlot:SetStyle()
	OutfitterEnableMainHandSlot:SetStyle()
	OutfitterEnableSecondaryHandSlot:SetStyle()
	OutfitterEnableHandsSlot:SetStyle()
	OutfitterEnableWaistSlot:SetStyle()
	OutfitterEnableLegsSlot:SetStyle()
	OutfitterEnableFeetSlot:SetStyle()
	OutfitterEnableFinger0Slot:SetStyle()
	OutfitterEnableFinger1Slot:SetStyle()
	OutfitterEnableTrinket0Slot:SetStyle()
	OutfitterEnableTrinket1Slot:SetStyle()
	OutfitterItemComparisons:SetStyle()
	OutfitterTooltipInfo:SetStyle()
	OutfitterShowHotkeyMessages:SetStyle()
	OutfitterShowMinimapButton:SetStyle()
	OutfitterShowOutfitBar:SetStyle()
	OutfitterAutoSwitch:SetStyle()
	OutfitterItemComparisons:ModSize(20)
	OutfitterTooltipInfo:ModSize(20)
	OutfitterShowHotkeyMessages:ModSize(20)
	OutfitterShowMinimapButton:ModSize(20)
	OutfitterShowOutfitBar:ModSize(20)
	OutfitterAutoSwitch:ModSize(20)
	OutfitterShowOutfitBar:ModPoint("TOPLEFT", OutfitterAutoSwitch, "BOTTOMLEFT", 0, -5)
	OutfitterEditScriptDialogDoneButton:SetStyle()
	OutfitterEditScriptDialogCancelButton:SetStyle()
	SV.API:Set("ScrollFrame", OutfitterEditScriptDialogSourceScriptScrollBar)
	SV.API:Set("Frame", OutfitterEditScriptDialogSourceScript,"Transparent")
	SV.API:Set("Frame", OutfitterEditScriptDialog)
	SV.API:Set("CloseButton", OutfitterEditScriptDialog.CloseButton)
	SV.API:Set("Tab", OutfitterEditScriptDialogTab1)
	SV.API:Set("Tab", OutfitterEditScriptDialogTab2)
end
MOD:SaveAddonStyle("Outfitter", StyleOutfitter)