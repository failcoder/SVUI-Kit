--[[
##########################################################
S V U I   By: Munglunch
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

SV:AssignMedia("font", "questdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "questheader", "SVUI Caps Font", 16, "OUTLINE");
SV:AssignMedia("font", "questnumber", "SVUI Number Font", 11, "OUTLINE");
SV:AssignMedia("globalfont", "questdialog", "SVUI_Font_Quest");
SV:AssignMedia("globalfont", "questheader", "SVUI_Font_Quest_Header");
SV:AssignMedia("globalfont", "questnumber", "SVUI_Font_Quest_Number");


function MOD:LoadOptions()
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