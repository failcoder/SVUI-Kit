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
local THEME = SV:NewTheme(...);

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

function THEME:Load()
	local LSM = LibStub("LibSharedMedia-3.0");
	LSM:Register("background", "SVUI Backdrop", [[Interface\DialogFrame\UI-DialogBox-Background]])

	SV.DialogFontDefault = "SVUI Default Font";

	if(GetLocale() == "enUS") then
		SV.defaults["font"]["dialog"] = {file = "SVUI Dialog Font",  size = 10,  outline = "OUTLINE"};
		SV.defaults["font"]["title"] = {file = "SVUI Dialog Font",  size = 16,  outline = "OUTLINE"};
		SV.Media["font"]["dialog"] = LSM:Fetch("font", "SVUI Dialog Font")
	end

	SV.defaults["font"]["number"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["number_big"]   = {file = "SVUI Caps Font",   size = 18,  outline = "OUTLINE"};
	SV.defaults["font"]["header"]      	= {file = "SVUI Caps Font",   size = 18,  outline = "OUTLINE"};  
	SV.defaults["font"]["combat"]      	= {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}; 
	SV.defaults["font"]["alert"]       	= {file = "SVUI Default Font",    size = 20,  outline = "OUTLINE"};
	SV.defaults["font"]["zone"]      	= {file = "SVUI Default Font",     size = 16,  outline = "OUTLINE"};
	SV.defaults["font"]["aura"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["data"]      	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["narrator"]    	= {file = "SVUI Default Font", size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["lootnumber"]   = {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["rollnumber"]   = {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"};

	SV.defaults["media"]["textures"]["pattern"]   	= "SVUI Backdrop";
	SV.defaults["media"]["textures"]["premium"]   	= "SVUI Backdrop";
	SV.defaults["media"]["textures"]["unitlarge"]   = "SVUI Backdrop";
	SV.defaults["media"]["textures"]["unitsmall"]   = "SVUI Backdrop";

	if(SV.defaults.UnitFrames) then
		SV.defaults["font"]["unitprimary"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
		SV.defaults["font"]["unitsecondary"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaurabar"]   	= {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaura"]  		= {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"}

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
		SV.defaults["font"]["mapinfo"]  	= {file = "SVUI Default Font", size = 14,  outline = "OUTLINE"}
		SV.defaults["font"]["mapcoords"]   	= {file = "SVUI Caps Font",   size = 14,  outline = "OUTLINE"}
		SV.defaults.Maps.locationText = "SIMPLE";
		SV.defaults.Maps.bordersize = 1;
		SV.defaults.Maps.bordercolor = "dark";
	end

	SV.API.Themes["Simple"] = {
		["Default"]     		= "SVUITheme_Simple_Default",
		["DockButton"]  		= "SVUITheme_Simple_DockButton",
		["Pattern"] 			= "SVUITheme_Simple_Default",
		["Premium"] 			= "SVUITheme_Simple_Default",
		["Window"]  			= "SVUITheme_Simple_Default",
		["WindowAlternate"]  	= "SVUITheme_Simple_Default",
		["Minimap"] 			= "SVUITheme_Simple_Minimap",
		["ActionPanel"] 		= "SVUITheme_Simple_ActionPanel",
		["Container"]   		= "SVUITheme_Simple_Default",
	};

	SV.Media["texture"]["pattern"] 		= LSM:Fetch("background", "SVUI Backdrop")
	SV.Media["texture"]["premium"] 		= LSM:Fetch("background", "SVUI Backdrop")
	SV.Media["texture"]["unitlarge"]   	= LSM:Fetch("background", "SVUI Backdrop")
	SV.Media["texture"]["unitsmall"]   	= LSM:Fetch("background", "SVUI Backdrop")
	SV.Media["texture"]["button"]   	= LSM:Fetch("background", "SVUI Backdrop");

	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme
	SV.Dock.SetBorderTheme = _SetBorderTheme
	-- print("Theme")
	-- print(SV.defaults["media"]["textures"]["unitlarge"])
	-- print(SV.Media["texture"]["unitlarge"])
end 