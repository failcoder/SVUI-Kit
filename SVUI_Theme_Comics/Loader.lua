--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	 =  _G.unpack;
local pairs 	 =  _G.pairs;
local tinsert 	 =  _G.tinsert;
local table 	 =  _G.table;
--[[ TABLE METHODS ]]--
local tsort = table.sort;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local LSM = LibStub("LibSharedMedia-3.0");
local THEME = SV:NewTheme(...);
--[[ 
########################################################## 
FORCIBLY CHANGE THE GAME WORLD COMBAT TEXT FONT
##########################################################
]]--
local SVUI_DAMAGE_FONT = "Interface\\AddOns\\SVUI_Theme_Comics\\assets\\fonts\\!DAMAGE.ttf";
local SVUI_DAMAGE_FONTSIZE = 32;

local function ForceDamageFont()
	_G.DAMAGE_TEXT_FONT = SVUI_DAMAGE_FONT
	_G.COMBAT_TEXT_CRIT_SCALE_TIME = 0.7;
	_G.COMBAT_TEXT_SPACING = 15;
end

ForceDamageFont();

LSM:Register("background", "SVUI UnitBG 1", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-BG1]])
LSM:Register("background", "SVUI UnitBG 2", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-BG1]])
LSM:Register("background", "SVUI UnitBG 3", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-BG1]])
LSM:Register("background", "SVUI UnitBG 4", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 1", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-SMALL-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 2", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-SMALL-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 3", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-SMALL-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 4", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Unitframe\Background\UNIT-SMALL-BG1]])
LSM:Register("border", "SVUI UnitBorder 1", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "SVUI SmallBorder 1", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("font", "SVUI Classic Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Classic.ttf]])
LSM:Register("font", "SVUI Combat Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Combat.ttf]])
LSM:Register("font", "SVUI Dialog Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Dialog.ttf]])
LSM:Register("font", "SVUI Number Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Numbers.ttf]])
LSM:Register("font", "SVUI Zone Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Zone.ttf]])
LSM:Register("font", "SVUI Flash Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Flash.ttf]])
LSM:Register("font", "SVUI Alert Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Alert.ttf]])
LSM:Register("font", "SVUI Narrator Font", [[Interface\AddOns\SVUI_Theme_Comics\assets\fonts\Narrative.ttf]])

THEME.media = {}
THEME.media.dockSparks = {
	[[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-SPARKS-3]],
};

SV.defaults.THEME["Comics"] = {
    ["loginmessage"] = true, 
    ["comix"] = '1',
    ["bigComix"] = false,
    ["gamemenu"] = '1',
    ["afk"] = '1', 
    ["drunk"] = true,
};