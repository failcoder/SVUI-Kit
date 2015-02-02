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
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.Layout

if(not MOD) then return end
--[[
 /$$$$$$$$/$$   /$$ /$$$$$$$$       /$$   /$$  /$$$$$$  /$$   /$$ /$$$$$$$ 
|__  $$__/ $$  | $$| $$_____/      | $$  | $$ /$$__  $$| $$$ | $$| $$__  $$
   | $$  | $$  | $$| $$            | $$  | $$| $$  \ $$| $$$$| $$| $$  \ $$
   | $$  | $$$$$$$$| $$$$$         | $$$$$$$$| $$$$$$$$| $$ $$ $$| $$  | $$
   | $$  | $$__  $$| $$__/         | $$__  $$| $$__  $$| $$  $$$$| $$  | $$
   | $$  | $$  | $$| $$            | $$  | $$| $$  | $$| $$\  $$$| $$  | $$
   | $$  | $$  | $$| $$$$$$$$      | $$  | $$| $$  | $$| $$ \  $$| $$$$$$$/
   |__/  |__/  |__/|________/      |__/  |__/|__/  |__/|__/  \__/|_______/ 
--]]
local TheHand = CreateFrame("Frame", "SVUI_HandOfLayout", UIParent)
TheHand:SetFrameStrata("DIALOG")
TheHand:SetFrameLevel(99)
TheHand:SetClampedToScreen(true)
TheHand:SetSize(128,128)
TheHand:SetPoint("CENTER")
TheHand.bg = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.bg:SetAllPoints(TheHand)
TheHand.bg:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-HAND-OFF]])
TheHand.energy = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.energy:SetAllPoints(TheHand)
TheHand.energy:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-ENERGY]])
SV.Animate:Orbit(TheHand.energy, 10)
TheHand.flash = TheHand.energy.anim;
TheHand.energy:Hide()
TheHand.elapsedTime = 0;
TheHand.flash:Stop()
TheHand:Hide()
TheHand.UserHeld = false;

local TheHand_OnUpdate = function(self, elapsed)
	self.elapsedTime = self.elapsedTime  +  elapsed
	if self.elapsedTime > 0.1 then
		self.elapsedTime = 0
		local x, y = GetCursorPosition()
		local scale = SV.Screen:GetEffectiveScale()
		self:SetPoint("CENTER", SV.Screen, "BOTTOMLEFT", (x  /  scale)  +  50, (y  /  scale)  +  50)
	end 
end

function TheHand:Enable()
	self:Show()
	self.bg:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-HAND-ON]])
	self.energy:Show()
	self.flash:Play()
	self:SetScript("OnUpdate", TheHand_OnUpdate) 
end

function TheHand:Disable()
	self.flash:Stop()
	self.energy:Hide()
	self.bg:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-HAND-OFF]])
	self:SetScript("OnUpdate", nil)
	self.elapsedTime = 0
	self:Hide()
end
--[[
 /$$      /$$                       /$$               /$$          
| $$$    /$$$                      | $$              | $$          
| $$$$  /$$$$  /$$$$$$  /$$$$$$$  /$$$$$$    /$$$$$$ | $$  /$$$$$$ 
| $$ $$/$$ $$ /$$__  $$| $$__  $$|_  $$_/   |____  $$| $$ /$$__  $$
| $$  $$$| $$| $$$$$$$$| $$  \ $$  | $$      /$$$$$$$| $$| $$  \ $$
| $$\  $ | $$| $$_____/| $$  | $$  | $$ /$$ /$$__  $$| $$| $$  | $$
| $$ \/  | $$|  $$$$$$$| $$  | $$  |  $$$$/|  $$$$$$$| $$|  $$$$$$/
|__/     |__/ \_______/|__/  |__/   \___/   \_______/|__/ \______/ 
--]]
local function ResetAllAlphas()
	for entry,_ in pairs(MOD.Frames) do
		local frame = _G[entry]
		if(frame) then 
			frame:SetAlpha(0.4)
		end 
	end 
end

function MOD:PostDragStart(frame)
	TheHand:Enable()
	TheHand.UserHeld = true 
end

function MOD:PostDragStop(frame)
	TheHand.UserHeld = false;
	TheHand:Disable()
end

function MOD:Override_OnEnter(frame)
	if TheHand.UserHeld then return end
	ResetAllAlphas()
	frame:SetAlpha(1)
	frame.text:SetTextColor(0, 1, 1)
	frame:SetBackdropBorderColor(0, 0.7, 1)
	UpdateFrameTarget = frame;
	SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-ON]])
	TheHand:SetPoint("CENTER", frame, "TOP", 0, 0)
	TheHand:Show()
	if CurrentFrameTarget ~= frame then 
		SVUI_LayoutPrecision:Hide()
		frame:GetScript("OnMouseUp")(frame)
	end
end

function MOD:Override_OnLeave(frame)
	if TheHand.UserHeld then return end
	frame.text:SetTextColor(0.5, 0.5, 0.5)
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
	SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-OFF]])
	TheHand:Hide()
	if(CurrentFrameTarget ~= frame and not SVUI_LayoutPrecision:IsShown()) then
		frame:SetAlpha(0.4)
	end
end

function MOD:Override_OnMouseDown(frame, callback)
	TheHand.UserHeld = false;
	if(CurrentFrameTarget == self and not SVUI_LayoutPrecision:IsShown()) then
		callback()
		SVUI_LayoutPrecision:Show()
	else
		SVUI_LayoutPrecision:Hide()
	end
	if SV.db.general.stickyFrames then 
		StickyStopMoving(self)
	else 
		self:StopMovingOrSizing()
	end
end

SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\MENTALO-OFF]]);