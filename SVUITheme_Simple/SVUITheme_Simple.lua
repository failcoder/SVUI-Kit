--[[
##############################################################################
S U P E R - V I L L A I N - T H E M E   By: Munglunch                        
##############################################################################
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random = math.random;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local THEME = SV:GetTheme("Simple");
local LSM = LibStub("LibSharedMedia-3.0");

local _SetDockStyleTheme = function(dock, isBottom)
	if dock.backdrop then return end
	local backdrop = CreateFrame("Frame", nil, dock)
	backdrop:SetAllPoints(dock)
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop:SetBackdrop({
	    bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\BUTTONS\WHITE8X8]],
	    edgeSize = 1,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    }, 
	});
	backdrop:SetBackdropColor(0,0,0,0.5);
	backdrop:SetBackdropBorderColor(0,0,0,0.8);
	return backdrop 
end

function THEME:Load()
	if(GetLocale() == "enUS") then
		SV.defaults["font"]["dialog"] = {file = "SVUI Dialog Font",  size = 10,  outline = "OUTLINE"};
		SV.defaults["font"]["title"] = {file = "SVUI Dialog Font",  size = 16,  outline = "OUTLINE"};
		SV.Media["font"]["dialog"] = LSM:Fetch("font", "SVUI Dialog Font")
	end

	SV.defaults["font"]["number"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["number_big"]   = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};
	SV.defaults["font"]["header"]      	= {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};  
	SV.defaults["font"]["combat"]      	= {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}; 
	SV.defaults["font"]["alert"]       	= {file = "SVUI Alert Font",    size = 20,  outline = "OUTLINE"};
	SV.defaults["font"]["zone"]      	= {file = "SVUI Zone Font",     size = 16,  outline = "OUTLINE"};
	SV.defaults["font"]["aura"]      	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["data"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["narrator"]    	= {file = "SVUI Narrator Font", size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["lootnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["rollnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};

	if(SV.defaults.UnitFrames) then
		SV.defaults["font"]["unitprimary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitsecondary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaurabar"]   	= {file = "SVUI Alert Font",  	size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauramedium"]  	= {file = "SVUI Default Font",  size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauralarge"]   	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"}
	end

	SV.defaults["media"]["textures"]["unitlarge"]   = "SVUI UnitBG 1";
	SV.defaults["media"]["textures"]["unitsmall"]   = "SVUI SmallUnitBG 1";
	SV.defaults["media"]["borders"]["unitlarge"]    = "SVUI UnitBorder 1";
	SV.defaults["media"]["borders"]["unitsmall"]    = "SVUI SmallBorder 1";

	if(SV.defaults.Maps) then
		SV.defaults.Maps.locationText = "CUSTOM";
		SV.defaults.Maps.bordersize = 6;
		SV.defaults.Maps.bordercolor = "light";
	end

	SV.API.Themes["Simple"] = {
		["Default"]     = "SVUITheme_Simple_Default",
		["DockButton"]  = "SVUITheme_Simple_DockButton",
		["Composite1"]  = "SVUITheme_Simple_Composite1",
		["Composite2"]  = "SVUITheme_Simple_Composite2",
		["UnitLarge"]   = "SVUITheme_Simple_UnitLarge",
		["UnitSmall"]   = "SVUITheme_Simple_UnitSmall",
		["Minimap"] 	= "SVUITheme_Simple_Minimap",
		["ActionPanel"] = "SVUITheme_Simple_ActionPanel",
	};

	SV.Media["font"]["combat"]    = LSM:Fetch("font", "SVUI Combat Font");
	SV.Media["font"]["narrator"]  = LSM:Fetch("font", "SVUI Narrator Font");
	SV.Media["font"]["zones"]     = LSM:Fetch("font", "SVUI Zone Font");
	SV.Media["font"]["alert"]     = LSM:Fetch("font", "SVUI Alert Font");
	SV.Media["font"]["numbers"]   = LSM:Fetch("font", "SVUI Number Font");
	SV.Media["font"]["flash"]     = LSM:Fetch("font", "SVUI Flash Font");

	SV.Media.misc.splash = "Interface\\AddOns\\SVUI_Theme_Comics\\assets\\artwork\\SPLASH";
	SV.Media.dock.durabilityLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-DUR]];
	SV.Media.dock.reputationLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-REP]];
	SV.Media.dock.experienceLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-XP]];
	SV.Media.dock.hearthIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-HEARTH]];
	SV.Media.dock.raidToolIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
	SV.Media.dock.garrisonToolIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-GARRISON]];
	SV.Media.dock.professionIconFile = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\PROFESSIONS]];
	SV.Media.dock.professionIconCoords = {
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
	}

	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme
end 