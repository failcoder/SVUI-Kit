--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
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
local string 	= _G.string;
local table     = _G.table;
local format = string.format;
local tcopy = table.copy;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry");
local L = SV.L;

function SV.Setup:SelectTheme()
	if not SVUI_ThemeSelectFrame then 
		local frame = CreateFrame("Button", "SVUI_ThemeSelectFrame", UIParent)
		frame:ModSize(350, 500)
		frame:SetStyle("Frame", "Composite2")
		frame:SetPoint("CENTER", SV.Screen, "CENTER", 0, 0)
		frame:SetFrameStrata("TOOLTIP");

		local THEMES = SVUILib:ListThemes()
		local count = 1;
		--[[ NEXT PAGE BUTTON ]]--
		for themeName, _ in pairs(Themes) do
			local yOffset = ((225 * i) - 200) * -1;
			local icon = SV.Media.setup[themeName] or SV.Media.setup.theme
			local themeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			themeButton:RemoveTextures()
			themeButton:ModSize(200, 200)
			themeButton:SetPoint("TOP", frame, "TOP", 0, yOffset)
			themeButton.texture = themeButton:CreateTexture(nil, "BORDER")
			themeButton.texture:SetAllPoints()
			themeButton.texture:SetTexture(icon)
			themeButton.texture:SetVertexColor(1, 1, 1)
			themeButton.value = themeName
			themeButton:SetScript("OnClick", function(self) 
				SV.db.THEME.active = self.value; 
				SV:StaticPopup_Show("RL_CLIENT");
			end)
			themeButton:SetScript("OnEnter", function(this)
				this.texture:SetVertexColor(0, 1, 1)
			end)
			themeButton:SetScript("OnLeave", function(this)
				this.texture:SetVertexColor(1, 1, 1)
			end)

			count = count + 1
		end
	end

	SVUI_ThemeSelectFrame:Show()
end