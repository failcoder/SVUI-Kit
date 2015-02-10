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
		frame:ModSize(350, 145)
		frame:SetStyle("Frame", "WindowAlternate")
		frame:SetPoint("CENTER", SV.Screen, "CENTER", 0, 0)
		frame:SetFrameStrata("TOOLTIP");

		local THEMES = SVUILib:ListThemes()
		local count = 1;
		local yOffset = ((135 * count) - 125) * -1;
		local icon = SV.Setup.media.theme
		local firstButton = CreateFrame("Frame", nil, frame)
		firstButton:ModSize(125, 125)
		firstButton:SetPoint("TOP", frame, "TOP", 0, yOffset)
		firstButton.texture = firstButton:CreateTexture(nil, "BORDER")
		firstButton.texture:SetAllPoints()
		firstButton.texture:SetTexture(icon)
		firstButton.texture:SetVertexColor(1, 1, 1)
		firstButton.text = firstButton:CreateFontString(nil, "OVERLAY")
		firstButton.text:SetFont(SV.media.font.zones, 18, "OUTLINE")
		firstButton.text:SetPoint("BOTTOM")
		firstButton.text:SetText("Default Theme")
		firstButton.text:SetTextColor(0.1, 0.5, 1)
		firstButton:EnableMouse(true)
		firstButton:SetScript("OnMouseDown", function(self) 
			SV.db.THEME.active = "NONE";
			SV:StaticPopup_Show("RL_CLIENT");
		end)
		firstButton:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0, 1, 1)
			this.text:SetTextColor(1, 1, 0)
		end)
		firstButton:SetScript("OnLeave", function(this)
			this.texture:SetVertexColor(1, 1, 1)
			this.text:SetTextColor(0.1, 0.5, 1)
		end)

		count = count + 1
		--[[ NEXT PAGE BUTTON ]]--
		for themeName, _ in pairs(THEMES) do
			if(themeName ~= 'NONE') then
				local yOffset = ((135 * count) - 125) * -1;
				local icon = SV.Setup.media[themeName] or SV.Setup.media.theme
				local themeButton = CreateFrame("Frame", nil, frame)
				themeButton:ModSize(125, 125)
				themeButton:SetPoint("TOP", frame, "TOP", 0, yOffset)
				themeButton.texture = themeButton:CreateTexture(nil, "BORDER")
				themeButton.texture:SetAllPoints()
				themeButton.texture:SetTexture(icon)
				themeButton.texture:SetVertexColor(1, 1, 1)
				themeButton.text = themeButton:CreateFontString(nil, "OVERLAY")
				themeButton.text:SetFont(SV.media.font.zones, 18, "OUTLINE")
				themeButton.text:SetPoint("BOTTOM")
				themeButton.text:SetText(themeName .. " Theme")
				themeButton.text:SetTextColor(0.1, 0.5, 1)
				themeButton:EnableMouse(true)
				themeButton:SetScript("OnMouseDown", function(self) 
					SV.db.THEME.active = themeName; 
					SV:StaticPopup_Show("RL_CLIENT");
				end)
				themeButton:SetScript("OnEnter", function(this)
					this.texture:SetVertexColor(0, 1, 1)
					this.text:SetTextColor(1, 1, 0)
				end)
				themeButton:SetScript("OnLeave", function(this)
					this.texture:SetVertexColor(1, 1, 1)
					this.text:SetTextColor(0.1, 0.5, 1)
				end)

				count = count + 1
			end
		end

		local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() frame:Hide() end)

		frame:ClearAllPoints()
		frame:ModSize(350, (135 * (count - 1)) + 20)
		frame:SetPoint("CENTER", SV.Screen, "CENTER", 0, 0)
	end

	SVUI_ThemeSelectFrame:Show()
end