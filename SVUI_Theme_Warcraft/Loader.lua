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
local THEME = SV:NewTheme(...);
--[[ 
########################################################## 
FORCIBLY CHANGE THE GAME WORLD COMBAT TEXT FONT
##########################################################
]]--
local SVUI_DAMAGE_FONT = "Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\fonts\\!DAMAGE.ttf";
local SVUI_DAMAGE_FONTSIZE = 32;

local function ForceDamageFont()
	_G.DAMAGE_TEXT_FONT = SVUI_DAMAGE_FONT
	_G.COMBAT_TEXT_CRIT_SCALE_TIME = 0.7;
	_G.COMBAT_TEXT_SPACING = 15;
end

ForceDamageFont();

THEME.media = {}
THEME.media.dockSparks = {
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-3]],
};