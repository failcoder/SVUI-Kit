--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;

local SV = _G["SVUI"];
local L = SV.L
local MOD = SV:NewPackage(...);
local Schema = MOD.Schema;

MOD.media = {}
MOD.media.dockIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\DOCK-ICON-QUESTS]];
MOD.media.buttonArt = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-BUTTON-ART]];
MOD.media.completeIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-COMPLETE-ICON]];
MOD.media.incompleteIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-INCOMPLETE-ICON]];

SV.defaults[Schema] = {
	["enable"] = true, 
};

SV.defaults["font"]["questdialog"]   	= {file = "SVUI Default Font", size = 12,  outline = "OUTLINE"}
SV.defaults["font"]["questheader"]   	= {file = "SVUI Caps Font",    size = 16,  outline = "OUTLINE"}
SV.defaults["font"]["questnumber"]   	= {file = "SVUI Number Font",  size = 11,  outline = "OUTLINE"}

local questFonts = {
	["questdialog"] = {
		order = 1,
		name = "Quest Tracker Dialog",
		desc = "Default font used in the quest tracker"
	},
	["questheader"] = {
		order = 2,
		name = "Quest Tracker Titles",
		desc = "Font used in the quest tracker for listing headers."
	}, 
	["questnumber"] = {
		order = 3,
		name = "Quest Tracker Numbers",
		desc = "Font used in the quest tracker to display numeric values."
	},
};


function MOD:LoadOptions()
	SV:GenerateFontOptionGroup("QuestTracker", 6, "Fonts used in the SVUI Quest Tracker.", questFonts)
	
	SV.Options.args[Schema] = {
		type = "group", 
		name = Schema, 
		get = function(a)return SV.db[Schema][a[#a]]end, 
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]); end, 
		args = {}
	}
end