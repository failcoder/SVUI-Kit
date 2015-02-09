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
local L = SV.L;
local AddonName, AddonObj = ...;
local PLUGIN = SV:NewPlugin(AddonName, AddonObj, "SVUI_Public_FightOMatic");
local Schema = PLUGIN.Schema;

SV.defaults[Schema] = {
    ["annoyingEmotes"] = false, 
}

SV.mediadefaults.internal.font["fightdialog"]   = {file = "SVUI Default Font", size = 12,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["fightnumber"]   = {file = "SVUI Caps Font",    size = 12,  outline = "OUTLINE"}

SV.GlobalFontList["SVUI_Font_Fight"]   = "fightdialog";
SV.GlobalFontList["SVUI_Font_FightNumber"] = "fightnumber";

local fightFonts = {
  ["fightdialog"] = {
    order = 1,
    name = "Fight-O-Matic Dialog",
    desc = "Font used for log window text."
  },
  ["fightnumber"] = {
    order = 2,
    name = "Fight-O-Matic Numbers",
    desc = "Font used for log window numbers."
  },
};

function PLUGIN:LoadOptions()
    SV:GenerateFontOptionGroup("Fight-O-Matic", 13, "Font used for Fight-O-Matic text.", fightFonts)

    SV.Options.args[Schema] = {
        type = "group", 
        name = Schema, 
        get = function(a)return SV.db[Schema][a[#a]]end, 
        set = function(a,b)PLUGIN:ChangeDBVar(b,a[#a]); end, 
        args = {
            annoyingEmotes = {
                order = 1,
                name = L["Annoying Emotes"],
                desc = L["Aggravate your opponents (and team-mates) with incessant emotes"],
                type = "toggle",
                get = function(key) return SV.db[Schema].annoyingEmotes end,
                set = function(key,value) PLUGIN:ChangeDBVar(value, key[#key]); end
            }
        }
    }
end