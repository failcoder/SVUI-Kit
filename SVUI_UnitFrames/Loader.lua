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
local LSM = LibStub("LibSharedMedia-3.0");

MOD.media = {}
MOD.media.groupNumbers = {
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\1]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\2]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\3]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\4]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\5]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\6]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\7]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\GroupNumbers\8]],
};
MOD.media.lml = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-LML]];
MOD.media.roles = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-ROLES]];
MOD.media.buddy = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-FRIENDSHIP]];
MOD.media.playerstate = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-PLAYER-STATE]];
MOD.media.afflicted = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-AFFLICTED]];

SV.API.Templates["ActionPanel"] = "SVUI_StyleTemplate_ActionPanel";
SV.API.Templates["UnitLarge"] 	= "SVUI_StyleTemplate_UnitLarge";
SV.API.Templates["UnitSmall"] 	= "SVUI_StyleTemplate_UnitSmall";

LSM:Register("background", "SVUI UnitBG 1", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-BG1]])
LSM:Register("background", "SVUI UnitBG 2", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-BG2]])
LSM:Register("background", "SVUI UnitBG 3", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-BG3]])
LSM:Register("background", "SVUI UnitBG 4", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-BG4]])
LSM:Register("background", "SVUI SmallUnitBG 1", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-SMALL-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 2", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-SMALL-BG2]])
LSM:Register("background", "SVUI SmallUnitBG 3", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-SMALL-BG3]])
LSM:Register("background", "SVUI SmallUnitBG 4", [[Interface\AddOns\SVUI_UnitFrames\assets\Background\UNIT-SMALL-BG4]])
LSM:Register("border", "SVUI UnitBorder 1", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "SVUI SmallBorder 1", [[Interface\BUTTONS\WHITE8X8]])

