--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local random        = math.random;
local floor         = math.floor
local ceil         	= math.ceil
local max         	= math.max

local SV = _G['SVUI']
local L = SV.L;
local THEME = SV:GetTheme("Comics");
local NARR_TEXT = "Meanwhile";
local NARR_PREFIX = "In ";

local _RefreshZoneText = function(self)
	if(not SV.db.Maps.locationText or SV.db.Maps.locationText == "HIDE") then
		self.Narrator:Hide();
		self.Zone:Hide();
	else
		if(SV.db.Maps.locationText == "SIMPLE") then
			self.Narrator:Hide();
			self.Zone:Show();
			self.Narrator.Text:SetText(NARR_TEXT)
		else
			self.Narrator:Show();
			self.Zone:Show();
			NARR_TEXT = L['Meanwhile...'];
			NARR_PREFIX = L["..at "];
			self.Narrator.Text:SetText(NARR_TEXT)
		end
		local zone = GetRealZoneText() or UNKNOWN
		zone = zone:sub(1, 25);
		local zoneText = ("%s%s"):format(NARR_PREFIX, zone);
		self.Zone.Text:SetText(zoneText)
	end
end

function THEME:LoadMapOverrides()
	local mwfont = SV.Media.font.narrator

	local narr = CreateFrame("Frame", nil, SVUI_MinimapFrame)
	narr:ModPoint("TOPLEFT", SVUI_MinimapFrame, "TOPLEFT", 2, -2)
	narr:SetSize(100, 22)
	narr:SetStyle("!_Frame")
  	narr:SetPanelColor("yellow")
  	narr:SetBackdropColor(1, 1, 0, 1)
	narr:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	narr:SetParent(Minimap)

	narr.Text = narr:CreateFontString(nil, "ARTWORK", nil, 7)
	narr.Text:SetFontObject(SVUI_Font_Narrator)
	narr.Text:SetJustifyH("CENTER")
	narr.Text:SetJustifyV("MIDDLE")
	narr.Text:SetAllPoints(narr)
	narr.Text:SetTextColor(1, 1, 1)
	narr.Text:SetShadowColor(0, 0, 0, 0.3)
	narr.Text:SetShadowOffset(2, -2)

	SV.Maps.Narrator = narr

	SV.Maps.ZONE_CHANGED = _RefreshZoneText
	SV.Maps.ZONE_CHANGED_NEW_AREA = _RefreshZoneText
end