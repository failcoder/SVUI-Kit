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
MOGIT
##########################################################
]]--
local function StyleMogItPreview()
	for i = 1, 99 do
		local MogItGearSlots = {
			"HeadSlot",
			"ShoulderSlot",
			"BackSlot",
			"ChestSlot",
			"ShirtSlot",
			"TabardSlot",
			"WristSlot",
			"HandsSlot",
			"WaistSlot",
			"LegsSlot",
			"FeetSlot",
			"MainHandSlot",
			"SecondaryHandSlot",
		}
		for _, object in pairs(MogItGearSlots) do
			if _G["MogItPreview"..i..object] then
				MOD:ApplyItemButtonStyle(_G["MogItPreview"..i..object])
				_G["MogItPreview"..i..object]:SetPushedTexture(nil)
				_G["MogItPreview"..i..object]:SetHighlightTexture(nil)
			end
		end
		if _G["MogItPreview"..i] then MOD:ApplyFrameStyle(_G["MogItPreview"..i]) end
		if _G["MogItPreview"..i.."CloseButton"] then MOD:ApplyCloseButtonStyle(_G["MogItPreview"..i.."CloseButton"]) end
		if _G["MogItPreview"..i.."Inset"] then _G["MogItPreview"..i.."Inset"]:RemoveTextures(true) end
		if _G["MogItPreview"..i.."Activate"] then _G["MogItPreview"..i.."Activate"]:SetStylePanel("Button") end
	end
end

local function StyleMogIt()
	assert(MogItFrame, "AddOn Not Loaded")
	
	MOD:ApplyFrameStyle(MogItFrame)
	MogItFrameInset:RemoveTextures(true)
	MOD:ApplyFrameStyle(MogItFilters)
	MogItFiltersInset:RemoveTextures(true)

	hooksecurefunc(MogIt, "CreatePreview", StyleMogItPreview)
	MOD:ApplyTooltipStyle(MogItTooltip)
	MOD:ApplyCloseButtonStyle(MogItFrameCloseButton)
	MOD:ApplyCloseButtonStyle(MogItFiltersCloseButton)
	MogItFrameFiltersDefaults:RemoveTextures(true)
	MogItFrameFiltersDefaults:SetStylePanel("Button")
	MOD:ApplyScrollFrameStyle(MogItScroll)
	MOD:ApplyScrollFrameStyle(MogItFiltersScrollScrollBar)
end
MOD:SaveAddonStyle("MogIt", StyleMogIt)