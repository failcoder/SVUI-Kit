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
local THEME = SV:GetTheme("Comics");
local LSM = LibStub("LibSharedMedia-3.0");

local _SetDockButtonTheme = function(_, button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("DockButton")

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

	backdrop.bg = backdrop:CreateTexture(nil, "BORDER")
	backdrop.bg:InsetPoints(backdrop)
	backdrop.bg:SetTexture(1, 1, 1, 1)
	
	if(isBottom) then
		backdrop.bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.8, 0, 0, 0, 0)
	else
		backdrop.bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.8)
	end

	backdrop.left = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.left:SetTexture(1, 1, 1, 1)
	backdrop.left:ModPoint("TOPLEFT", 1, -1)
	backdrop.left:ModPoint("BOTTOMLEFT", -1, -1)
	backdrop.left:ModWidth(4)
	if(isBottom) then
		backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
	else
		backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	end

	backdrop.right = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.right:SetTexture(1, 1, 1, 1)
	backdrop.right:ModPoint("TOPRIGHT", -1, -1)
	backdrop.right:ModPoint("BOTTOMRIGHT", -1, -1)
	backdrop.right:ModWidth(4)
	if(isBottom) then
		backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
	else
		backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	end

	backdrop.bottom = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.bottom:ModPoint("BOTTOMLEFT", 1, -1)
	backdrop.bottom:ModPoint("BOTTOMRIGHT", -1, -1)
	if(isBottom) then
		backdrop.bottom:SetTexture(0, 0, 0, 1)
		backdrop.bottom:ModHeight(4)
	else
		backdrop.bottom:SetTexture(0, 0, 0, 0)
		backdrop.bottom:SetAlpha(0)
		backdrop.bottom:ModHeight(1)
	end

	backdrop.top = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.top:ModPoint("TOPLEFT", 1, -1)
	backdrop.top:ModPoint("TOPRIGHT", -1, 1)
	if(isBottom) then
		backdrop.top:SetTexture(0, 0, 0, 0)
		backdrop.top:SetAlpha(0)
		backdrop.top:ModHeight(1)
	else
		backdrop.top:SetTexture(0, 0, 0, 1)
		backdrop.top:ModHeight(4)
	end

	return backdrop 
end

local function SetButtonBasics(frame)
    if(frame.Left) then 
        frame.Left:SetAlpha(0)
    end 

    if(frame.Middle) then 
        frame.Middle:SetAlpha(0)
    end 

    if(frame.Right) then 
        frame.Right:SetAlpha(0)
    end 

    if(frame.SetNormalTexture) then 
        frame:SetNormalTexture("")
    end 

    if(frame.SetDisabledTexture) then 
        frame:SetDisabledTexture("")
    end

    if(frame.SetCheckedTexture) then 
        frame:SetCheckedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover) 
    end 
end

local SetFrameBorderColor = function(self, r, g, b, setPrevious, reset)
    if(setPrevious) then
        self.__border.__previous = setPrevious
    elseif(reset) then
        r,g,b = unpack(SV.Media.color[self.__border.__previous])
    end
    self.__border[1]:SetTexture(r, g, b)
    self.__border[2]:SetTexture(r, g, b)
    self.__border[3]:SetTexture(r, g, b)
    self.__border[4]:SetTexture(r, g, b)
end

local ShowAlertFlash = function(self)
    self:ColorBorder(1,0.9,0)
    SV.Animate:Flash(self.__border, 0.75, true)
end

local HideAlertFlash = function(self)
    SV.Animate:StopFlash(self.__border)
    self:ColorBorder(1,0.9,0, nil, true)
end

local _CreateDockButton = function(self, frame, inverse, inverted, styleName)
    if(not frame or (frame and frame.Panel)) then return end

    local borderSize = 2
    styleName = styleName or "DockButton";
    self:APPLY(frame, styleName, inverse, false, 0, -borderSize, -borderSize)

    if(inverted) then
        frame.Panel:SetAttribute("panelGradient", "darkest2")
    else
        frame.Panel:SetAttribute("panelGradient", "darkest")
    end

    if(not frame.__border) then
        local t = SV.Media.color.default
        local r,g,b = t[1], t[2], t[3]

        local border = CreateFrame("Frame", nil, frame)
        border:SetAllPoints()

        border[1] = border:CreateTexture(nil,"BORDER")
        border[1]:SetTexture(r,g,b)
        border[1]:SetPoint("TOPLEFT", -1, 1)
        border[1]:SetPoint("BOTTOMLEFT", -1, -1)
        border[1]:SetWidth(borderSize)

        local leftoutline = border:CreateTexture(nil,"BORDER")
        leftoutline:SetTexture(0,0,0)
        leftoutline:SetPoint("TOPLEFT", -2, 2)
        leftoutline:SetPoint("BOTTOMLEFT", -2, -2)
        leftoutline:SetWidth(1)

        border[2] = border:CreateTexture(nil,"BORDER")
        border[2]:SetTexture(r,g,b)
        border[2]:SetPoint("TOPRIGHT", 1, 1)
        border[2]:SetPoint("BOTTOMRIGHT", 1, -1)
        border[2]:SetWidth(borderSize)

        local rightoutline = border:CreateTexture(nil,"BORDER")
        rightoutline:SetTexture(0,0,0)
        rightoutline:SetPoint("TOPRIGHT", 2, 2)
        rightoutline:SetPoint("BOTTOMRIGHT", 2, -2)
        rightoutline:SetWidth(1)

        border[3] = border:CreateTexture(nil,"BORDER")
        border[3]:SetTexture(r,g,b)
        border[3]:SetPoint("TOPLEFT", -1, 1)
        border[3]:SetPoint("TOPRIGHT", 1, 1)
        border[3]:SetHeight(borderSize)

        local topoutline = border:CreateTexture(nil,"BORDER")
        topoutline:SetTexture(0,0,0)
        topoutline:SetPoint("TOPLEFT", -2, 2)
        topoutline:SetPoint("TOPRIGHT", 2, 2)
        topoutline:SetHeight(1)

        border[4] = border:CreateTexture(nil,"BORDER")
        border[4]:SetTexture(r,g,b)
        border[4]:SetPoint("BOTTOMLEFT", -1, -1)
        border[4]:SetPoint("BOTTOMRIGHT", 1, -1)
        border[4]:SetHeight(borderSize)

        local bottomoutline = border:CreateTexture(nil,"BORDER")
        bottomoutline:SetTexture(0,0,0)
        bottomoutline:SetPoint("BOTTOMLEFT", -2, -2)
        bottomoutline:SetPoint("BOTTOMRIGHT", 2, -2)
        bottomoutline:SetHeight(1)

        frame.__border = border
        frame.__border.__previous = 'default';
        frame.ColorBorder = SetFrameBorderColor
        frame.StartAlert = ShowAlertFlash
        frame.StopAlert = HideAlertFlash
    end
end;

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

	SV.API.Methods["DockButton"] = _CreateDockButton;

	SV.API.Themes["Comics"] = {
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

	SV.Dock.SetButtonTheme = _SetDockButtonTheme
	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme

	self.AFK:Initialize()
	self.Comix:Initialize()
	self.GameMenu:Initialize()
	self.Drunk:Initialize()
	self:InitializeHenchmen()
	self:LoadUFOverrides()
	self:LoadMapOverrides()
end 