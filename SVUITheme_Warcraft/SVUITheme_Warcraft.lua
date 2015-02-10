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
local LSM = LibStub("LibSharedMedia-3.0");
--[[ 
########################################################## 
MISC
##########################################################
]]--
local docksparks = {
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-1]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-2]],
	[[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-SPARKS-3]],
};

local _SetDockButtonTheme = function(_, button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("Button")

	local sparks = button:CreateTexture(nil, "OVERLAY", nil, 2)
	sparks:ModSize(sparkSize, sparkSize)
	sparks:SetPoint("CENTER", button, "BOTTOMRIGHT", -sparkOffset, 4)
	sparks:SetTexture(docksparks[1])
	sparks:SetVertexColor(0.7, 0.6, 0.5)
	sparks:SetBlendMode("ADD")
	sparks:SetAlpha(0)

	SV.Animate:Sprite8(sparks, 0.08, 2, false, true)

	button.Sparks = sparks;

	button.ClickTheme = function(self)
		self.Sparks:SetTexture(docksparks[random(1,3)])
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

LSM:Register("border", "SVUI Warcraft Basic Border", [[Interface\Glues\COMMON\TextPanel-Border]])
LSM:Register("border", "SVUI Warcraft Dialog Border", [[Interface\DialogFrame\UI-DialogBox-Border]])
LSM:Register("border", "SVUI Warcraft Fancy Border", [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\THEMED-BORDER]])

SV.mediadefaults.shared.font["default"]     	= {file = "Arial Narrow",  size = 12,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["dialog"]      	= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["title"]       	= {file = "Arial Narrow",  size = 16,  outline = "OUTLINE"}; 
SV.mediadefaults.shared.font["number"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["number_big"]    = {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["header"]      	= {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};  
SV.mediadefaults.shared.font["combat"]      	= {file = "Morpheus",   size = 64,  outline = "OUTLINE"}; 
SV.mediadefaults.shared.font["alert"]       	= {file = "Skurri",    size = 20,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["zone"]      	= {file = "Morpheus",     size = 16,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["caps"]      	= {file = "Skurri",     size = 12,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["aura"]      	= {file = "Friz Quadrata TT",   size = 10,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["data"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["narrator"]    	= {file = "Arial Narrow", size = 12,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["lootdialog"]    = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["lootnumber"]    = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["rolldialog"]    = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["rollnumber"]    = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};

if(SV.defaults.UnitFrames) then
	SV.mediadefaults.shared.font["unitprimary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitsecondary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitaurabar"]   	= {file = "Skurri",  	size = 10,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitaura"]  		= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"}
end

SV.mediadefaults.dock.durabilityLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-DUR]];
SV.mediadefaults.dock.reputationLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-REP]];
SV.mediadefaults.dock.experienceLabel = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\LABEL-XP]];
SV.mediadefaults.dock.hearthIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-HEARTH]];
SV.mediadefaults.dock.raidToolIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
SV.mediadefaults.dock.garrisonToolIcon = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\DOCK-ICON-GARRISON]];
SV.mediadefaults.dock.professionIconFile = [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\Dock\PROFESSIONS]];
SV.mediadefaults.dock.professionIconCoords = {
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

SV.API.Templates["Default"]     	= "SVUITheme_Warcraft_Default";
SV.API.Templates["DockButton"]  	= "SVUITheme_Warcraft_DockButton";
SV.API.Templates["Window"]  		= "SVUITheme_Warcraft_Window";
SV.API.Templates["Window2"] = "SVUITheme_Warcraft_Window2";
SV.API.Templates["UnitLarge"]   	= "SVUITheme_Warcraft_UnitLarge";
SV.API.Templates["UnitSmall"]   	= "SVUITheme_Warcraft_UnitSmall";
SV.API.Templates["Minimap"] 		= "SVUITheme_Warcraft_Minimap";
SV.API.Templates["ActionPanel"] 	= "SVUITheme_Warcraft_ActionPanel";

SV.Dock.SetButtonTheme = _SetDockButtonTheme
SV.Dock.SetThemeDockStyle = _SetDockStyleTheme