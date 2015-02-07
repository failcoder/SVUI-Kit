--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local error 	= _G.error;
local pcall 	= _G.pcall;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper, find = string.lower, string.upper, string.find;
--[[ TABLE METHODS ]]--
local twipe = table.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local LSM = LibStub("LibSharedMedia-3.0")
local NewHook = hooksecurefunc;
--[[ 
########################################################## 
 /$$$$$$$$/$$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$
| $$_____/ $$__  $$ /$$__  $$| $$$    /$$$| $$_____/
| $$     | $$  \ $$| $$  \ $$| $$$$  /$$$$| $$      
| $$$$$  | $$$$$$$/| $$$$$$$$| $$ $$/$$ $$| $$$$$   
| $$__/  | $$__  $$| $$__  $$| $$  $$$| $$| $$__/   
| $$     | $$  \ $$| $$  | $$| $$\  $ | $$| $$      
| $$     | $$  | $$| $$  | $$| $$ \/  | $$| $$$$$$$$
|__/     |__/  |__/|__/  |__/|__/     |__/|________/
##########################################################
]]--
function MOD:ApplyFrameStyle(this, template, noStripping, fullStripping)
	if(not this or (this and this.Panel)) then return end  
	if not noStripping then this:RemoveTextures(fullStripping) end
	template = template or "Transparent"
	this:SetStyle("Frame", template)
end 

function MOD:ApplyAdjustedFrameStyle(this, template, xTopleft, yTopleft, xBottomright, yBottomright)
	if(not this or (this and this.Panel)) then return end
	template = template or "Transparent"
	this:SetStyle("Frame", template)
	this.Panel:SetPoint("TOPLEFT", this, "TOPLEFT", xTopleft, yTopleft)
	this.Panel:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", xBottomright, yBottomright)
end 

function MOD:ApplyFixedFrameStyle(this, template, noStripping, fullStripping)
	if(not this or (this and this.Panel)) then return end  
	if not noStripping then this:RemoveTextures(fullStripping) end
	template = template or "Transparent"
    this:SetStyle("!_Frame", template)
end

function MOD:ApplyWindowStyle(this, action, fullStrip)
	if(not this or (this and this.Panel)) then return end
	local template = action and "WindowAlternate" or "Window"
	local baselevel = this:GetFrameLevel()
	if(baselevel < 1) then 
		this:SetFrameLevel(1)
	end
	
	this:RemoveTextures(fullStrip)
	this:SetStyle("Frame", template)
end

function MOD:ApplyAdjustedWindowStyle(this, action, fullStrip, padding, xOffset, yOffset)
	if(not this or (this and this.Panel)) then return end
	local template = action and "WindowAlternate" or "Window"
	local baselevel = this:GetFrameLevel()
	if(baselevel < 1) then 
		this:SetFrameLevel(1)
	end
	
	this:RemoveTextures(fullStrip)
	this:SetStyle("Frame", template, false, padding, xOffset, yOffset)
end
--[[
########################################################## 
 /$$$$$$$$/$$$$$$   /$$$$$$  /$$    /$$$$$$$$/$$$$$$ /$$$$$$$ 
|__  $$__/$$__  $$ /$$__  $$| $$   |__  $$__/_  $$_/| $$__  $$
   | $$ | $$  \ $$| $$  \ $$| $$      | $$    | $$  | $$  \ $$
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$$$$$$/
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$____/ 
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$      
   | $$ |  $$$$$$/|  $$$$$$/| $$$$$$$$| $$   /$$$$$$| $$      
   |__/  \______/  \______/ |________/|__/  |______/|__/      
##########################################################
--]]
local Tooltip_OnShow = function(self)
	self:SetBackdrop({
		bgFile = SV.BaseTexture,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		edgeSize=1
	})
	self:SetBackdropColor(0,0,0,0.8)
	self:SetBackdropBorderColor(0,0,0)
end

function MOD:ApplyTooltipStyle(frame)
	if(not frame or (frame and frame.SkinsHooked)) then return end
	frame:HookScript('OnShow', Tooltip_OnShow)
	frame.SkinsHooked = true
end 
--[[
########################################################## 
  /$$$$$$  /$$       /$$$$$$$$ /$$$$$$$  /$$$$$$$$
 /$$__  $$| $$      | $$_____/| $$__  $$|__  $$__/
| $$  \ $$| $$      | $$      | $$  \ $$   | $$   
| $$$$$$$$| $$      | $$$$$   | $$$$$$$/   | $$   
| $$__  $$| $$      | $$__/   | $$__  $$   | $$   
| $$  | $$| $$      | $$      | $$  \ $$   | $$   
| $$  | $$| $$$$$$$$| $$$$$$$$| $$  | $$   | $$   
|__/  |__/|________/|________/|__/  |__/   |__/   
##########################################################
--]]
local SetAlertColor = function(self, r, g, b)
	self.AlertPanel:SetBackdropColor(r,g,b)
	self.AlertPanel.left:SetVertexColor(r,g,b)
	self.AlertPanel.right:SetVertexColor(r,g,b)
	self.AlertPanel.top:SetVertexColor(r,g,b)
	self.AlertPanel.bottom:SetVertexColor(r,g,b)
end

