--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local select  = _G.select;
local unpack  = _G.unpack;
local pairs   = _G.pairs;
local ipairs  = _G.ipairs;
local type    = _G.type;
local print   = _G.print;
local string  = _G.string;
local math    = _G.math;
local table   = _G.table;
local GetTime = _G.GetTime;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local floor, modf = math.floor, math.modf;
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry")
local L = SV.L
--[[ 
########################################################## 
DEFINE SOUND EFFECTS
##########################################################
]]--
local SOUND = SV.Sounds;

SOUND:Register("Buttons", [[sound\interface\uchatscrollbutton.ogg]])
SOUND:Register("Levers", [[sound\interface\ui_blizzardstore_buynow.ogg]])
SOUND:Register("Levers", [[sound\doodad\g_levermetalcustom0.ogg]])
SOUND:Register("Levers", [[sound\item\weapons\gun\gunload01.ogg]])
SOUND:Register("Levers", [[sound\item\weapons\gun\gunload02.ogg]])
SOUND:Register("Levers", [[sound\creature\gyrocopter\gyrocoptergearshift2.ogg]])
SOUND:Register("Gears", [[sound\creature\gyrocopter\gyrocoptergearshift3.ogg]])
SOUND:Register("Gears", [[sound\doodad\g_buttonbigredcustom0.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electricitysparkmedium_02.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps01.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps02.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps03.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps04.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps05.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_01.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_02.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_03.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_04.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_05.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_06.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_07.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_08.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_01.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_02.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_03.ogg]])
SOUND:Register("Phase", [[sound\doodad\be_scryingorb_explode.ogg]])
--[[ 
########################################################## 
DEFINE SHARED MEDIA
##########################################################
]]--
local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("background", "SVUI Default BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]])
LSM:Register("background", "SVUI Transparent BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\TRANSPARENT]])
LSM:Register("background", "SVUI Button BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]])
LSM:Register("background", "SVUI Backdrop 1", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN1]])
LSM:Register("background", "SVUI Backdrop 2", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN2]])
LSM:Register("background", "SVUI Backdrop 3", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN3]])
LSM:Register("background", "SVUI Backdrop 4", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN4]])
LSM:Register("background", "SVUI Backdrop 5", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN5]])
LSM:Register("background", "SVUI Artwork 1", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART1]])
LSM:Register("background", "SVUI Artwork 2", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART2]])
LSM:Register("background", "SVUI Artwork 3", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART3]])
LSM:Register("background", "SVUI Artwork 4", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART4]])
LSM:Register("background", "SVUI Artwork 5", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART5]])
LSM:Register("background", "SVUI UnitBG 1", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG1]])
LSM:Register("background", "SVUI UnitBG 2", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG2]])
LSM:Register("background", "SVUI UnitBG 3", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG3]])
LSM:Register("background", "SVUI UnitBG 4", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG4]])
LSM:Register("background", "SVUI SmallUnitBG 1", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG1]])
LSM:Register("background", "SVUI SmallUnitBG 2", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG2]])
LSM:Register("background", "SVUI SmallUnitBG 3", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG3]])
LSM:Register("background", "SVUI SmallUnitBG 4", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG4]])

LSM:Register("border", "SVUI Border", [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]])
LSM:Register("border", "SVUI Border 2", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "SVUI Textured Border", [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]])
LSM:Register("border", "SVUI Inset Shadow", [[Interface\AddOns\SVUI_!Core\assets\borders\INSET]])
LSM:Register("border", "SVUI Shadow Border", [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]])

