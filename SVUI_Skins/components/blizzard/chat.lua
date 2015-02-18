--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format, join, gsub = string.format, string.join, string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;  -- Basic
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
FRAME LISTS
##########################################################
]]--
local CHAT_CONFIG_CHANNEL_LIST = _G.CHAT_CONFIG_CHANNEL_LIST;
local CHANNELS = _G.CHANNELS;

local ChatMenuList = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"VoiceMacroMenu",		
};
local ChatFrameList1 = {
	"ChatConfigFrame",
	"ChatConfigBackgroundFrame",
	"ChatConfigCategoryFrame",
	"ChatConfigChatSettingsClassColorLegend",
	"ChatConfigChatSettingsLeft",
	"ChatConfigChannelSettingsLeft",
	"ChatConfigChannelSettingsClassColorLegend",
	"ChatConfigOtherSettingsCombat",
	"ChatConfigOtherSettingsPVP",
	"ChatConfigOtherSettingsSystem",
	"ChatConfigOtherSettingsCreature",
	"ChatConfigCombatSettingsFilters",
	"CombatConfigMessageSourcesDoneBy",
	"CombatConfigMessageSourcesDoneTo",
	"CombatConfigColorsUnitColors",
	"CombatConfigColorsHighlighting",
	"CombatConfigColorsColorizeUnitName",
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
};
local ChatFrameList2 = {
	"ChatConfigFrameDefaultButton",
	"ChatConfigFrameOkayButton",
	"CombatLogDefaultButton",
	"ChatConfigCombatSettingsFiltersCopyFilterButton",
	"ChatConfigCombatSettingsFiltersAddFilterButton",
	"ChatConfigCombatSettingsFiltersDeleteButton",
	"CombatConfigSettingsSaveButton",
	"ChatConfigFrameCancelButton",
};
local ChatFrameList3 = {
	"ChatConfigCategoryFrame",
	"ChatConfigBackgroundFrame",
	"ChatConfigChatSettingsClassColorLegend",
	"ChatConfigChannelSettingsClassColorLegend",
	"ChatConfigCombatSettingsFilters",
	"ChatConfigCombatSettingsFiltersScrollFrame",
	"CombatConfigColorsHighlighting",
	"CombatConfigColorsColorizeUnitName",
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
	"ChatConfigChatSettingsLeft",
	"ChatConfigOtherSettingsCombat",
	"ChatConfigOtherSettingsPVP",
	"ChatConfigOtherSettingsSystem",
	"ChatConfigOtherSettingsCreature",
	"ChatConfigChannelSettingsLeft",
	"CombatConfigMessageSourcesDoneBy",
	"CombatConfigMessageSourcesDoneTo",
	"CombatConfigColorsUnitColors",
};
local ChatFrameList4 = {
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
};
local ChatFrameList5 = {
	"ChatConfigFrameOkayButton",
	"ChatConfigFrameDefaultButton",
	"CombatLogDefaultButton",
	"ChatConfigCombatSettingsFiltersDeleteButton",
	"ChatConfigCombatSettingsFiltersAddFilterButton",
	"ChatConfigCombatSettingsFiltersCopyFilterButton",
	"CombatConfigSettingsSaveButton",
};
local ChatFrameList6 = {
	"CombatConfigColorsHighlightingLine",
	"CombatConfigColorsHighlightingAbility",
	"CombatConfigColorsHighlightingDamage",
	"CombatConfigColorsHighlightingSchool",
	"CombatConfigColorsColorizeUnitNameCheck",
	"CombatConfigColorsColorizeSpellNamesCheck",
	"CombatConfigColorsColorizeSpellNamesSchoolColoring",
	"CombatConfigColorsColorizeDamageNumberCheck",
	"CombatConfigColorsColorizeDamageNumberSchoolColoring",
	"CombatConfigColorsColorizeDamageSchoolCheck",
	"CombatConfigColorsColorizeEntireLineCheck",
	"CombatConfigFormattingShowTimeStamp",
	"CombatConfigFormattingShowBraces",
	"CombatConfigFormattingUnitNames",
	"CombatConfigFormattingSpellNames",
	"CombatConfigFormattingItemNames",
	"CombatConfigFormattingFullText",
	"CombatConfigSettingsShowQuickButton",
	"CombatConfigSettingsSolo",
	"CombatConfigSettingsParty",
	"CombatConfigSettingsRaid",
};
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local ChatGeneric_OnShow = function(self)
	 if(not self.Panel) then 
	 	self:SetStyle("Frame", "Window") 
	end 
end

local ChatMenu_OnShow = function(self) 
	if(not self.Panel) then 
		self:SetStyle("Frame", "Window") 
	end 
	self:ClearAllPoints() 
	self:ModPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30) 
end

