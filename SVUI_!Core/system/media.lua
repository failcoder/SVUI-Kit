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

local DIALOGUE_FONTNAME = "SVUI Dialog Font";
if(GetLocale() ~= "enUS") then
	DIALOGUE_FONTNAME = "SVUI Default Font"
end
SV.DialogFontDefault = DIALOGUE_FONTNAME;
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

LSM:Register("background", "SVUI Backdrop", [[Interface\DialogFrame\UI-DialogBox-Background]])
LSM:Register("background", "SVUI Artwork", [[Interface\FrameGeneral\UI-Background-Rock]])
LSM:Register("border", "SVUI BasicBorder", [[Interface\Glues\COMMON\TextPanel-Border]])
LSM:Register("border", "SVUI FancyBorder", [[Interface\DialogFrame\UI-DialogBox-Border]])
LSM:Register("border", "SVUI ShadowBorder", [[Interface\AddOns\SVUI_!Core\assets\textures\GLOW]])
LSM:Register("statusbar", "SVUI BasicBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\DEFAULT]])
LSM:Register("statusbar", "SVUI MultiColorBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\GRADIENT]])
LSM:Register("statusbar", "SVUI SmoothBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\SMOOTH]])
LSM:Register("statusbar", "SVUI PlainBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\FLAT]])
LSM:Register("statusbar", "SVUI FancyBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\TEXTURED]])
LSM:Register("statusbar", "SVUI GlossBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\GLOSS]])
LSM:Register("statusbar", "SVUI GlowBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\GLOWING]])
LSM:Register("statusbar", "SVUI LazerBar", [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\LAZER]])
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
SV.BaseTexture = [[Interface\AddOns\SVUI_!Core\assets\textures\DEFAULT]];
SV.NoTexture = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]];

SV.defaults["font"] = {};
SV.defaults["font"]["default"]     	= {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"};
SV.defaults["font"]["dialog"]      	= {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"};
SV.defaults["font"]["title"]       	= {file = "SVUI Default Font",  size = 16,  outline = "OUTLINE"}; 
SV.defaults["font"]["number"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
SV.defaults["font"]["number_big"]   = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};
SV.defaults["font"]["header"]      	= {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};  
SV.defaults["font"]["combat"]      	= {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}; 
SV.defaults["font"]["alert"]       	= {file = "SVUI Alert Font",    size = 20,  outline = "OUTLINE"};
SV.defaults["font"]["zone"]      	= {file = "SVUI Zone Font",     size = 16,  outline = "OUTLINE"};
SV.defaults["font"]["caps"]      	= {file = "SVUI Caps Font",     size = 12,  outline = "OUTLINE"};
SV.defaults["font"]["aura"]      	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"};
SV.defaults["font"]["data"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
SV.defaults["font"]["narrator"]    	= {file = "SVUI Narrator Font", size = 12,  outline = "OUTLINE"};
SV.defaults["font"]["lootdialog"]   = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"};
SV.defaults["font"]["lootnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
SV.defaults["font"]["rolldialog"]   = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"};
SV.defaults["font"]["rollnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
SV.defaults["font"]["pixel"]       	= {file = "SVUI Pixel Font",    size = 8,   outline = "MONOCHROMEOUTLINE"};
	
SV.defaults["media"] = {
	["textures"] = { 
		["pattern"]      = "SVUI Backdrop", 
		["premium"]      = "SVUI Artwork"
	},
	["borders"] = { 
		["pattern"]      = "SVUI BasicBorder", 
		["premium"]      = "SVUI FancyBorder", 
		["shadow"]       = "SVUI ShadowBorder"
	},
	["colors"] = {
		["default"]      = {0.2, 0.2, 0.2, 1}, 
		["special"]      = {0.37, 0.32, 0.29, 1}, 
		["specialdark"]  = {0.37, 0.32, 0.29, 1},
	},
};

SV.Media = {};

do
	local myclass = select(2,UnitClass("player"))
	local cColor1 = CUSTOM_CLASS_COLORS[myclass]
	local cColor2 = RAID_CLASS_COLORS[myclass]
	local r1,g1,b1 = cColor1.r,cColor1.g,cColor1.b
	local r2,g2,b2 = cColor2.r*.25, cColor2.g*.25, cColor2.b*.25
	local ir1,ig1,ib1 = (1 - r1), (1 - g1), (1 - b1)
	local ir2,ig2,ib2 = (1 - cColor2.r)*.25, (1 - cColor2.g)*.25, (1 - cColor2.b)*.25

	SV.Media["color"] = {
		["default"]     = {0.2, 0.2, 0.2, 1}, 
		["special"]     = {.37, .32, .29, 1},
		["specialdark"] = {.23, .22, .21, 1},
		["unique"]      = {0.32, 0.258, 0.21, 1},
		["container"]   = {.28, .27, .26, 1},  
		["class"]       = {r1, g1, b1, 1},
		["bizzaro"]     = {ir1, ig1, ib1, 1},
		["medium"]      = {0.47, 0.47, 0.47},
		["dark"]        = {0, 0, 0, 1},
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

	SV.Media["gradient"]  = {
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

	SV.Media["font"] = {
		["default"]   = LSM:Fetch("font", "SVUI Default Font"),
		["combat"]    = LSM:Fetch("font", "SVUI Combat Font"),
		["narrator"]  = LSM:Fetch("font", "SVUI Narrator Font"),
		["zones"]     = LSM:Fetch("font", "SVUI Zone Font"),
		["alert"]     = LSM:Fetch("font", "SVUI Alert Font"),
		["numbers"]   = LSM:Fetch("font", "SVUI Number Font"),
		["pixel"]     = LSM:Fetch("font", "SVUI Pixel Font"),
		["caps"]      = LSM:Fetch("font", "SVUI Caps Font"),
		["flash"]     = LSM:Fetch("font", "SVUI Flash Font"),
		["dialog"]    = LSM:Fetch("font", "SVUI Default Font"),
	}

	SV.Media["bar"] = { 
		["default"]   = LSM:Fetch("statusbar", "SVUI BasicBar"), 
		["gradient"]  = LSM:Fetch("statusbar", "SVUI MultiColorBar"), 
		["smooth"]    = LSM:Fetch("statusbar", "SVUI SmoothBar"), 
		["flat"]      = LSM:Fetch("statusbar", "SVUI PlainBar"), 
		["textured"]  = LSM:Fetch("statusbar", "SVUI FancyBar"), 
		["gloss"]     = LSM:Fetch("statusbar", "SVUI GlossBar"), 
		["glow"]      = LSM:Fetch("statusbar", "SVUI GlowBar"),
		["lazer"]     = LSM:Fetch("statusbar", "SVUI LazerBar"),
	}

	SV.Media["backdrop"] = {
		unit = {
			bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]], 
		    tile = false, 
		    tileSize = 0, 
		    edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
		    edgeSize = 20,
		    insets = 
		    {
		        left = 0, 
		        right = 0, 
		        top = 0, 
		        bottom = 0, 
		    },
		},
		unitBGColor = {0,0,0,0},
		unitBorderColor = {1,1,1,1}
	}

	SV.Media["bg"] = {
		["pattern"]     = LSM:Fetch("background", "SVUI Backdrop"),
		["premium"]     = LSM:Fetch("background", "SVUI Artwork"),
	}

	SV.Media["border"] = {
		["pattern"]     = LSM:Fetch("border", "SVUI BasicBorder"),
		["premium"]     = LSM:Fetch("border", "SVUI FancyBorder"),
		["shadow"]      = LSM:Fetch("border", "SVUI ShadowBorder"),
	}

	SV.Media["misc"] = {
		["splash"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\SPLASH]],
	}

	SV.Media["setup"] = {
		["option"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\SETUP-OPTION]],
		["arrow"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\SETUP-ARROW]]
	}

	SV.Media["icon"] = {
		["close"]       = [[Interface\AddOns\SVUI_!Core\assets\textures\CLOSE-BUTTON]],
		["star"]        = [[Interface\AddOns\SVUI_!Core\assets\textures\FAVORITE-STAR]],
		["move_up"]     = [[Interface\AddOns\SVUI_!Core\assets\textures\MOVE-UP]],
		["move_down"]   = [[Interface\AddOns\SVUI_!Core\assets\textures\MOVE-DOWN]],
		["move_left"]   = [[Interface\AddOns\SVUI_!Core\assets\textures\MOVE-LEFT]], 
		["move_right"]  = [[Interface\AddOns\SVUI_!Core\assets\textures\MOVE-RIGHT]],
		["exitIcon"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\EXIT]]
	}

	SV.Media["alert"] = {
		["full"]    = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-FULL]],
		["icon"]    = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-ICON-BORDER]],
		["saved"]   = {
			[[Interface\AddOns\SVUI_!Core\assets\textures\Alert\SAVED-BG]],
			[[Interface\AddOns\SVUI_!Core\assets\textures\Alert\SAVED-FG]],
		},
		["typeA"] = {
			COLOR 	= {0.8, 0.2, 0.2},
			BG 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BG]], 
			LEFT 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-LEFT]],
			RIGHT 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-RIGHT]],
			TOP 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-TOP]],
			BOTTOM 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BOTTOM]],
		},
		["typeB"] = {
			COLOR 	= {0.08, 0.4, 0},
			BG 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BG-2]], 
			LEFT 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-LEFT-2]],
			RIGHT 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-RIGHT-2]],
			TOP 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-TOP]],
			BOTTOM 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BOTTOM]],
		},
	}

	SV.Media["dock"] = {
		["durabilityLabel"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-DUR]],
		["reputationLabel"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-REP]],
		["experienceLabel"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-XP]],
		["hearthIcon"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-HEARTH]],
		["raidToolIcon"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-RAIDTOOL]],
		["garrisonToolIcon"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-GARRISON]],
		["professionIconFile"] = [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\PROFESSIONS]],
		["professionIconCoords"] = {
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
end
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
		if(self.Media or self.db.media) then
			t = self.Media.color[arg1] or self.db.media.unitframes[arg1]
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
	local fontsize = SV.db.font.default.size;
	STANDARD_TEXT_FONT = LSM:Fetch("font", SV.db.font.default.file);
	UNIT_NAME_FONT = LSM:Fetch("font", SV.db.font.caps.file);
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
	["SVUI_Font_Quest"] = "questdialog",
	["SVUI_Font_Quest_Header"] = "questheader",
	["SVUI_Font_Quest_Number"] = "questnumber",
	["SVUI_Font_NamePlate"] = "platename",
	["SVUI_Font_NamePlate_Aura"] = "plateaura",
	["SVUI_Font_NamePlate_Number"] = "platenumber",
	["SVUI_Font_Bag"] = "bagdialog",
	["SVUI_Font_Bag_Number"] = "bagnumber",
	["SVUI_Font_Roll"] = "rolldialog",
	["SVUI_Font_Roll_Number"] = "rollnumber",
	["SVUI_Font_Loot"] = "lootdialog",
	["SVUI_Font_Loot_Number"] = "lootnumber",
	["SVUI_Font_Unit"] = "unitprimary",
	["SVUI_Font_Unit_Small"] = "unitsecondary",
	["SVUI_Font_UnitAura"] = "unitauramedium",
	["SVUI_Font_UnitAura_Bar"] = "unitaurabar",
	["SVUI_Font_UnitAura_Small"] = "unitaurasmall",
	["SVUI_Font_UnitAura_Large"] = "unitauralarge",
};

