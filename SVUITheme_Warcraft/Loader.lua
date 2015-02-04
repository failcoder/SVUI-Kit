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
THEME.media = {}
THEME.media.dockSparks = {
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-3]],
};

SV.defaults.THEME["Warcraft"] = {};

SV.Options.args.Themes.args.Warcraft = {
	type = "group",
	name = L["Warcraft Theme"],
	guiInline = true, 
	args = {}
};