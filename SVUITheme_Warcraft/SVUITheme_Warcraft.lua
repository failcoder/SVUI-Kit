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
local table 	 =  _G.table;
--[[ TABLE METHODS ]]--
local tsort = table.sort;
--[[ MATH METHODS ]]--
local random = math.random;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local THEME = SV:NewTheme(...);
local LSM = LibStub("LibSharedMedia-3.0");

THEME.media = {}
THEME.media.dockSparks = {
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-3]],
};
--[[ 
########################################################## 
MISC
##########################################################
]]--
local _SetDockButtonTheme = function(_, button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("Button")

	local sparks = button:CreateTexture(nil, "OVERLAY", nil, 2)
	sparks:ModSize(sparkSize, sparkSize)
	sparks:SetPoint("CENTER", button, "BOTTOMRIGHT", -sparkOffset, 4)
	sparks:SetTexture(THEME.media.dockSparks[1])
	sparks:SetVertexColor(0.7, 0.6, 0.5)
	sparks:SetBlendMode("ADD")
	sparks:SetAlpha(0)

	SV.Animate:Sprite8(sparks, 0.08, 2, false, true)

	button.Sparks = sparks;

	button.ClickTheme = function(self)
		self.Sparks:SetTexture(THEME.media.dockSparks[random(1,3)])
		self.Sparks.anim:Play()
	end
end

local _SetDockStyleTheme = function(dock, isBottom)
	if dock.backdrop then return end

	local backdrop = CreateFrame("Frame", nil, dock)
	backdrop:SetAllPoints(dock)
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop:SetBackdrop({
	    bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\Glues\COMMON\TextPanel-Border]],
	    edgeSize = 15,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    }, 
	});
	backdrop:SetBackdropColor(0,0,0,0.5);
	backdrop:SetBackdropBorderColor(1,1,1,1);

	return backdrop 
end

function THEME:Load()
	LSM:Register("border", "SVUI Warcraft Basic Border", [[Interface\Glues\COMMON\TextPanel-Border]])
	LSM:Register("border", "SVUI Warcraft Dialog Border", [[Interface\DialogFrame\UI-DialogBox-Border]])
	LSM:Register("border", "SVUI Warcraft Fancy Border", [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\THEMED-BORDER]])

	SV.defaults["font"]["default"]     	= {file = "Arial Narrow",  size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["dialog"]      	= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["title"]       	= {file = "Arial Narrow",  size = 16,  outline = "OUTLINE"}; 
	SV.defaults["font"]["number"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["number_big"]   = {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};
	SV.defaults["font"]["header"]      	= {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};  
	SV.defaults["font"]["combat"]      	= {file = "Morpheus",   size = 64,  outline = "OUTLINE"}; 
	SV.defaults["font"]["alert"]       	= {file = "Skurri",    size = 20,  outline = "OUTLINE"};
	SV.defaults["font"]["zone"]      	= {file = "Morpheus",     size = 16,  outline = "OUTLINE"};
	SV.defaults["font"]["caps"]      	= {file = "Skurri",     size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["aura"]      	= {file = "Friz Quadrata TT",   size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["data"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["narrator"]    	= {file = "Arial Narrow", size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["lootdialog"]   = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["lootnumber"]   = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["rolldialog"]   = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["rollnumber"]   = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};

	if(SV.defaults.UnitFrames) then
		SV.defaults["font"]["unitprimary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitsecondary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaurabar"]   	= {file = "Skurri",  	size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaura"]  		= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"}
	end

	SV.API.Themes["Warcraft"] = {
		["Default"]     	= "SVUITheme_Warcraft_Default",
		["DockButton"]  	= "SVUITheme_Warcraft_DockButton",
		["Window"]  		= "SVUITheme_Warcraft_Window",
		["WindowAlternate"] = "SVUITheme_Warcraft_WindowAlternate",
		["UnitLarge"]   	= "SVUITheme_Warcraft_UnitLarge",
		["UnitSmall"]   	= "SVUITheme_Warcraft_UnitSmall",
		["Minimap"] 		= "SVUITheme_Warcraft_Minimap",
		["ActionPanel"] 	= "SVUITheme_Warcraft_ActionPanel",
	};

	SV.Media["font"]["default"]   = LSM:Fetch("font", "Arial Narrow");
	SV.Media["font"]["combat"]    = LSM:Fetch("font", "Morpheus");
	SV.Media["font"]["narrator"]  = LSM:Fetch("font", "Arial Narrow");
	SV.Media["font"]["zones"]     = LSM:Fetch("font", "Morpheus");
	SV.Media["font"]["alert"]     = LSM:Fetch("font", "Skurri");
	SV.Media["font"]["numbers"]   = LSM:Fetch("font", "Friz Quadrata TT");
	SV.Media["font"]["caps"]      = LSM:Fetch("font", "Friz Quadrata TT");
	SV.Media["font"]["flash"]     = LSM:Fetch("font", "Skurri");
	SV.Media["font"]["dialog"]    = LSM:Fetch("font", "Arial Narrow");

	SV.Media.misc.splash = "Interface\\AddOns\\SVUITheme_Warcraft\\assets\\artwork\\SPLASH";
	SV.Media.dock.durabilityLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-DUR]];
	SV.Media.dock.reputationLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-REP]];
	SV.Media.dock.experienceLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-XP]];
	SV.Media.dock.hearthIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-HEARTH]];
	SV.Media.dock.raidToolIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
	SV.Media.dock.garrisonToolIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-GARRISON]];
	SV.Media.dock.professionIconFile = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\PROFESSIONS]];
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

	SV.Dock.SetButtonTheme = _SetDockButtonTheme
	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme
end 