function SV:FontManager(obj, template, arg, sizeMod, styleOverride, colorR, colorG, colorB)
	if not obj then return end
	template = template or "default";
	local info = self.db.font[template];
	if(not info) then return end

	local isSystemFont = false;
	if(arg and (arg == 'SYSTEM')) then
		isSystemFont = true;
	end

	local file = LSM:Fetch("font", info.file);
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

function SV:RegisterFonts()
	for globalName, id in pairs(self.GlobalFontList) do
		local obj = _G[globalName];
		if(obj) then
			self:FontManager(obj, id);
		end
	end
end

local function UpdateFontTemplate(template)
	template = template or "default";
	local info = SV.db.font[template];
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

SV.Events:On("ALL_FONTS_UPDATED", "UpdateAllFontTemplates", UpdateAllFontTemplates);
SV.Events:On("FONT_GROUP_UPDATED", "UpdateFontGroup", UpdateFontGroup);
--[[ 
########################################################## 
MEDIA UPDATES
##########################################################
]]--
function SV.Media:Update()
	local settings = SV.db.media
	self.color.default      = settings.colors.default
	self.color.special      = settings.colors.special
	self.color.specialdark  = settings.colors.specialdark

	for k,v in pairs(self.bg) do
		self.bg[k] = LSM:Fetch("background", settings.textures[k])
	end

	for k,v in pairs(self.border) do
		self.border[k] = LSM:Fetch("border", settings.textures[k])
	end

	local cColor1 = self.color.special
	local cColor2 = self.color.default
	local r1,g1,b1 = cColor1[1], cColor1[2], cColor1[3]
	local r2,g2,b2 = cColor2[1], cColor2[2], cColor2[3]

	self.gradient.special = {"VERTICAL",r1,g1,b1,r2,g2,b2}

	SV.Events:Trigger("MEDIA_COLORS_UPDATED");
end

function SV:RefreshAllSystemMedia()
	self.Media:Update();
	ChangeGlobalFonts();
	ChangeSystemFonts();
	self:RegisterFonts();
	self.Events:Trigger("ALL_FONTS_UPDATED");
	self.MediaInitialized = true;
end