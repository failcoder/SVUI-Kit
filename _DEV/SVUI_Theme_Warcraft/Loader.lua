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
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-3]],
};

SV.defaults.THEME["Warcraft"] = {
    ["loginmessage"] = true, 
    ["comix"] = '1',
    ["bigComix"] = false,
    ["gamemenu"] = '1',
    ["afk"] = '1', 
    ["drunk"] = true,
};
SV.Options.args.Themes.args.Warcraft = {
	type = "group",
	name = L["Warcraft Theme"],
	guiInline = true, 
	args = {
		themeGroup = {
			order = 1, 
			type = "group", 
			guiInline = true, 
			name = L["Fun Stuff"],
			args = {
				comix = {
					order = 1,
					type = 'select',
					name = L["Super Comic Popups"],
					get = function(j)return SV.db.THEME["Warcraft"].comix end,
					set = function(j,value) SV.db.THEME["Warcraft"].comix = value; THEME.Comix:Toggle() end,
					values = {
						['NONE'] = NONE,
						['1'] = 'All Popups',
						['2'] = 'Only Small Popups',
					}
				},
				afk = {
					order = 2,
					type = 'select',
					name = L["Super AFK Screen"],
					get = function(j)return SV.db.THEME["Warcraft"].afk end,
					set = function(j,value) SV.db.THEME["Warcraft"].afk = value; THEME.AFK:Toggle() end,
					values = {
						['NONE'] = NONE,
						['1'] = 'Fully Enabled',
						['2'] = 'Enabled (No Spinning)',
					}
				},
				gamemenu = {
					order = 3,
					type = 'select',
					name = L["Super Game Menu"],
					get = function(j)return SV.db.THEME["Warcraft"].gamemenu end,
					set = function(j,value) SV.db.THEME["Warcraft"].gamemenu = value; SV:StaticPopup_Show("RL_CLIENT") end,
					values = {
						['NONE'] = NONE,
						['1'] = 'You + Henchman',
						['2'] = 'You x2',
					}
				},
			}
		},
	}
};