function MOD:ApplyAlertStyle(frame, typeIndex)
	if(not frame or (frame and frame.AlertPanel)) then return end

	local alertType = (typeIndex and typeIndex == 2) and "typeB" or "typeA";

	local TEMPLATE = SV.Media.alert[alertType];
	local r,g,b = unpack(TEMPLATE.COLOR);
	local size = frame:GetHeight();
	local half = size * 0.5;
	local offset = size * 0.1;
	local lvl = frame:GetFrameLevel();

	if lvl < 1 then lvl = 1 end

    local alertpanel = CreateFrame("Frame", nil, frame)
    alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", offset, 0)
    alertpanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -offset, 0)
    alertpanel:SetFrameLevel(lvl - 1)
    alertpanel:SetBackdrop({
        bgFile = TEMPLATE.BG
    })
    alertpanel:SetBackdropColor(r,g,b)

    --[[ LEFT ]]--
    alertpanel.left = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.left:SetTexture(TEMPLATE.LEFT)
    alertpanel.left:SetVertexColor(r,g,b)
    alertpanel.left:SetPoint("TOPRIGHT", alertpanel, "TOPLEFT", 0, 0)
    alertpanel.left:SetPoint("BOTTOMRIGHT", alertpanel, "BOTTOMLEFT", 0, 0)
    alertpanel.left:SetWidth(size)

    --[[ RIGHT ]]--
    alertpanel.right = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.right:SetTexture(TEMPLATE.RIGHT)
    alertpanel.right:SetVertexColor(r,g,b)
    alertpanel.right:SetPoint("TOPLEFT", alertpanel, "TOPRIGHT", 0, 0)
    alertpanel.right:SetPoint("BOTTOMLEFT", alertpanel, "BOTTOMRIGHT", 0, 0)
    alertpanel.right:SetWidth(size * 2)

    --[[ TOP ]]--
    alertpanel.top = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.top:SetTexture(TEMPLATE.TOP)
    alertpanel.top:SetPoint("BOTTOMLEFT", alertpanel, "TOPLEFT", 0, 0)
    alertpanel.top:SetPoint("BOTTOMRIGHT", alertpanel, "TOPRIGHT", 0, 0)
    alertpanel.top:SetHeight(half)

    --[[ BOTTOM ]]--
    alertpanel.bottom = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.bottom:SetTexture(TEMPLATE.BOTTOM)
    alertpanel.bottom:SetPoint("TOPLEFT", alertpanel, "BOTTOMLEFT", 0, 0)
    alertpanel.bottom:SetPoint("TOPRIGHT", alertpanel, "BOTTOMRIGHT", 0, 0)
    alertpanel.bottom:SetWidth(half)

    frame.AlertPanel = alertpanel
    frame.AlertColor = SetAlertColor
end

local SetIconAlertColor = function(self, r, g, b)
	--self.AlertPanel.bg:SetGradient('VERTICAL', (r*0.5), (g*0.5), (b*0.5), r, g, b)
	self.AlertPanel.icon:SetGradient('VERTICAL', (r*0.5), (g*0.5), (b*0.5), r, g, b)
end

function MOD:ApplyItemAlertStyle(frame, noicon)
	if(not frame or (frame and frame.AlertPanel)) then return end

	local size = frame:GetWidth() * 0.5;
	local lvl = frame:GetFrameLevel();

	if lvl < 1 then lvl = 1 end

    local alertpanel = CreateFrame("Frame", nil, frame)
    alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", -25, 10)
    alertpanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10)
    alertpanel:SetHeight(size)
    alertpanel:SetFrameLevel(lvl - 1)

    --[[ FRAME BG ]]--
    alertpanel.bg = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -5)
    alertpanel.bg:SetAllPoints()
    alertpanel.bg:SetTexture(SV.Media.alert.full)
    alertpanel.bg:SetGradient('VERTICAL', 0, 0, 0, .37, .32, .29)

    if(not noicon) then
	    --[[ ICON BG ]]--
	    alertpanel.icon = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -2)
	    alertpanel.icon:SetTexture(SV.Media.alert.icon)
	    alertpanel.icon:SetGradient('VERTICAL', 1, 0.35, 0, 1, 1, 0)
	    alertpanel.icon:SetPoint("LEFT", alertpanel, "LEFT", -45, 20)
	    alertpanel.icon:SetSize(size, size)
	    frame.AlertColor = SetIconAlertColor
	end

    frame.AlertPanel = alertpanel
end
--[[
########################################################## 
 /$$      /$$ /$$$$$$  /$$$$$$   /$$$$$$ 
| $$$    /$$$|_  $$_/ /$$__  $$ /$$__  $$
| $$$$  /$$$$  | $$  | $$  \__/| $$  \__/
| $$ $$/$$ $$  | $$  |  $$$$$$ | $$      
| $$  $$$| $$  | $$   \____  $$| $$      
| $$\  $ | $$  | $$   /$$  \ $$| $$    $$
| $$ \/  | $$ /$$$$$$|  $$$$$$/|  $$$$$$/
|__/     |__/|______/ \______/  \______/ 
##########################################################
--]]
function MOD:ApplyEditBoxStyle(this, width, height, x, y)
	if not this then return end
	this:RemoveTextures(true)
    this:SetStyle("Editbox", x, y)
    if width then this:ModWidth(width) end
	if height then this:ModHeight(height) end
end