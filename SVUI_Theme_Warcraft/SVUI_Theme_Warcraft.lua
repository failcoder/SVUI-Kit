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
local THEME = SV:GetTheme("Warcraft");

local _SetDockButtonTheme = function(button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStylePanel("Button")

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
	SV.Media.XML["Default"]     = "SVUI_WarcraftTheme_Default";
	SV.Media.XML["Composite1"]  = "SVUI_WarcraftTheme_Composite1";
	SV.Media.XML["Composite2"]  = "SVUI_WarcraftTheme_Composite2";
	SV.Media.XML["UnitLarge"]   = "SVUI_WarcraftTheme_UnitLarge";
	SV.Media.XML["UnitSmall"]   = "SVUI_WarcraftTheme_UnitSmall";
	SV.Media.XML["ActionPanel"] = "SVUI_WarcraftTheme_ActionPanel";
	SV.Media.XML["Minimap"] 	= "SVUI_WarcraftTheme_Minimap";

	SV.Media.misc.splash = "Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\artwork\\SPLASH";
	SV.Media.dock.durabilityLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-DUR]];
	SV.Media.dock.reputationLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-REP]];
	SV.Media.dock.experienceLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-XP]];
	SV.Media.dock.hearthIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-HEARTH]];
	SV.Media.dock.raidToolIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
	SV.Media.dock.garrisonToolIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-GARRISON]];
	SV.Media.dock.professionIconFile = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\PROFESSIONS]];
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
	SV.defaults.THEME["Warcraft"] = {};
	SV.Options.args.Themes.args.Warcraft = {
		type = "group",
		name = L["Warcraft Theme"],
		args = {}
	};

	SV.Dock.SetButtonTheme = _SetDockButtonTheme
	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme

	self:LoadUFOverrides()
end 