local ChatConfigChannelSettingsLeft_OnEvent = function(self)
	local checkBoxTable = self.checkBoxTable;
    local checkBoxNameString = "ChatConfigChannelSettingsLeftCheckBox";
    local boxHeight = ChatConfigOtherSettingsCombatCheckBox1:GetHeight() or 20
    local colorsHeight = ChatConfigChatSettingsLeftCheckBox1Check:GetHeight() or 20
	for i = 1,#checkBoxTable do
		local gName = ("ChatConfigChannelSettingsLeftCheckBox%d"):format(i)
		local checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", 'Transparent')
			end
			checkbox:SetHeight(boxHeight)
			checkbox.Panel:ModPoint("TOPLEFT",3,-1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT",-3,1)

			local check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end

			local colors = _G[("%sColorClasses"):format(gName)]
			if(colors) then
				colors:SetStyle("Checkbox")
				colors:SetHeight(colorsHeight)
			end
		end
	end
end

local ChatConfigBackgroundFrame_OnShow = function(self)
	local gName, checkbox, check, colors
	local boxHeight = ChatConfigOtherSettingsCombatCheckBox1:GetHeight() or 20
    local colorsHeight = ChatConfigChatSettingsLeftCheckBox1Check:GetHeight() or 20

	for i = 1, #CHAT_CONFIG_CHAT_LEFT do
		gName = ("ChatConfigChatSettingsLeftCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)
			checkbox:SetHeight(boxHeight)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end

			colors = _G[("%sColorClasses"):format(gName)]
			if(colors) then
				colors:SetStyle("Checkbox")
				colors:SetHeight(colorsHeight)
			end
		end
	end
	for i = 1, #CHAT_CONFIG_OTHER_COMBAT do
		gName = ("ChatConfigOtherSettingsCombatCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #CHAT_CONFIG_OTHER_PVP do
		gName = ("ChatConfigOtherSettingsPVPCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #CHAT_CONFIG_OTHER_SYSTEM do
		gName = ("ChatConfigOtherSettingsSystemCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #CHAT_CONFIG_CHAT_CREATURE_LEFT do
		gName = ("ChatConfigOtherSettingsCreatureCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #COMBAT_CONFIG_MESSAGESOURCES_BY do
		gName = ("CombatConfigMessageSourcesDoneByCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #COMBAT_CONFIG_MESSAGESOURCES_TO do
		gName = ("CombatConfigMessageSourcesDoneToCheckBox%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)

			check = _G[("%sCheck"):format(gName)]
			if(check) then
				check:SetStyle("Checkbox")
			end
		end
	end
	for i = 1, #COMBAT_CONFIG_UNIT_COLORS do
		gName = ("CombatConfigColorsUnitColorsSwatch%d"):format(i)
		checkbox = _G[gName]
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", "Default")
			end
			checkbox.Panel:ModPoint("TOPLEFT", 3, -1)
			checkbox.Panel:ModPoint("BOTTOMRIGHT", -3, 1)
		end
	end
	for i = 1, 4 do
		gName = ("CombatConfigMessageTypesLeftCheckBox%d"):format(i)
		for j = 1, 4 do
			local gName2 = ("%s_%d"):format(gName, j)
			if(_G[gName] and _G[gName2]) then
				_G[gName]:SetStyle("Checkbox")
				_G[gName2]:SetStyle("Checkbox")
			end
		end

		gName = ("CombatConfigMessageTypesRightCheckBox%d"):format(i)
		for j = 1, 10 do
			local gName2 = ("%s_%d"):format(gName, j)
			if(_G[gName] and _G[gName2]) then
				_G[gName]:SetStyle("Checkbox")
				_G[gName2]:SetStyle("Checkbox")
			end
		end

		gName = ("CombatConfigMessageTypesMiscCheckBox%d"):format(i)
		if(_G[gName]) then
			_G[gName]:SetStyle("Checkbox")
		end
	end
end
--[[ 
########################################################## 
CHAT MODR
##########################################################
]]--
local function ChatStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.chat ~= true then
		 return 
	end

	for i = 1, #ChatMenuList do
		local name = ChatMenuList[i]
		local this = _G[name]
		if(this) then
			if(name == "ChatMenu") then
				this:HookScript("OnShow", ChatMenu_OnShow)
			else
				this:HookScript("OnShow", ChatGeneric_OnShow)
			end
		end
	end
	
	for i = 1, #ChatFrameList1 do
		local name = ChatFrameList1[i]
		local this = _G[name]
		if(this) then
			this:RemoveTextures()
		end
	end

	for i = 1, #ChatFrameList2 do
		local name = ChatFrameList2[i]
		local this = _G[name]
		if(this) then
			this:RemoveTextures()
		end
	end	

	ChatConfigFrameOkayButton:ModPoint("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:ModPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:ModPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:ModPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	if(_G["CombatConfigTab1"]) then _G["CombatConfigTab1"]:RemoveTextures() end
	if(_G["CombatConfigTab2"]) then _G["CombatConfigTab2"]:RemoveTextures() end
	if(_G["CombatConfigTab3"]) then _G["CombatConfigTab3"]:RemoveTextures() end
	if(_G["CombatConfigTab4"]) then _G["CombatConfigTab4"]:RemoveTextures() end
	if(_G["CombatConfigTab5"]) then _G["CombatConfigTab5"]:RemoveTextures() end

	CombatConfigSettingsNameEditBox:SetStyle("Editbox")
	ChatConfigFrame:SetStyle("Frame", "Window", true)

	for i = 1, #ChatFrameList3 do
		local frame = _G[ChatFrameList3[i]]
		if(frame) then
			frame:RemoveTextures()
			frame:SetStyle("Frame", 'Transparent')
		end
	end

	for i = 1, #ChatFrameList4 do
		local this = _G[ChatFrameList4[i]]
		if(this) then
			this:ClearAllPoints()
			if this == CombatConfigColorsColorizeSpellNames then
				this:ModPoint("TOP",CombatConfigColorsColorizeUnitName,"BOTTOM",0,-2)
			else
				this:ModPoint("TOP",_G[ChatFrameList4[i-1]],"BOTTOM",0,-2)
			end
		end
	end

	ChatConfigChannelSettingsLeft:HookScript("OnShow", ChatConfigChannelSettingsLeft_OnEvent)

	-- do
	-- 	local chatchannellist = GetChannelList()
	-- 	local CreateChatChannelList = _G.CreateChatChannelList;
	-- 	local ChatConfigChannelSettings = _G.ChatConfigChannelSettings;
	-- 	CreateChatChannelList(ChatConfigChannelSettings, chatchannellist)
	-- end

	ChatConfig_CreateCheckboxes(ChatConfigChannelSettingsLeft, CHAT_CONFIG_CHANNEL_LIST, "ChatConfigCheckBoxWithSwatchAndClassColorTemplate", CHANNELS)
	ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft)

	ChatConfigBackgroundFrame:SetScript("OnShow", ChatConfigBackgroundFrame_OnShow)

	for i = 1, #COMBAT_CONFIG_TABS do
		local this = _G["CombatConfigTab"..i]
		if(this) then
			SV.API:Set("Tab", this)
			this:SetHeight(this:GetHeight()-2)
			this:SetWidth(ceil(this:GetWidth()+1.6))
			_G["CombatConfigTab"..i.."Text"]:SetPoint("BOTTOM", 0, 10)
		end
	end

	CombatConfigTab1:ClearAllPoints()
	CombatConfigTab1:SetPoint("BOTTOMLEFT", ChatConfigBackgroundFrame, "TOPLEFT", 6, -2)

	for i = 1, #ChatFrameList5 do
		local this = _G[ChatFrameList5[i]]
		if(this) then
			this:SetStyle("Button")
		end
	end
	
	ChatConfigFrameOkayButton:SetPoint("TOPRIGHT", ChatConfigBackgroundFrame, "BOTTOMRIGHT", -3, -5)
	ChatConfigFrameDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 1, -5)
	CombatLogDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 1, -5)
	ChatConfigCombatSettingsFiltersDeleteButton:SetPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", -3, -1)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -2, 0)
	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersCopyFilterButton, "LEFT", -2, 0)

	for i = 1, #ChatFrameList6 do
		local this = _G[ChatFrameList6[i]]
		if(this) then
			this:SetStyle("Checkbox")
		end
	end

	SV.API:Set("PageButton", ChatConfigMoveFilterUpButton,true)
	SV.API:Set("PageButton", ChatConfigMoveFilterDownButton,true)
	SV.API:Set("PageButton", CombatLogQuickButtonFrame_CustomAdditionalFilterButton,true)

	SV.API:Set("ScrollBar", SVUI_CopyChatScrollFrameScrollBar)
	SV.API:Set("CloseButton", SVUI_CopyChatFrameCloseButton)

	ChatConfigMoveFilterUpButton:ClearAllPoints()
	ChatConfigMoveFilterDownButton:ClearAllPoints()
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT",ChatConfigMoveFilterUpButton,24,0)

	CombatConfigSettingsNameEditBox:SetStyle("Editbox")

	ChatConfigFrame:ModSize(680,596)
	ChatConfigFrameHeader:ClearAllPoints()
	ChatConfigFrameHeader:SetPoint("TOP", ChatConfigFrame, "TOP", 0, -5)

	-- for i=1, select("#", GetChatWindowChannels(3)) do
	-- 	local info = select(i, GetChatWindowChannels(3))
	-- 	print(info)
	-- end
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(ChatStyle)