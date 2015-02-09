--[[
##########################################################
S V U I   By: S.Jackson
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
local MOD = SV:NewModule(...);
local Schema = MOD.Schema;

MOD.media = {}
MOD.media.dockIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\DOCK-ICON-QUESTS]];
MOD.media.buttonArt = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-BUTTON-ART]];
MOD.media.completeIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-COMPLETE-ICON]];
MOD.media.incompleteIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-INCOMPLETE-ICON]];

SV.defaults[Schema] = {
	["itemBarDirection"] = 'VERTICAL', 
};

SV.mediadefaults.internal.font["questdialog"]   	= {file = "SVUI Default Font", size = 12,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["questheader"]   	= {file = "SVUI Caps Font",    size = 16,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["questnumber"]   	= {file = "SVUI Number Font",  size = 11,  outline = "OUTLINE"}

SV.GlobalFontList["SVUI_Font_Quest"] = "questdialog";
SV.GlobalFontList["SVUI_Font_Quest_Header"] = "questheader";
SV.GlobalFontList["SVUI_Font_Quest_Number"] = "questnumber";

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
		args = {
			itemBarDirection = {
				order = 1, 
				type = 'select', 
				name = L["Item Bar Direction"], 
				values = {
					['VERTICAL'] = L['Vertical'], 
					['HORIZONTAL'] = L['Horizontal']
				},
			},
		}
	}
end