LSM:Register("statusbar", "SVUI BasicBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\DEFAULT]])
LSM:Register("statusbar", "SVUI MultiColorBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]])
LSM:Register("statusbar", "SVUI SmoothBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\SMOOTH]])
LSM:Register("statusbar", "SVUI PlainBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\FLAT]])
LSM:Register("statusbar", "SVUI FancyBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\TEXTURED]])
LSM:Register("statusbar", "SVUI GlossBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOSS]])
LSM:Register("statusbar", "SVUI GlowBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOWING]])
LSM:Register("statusbar", "SVUI LazerBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\LAZER]])

LSM:Register("sound", "Whisper Alert", [[Interface\AddOns\SVUI_!Core\assets\sounds\whisper.mp3]])
LSM:Register("sound", "Toasty", [[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])

LSM:Register("font", "SVUI Default Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Pixel Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Pixel.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Caps Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Caps.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Classic Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Classic.ttf]])
LSM:Register("font", "SVUI Combat Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Combat.ttf]])
LSM:Register("font", "SVUI Dialog Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Dialog.ttf]])
LSM:Register("font", "SVUI Number Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]])
LSM:Register("font", "SVUI Zone Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Zone.ttf]])
LSM:Register("font", "SVUI Flash Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Flash.ttf]])
LSM:Register("font", "SVUI Alert Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Alert.ttf]])
LSM:Register("font", "SVUI Narrator Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Narrative.ttf]])
--[[ 
########################################################## 
CREATE AND POPULATE MEDIA DATA
##########################################################
]]--
do
	local myclass = select(2,UnitClass("player"))
	local cColor1 = CUSTOM_CLASS_COLORS[myclass]
	local cColor2 = RAID_CLASS_COLORS[myclass]
	local r1,g1,b1 = cColor1.r,cColor1.g,cColor1.b
	local r2,g2,b2 = cColor2.r*.25, cColor2.g*.25, cColor2.b*.25
	local ir1,ig1,ib1 = (1 - r1), (1 - g1), (1 - b1)
	local ir2,ig2,ib2 = (1 - cColor2.r)*.25, (1 - cColor2.g)*.25, (1 - cColor2.b)*.25
	
	SV.mediadefaults["shared"] = {
		["font"] = {
			["default"]     = {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"},
			["dialog"]      = {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"},
			["title"]       = {file = "SVUI Default Font",  size = 16,  outline = "OUTLINE"}, 
			["number"]      = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
			["number_big"]  = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"},
			["header"]      = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"},  
			["combat"]      = {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}, 
			["alert"]       = {file = "SVUI Alert Font",    size = 20,  outline = "OUTLINE"},
			["flash"]      	= {file = "SVUI Flash Font",    size = 18,  outline = "OUTLINE"},
			["zone"]      	= {file = "SVUI Zone Font",     size = 16,  outline = "OUTLINE"},
			["caps"]      	= {file = "SVUI Caps Font",     size = 12,  outline = "OUTLINE"},
			["aura"]      	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"},
			["data"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
			["narrator"]    = {file = "SVUI Narrator Font", size = 12,  outline = "OUTLINE"},
			["lootdialog"]  = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"},
			["lootnumber"]  = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
			["rolldialog"]  = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"},
			["rollnumber"]  = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
			["tipdialog"]   = {file = "SVUI Default Font",  size = 12,  outline = "NONE"},
			["tipheader"]   = {file = "SVUI Default Font",  size = 14,  outline = "NONE"},
			["pixel"]       = {file = "SVUI Pixel Font",    size = 8,   outline = "MONOCHROMEOUTLINE"},
		},
		["statusbar"] = {
			["default"]   	= {file = "SVUI BasicBar",  	offset = 0}, 
			["gradient"]  	= {file = "SVUI MultiColorBar", offset = 0},
			["smooth"]    	= {file = "SVUI SmoothBar",  	offset = 0},
			["flat"]      	= {file = "SVUI PlainBar",  	offset = 0},
			["textured"]  	= {file = "SVUI FancyBar",  	offset = 0},
			["gloss"]     	= {file = "SVUI GlossBar",  	offset = 0},
			["glow"]      	= {file = "SVUI GlowBar",  		offset = 2},
			["lazer"]     	= {file = "SVUI LazerBar",  	offset = 10},
		},
		["background"] = {
			["default"]     = {file = "SVUI Default BG",  		size = 0, tiled = false}, 
			["transparent"] = {file = "SVUI Transparent BG",	size = 0, tiled = false}, 
			["button"]      = {file = "SVUI Button BG",  		size = 0, tiled = false}, 
			["pattern"]     = {file = "SVUI Backdrop 1",  		size = 0, tiled = false},  
			["premium"]     = {file = "SVUI Artwork 1",  		size = 0, tiled = false},
			["unitlarge"]   = {file = "SVUI UnitBG 1",  		size = 0, tiled = false},
			["unitsmall"]   = {file = "SVUI SmallUnitBG 1",  	size = 0, tiled = false},
		},
		["border"] = {
			["default"] 	= {file = "SVUI Border", 		  	size = 1},
			["transparent"] = {file = "SVUI Border", 			size = 1},
			["button"]      = {file = "SVUI Textured Border", 	size = 15},
			["pattern"]     = {file = "SVUI Textured Border", 	size = 15},
			["premium"]     = {file = "SVUI Textured Border", 	size = 15},
			["shadow"]      = {file = "SVUI Shadow Border",   	size = 3},
			["inset"]       = {file = "SVUI Inset Shadow",   	size = 6},
			["unitlarge"]   = {file = "SVUI Border 2",  		size = 0},
			["unitsmall"]   = {file = "SVUI Border 2",  		size = 0},
		},
	}

	SV.mediadefaults["font"] = {
		["default"]   	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],
		["dialog"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],
		["number"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]],
		["combat"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Combat.ttf]],
		["zone"]      	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Zone.ttf]],
		["alert"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Alert.ttf]],
		["caps"]      	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Caps.ttf]],
		["narrator"]  	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Narrative.ttf]],
		["flash"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Flash.ttf]],
		["pixel"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Pixel.ttf]],
	}
	SV.mediadefaults["statusbar"] = { 
		["default"]   	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\DEFAULT]], 
		["gradient"]  	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]], 
		["smooth"]    	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\SMOOTH]], 
		["flat"]      	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\FLAT]], 
		["textured"]  	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\TEXTURED]], 
		["gloss"]     	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOSS]], 
		["glow"]      	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOWING]],
		["lazer"]     	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\LAZER]],
	}
	SV.mediadefaults["background"] = {
		["default"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]],
		["transparent"] = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\TRANSPARENT]],
		["button"]      = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]],
		["pattern"]     = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN1]],
		["premium"]     = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART1]],
		["unitlarge"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG1]],
		["unitsmall"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG1]],
	}
	SV.mediadefaults["border"] = {
		["default"] 	= [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
		["button"]      = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
		["pattern"]     = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
		["premium"]     = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
		["shadow"]      = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
		["inset"]       = [[Interface\AddOns\SVUI_!Core\assets\borders\INSET]],
		["unitlarge"] 	= [[Interface\BUTTONS\WHITE8X8]],
		["unitsmall"] 	= [[Interface\BUTTONS\WHITE8X8]],
	}
	SV.mediadefaults["color"] = {
		["default"]     = {0.2, 0.2, 0.2, 1}, 
		["special"]     = {.37, .32, .29, 1},
		["specialdark"] = {.23, .22, .21, 1},
		["unique"]      = {0.32, 0.258, 0.21, 1},
		["container"]   = {.28, .27, .26, 1},  
		["class"]       = {r1, g1, b1, 1},
		["bizzaro"]     = {ir1, ig1, ib1, 1},
		["medium"]      = {0.47, 0.47, 0.47},
		["dark"]        = {0.1, 0.1, 0.1, 1},
		["darkest"]     = {0, 0, 0, 1},
		["light"]       = {0.95, 0.95, 0.95, 1},
		["light2"]      = {0.65, 0.65, 0.65, 1},
		["lightgrey"]   = {0.32, 0.35, 0.38, 1},
		["highlight"]   = {0.28, 0.75, 1, 1},
		["checked"]     = {0.25, 0.9, 0.08, 1},
		["green"]       = {0.25, 0.9, 0.08, 1},
		["blue"]        = {0.08, 0.25, 0.82, 1},
		["tan"]         = {0.4, 0.32, 0.23, 1},
		["red"]         = {0.9, 0.08, 0.08, 1},
		["yellow"]      = {1, 1, 0, 1},
		["gold"]        = {1, 0.68, 0.1, 1},
		["transparent"] = {0, 0, 0, 0.5},
		["hinted"]      = {0, 0, 0, 0.35},
		["invisible"]   = {0, 0, 0, 0},
		["white"]       = {1, 1, 1, 1},
	}
	SV.mediadefaults["bordercolor"] = {
		["default"]     = {0, 0, 0, 1}, 
		["class"]       = {r1, g1, b1, 1},
		["checkbox"]    = {0.1, 0.1, 0.1, 1},
	}
	SV.mediadefaults["gradient"]  = {
		["default"]   = {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22}, 
		["special"]   = {"VERTICAL", 0.33, 0.25, 0.13, 0.47, 0.39, 0.27},
		["specialdark"] = {"VERTICAL", 0.23, 0.15, 0.03, 0.33, 0.25, 0.13},
		["container"] = {"VERTICAL", 0.12, 0.11, 0.1, 0.22, 0.21, 0.2},
		["class"]     = {"VERTICAL", r2, g2, b2, r1, g1, b1}, 
		["bizzaro"]   = {"VERTICAL", ir2, ig2, ib2, ir1, ig1, ib1},
		["medium"]    = {"VERTICAL", 0.22, 0.22, 0.22, 0.47, 0.47, 0.47},
		["dark"]      = {"VERTICAL", 0.02, 0.02, 0.02, 0.22, 0.22, 0.22},
		["darkest"]   = {"VERTICAL", 0.15, 0.15, 0.15, 0, 0, 0},
		["darkest2"]  = {"VERTICAL", 0, 0, 0, 0.12, 0.12, 0.12},
		["light"]     = {"VERTICAL", 0.65, 0.65, 0.65, 0.95, 0.95, 0.95},
		["light2"]    = {"VERTICAL", 0.95, 0.95, 0.95, 0.65, 0.65, 0.65},
		["highlight"] = {"VERTICAL", 0.3, 0.8, 1, 0.1, 0.9, 1},
		["checked"]   = {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08},
		["green"]     = {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08}, 
		["red"]       = {"VERTICAL", 0.5, 0, 0, 0.9, 0.08, 0.08}, 
		["yellow"]    = {"VERTICAL", 1, 0.3, 0, 1, 1, 0},
		["tan"]       = {"VERTICAL", 0.15, 0.08, 0, 0.37, 0.22, 0.1},
		["inverse"]   = {"VERTICAL", 0.25, 0.25, 0.25, 0.12, 0.12, 0.12},
		["icon"]      = {"VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1},
		["white"]     = {"VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1},
	}
	SV.mediadefaults["button"] = {
		["check"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK]],
		["checkbg"]     = [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK-BG]],
		["uncheck"]     = [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK-DISABLED]],
		["round"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\ ROUND-BORDER]],
		["scrollup"]    = [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-UP]],
		["scrolldown"]  = [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-DOWN]],
		["knob"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-KNOB]],
		["option"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\SETUP-OPTION]],
		["arrow"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\SETUP-ARROW]],
		["radio"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\RADIO]],
	}
	SV.mediadefaults["icon"] = {
		["default"]     = [[Interface\AddOns\SVUI_!Core\assets\icons\SVUI]],
		["theme"]       = [[Interface\AddOns\SVUI_!Core\assets\icons\THEME]],
		["vs"]          = [[Interface\AddOns\SVUI_!Core\assets\icons\VS]],
		["close"]       = [[Interface\AddOns\SVUI_!Core\assets\icons\CLOSE]],
		["star"]        = [[Interface\AddOns\SVUI_!Core\assets\icons\FAVORITE-STAR]],
		["move_up"]     = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-UP]],
		["move_down"]   = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-DOWN]],
		["move_left"]   = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-LEFT]], 
		["move_right"]  = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-RIGHT]],
		["exitIcon"] 	= [[Interface\AddOns\SVUI_!Core\assets\icons\EXIT]]
	}
	SV.mediadefaults["dock"] = {
		["durabilityLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-DUR]],
		["reputationLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-REP]],
		["experienceLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-XP]],
		["breakStuffIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-BREAKSTUFF]],
		["hearthIcon"] 			= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-HEARTH]],
		["raidToolIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-RAIDTOOL]],
		["garrisonToolIcon"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-GARRISON]],
		["professionIconFile"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\PROFESSIONS]],
		["professionIconCoords"]= {
			[171] 	= {0,0.25,0,0.25}, 				-- PRO-ALCHEMY
		    [794] 	= {0.25,0.5,0,0.25,80451}, 		-- PRO-ARCHAELOGY
		    [164] 	= {0.5,0.75,0,0.25}, 			-- PRO-BLACKSMITH
		    [185] 	= {0.75,1,0,0.25,818,67097}, 	-- PRO-COOKING
		    [333] 	= {0,0.25,0.25,0.5,13262}, 		-- PRO-ENCHANTING
		    [202] 	= {0.25,0.5,0.25,0.5}, 			-- PRO-ENGINEERING
		    [129] 	= {0.5,0.75,0.25,0.5}, 			-- PRO-FIRSTAID
		    [773] 	= {0,0.25,0.5,0.75,51005}, 		-- PRO-INSCRIPTION
		    [755] 	= {0.25,0.5,0.5,0.75,31252},	-- PRO-JEWELCRAFTING
		    [165] 	= {0.5,0.75,0.5,0.75}, 			-- PRO-LEATHERWORKING
		    [186] 	= {0.75,1,0.5,0.75}, 			-- PRO-MINING
		    [197] 	= {0.25,0.5,0.75,1}, 			-- PRO-TAILORING
		},
		["sparks"] = {
			[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-1]],
			[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-2]],
			[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-3]],
		},
	}
	SV.mediadefaults["backdrop"] = {
		["default"] = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
		    edgeSize = 1,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["button"] = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
		    edgeSize = 1,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["pattern"] = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN1]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
		    edgeSize = 15,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["premium"] = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART1]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
		    edgeSize = 15,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["aura"] = {
			bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
		    edgeSize = 1,
		    insets = 
		    {
		        left = 1, 
		        right = 1, 
		        top = 1, 
		        bottom = 1, 
		    },
		},
		["glow"] = {
			bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
		    edgeSize = 3,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["tooltip"] = {
			bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
		    edgeSize = 1,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		["outline"] = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
		    edgeSize = 1,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
	}
end

local function tablesplice(mergeTable, targetTable)
    if type(targetTable) ~= "table" then targetTable = {} end

    if type(mergeTable) == 'table' then 
        for key,val in pairs(mergeTable) do 
            if type(val) == "table" then 
                targetTable[key] = tablesplice(val, targetTable[key])
            else
                targetTable[key] = val
            end  
        end 
    end 
    return targetTable 
end

SV.media = tablesplice(SV.mediadefaults, {});
--[[ 
########################################################## 
LOCALIZED GLOBALS
##########################################################
]]--
local NAMEPLATE_FONT      = _G.NAMEPLATE_FONT
local CHAT_FONT_HEIGHTS   = _G.CHAT_FONT_HEIGHTS
local STANDARD_TEXT_FONT  = _G.STANDARD_TEXT_FONT
local UNIT_NAME_FONT      = _G.UNIT_NAME_FONT
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS   = _G.RAID_CLASS_COLORS
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT  = _G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
--[[ 
########################################################## 
FORCIBLY CHANGE THE GAME WORLD COMBAT TEXT FONT
##########################################################
]]--
local SVUI_DAMAGE_FONT = "Interface\\AddOns\\SVUI_!Core\\assets\\fonts\\!DAMAGE.ttf";
local SVUI_DAMAGE_FONTSIZE = 32;

local function ForceDamageFont()
	_G.DAMAGE_TEXT_FONT = SVUI_DAMAGE_FONT
	_G.COMBAT_TEXT_CRIT_SCALE_TIME = 0.7;
	_G.COMBAT_TEXT_SPACING = 15;
end

ForceDamageFont();
--[[ 
########################################################## 
SOME CORE VARS
##########################################################
]]--
SV.DialogFontDefault = "SVUI Dialog Font";
if(GetLocale() ~= "enUS") then
	SV.DialogFontDefault = "SVUI Default Font";
end
SV.SplashImage 	= [[Interface\AddOns\SVUI_!Core\assets\textures\SPLASH]];
SV.BaseTexture 	= [[Interface\AddOns\SVUI_!Core\backgrounds\DEFAULT]];
SV.NoTexture 	= [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]];
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function SV:ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select('#', ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end
	local num = select('#', ...) / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

function SV:HexColor(arg1,arg2,arg3)
	local r,g,b;
	if arg1 and type(arg1) == "string" then
		local t
		if(self.media and self.media.shared) then
			t = self.media.color[arg1] or self.media.unitframes[arg1]
		end
		if t then
			r,g,b = t[1],t[2],t[3]
		else
			r,g,b = 0,0,0
		end
	else
		r = type(arg1) == "number" and arg1 or 0;
		g = type(arg2) == "number" and arg2 or 0;
		b = type(arg3) == "number" and arg3 or 0;
	end
	r = (r < 0 or r > 1) and 0 or (r * 255)
	g = (g < 0 or g > 1) and 0 or (g * 255)
	b = (b < 0 or b > 1) and 0 or (b * 255)
	local hexString = ("%02x%02x%02x"):format(r,g,b)
	return hexString
end
--[[ 
########################################################## 
ALTERING GLOBAL FONTS
##########################################################
]]--
local function UpdateChatFontSizes()
	_G.CHAT_FONT_HEIGHTS[1] = 8
	_G.CHAT_FONT_HEIGHTS[2] = 9
	_G.CHAT_FONT_HEIGHTS[3] = 10
	_G.CHAT_FONT_HEIGHTS[4] = 11
	_G.CHAT_FONT_HEIGHTS[5] = 12
	_G.CHAT_FONT_HEIGHTS[6] = 13
	_G.CHAT_FONT_HEIGHTS[7] = 14
	_G.CHAT_FONT_HEIGHTS[8] = 15
	_G.CHAT_FONT_HEIGHTS[9] = 16
	_G.CHAT_FONT_HEIGHTS[10] = 17
	_G.CHAT_FONT_HEIGHTS[11] = 18
	_G.CHAT_FONT_HEIGHTS[12] = 19
	_G.CHAT_FONT_HEIGHTS[13] = 20
end

hooksecurefunc("FCF_ResetChatWindows", UpdateChatFontSizes)

local function ChangeGlobalFonts()
	local fontsize = SV.media.shared.font.default.size;
	STANDARD_TEXT_FONT = LSM:Fetch("font", SV.media.shared.font.default.file);
	UNIT_NAME_FONT = LSM:Fetch("font", SV.media.shared.font.caps.file);
	NAMEPLATE_FONT = STANDARD_TEXT_FONT
	UpdateChatFontSizes()
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = fontsize
end
--[[ 
########################################################## 
FONT TEMPLATING METHODS
##########################################################
]]--
local ManagedFonts = {};
SV.GlobalFontList = {
	["SVUI_Font_Default"] = "default",
	["SVUI_Font_Aura"] = "aura",
	["SVUI_Font_Number"] = "number",
	["SVUI_Font_Number_Huge"] = "number_big",
	["SVUI_Font_Header"] = "header",
	["SVUI_Font_Data"] = "data",
	["SVUI_Font_Caps"] = "caps",
	["SVUI_Font_Narrator"] = "narrator",
	["SVUI_Font_Pixel"] = "pixel",
	["SVUI_Font_Roll"] = "rolldialog",
	["SVUI_Font_Roll_Number"] = "rollnumber",
	["SVUI_Font_Loot"] = "lootdialog",
	["SVUI_Font_Loot_Number"] = "lootnumber",
};

function SV:FontManager(obj, template, arg, sizeMod, styleOverride, colorR, colorG, colorB)
	if not obj then return end
	template = template or "default";
	local info = SV.media.shared.font[template];
	if(not info) then return end

	local isSystemFont = false;
	if(arg and (arg == 'SYSTEM')) then
		isSystemFont = true;
	end

	local file = SV.media.font[template];
	local size = info.size;
	local outline = info.outline;

	if(styleOverride) then
		obj.___fontOutline = styleOverride;
		outline = styleOverride;
	end

	obj.___fontSizeMod = sizeMod or 0;
	obj:SetFont(file, (size + obj.___fontSizeMod), outline)

	if(not isSystemFont) then
		if(info.outline and info.outline ~= "NONE") then 
			obj:SetShadowColor(0, 0, 0, 0)
		else 
			obj:SetShadowColor(0, 0, 0, 0.2)
		end 
		obj:SetShadowOffset(1, -1)
		obj:SetJustifyH(arg or "CENTER")
		obj:SetJustifyV("MIDDLE")
	end

	if(colorR and colorG and colorB) then
		obj:SetTextColor(colorR, colorG, colorB);
	end

	if(not ManagedFonts[template]) then
		ManagedFonts[template] = {}
	end

	ManagedFonts[template][obj] = true
end

local function _alterFont(globalName, template, sizeMod, styleOverride, cR, cG, cB)
	if(not template) then return end
	if(not _G[globalName]) then return end
	styleOverride = styleOverride or "NONE"
	SV:FontManager(_G[globalName], template, "SYSTEM", sizeMod, styleOverride, cR, cG, cB);
end

local function ChangeSystemFonts()
	--_alterFont("GameFontNormal", "default", fontsize - 2)
	_alterFont("GameFontWhite", "default", 0, 'OUTLINE', 1, 1, 1)
	_alterFont("GameFontWhiteSmall", "default", 0, 'NONE', 1, 1, 1)
	_alterFont("GameFontBlack", "default", 0, 'NONE', 0, 0, 0)
	_alterFont("GameFontBlackSmall", "default", -1, 'NONE', 0, 0, 0)
	_alterFont("GameFontNormalMed2", "default", 2)
	--_alterFont("GameFontNormalMed1", "default", 0)
	_alterFont("GameFontNormalLarge", "default")
	_alterFont("GameFontNormalLargeOutline", "default")
	_alterFont("GameFontHighlightSmall", "default")
	_alterFont("GameFontHighlight", "default", 1)
	_alterFont("GameFontHighlightLeft", "default", 1)
	_alterFont("GameFontHighlightRight", "default", 1)
	_alterFont("GameFontHighlightLarge2", "default", 2)
	_alterFont("SystemFont_Med1", "default")
	_alterFont("SystemFont_Med3", "default")
	_alterFont("SystemFont_Outline_Small", "default", 0, "OUTLINE")
	_alterFont("FriendsFont_Normal", "default")
	_alterFont("FriendsFont_Small", "default")
	_alterFont("FriendsFont_Large", "default", 3)
	_alterFont("FriendsFont_UserText", "default", -1)
	_alterFont("SystemFont_Small", "default", -1)
	_alterFont("GameFontNormalSmall", "default", -1)
	_alterFont("NumberFont_Shadow_Med", "default", -1, "OUTLINE")
	_alterFont("NumberFont_Shadow_Small", "default", -1, "OUTLINE")
	_alterFont("SystemFont_Tiny", "default", -1)
	_alterFont("SystemFont_Shadow_Med1", "default")
	_alterFont("SystemFont_Shadow_Med1_Outline", "default")
	_alterFont("SystemFont_Shadow_Med2", "default")
	_alterFont("SystemFont_Shadow_Med3", "default")
	_alterFont("SystemFont_Large", "default")
	_alterFont("SystemFont_Huge1", "default", 4)
	_alterFont("SystemFont_Huge1_Outline", "default", 4)
	_alterFont("SystemFont_Shadow_Small", "default")
	_alterFont("SystemFont_Shadow_Large", "default", 3)
	_alterFont("QuestFont", "dialog");
	_alterFont("QuestFont_Enormous", "zone", 15, "OUTLINE");
	_alterFont("SpellFont_Small", "dialog", 0, "OUTLINE", 1, 1, 1);
	_alterFont("SystemFont_Shadow_Outline_Large", "title", 0, "OUTLINE");
	_alterFont("SystemFont_Shadow_Outline_Huge2", "title", 8, "OUTLINE");
	_alterFont("GameFont_Gigantic", "alert", 0, "OUTLINE", 32)
	_alterFont("SystemFont_Shadow_Huge1", "alert", 0, "OUTLINE")
	--_alterFont("SystemFont_OutlineThick_Huge2", "alert", 0, "THICKOUTLINE")
	_alterFont("SystemFont_OutlineThick_Huge4", "zone", 6, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF", "zone", 9, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF2", "zone", 15, "OUTLINE");
	_alterFont("QuestFont_Large", "zone", -3);
	_alterFont("QuestFont_Huge", "zone", -2);
	_alterFont("QuestFont_Super_Huge", "zone");
	_alterFont("SystemFont_OutlineThick_Huge2", "zone", 2, "OUTLINE");
	_alterFont("Game18Font", "number", 1)
	_alterFont("Game24Font", "number", 3)
	_alterFont("Game27Font", "number", 5)
	_alterFont("Game30Font", "number_big")
	_alterFont("Game32Font", "number_big", 1)
	_alterFont("NumberFont_OutlineThick_Mono_Small", "number", 0, "OUTLINE")
	_alterFont("NumberFont_Outline_Huge", "number_big", 0, "OUTLINE")
	_alterFont("NumberFont_Outline_Large", "number", 3, "OUTLINE")
	_alterFont("NumberFont_Outline_Med", "number", 1, "OUTLINE")
	_alterFont("NumberFontNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFont_GameNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRight", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightRed", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightYellow", "number", 0, "OUTLINE")
	_alterFont("GameTooltipHeader", "tipheader")
	_alterFont("Tooltip_Med", "tipdialog")
	_alterFont("Tooltip_Small", "tipdialog", -1)
	_alterFont("SystemFont_Shadow_Huge3", "combat", 0, "OUTLINE")
	_alterFont("CombatTextFont", "combat", 64, "OUTLINE")
end

local function _defineFont(globalName, template)
	if(not template) then return end
	if(not _G[globalName]) then return end
	SV:FontManager(_G[globalName], template);
end

local function UpdateFontTemplate(template)
	template = template or "default";
	local info = SV.media.shared.font[template];
	local file = LSM:Fetch("font", info.file);
	local size = info.size;
	local line = info.outline;
	local list = ManagedFonts[template];
	if(not list) then return end
	for object in pairs(list) do
		if object then
			if(object.___fontOutline) then
				object:SetFont(file, (size + object.___fontSizeMod), object.___fontOutline);
			else
				object:SetFont(file, (size + object.___fontSizeMod), line);
			end
		else
			ManagedFonts[template][object] = nil;
		end
	end
end

local function UpdateAllFontTemplates()
	for template, _ in pairs(ManagedFonts) do
		UpdateFontTemplate(template)
	end
	ChangeGlobalFonts();
end

local function UpdateFontGroup(...)
	for i = 1, select('#', ...) do
		local template = select(i, ...)
		if not template then break end
		UpdateFontTemplate(template)
	end
end

SV.Events:On("ALL_FONTS_UPDATED", UpdateAllFontTemplates, "UpdateAllFontTemplates");
SV.Events:On("FONT_GROUP_UPDATED", UpdateFontGroup, "UpdateFontGroup");
--[[ 
########################################################## 
MEDIA UPDATES
##########################################################
]]--
function SV:UpdateSharedMedia()
	local settings = self.media.shared
	for mediaType, mediaData in pairs(settings) do
		if(self.media[mediaType]) then
			for name,userSettings in pairs(mediaData) do
				if(userSettings.file) then
					self.media[mediaType][name] = LSM:Fetch(mediaType, userSettings.file)
				end
			end
		end
	end

	for name, bd in pairs(self.media.backdrop) do
		if(self.media.background[name] and self.media.border[name]) then
			local bordersetup = self.media.shared.border[name];
			local bgsetup = self.media.shared.background[name];
			bd.bgFile = self.media.background[name]; 
		    bd.tile = bgsetup.tiled;
		    bd.tileSize = bgsetup.size;
			bd.edgeFile = self.media.border[name];
			bd.edgeSize = bordersetup.size;
		end
	end

	local cColor1 = self.media.color.special
	local cColor2 = self.media.color.default
	local r1,g1,b1 = cColor1[1], cColor1[2], cColor1[3]
	local r2,g2,b2 = cColor2[1], cColor2[2], cColor2[3]
	self.media.gradient.special = {"VERTICAL",r1,g1,b1,r2,g2,b2}

	self.Events:Trigger("SHARED_MEDIA_UPDATED");
end

function SV:RegisterFonts()
	for globalName, id in pairs(self.GlobalFontList) do
		local obj = _G[globalName];
		if(obj) then
			self:FontManager(obj, id);
		end
	end

	self.Events:Trigger("ALL_FONTS_UPDATED");
end

function SV:RefreshAllMedia()
	self:UpdateSharedMedia();
	ChangeGlobalFonts();
	ChangeSystemFonts();
	self:RegisterFonts();
	self.MediaInitialized = true;
end