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
local LSM = _G.LibStub("LibSharedMedia-3.0");

LSM:Register("border", "SVUI Warcraft Basic Border", [[Interface\Glues\COMMON\TextPanel-Border]])
LSM:Register("border", "SVUI Warcraft Dialog Border", [[Interface\DialogFrame\UI-DialogBox-Border]])
LSM:Register("border", "SVUI Warcraft Fancy Border", [[Interface\AddOns\SVUITheme_Warcraft\assets\artwork\THEMED-BORDER]])

SV:AssignMedia("font", "default", "Arial Narrow");
SV:AssignMedia("font", "dialog", "Arial Narrow");
SV:AssignMedia("font", "title", "Arial Narrow");
SV:AssignMedia("font", "narrator", "Arial Narrow");
SV:AssignMedia("font", "lootdialog", "Arial Narrow");
SV:AssignMedia("font", "rolldialog", "Arial Narrow");
SV:AssignMedia("font", "number", "Friz Quadrata TT");
SV:AssignMedia("font", "number_big", "Friz Quadrata TT");
SV:AssignMedia("font", "header", "Friz Quadrata TT");
SV:AssignMedia("font", "aura", "Friz Quadrata TT");
SV:AssignMedia("font", "data", "Friz Quadrata TT");
SV:AssignMedia("font", "lootnumber", "Friz Quadrata TT");
SV:AssignMedia("font", "rollnumber", "Friz Quadrata TT");
SV:AssignMedia("font", "combat", "Morpheus");
SV:AssignMedia("font", "zone", "Morpheus");
SV:AssignMedia("font", "alert", "Skurri");
SV:AssignMedia("font", "caps", "Skurri");

--SV:AssignMedia("bordercolor", "default", 1, 1, 1, 1);
SV:AssignMedia("template", "Default", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Button", "SVUITheme_Warcraft_DockButton");
SV:AssignMedia("template", "DockButton", "SVUITheme_Warcraft_DockButton");
SV:AssignMedia("template", "Pattern", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Premium", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Model", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Window", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Window2", "SVUITheme_Warcraft_Default");
SV:AssignMedia("template", "Minimap", "SVUITheme_Warcraft_Minimap");
SV:AssignMedia("template", "ActionPanel", "SVUITheme_Warcraft_ActionPanel");
SV:AssignMedia("template", "Container", "SVUITheme_Warcraft_Default");

local _RefreshZoneText = function(self)
	if(self.InfoTop:IsShown()) then
		self.InfoTop:Hide();
	end
	if(not SV.db.Maps.locationText or SV.db.Maps.locationText == "HIDE") then
		self.InfoBottom:Hide();
	else
		self.InfoBottom:Show();
		local zone = GetRealZoneText() or UNKNOWN
		self.InfoBottom.Text:SetText(zone)
	end
end

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

function SV:LoadTheme()
	if(self.defaults.UnitFrames) then
		self:AssignMedia("font", "unitprimary", "Friz Quadrata TT", 14);
		self:AssignMedia("font", "unitsecondary", "Friz Quadrata TT", 14);
		self:AssignMedia("font", "unitaurabar", "Skurri", 12);
		self:AssignMedia("font", "unitaura", "Arial Narrow", 12);
	end
	if(self.defaults.Maps) then
		self:AssignMedia("font", "mapinfo", "Friz Quadrata TT", 14);
		self:AssignMedia("font", "mapcoords", "Friz Quadrata TT", 14);
		self.defaults.Maps.locationText = "SIMPLE";
		self.defaults.Maps.bordersize = 1;
		self.defaults.Maps.bordercolor = "dark";
	end
	if(self.Maps) then
		self.Maps.RefreshZoneText = _RefreshZoneText
	end

	self.Dock.SetButtonTheme = _SetDockButtonTheme
	self.Dock.SetThemeDockStyle = _SetDockStyleTheme
	self.Dock.SetBorderTheme = _SetBorderTheme
end