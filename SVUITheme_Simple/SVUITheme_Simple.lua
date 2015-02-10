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
local SV = _G["SVUI"];
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

local _SetBorderTheme = function(self)
	self.Border.Top:ModPoint("TOPLEFT", SV.Screen, "TOPLEFT", -1, 1)
	self.Border.Top:ModPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", 1, 1)
	self.Border.Top:ModHeight(10)
	self.Border.Top:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		tileSize = 0, 
		edgeSize = 1, 
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Border.Top:SetBackdropColor(0,0,0,0)
	self.Border.Top:SetBackdropBorderColor(0,0,0,0)
	self.Border.Top:SetFrameLevel(0)
	self.Border.Top:SetFrameStrata('BACKGROUND')
	self.Border.Top:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)

	self.Border.Bottom:ModPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", -1, -1)
	self.Border.Bottom:ModPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 1, -1)
	self.Border.Bottom:ModHeight(10)
	self.Border.Bottom:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		tileSize = 0, 
		edgeSize = 1, 
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Border.Bottom:SetBackdropColor(0,0,0,0)
	self.Border.Bottom:SetBackdropBorderColor(0,0,0,0)
	self.Border.Bottom:SetFrameLevel(0)
	self.Border.Bottom:SetFrameStrata('BACKGROUND')
	self.Border.Bottom:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)
end

LSM:Register("background", "SVUI Backdrop", [[Interface\DialogFrame\UI-DialogBox-Background]])

SV.DialogFontDefault = "SVUI Default Font";

if(GetLocale() == "enUS") then
	SV.mediadefaults.shared.font["dialog"] = {file = "SVUI Dialog Font",  size = 10,  outline = "OUTLINE"};
	SV.mediadefaults.shared.font["title"] = {file = "SVUI Dialog Font",  size = 16,  outline = "OUTLINE"};
end

SV.mediadefaults.shared.font["number"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["number_big"]   = {file = "SVUI Caps Font",   size = 18,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["header"]      	= {file = "SVUI Caps Font",   size = 18,  outline = "OUTLINE"};  
SV.mediadefaults.shared.font["combat"]      	= {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}; 
SV.mediadefaults.shared.font["alert"]       	= {file = "SVUI Default Font",    size = 20,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["zone"]      	= {file = "SVUI Default Font",     size = 16,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["aura"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["data"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["narrator"]    	= {file = "SVUI Default Font", size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["lootnumber"]   = {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
SV.mediadefaults.shared.font["rollnumber"]   = {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};

SV.mediadefaults.shared.background["pattern"]   	= {file = "SVUI Backdrop", size = 0, tiled = false};
SV.mediadefaults.shared.background["premium"]   	= {file = "SVUI Backdrop", size = 0, tiled = false};
SV.mediadefaults.shared.background["button"]   	= {file = "SVUI Backdrop", size = 0, tiled = false};
SV.mediadefaults.shared.background["unitlarge"]   = {file = "SVUI Backdrop", size = 0, tiled = false};
SV.mediadefaults.shared.background["unitsmall"]   = {file = "SVUI Backdrop", size = 0, tiled = false};

if(SV.defaults.UnitFrames) then
	SV.mediadefaults.shared.font["unitprimary"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitsecondary"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitaurabar"]   	= {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["unitaura"]  		= {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"}

	SV.defaults.UnitFrames.player.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.target.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.pet.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.targettarget.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.focus.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.focustarget.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.raid.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.party.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.boss.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.arena.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.tank.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.assist.name.font = SV.DialogFontDefault;
	SV.defaults.UnitFrames.raidpet.name.font = SV.DialogFontDefault;
end

if(SV.defaults.Maps) then
	SV.mediadefaults.shared.font["mapinfo"]  	= {file = "SVUI Default Font", size = 14,  outline = "OUTLINE"}
	SV.mediadefaults.shared.font["mapcoords"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
	SV.defaults.Maps.locationText = "SIMPLE";
	SV.defaults.Maps.bordersize = 1;
	SV.defaults.Maps.bordercolor = "dark";
end

SV.API.Templates["Default"]     	= "SVUITheme_Simple_Default";
SV.API.Templates["Button"]  		= "SVUITheme_Simple_DockButton";
SV.API.Templates["DockButton"]  	= "SVUITheme_Simple_DockButton";
SV.API.Templates["Pattern"]   		= "SVUITheme_Simple_Default";
SV.API.Templates["Premium"]   		= "SVUITheme_Simple_Default";
SV.API.Templates["Window"]  		= "SVUITheme_Simple_Default";
SV.API.Templates["Window2"] = "SVUITheme_Simple_Default";
SV.API.Templates["Minimap"] 		= "SVUITheme_Simple_Minimap";
SV.API.Templates["ActionPanel"] 	= "SVUITheme_Simple_ActionPanel";
SV.API.Templates["Container"]  		= "SVUITheme_Simple_Default";

SV.Dock.SetThemeDockStyle = _SetDockStyleTheme
SV.Dock.SetBorderTheme = _SetBorderTheme
-- print("Theme")
-- print(SV.mediadefaults.shared.background["unitlarge"])
-- print(SV.media["background"]["unitlarge"])