SV.mediadefaults.internal.font["unitprimary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["unitsecondary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["unitaurabar"]   	= {file = "SVUI Alert Font",  	size = 10,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["unitaura"]  	= {file = "SVUI Caps Font",  	size = 18,  outline = "OUTLINE"}
SV.mediadefaults.internal.font["unitaurasmall"]   	= {file = "SVUI Pixel Font",  	size = 8,   outline = "MONOCHROMEOUTLINE"}

SV.mediadefaults.internal.bg["unitlarge"]   = "SVUI UnitBG 1";
SV.mediadefaults.internal.bg["unitsmall"]   = "SVUI SmallUnitBG 1";
SV.mediadefaults.internal.border["unitlarge"]    = "SVUI UnitBorder 1";
SV.mediadefaults.internal.border["unitsmall"]    = "SVUI SmallBorder 1";

SV.mediadefaults.internal["unitframes"] = {
	["health"]       = {0.3, 0.5, 0.3}, 
	["power"]        = {
		["MANA"]         = {0.41, 0.85, 1}, 
		["RAGE"]         = {1, 0.31, 0.31}, 
		["FOCUS"]        = {1, 0.63, 0.27}, 
		["ENERGY"]       = {0.85, 0.83, 0.25}, 
		["RUNES"]        = {0.55, 0.57, 0.61}, 
		["RUNIC_POWER"] = {0, 0.82, 1}, 
		["FUEL"]         = {0, 0.75, 0.75}
	}, 
	["reaction"]     = {
		[1] = {0.92, 0.15, 0.15}, 
		[2] = {0.92, 0.15, 0.15}, 
		[3] = {0.92, 0.15, 0.15}, 
		[4] = {0.85, 0.85, 0.13}, 
		[5] = {0.19, 0.85, 0.13}, 
		[6] = {0.19, 0.85, 0.13}, 
		[7] = {0.19, 0.85, 0.13}, 
		[8] = {0.19, 0.85, 0.13}, 
	},
	["tapped"]           = {0.55, 0.57, 0.61}, 
	["disconnected"]     = {0.84, 0.75, 0.65}, 
	["casting"]          = {0, 0.92, 1}, 
	["spark"]            = {0, 0.42, 1}, 
	["interrupt"]        = {0.78, 0, 1}, 
	["shield_bars"]      = {0.56, 0.4, 0.62}, 
	["buff_bars"]        = {0.31, 0.31, 0.31}, 
	["debuff_bars"]      = {0.8, 0.1, 0.1}, 
	["predict"]          = {
		["personal"]         = {0, 1, 0.5, 0.25}, 
		["others"]           = {0, 1, 0, 0.25}, 
		["absorbs"]          = {1, 1, 0, 0.25}
	}
};

SV.media["bg"]["unitlarge"]   	= LSM:Fetch("background", "SVUI UnitBG 1")
SV.media["bg"]["unitsmall"]   	= LSM:Fetch("background", "SVUI SmallUnitBG 1")
SV.media["border"]["unitlarge"] 	= LSM:Fetch("border", "SVUI UnitBorder 1")
SV.media["border"]["unitsmall"] 	= LSM:Fetch("border", "SVUI SmallBorder 1")
-- print("Unitframe")
-- print(SV.mediadefaults.internal.bg["unitlarge"])
<<<<<<< HEAD
-- print(SV.Media["texture"]["unitlarge"])
=======
-- print(SV.media["bg"]["unitlarge"])
>>>>>>> origin/master

SV.GlobalFontList["SVUI_Font_Unit"] = "unitprimary";
SV.GlobalFontList["SVUI_Font_Unit_Small"] = "unitsecondary";
SV.GlobalFontList["SVUI_Font_UnitAura"] = "unitaura";
SV.GlobalFontList["SVUI_Font_UnitAura_Bar"] = "unitaurabar";
SV.GlobalFontList["SVUI_Font_UnitAura_Small"] = "unitaurasmall";

SV.defaults[Schema] = {
	["themed"] = true,
	["disableBlizzard"] = true, 
	["smoothbars"] = false, 
	["statusbar"] = "SVUI MultiColorBar", 
	["auraBarStatusbar"] = "SVUI MultiColorBar", 
	["font"] = "SVUI Number Font", 
	["fontSize"] = 10, 
	["fontOutline"] = "NONE", 
	["auraFont"] = "SVUI Alert Font", 
	["auraFontSize"] = 10, 
	["auraFontOutline"] = "NONE", 
	["OORAlpha"] = 0.4,
	["groupOORAlpha"] = 0.2, 
	["combatFadeRoles"] = true, 
	["combatFadeNames"] = true, 
	["debuffHighlighting"] = true, 
	["fastClickTarget"] = false, 
	["healglow"] = true, 
	["glowtime"] = 0.8, 
	["glowcolor"] = {1, 1, 0}, 
	["autoRoleSet"] = false, 
	["forceHealthColor"] = false, 
	["overlayAnimation"] = true, 
	["powerclass"] = false,
	["auraBarByType"] = true, 
	["auraBarShield"] = true, 
	["castClassColor"] = false, 
	["xrayFocus"] = true,
	["resolveBar"] = true,
	["player"] = {
		["enable"] = true, 
		["width"] = 215, 
		["height"] = 40, 
		["combatfade"] = false, 
		["predict"] = false, 
		["threatEnabled"] = true, 
		["playerExpBar"] = false, 
		["playerRepBar"] = false, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "current", 
			["name_colored"] = true, 
			["name_length"] = 21, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:current]", 
			["position"] = "INNERRIGHT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 11,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["xOffset"] = 0, 
			["yOffset"] = 0,
			["detachedWidth"] = 250, 
			["druidMana"] = true,
			["fontSize"] = 11,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["pvp"] = 
		{
			["font"] = "SVUI Number Font", 
			["fontSize"] = 12, 
			["fontOutline"] = "OUTLINE", 
			["position"] = "BOTTOM", 
			["tags"] = "||cFFB04F4F[pvptimer][mouseover]||r", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 50,
			["camDistanceScale"] = 1.6, 
			["rotation"] = 0, 
			["style"] = "3DOVERLAY", 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 8, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPLEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT",
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true, 
			["filterAll"] = false, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 8, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 8, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "TOPLEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT",
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] =  0, 
			["yOffset"] = 8, 
			["sizeOverride"] = 0, 
		}, 
		["aurabar"] = 
		{
			["enable"] = false, 
			["anchorPoint"] = "ABOVE", 
			["attachTo"] = "DEBUFFS",
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true, 
			["filterAll"] = false, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["friendlyAuraType"] = "HELPFUL", 
			["enemyAuraType"] = "HARMFUL", 
			["height"] = 18, 
			["sort"] = "TIME_REMAINING", 
		}, 
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 215, 
			["height"] = 20, 
			["matchFrameWidth"] = true, 
			["icon"] = true, 
			["latency"] = false, 
			["format"] = "REMAINING", 
			["ticks"] = false, 
			["spark"] = true, 
			["displayTarget"] = false, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["classbar"] = 
		{
			["enable"] = true,
			["inset"] = "inset", 
			["height"] = 25, 
			["detachFromFrame"] = false,
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 25, 
				["attachTo"] = "INNERBOTTOMRIGHT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
			["combatIcon"] = {
				["enable"] = true, 
				["size"] = 26, 
				["attachTo"] = "TOPRIGHT", 
				["xOffset"] = 28, 
				["yOffset"] = 2, 
			}, 
			["restIcon"] = {
				["enable"] = true, 
				["size"] = 22, 
				["attachTo"] = "INNERBOTTOMRIGHT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
		["stagger"] = 
		{
			["enable"] = true, 
		}, 
	}, 
	["target"] = {
		["enable"] = true, 
		["width"] = 215, 
		["height"] = 40, 
		["threatEnabled"] = true, 
		["rangeCheck"] = true, 
		["predict"] = false, 
		["middleClickFocus"] = true,
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "current", 
			["name_colored"] = true, 
			["name_length"] = 18, 
			["smartlevel"] = true, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:current]", 
			["position"] = "INNERLEFT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["reversed"] = true, 
			["fontSize"] = 11,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "[power:color][power:current]", 
			["height"] = 7, 
			["position"] = "INNERRIGHT", 
			["hideonnpc"] = true, 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["fontSize"] = 11,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "TOPRIGHT", 
			["tags"] = "[name:color][name:18][smartlevel]", 
			["xOffset"] = -2, 
			["yOffset"] = 9, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 50, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1.6, 
			["style"] = "3DOVERLAY", 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 8, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 8, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 8, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 8, 
			["sizeOverride"] = 0, 
		}, 
		["aurabar"] = 
		{
			["enable"] = false, 
			["anchorPoint"] = "ABOVE", 
			["attachTo"] = "DEBUFFS",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = true, 
				enemy = true, 
			}, 
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = true, 
				enemy = true, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = true, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["friendlyAuraType"] = "HELPFUL", 
			["enemyAuraType"] = "HARMFUL", 
			["height"] = 18, 
			["sort"] = "TIME_REMAINING", 
		}, 
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 215, 
			["height"] = 20, 
			["matchFrameWidth"] = true, 
			["icon"] = true, 
			["format"] = "REMAINING", 
			["spark"] = true, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["combobar"] = 
		{
			["enable"] = true, 
			["height"] = 30, 
			["smallIcons"] = false, 
			["hudStyle"] = false, 
			["hudScale"] = 64, 
			["autoHide"] = true, 
		}, 
		["icons"] = 
		{
			["classIcon"] = 
			{
				["enable"] = false, 
				["size"] = 26, 
				["attachTo"] = "INNERBOTTOMLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			},
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 30, 
				["attachTo"] = "INNERLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}
		}, 
	}, 
	["targettarget"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["threatEnabled"] = false, 
		["width"] = 150, 
		["height"] = 25, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 10, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "INNERRIGHT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 9,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = false, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["xOffset"] = 0, 
			["yOffset"] = 0,
			["fontSize"] = 9,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "[name:color][name:10]", 
			["xOffset"] = 0, 
			["yOffset"] = 1, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 45, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1, 
			["style"] = "3DOVERLAY", 
		}, 
		["buffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 7, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] =  0, 
			["yOffset"] =  4, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 5, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] =  0, 
			["yOffset"] =  4, 
			["sizeOverride"] = 0, 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 18, 
				["attachTo"] = "INNERRIGHT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
	}, 
	["focus"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["threatEnabled"] = true, 
		["width"] = 170, 
		["height"] = 30, 
		["predict"] = false, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 15, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "INNERRIGHT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["xOffset"] = 0, 
			["yOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "[name:color][name:15]", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		},
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 170, 
			["height"] = 10,
			["icon"] = false,
			["matchFrameWidth"] = true,
			["format"] = "REMAINING", 
			["spark"] = true, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 7, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = false, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 4, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 5, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = -4, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		},
		["auraWatch"] = 
		{
			["enable"] = true, 
			["size"] = 8, 
		}, 
		["aurabar"] = 
		{
			["enable"] = false, 
			["anchorPoint"] = "ABOVE", 
			["attachTo"] = "FRAME",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = true, 
			}, 
			["useFilter"] = "", 
			["friendlyAuraType"] = "HELPFUL", 
			["enemyAuraType"] = "HARMFUL", 
			["height"] = 18, 
			["sort"] = "TIME_REMAINING", 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 18, 
				["attachTo"] = "INNERLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
	}, 
	["focustarget"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["threatEnabled"] = false, 
		["width"] = 150, 
		["height"] = 26, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 15, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "INNERRIGHT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = false, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["xOffset"] = 0, 
			["yOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "[name:color][name:15]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		},
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 7, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPRIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = false, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 4, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 5, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = -4, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 18, 
				["attachTo"] = "INNERLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
	}, 
	["pet"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["threatEnabled"] = true, 
		["width"] = 110, 
		["height"] = 40, 
		["predict"] = false, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 10, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "INNERRIGHT", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "[name:color][name:8]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 40, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1, 
			["style"] = "3DOVERLAY", 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 4, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "TOPLEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT",
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true,
			["filterAll"] = true, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 4, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 4, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "TOPLEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT",
			["filterWhiteList"] = false,
			["filterPlayer"] = false,
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 4, 
			["sizeOverride"] = 0, 
		}, 
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 130, 
			["height"] = 8, 
			["icon"] = false, 
			["matchFrameWidth"] = true,
			["format"] = "REMAINING", 
			["spark"] = false, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["auraWatch"] = 
		{
			["enable"] = true, 
			["size"] = 8, 
		}, 
	}, 
	["pettarget"] = {
		["enable"] = false, 
		["rangeCheck"] = true, 
		["threatEnabled"] = false, 
		["width"] = 130, 
		["height"] = 26, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 15, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "INNERRIGHT", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = false, 
			["tags"] = "", 
			["height"] = 7, 
			["position"] = "INNERLEFT", 
			["hideonnpc"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "CENTER", 
			["tags"] = "[name:color][name:15]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["buffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 7, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "BOTTOMLEFT", 
			["verticalGrowth"] = "DOWN", 
			["horizontalGrowth"] = "RIGHT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterRaid"] = 
			{
				friendly = true, 
				enemy = false, 
			},
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = true, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = -8, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 5, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "BOTTOMRIGHT", 
			["verticalGrowth"] = "DOWN", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = 
			{
				friendly = false, 
				enemy = false, 
			},
			["filterPlayer"] = 
			{
				friendly = false, 
				enemy = true, 
			}, 
			["filterAll"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterInfinite"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["filterDispellable"] = 
			{
				friendly = false, 
				enemy = false, 
			}, 
			["useFilter"] = "", 
			["xOffset"] = 0, 
			["yOffset"] = 8, 
			["sizeOverride"] = 0, 
		}, 
	}, 
	["boss"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["showBy"] = "UP", 
		["width"] = 200, 
		["height"] = 45, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "current", 
			["name_colored"] = true, 
			["name_length"] = 15, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:current]", 
			["position"] = "INNERTOPRIGHT", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "[power:color][power:current]", 
			["height"] = 7, 
			["position"] = "INNERBOTTOMRIGHT", 
			["hideonnpc"] = false, 
			["yOffset"] = 7, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 35, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1, 
			["style"] = "3DOVERLAY", 
		}, 
		["name"] = 
		{
			["position"] = "INNERLEFT", 
			["tags"] = "[name:color][name:15]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 2, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterRaid"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] =  -8, 
			["yOffset"] =  0, 
			["sizeOverride"] = 40, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] =  -8, 
			["yOffset"] =  0, 
			["sizeOverride"] = 40, 
		}, 
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 200, 
			["height"] = 18, 
			["icon"] = true, 
			["matchFrameWidth"] = true,
			["format"] = "REMAINING", 
			["spark"] = true, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 22, 
				["attachTo"] = "CENTER", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
	}, 
	["arena"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["showBy"] = "UP", 
		["width"] = 215, 
		["height"] = 45,  
		["predict"] = false, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "current", 
			["name_colored"] = true, 
			["name_length"] = 15, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:current]", 
			["position"] = "INNERTOPRIGHT", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = true, 
			["tags"] = "[power:color][power:current]", 
			["height"] = 7, 
			["position"] = "INNERBOTTOMRIGHT", 
			["hideonnpc"] = false, 
			["yOffset"] = 7, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "INNERLEFT", 
			["tags"] = "[name:color][name:15]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10,  
			["fontOutline"] = "OUTLINE", 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 45, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1, 
			["style"] = "3DOVERLAY", 
		}, 
		["buffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT",
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterRaid"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "Shield", 
			["xOffset"] = -8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 40, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "BUFFS", 
			["anchorPoint"] = "LEFT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "LEFT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterRaid"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "CC",
			["xOffset"] = -8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 40, 
		}, 
		["castbar"] = 
		{
			["enable"] = true, 
			["width"] = 215, 
			["height"] = 18, 
			["icon"] = true, 
			["matchFrameWidth"] = true,
			["format"] = "REMAINING", 
			["spark"] = true, 
			["useCustomColor"] = false, 
			["castingColor"] = {0.8, 0.8, 0}, 
			["sparkColor"] = {1, 0.72, 0}, 
		}, 
		["pvp"] = 
		{
			["enable"] = true,
			["trinketPosition"] = "LEFT",
			["trinketSize"] = 45,
			["trinketX"] = -2, 
			["trinketY"] = 0,
			["specPosition"] = "RIGHT",
			["specSize"] = 45,
			["specX"] = 2, 
			["specY"] = 0,
		}, 
	}, 
	["party"] = {
		["enable"] = true, 
		["rangeCheck"] = true, 
		["threatEnabled"] = true, 
		["visibility"] = "[group:raid][nogroup] hide;show", 
		["showBy"] = "UP_RIGHT", 
		["wrapXOffset"] = 9, 
		["wrapYOffset"] = 24,
		["allowedGroup"] = {
			[1] = true, 
		},
		["gRowCol"] = 1,
		["sortMethod"] = "GROUP", 
		["sortDir"] = "ASC",
		["invertGroupingOrder"] = false, 
		["showPlayer"] = true, 
		["predict"] = false,
		["width"] = 115, 
		["height"] = 30,
		["grid"] = {
			["enable"] = false,
			["size"] = 45,
			["fontsize"] = 12,
			["iconSize"] = 12,
			["powerEnable"] = false
		}, 
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 10, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "BOTTOM", 
			["orientation"] = "HORIZONTAL", 
			["frequentUpdates"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = false, 
			["tags"] = "", 
			["frequentUpdates"] = false, 
			["height"] = 7, 
			["position"] = "BOTTOMRIGHT", 
			["hideonnpc"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "BOTTOMLEFT", 
			["tags"] = "[name:color][name:10]", 
			["yOffset"] = -2, 
			["xOffset"] = 0, 
			["font"] = SV.DialogFontDefault, 
			["fontSize"] = 10, 
			["fontOutline"] = "NONE", 
		}, 
		["buffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 2, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHTTOP", 
			["verticalGrowth"] = "DOWN", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true, 
			["filterAll"] = false, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = true, 
			["perrow"] = 2, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHTTOP", 
			["verticalGrowth"] = "DOWN", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["auraWatch"] = 
		{
			["enable"] = true, 
			["size"] = 8, 
			["fontSize"] = 11, 
		}, 
		["petsGroup"] = 
		{
			["enable"] = false, 
			["width"] = 30, 
			["height"] = 30,
			["gridAllowed"] = true,
			["anchorPoint"] = "BOTTOMLEFT", 
			["xOffset"] =  - 1, 
			["yOffset"] = 0, 
			["name_length"] = 3, 
			["tags"] = "[name:3]", 
		}, 
		["targetsGroup"] = 
		{
			["enable"] = false, 
			["width"] = 30, 
			["height"] = 30,
			["gridAllowed"] = true,
			["anchorPoint"] = "TOPLEFT", 
			["xOffset"] =  - 1, 
			["yOffset"] = 0, 
			["name_length"] = 3, 
			["tags"] = "[name:3]", 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 25, 
				["attachTo"] = "INNERBOTTOMLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
			["roleIcon"] = 
			{
				["enable"] = true, 
				["size"] = 15, 
				["attachTo"] = "BOTTOMRIGHT", 
				["xOffset"] = 0, 
				["yOffset"] = -2, 
			}, 
			["raidRoleIcons"] = 
			{
				["enable"] = true, 
				["size"] = 25, 
				["attachTo"] = "TOPLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = -4, 
			}, 
		}, 
		["portrait"] = 
		{
			["enable"] = true, 
			["width"] = 45, 
			["overlay"] = true, 
			["rotation"] = 0, 
			["camDistanceScale"] = 1, 
			["style"] = "3DOVERLAY", 
		}, 
	},
	["raid"] = {
		["enable"] = true,
		["rangeCheck"] = true, 
		["threatEnabled"] = true, 
		["visibility"] = "[group:raid] show;hide",
		["showBy"] = "RIGHT_DOWN", 
		["wrapXOffset"] = 8, 
		["wrapYOffset"] = 8,
		["showGroupNumber"] = false,
		["allowedGroup"] = {
			[1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true,
		},
		["gRowCol"] = 1,
		["sortMethod"] = "GROUP", 
		["sortDir"] = "ASC", 
		["showPlayer"] = true, 
		["predict"] = false,
		["width"] = 50, 
		["height"] = 30,
		["grid"] = {
			["enable"] = false,
			["size"] = 30,
			["fontsize"] = 12,
			["iconSize"] = 12,
			["powerEnable"] = false
		},
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "none", 
			["name_colored"] = true, 
			["name_length"] = 4, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{ 
			["tags"] = "", 
			["position"] = "BOTTOM", 
			["orientation"] = "HORIZONTAL", 
			["frequentUpdates"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["power"] = 
		{
			["enable"] = false, 
			["tags"] = "", 
			["frequentUpdates"] = false, 
			["height"] = 4, 
			["position"] = "BOTTOMRIGHT", 
			["hideonnpc"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0,
			["fontSize"] = 10,
			["classColor"] = false,
		}, 
		["name"] = 
		{
			["position"] = "INNERTOPLEFT", 
			["tags"] = "[name:color][name:4]", 
			["yOffset"] = 0, 
			["xOffset"] = 8, 
			["font"] = "SVUI Default Font", 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["buffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true, 
			["filterAll"] = false, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["rdebuffs"] = 
		{
			["enable"] = true, 
			["size"] = 22, 
			["xOffset"] = 0, 
			["yOffset"] = 2, 
		}, 
		["auraWatch"] = 
		{
			["enable"] = true, 
			["size"] = 8, 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 15, 
				["attachTo"] = "INNERBOTTOMRIGHT", 
				["xOffset"] = -8, 
				["yOffset"] = 0, 
			}, 
			["roleIcon"] = 
			{
				["enable"] = true, 
				["size"] = 12, 
				["attachTo"] = "INNERBOTTOMLEFT", 
				["xOffset"] = 8, 
				["yOffset"] = 0, 
			}, 
			["raidRoleIcons"] = 
			{
				["enable"] = true, 
				["size"] = 18, 
				["attachTo"] = "TOPLEFT", 
				["xOffset"] = 8, 
				["yOffset"] = -4, 
			}, 
		},
	}, 
	["raidpet"] = {
		["enable"] = false,
		["rangeCheck"] = true, 
		["threatEnabled"] = true, 
		["visibility"] = "[group:raid] show;hide", 
		["showBy"] = "DOWN_RIGHT", 
		["wrapXOffset"] = 3, 
		["wrapYOffset"] = 3,
		["allowedGroup"] = {
			[1] = true, [2] = true,
		},
		["gRowCol"] = 1,
		["sortMethod"] = "PETNAME", 
		["sortDir"] = "ASC",  
		["invertGroupingOrder"] = false, 
		["predict"] = false,
		["width"] = 80, 
		["height"] = 30,
		["grid"] = {
			["enable"] = false,
			["size"] = 30,
			["fontsize"] = 12,
			["iconSize"] = 12,
			["powerEnable"] = false
		},
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "deficit", 
			["name_colored"] = true, 
			["name_length"] = 4, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:deficit]", 
			["position"] = "INNERBOTTOMRIGHT", 
			["orientation"] = "HORIZONTAL", 
			["frequentUpdates"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["name"] = 
		{
			["position"] = "INNERTOPLEFT", 
			["tags"] = "[name:color][name:4]", 
			["yOffset"] = 4, 
			["xOffset"] = -4, 
			["font"] = "SVUI Default Font", 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["buffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = true, 
			["filterRaid"] = true,
			["filterAll"] = false, 
			["filterInfinite"] = true, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["debuffs"] = 
		{
			["enable"] = false, 
			["perrow"] = 3, 
			["numrows"] = 1, 
			["attachTo"] = "FRAME", 
			["anchorPoint"] = "RIGHT", 
			["verticalGrowth"] = "UP", 
			["horizontalGrowth"] = "RIGHT", 
			["filterWhiteList"] = false,
			["filterPlayer"] = false, 
			["filterAll"] = false, 
			["filterInfinite"] = false, 
			["filterDispellable"] = false, 
			["useFilter"] = "", 
			["xOffset"] = 8, 
			["yOffset"] = 0, 
			["sizeOverride"] = 0, 
		}, 
		["auraWatch"] = 
		{
			["enable"] = true, 
			["size"] = 8, 
		}, 
		["rdebuffs"] = 
		{
			["enable"] = true, 
			["size"] = 26, 
			["xOffset"] = 0, 
			["yOffset"] = 2, 
		}, 
		["icons"] = 
		{
			["raidicon"] = 
			{
				["enable"] = true, 
				["size"] = 18, 
				["attachTo"] = "INNERTOPLEFT", 
				["xOffset"] = 0, 
				["yOffset"] = 0, 
			}, 
		}, 
	}, 
	["tank"] = {
		["enable"] = true, 
		["threatEnabled"] = true,
		["visibility"] = "[group:raid] show;hide",
		["rangeCheck"] = true, 
		["width"] = 120, 
		["height"] = 28,
		["grid"] = {
			["enable"] = false,
			["size"] = 45,
			["fontsize"] = 12,
			["iconSize"] = 12,
			["powerEnable"] = false
		},
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "deficit", 
			["name_colored"] = true, 
			["name_length"] = 8, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:deficit]", 
			["position"] = "INNERRIGHT", 
			["orientation"] = "HORIZONTAL", 
			["frequentUpdates"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["name"] = 
		{
			["position"] = "INNERLEFT", 
			["tags"] = "[name:color][name:8]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = "SVUI Default Font", 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["targetsGroup"] = 
		{
			["enable"] = false, 
			["anchorPoint"] = "RIGHT", 
			["xOffset"] = 1, 
			["yOffset"] = 0, 
			["width"] = 120, 
			["height"] = 28, 
		}, 
	}, 
	["assist"] = {
		["enable"] = true, 
		["threatEnabled"] = true,
		["visibility"] = "[group:raid] show;hide",
		["rangeCheck"] = true, 
		["width"] = 120, 
		["height"] = 28,
		["grid"] = {
			["enable"] = false,
			["size"] = 45,
			["fontsize"] = 12,
			["iconSize"] = 12,
			["powerEnable"] = false
		},
		["formatting"] = {
			["power_colored"] = true, 
			["power_type"] = "none", 
			["power_class"] = false, 
			["power_alt"] = false, 
			["health_colored"] = true, 
			["health_type"] = "deficit", 
			["name_colored"] = true, 
			["name_length"] = 8, 
			["smartlevel"] = false, 
			["absorbs"] = false, 
			["threat"] = false, 
			["incoming"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
		}, 
		["misc"] = {
			["tags"] = ""
		}, 
		["health"] = 
		{
			["tags"] = "[health:color][health:deficit]", 
			["position"] = "INNERRIGHT", 
			["orientation"] = "HORIZONTAL", 
			["frequentUpdates"] = false, 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["reversed"] = false,
			["fontSize"] = 10,
			["classColor"] = true, 
			["valueColor"] = true, 
			["classBackdrop"] = false, 
		}, 
		["name"] = 
		{
			["position"] = "INNERLEFT", 
			["tags"] = "[name:color][name:8]", 
			["yOffset"] = 0, 
			["xOffset"] = 0, 
			["font"] = "SVUI Default Font", 
			["fontSize"] = 10, 
			["fontOutline"] = "OUTLINE", 
		}, 
		["targetsGroup"] = 
		{
			["enable"] = false, 
			["anchorPoint"] = "RIGHT", 
			["xOffset"] = 1, 
			["yOffset"] = 0, 
			["width"] = 120, 
			["height"] = 28, 
		}, 
	},
};