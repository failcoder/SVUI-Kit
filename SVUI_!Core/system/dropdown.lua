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
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table; 
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local min 			= math.min;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
--[[ 
########################################################## 
ADDON
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L

SV.Dropdown = _G["SVUI_DropdownFrame"];

local DropdownButton_OnClick = function(self)
	self.func(self.target)
	self:GetParent():Hide()
	ToggleFrame(SV.Dropdown);
end

local DropdownButton_OnEnter = function(self)
	self.hoverTex:Show()
end

local DropdownButton_OnLeave = function(self)
	self.hoverTex:Hide()
end

local function GetScreenPosition(frame)
	local parent = frame:GetParent()
	local centerX, centerY = parent:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local result;
	if not centerX or not centerY then 
		return "CENTER"
	end 
	local heightTop = screenHeight * 0.75;
	local heightBottom = screenHeight * 0.25;
	local widthLeft = screenWidth * 0.25;
	local widthRight = screenWidth * 0.75;
	if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then 
		result = "TOP"
	elseif((centerX < widthLeft) and (centerY > heightTop)) then 
		result = "TOPLEFT"
	elseif((centerX > widthRight) and (centerY > heightTop)) then 
		result = "TOPRIGHT"
	elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then 
		result = "BOTTOM"
	elseif((centerX < widthLeft) and (centerY < heightBottom)) then 
		result = "BOTTOMLEFT"
	elseif((centerX > widthRight) and (centerY < heightBottom)) then 
		result = "BOTTOMRIGHT"
	elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then 
		result = "LEFT"
	elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then 
		result = "RIGHT"
	else 
		result = "CENTER"
	end
	return result 
end

function SV.Dropdown:Open(target, list)
	if(InCombatLockdown() or (not list)) then return end

	if(not self.option) then
		self.option = {};
		self:SetFrameStrata("DIALOG");
		self:SetClampedToScreen(true);
		tinsert(UISpecialFrames, self:GetName());
		self:Hide();
	end

	local maxPerColumn = 25;
	local cols = 1;

	for i=1, #self.option do
		self.option[i].button:Hide();
		self.option[i].divider:Hide();
		self.option[i].header:Hide();
		self.option[i]:Hide();
	end

	for i=1, #list do
		if(not self.option[i]) then
			-- HOLDER
			self.option[i] = CreateFrame("Frame", nil, self);
			self.option[i]:SetHeight(16);
			self.option[i]:SetWidth(135);

			-- DIVIDER
			self.option[i].divider = self.option[i]:CreateTexture(nil, 'BORDER');
			self.option[i].divider:SetAllPoints();
			self.option[i].divider:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\DROPDOWN-DIVIDER]]);
			self.option[i].divider:Hide();

			self.option[i].header = self.option[i]:CreateFontString(nil, 'OVERLAY');
			self.option[i].header:SetAllPoints();
			self.option[i].header:SetFont(SV.media.font.default, 10, "OUTLINE");
			self.option[i].header:SetTextColor(1, 0.8, 0)
			self.option[i].header:SetJustifyH("CENTER");
			self.option[i].header:SetJustifyV("MIDDLE");

			-- BUTTON
			self.option[i].button = CreateFrame("Button", nil, self.option[i]);
			self.option[i].button:SetAllPoints();

			self.option[i].button.hoverTex = self.option[i].button:CreateTexture(nil, 'OVERLAY');
			self.option[i].button.hoverTex:SetAllPoints();
			self.option[i].button.hoverTex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\TITLE-HIGHLIGHT]]);
			self.option[i].button.hoverTex:SetBlendMode("ADD");
			self.option[i].button.hoverTex:Hide();

			self.option[i].button.text = self.option[i].button:CreateFontString(nil, 'BORDER');
			self.option[i].button.text:SetAllPoints();
			self.option[i].button.text:SetFont(SV.media.font.default, 12, "OUTLINE");
			self.option[i].button.text:SetJustifyH("LEFT");

			self.option[i].button:SetScript("OnEnter", DropdownButton_OnEnter);
			self.option[i].button:SetScript("OnLeave", DropdownButton_OnLeave);   
		end

		self.option[i]:Show();

		if(list[i].text) then
			self.option[i].button:Show();
			self.option[i].button.target = target;
			self.option[i].button.text:SetText(list[i].text);
			self.option[i].button.func = list[i].func;
			self.option[i].button:SetScript("OnClick", DropdownButton_OnClick);
		elseif(list[i].title) then
			self.option[i].header:Show();
			self.option[i].header:SetText(list[i].title);
			if(list[i].divider) then
				self.option[i].divider:Show();
			end
			self.option[i].button:SetScript("OnClick", nil);
		end

		if(i == 1) then
			self.option[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
		elseif((i - 1) % maxPerColumn == 0) then
			self.option[i]:SetPoint("TOPLEFT", self.option[i - maxPerColumn], "TOPRIGHT", 10, 0)
			cols = cols + 1
		else
			self.option[i]:SetPoint("TOPLEFT", self.option[i - 1], "BOTTOMLEFT")
		end
	end

	local maxHeight = (min(maxPerColumn, #list) * 16) + 20;
	local maxWidth = (135 * cols) + (10 * cols) + 10;
	local point = GetScreenPosition(target);

	self:ClearAllPoints();
	self:SetSize(maxWidth, maxHeight);

	if(point:find("BOTTOM")) then
		self:SetPoint("BOTTOMLEFT", target, "TOPLEFT", 10, 10);
	else
		self:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 10, -10);
	end

	if(GameTooltip:IsShown()) then
		GameTooltip:Hide();
	end

	ToggleFrame(self);
end

local function InitializeDropdown()
	SV.Dropdown:SetParent(SV.Screen)
	SV.Dropdown:SetFrameStrata("DIALOG")
	SV.Dropdown:SetFrameLevel(99)
	SV.Dropdown:SetStyle("Frame", "Default")
	SV.Dropdown.option = {}
	SV.Dropdown:SetClampedToScreen(true)
	SV.Dropdown:SetSize(155, 94)

	WorldFrame:HookScript("OnMouseDown", function()
		if(SV.Dropdown:IsShown()) then
			ToggleFrame(SV.Dropdown)
		end
	end)

	SV:ManageVisibility(SV.Dropdown)
end

SV.Events:On("LOAD_ALL_WIDGETS", InitializeDropdown);