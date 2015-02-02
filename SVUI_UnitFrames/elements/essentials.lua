--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
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
local floor         = math.floor;
local ceil         	= math.ceil;
local min 			= math.min;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end 

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local FontMapping = {
	["player"] = "SVUI_Font_Unit", 
	["target"] = "SVUI_Font_Unit", 
	["targettarget"] = "SVUI_Font_Unit_Small",
	["pet"] = "SVUI_Font_Unit", 
	["pettarget"] = "SVUI_Font_Unit_Small",
	["focus"] = "SVUI_Font_Unit",  
	["focustarget"] = "SVUI_Font_Unit_Small",
	["boss"] = "SVUI_Font_Unit", 
	["arena"] = "SVUI_Font_Unit",
	["party"] = "SVUI_Font_Unit_Small",
	["raid"] = "SVUI_Font_Unit_Small",
	["raidpet"] = "SVUI_Font_Unit_Small",
	["tank"] = "SVUI_Font_Unit_Small",
	["assist"] = "SVUI_Font_Unit_Small",
};

local _hook_ActionPanel_OnSizeChanged = function(self)
	local width,height = self:GetSize()
	local widthScale = min(128, width)
	local heightScale = widthScale * 0.25

	self.special[1]:SetSize(widthScale, heightScale)
	self.special[2]:SetSize(widthScale, heightScale)
	self.special[3]:SetSize(height * 0.5, height)
end
-- local MISSING_MODEL_FILE = [[Spells\Blackmagic_precast_base.m2]];
-- local MISSING_MODEL_FILE = [[Spells\Crow_baked.m2]];
-- local MISSING_MODEL_FILE = [[Spells\monsterlure01.m2]];
-- local MISSING_MODEL_FILE = [[interface\buttons\talktome_gears.m2]];
-- local MISSING_MODEL_FILE = [[creature\Ghostlyskullpet\ghostlyskullpet.m2]];
-- local MISSING_MODEL_FILE = [[creature\ghost\ghost.m2]];
-- local MISSING_MODEL_FILE = [[Spells\Monk_travelingmist_missile.m2]];
local ELITE_TOP = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-TOP]];
local ELITE_BOTTOM = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-BOTTOM]];
local ELITE_RIGHT = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-RIGHT]];
local STUNNED_ANIM = [[Interface\Addons\SVUI_UnitFrames\assets\UNIT-STUNNED]];
local AGGRO_TEXTURE = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-AGGRO]];
local token = {[0] = "MANA", [1] = "RAGE", [2] = "FOCUS", [3] = "ENERGY", [6] = "RUNIC_POWER"}
--[[ 
########################################################## 
ACTIONPANEL
##########################################################
]]--
local UpdateThreat = function(self, event, unit)
	if(not unit) then return end
	local threat = self.Threat
	local status = UnitThreatSituation(unit)
	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetBackdropBorderColor(r, g, b)
		threat:Show()
	else
		threat:SetBackdropBorderColor(0, 0, 0, 0.5)
		threat:Hide()
	end
end

local UpdatePlayerThreat = function(self, event, unit)
	if(unit ~= "player") then return end
	local threat = self.Threat
	local aggro = self.Aggro
	local status = UnitThreatSituation(unit)
	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetBackdropBorderColor(r, g, b)
		if(status > 1 and (not aggro:IsShown())) then
			self.Combat:Hide()
			aggro:Show()
		end
		threat:Show()
	else
		threat:SetBackdropBorderColor(0, 0, 0, 0.5)
		if(aggro:IsShown()) then
			aggro:Hide()
			if(UnitAffectingCombat('player')) then
				self.Combat:Show()
			end
		end
		threat:Hide()
	end 
end

local function CreateThreat(frame, unit)
	if(not frame.ActionPanel) then return; end
	local threat = CreateFrame("Frame", nil, frame.ActionPanel)
    threat:SetPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", -3, 3)
    threat:SetPoint("BOTTOMRIGHT", frame.ActionPanel, "BOTTOMRIGHT", 3, -3)
    threat:SetBackdrop({
        edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\GLOW]],
        edgeSize = 3,
        insets = 
        {
            left = 2, 
            right = 2, 
            top = 2, 
            bottom = 2, 
        },
    });
    threat:SetBackdropBorderColor(0,0,0,0.5)

	if(unit == "player") then
		local aggro = CreateFrame("Frame", "SVUI_PlayerThreatAlert", frame)
		aggro:SetFrameStrata("HIGH")
		aggro:SetFrameLevel(30)
		aggro:SetSize(40,40)
		aggro:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -6, -6)
		aggro.texture = aggro:CreateTexture(nil, "OVERLAY")
		aggro.texture:SetAllPoints(aggro)
		aggro.texture:SetTexture(AGGRO_TEXTURE)
		SV.Animate:Pulse(aggro)
		aggro:SetScript("OnShow", function(this)
			this.anim:Play() 
		end);
		aggro:Hide();
		frame.Aggro = aggro

		threat.Override = UpdatePlayerThreat
	else
		threat.Override = UpdateThreat
	end

	return threat 
end

function MOD:CreateActionPanel(frame)
    if(frame.ActionPanel) then return; end

    local panel = CreateFrame('Frame', nil, frame)
    panel:ModPoint('TOPLEFT', frame, 'TOPLEFT', -5, 5)
    panel:ModPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 5, -5)
    panel:SetBackdrop({
		bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
	    edgeSize = 20,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    },
	})
    panel:SetBackdropColor(0,0,0,0)
    panel:SetBackdropBorderColor(1,1,1,1)

    return panel
end

local function CreateNameText(frame, unitName)
	local db = SV.db.UnitFrames
	if(SV.db.UnitFrames[unitName] and SV.db.UnitFrames[unitName].name) then
		db = SV.db.UnitFrames[unitName].name
	end
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	name:SetShadowOffset(2, -2)
	name:SetShadowColor(0, 0, 0, 1)
	if unitName == "target" then
		name:SetPoint("RIGHT", frame)
		name:SetJustifyH("RIGHT")
    	name:SetJustifyV("MIDDLE")
	else
		name:SetPoint("CENTER", frame)
		name:SetJustifyH("CENTER")
    	name:SetJustifyV("MIDDLE")
	end
	return name;
end

function MOD:SetActionPanel(frame, unit, noHealthText, noPowerText, noMiscText)
	if(frame.ActionPanel) then return; end
	frame:SetStyle("Frame", "ActionPanel")
	if(unit and (unit == "target" or unit == "player")) then
		local baseSize = SV.db.font.unitprimary.size / 0.55;
		local info = CreateFrame("Frame", nil, frame)
		info:SetFrameStrata("BACKGROUND")
		info:SetFrameLevel(0)
		info:ModPoint("TOPLEFT", frame.ActionPanel, "BOTTOMLEFT", 0, 1)
		info:ModPoint("TOPRIGHT", frame.ActionPanel, "BOTTOMRIGHT", 0, 1)
		info:SetHeight(baseSize)

		frame.TextGrip = CreateFrame("Frame", nil, info)
		frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetFrameLevel(20)
		frame.TextGrip:SetAllPoints(info)

		frame.InfoPanel = info;

		if(unit == "target") then
			frame.ActionPanel:SetFrameLevel(1)
			if(SV.db.UnitFrames.themed) then
				frame.ActionPanel.special = CreateFrame("Frame", nil, frame.ActionPanel)
				frame.ActionPanel.special:SetAllPoints(frame)
				frame.ActionPanel.special:SetFrameStrata("BACKGROUND")
				frame.ActionPanel.special:SetFrameLevel(0)
				frame.ActionPanel.special[1] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				frame.ActionPanel.special[1]:SetPoint("BOTTOMRIGHT", frame.ActionPanel.special, "TOPRIGHT", 0, 0)
				frame.ActionPanel.special[1]:SetWidth(frame.ActionPanel:GetWidth())
				frame.ActionPanel.special[1]:SetHeight(frame.ActionPanel:GetWidth() * 0.25)
				frame.ActionPanel.special[1]:SetTexture(ELITE_TOP)
				frame.ActionPanel.special[1]:SetVertexColor(1, 0.75, 0)
				frame.ActionPanel.special[1]:SetBlendMode("BLEND")
				frame.ActionPanel.special[2] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				frame.ActionPanel.special[2]:SetPoint("TOPRIGHT", frame.ActionPanel.special, "BOTTOMRIGHT", 0, 0)
				frame.ActionPanel.special[2]:SetWidth(frame.ActionPanel:GetWidth())
				frame.ActionPanel.special[2]:SetHeight(frame.ActionPanel:GetWidth() * 0.25)
				frame.ActionPanel.special[2]:SetTexture(ELITE_BOTTOM)
				frame.ActionPanel.special[2]:SetVertexColor(1, 0.75, 0)
				frame.ActionPanel.special[2]:SetBlendMode("BLEND")
				frame.ActionPanel.special[3] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				frame.ActionPanel.special[3]:SetPoint("LEFT", frame.ActionPanel.special, "RIGHT", 0, 0)
				frame.ActionPanel.special[3]:SetHeight(frame.ActionPanel:GetHeight())
				frame.ActionPanel.special[3]:SetWidth(frame.ActionPanel:GetHeight() * 0.5)
				frame.ActionPanel.special[3]:SetTexture(ELITE_RIGHT)
				frame.ActionPanel.special[3]:SetVertexColor(1, 0.75, 0)
				frame.ActionPanel.special[3]:SetBlendMode("BLEND")
				frame.ActionPanel.special:SetAlpha(0.7)
				frame.ActionPanel.special:Hide()

				frame.ActionPanel:SetScript("OnSizeChanged", _hook_ActionPanel_OnSizeChanged)
			end

			frame.ActionPanel.class = CreateFrame("Frame", nil, frame.TextGrip)
			frame.ActionPanel.class:ModSize(18)
			frame.ActionPanel.class:ModPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", 2, -2)
			frame.ActionPanel.class:SetStyle("Frame", "Default", true, 2, 0, 0)

			frame.ActionPanel.class.texture = frame.ActionPanel.class.Panel:CreateTexture(nil, "BORDER")
			frame.ActionPanel.class.texture:SetAllPoints(frame.ActionPanel.class.Panel)
			frame.ActionPanel.class.texture:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]])

			local border1 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border1:SetTexture(0, 0, 0)
			border1:SetPoint("TOPLEFT")
			border1:SetPoint("TOPRIGHT")
			border1:SetHeight(2)

			local border2 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border2:SetTexture(0, 0, 0)
			border2:SetPoint("BOTTOMLEFT")
			border2:SetPoint("BOTTOMRIGHT")
			border2:SetHeight(2)

			local border3 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border3:SetTexture(0, 0, 0)
			border3:SetPoint("TOPRIGHT")
			border3:SetPoint("BOTTOMRIGHT")
			border3:SetWidth(2)

			local border4 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border4:SetTexture(0, 0, 0)
			border4:SetPoint("TOPLEFT")
			border4:SetPoint("BOTTOMLEFT")
			border4:SetWidth(2)
		else
			frame.LossOfControl = CreateFrame("Frame", nil, frame.TextGrip)
			frame.LossOfControl:SetAllPoints(frame)
			frame.LossOfControl:SetFrameStrata("DIALOG")
			frame.LossOfControl:SetFrameLevel(99)

			local stunned = frame.LossOfControl:CreateTexture(nil, "OVERLAY", nil, 1)
			stunned:SetPoint("CENTER", frame, "CENTER", 0, 0)
			stunned:SetSize(96, 96)
			stunned:SetTexture(STUNNED_ANIM)
			stunned:SetBlendMode("ADD")
			SV.Animate:Sprite4(stunned, 0.12, false, true)
			stunned:Hide()
			frame.LossOfControl.stunned = stunned

			LossOfControlFrame:HookScript("OnShow", function()
				if(_G["SVUI_Player"] and _G["SVUI_Player"].LossOfControl) then
					_G["SVUI_Player"].LossOfControl:Show()
				end
			end)
			LossOfControlFrame:HookScript("OnHide", function()
				if(_G["SVUI_Player"] and _G["SVUI_Player"].LossOfControl) then
					_G["SVUI_Player"].LossOfControl:Hide()
				end
			end)
		end
	elseif(unit == 'pet') then
		local info = CreateFrame("Frame", nil, frame)
		info:SetFrameStrata("BACKGROUND")
		info:SetFrameLevel(0)
		info:ModPoint("TOPLEFT", frame.ActionPanel, "BOTTOMLEFT", -1, 1)
		info:ModPoint("TOPRIGHT", frame.ActionPanel, "BOTTOMRIGHT", 1, 1)
		info:SetHeight(30)

		local bg = info:CreateTexture(nil, "BACKGROUND")
		bg:InsetPoints(info)
		bg:SetTexture(1, 1, 1, 1)
		bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.7)

		frame.TextGrip = CreateFrame("Frame", nil, info)
		frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetFrameLevel(20)
		frame.TextGrip:SetAllPoints(info)
	else
		frame.TextGrip = CreateFrame("Frame", nil, frame)
		frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetFrameLevel(99)
		frame.TextGrip:ModPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", 2, -2)
		frame.TextGrip:ModPoint("BOTTOMRIGHT", frame.ActionPanel, "BOTTOMRIGHT", -2, 2)
	end

	frame.TextGrip.Name = CreateNameText(frame.TextGrip, unit)

	local reverse = unit and (unit == "target" or unit == "focus" or unit == "boss" or unit == "arena") or false;
	local offset, direction
	local fontgroup = FontMapping[unit]
	if(not noHealthText) then
		frame.TextGrip.Health = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Health:SetFontObject(_G[fontgroup])
		offset = reverse and 2 or -2;
		direction = reverse and "LEFT" or "RIGHT";
		frame.TextGrip.Health:ModPoint(direction, frame.TextGrip, direction, offset, 0)
	end

	if(not noPowerText) then
		frame.TextGrip.Power = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Power:SetFontObject(_G[fontgroup])
		offset = reverse and -2 or 2;
		direction = reverse and "RIGHT" or "LEFT";
		frame.TextGrip.Power:ModPoint(direction, frame.TextGrip, direction, offset, 0)
	end

	if(not noMiscText) then
		frame.TextGrip.Misc = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Misc:SetFontObject(_G[fontgroup])
		frame.TextGrip.Misc:ModPoint("CENTER", frame, "CENTER", 0, 0)
	end

	frame.MasterGrip = CreateFrame("Frame", nil, frame)
	frame.MasterGrip:SetAllPoints(frame)

	frame.StatusPanel = CreateFrame("Frame", nil, frame.MasterGrip)
	frame.StatusPanel:EnableMouse(false)

	if(unit and (unit == "player" or unit == "pet" or unit == "target" or unit == "targettarget" or unit == "focus" or unit == "focustarget")) then
		frame.StatusPanel:SetAllPoints(frame.MasterGrip)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-TAPPED]]
		}
	else
		frame.StatusPanel:SetSize(50, 50)
		frame.StatusPanel:SetPoint("CENTER", frame.MasterGrip, "CENTER", 0, 0)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-TAPPED]]
		}
	end

	frame.StatusPanel.texture = frame.StatusPanel:CreateTexture(nil, "OVERLAY")
	frame.StatusPanel.texture:SetAllPoints()
	frame.StatusPanel:SetFrameStrata("LOW")
	frame.StatusPanel:SetFrameLevel(28)

	frame.Threat = CreateThreat(frame, unit)
end
--[[ 
########################################################## 
HEALTH
##########################################################
]]--
function MOD:OverlayHealthUpdate(event, unit)
	if(self.unit ~= unit) or not unit then return end
	local health = self.Health

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	local invisible = ((min == max) or UnitIsDeadOrGhost(unit) or disconnected);
	local tapped = (UnitIsTapped(unit) and (not UnitIsTappedByPlayer(unit)));
	if invisible then health.lowAlerted = false end
	
	if health.fillInverted then
		health:SetReverseFill(true)
	end

	health:SetMinMaxValues(-max, 0)
	health:SetValue(-min)

	health.percent = invisible and 100 or ((min / max) * 100)
	
	health.disconnected = disconnected

	if health.frequentUpdates ~= health.__frequentUpdates then
		health.__frequentUpdates = health.frequentUpdates
		self:UpdateFrequentUpdates()
	end

	local bg = health.bg;
	local mu
	if(max == 0) then
		mu = 0
	else
		mu = (min / max)
	end

	if(invisible) then
		health:SetStatusBarColor(0.6,0.4,1,0.5)
	elseif(health.colorOverlay) then
		local t = oUF_SVUI.colors.health
		health:SetStatusBarColor(t[1], t[2], t[3], 0.9)
	else
		health:SetStatusBarColor(1, 0.25 * mu, 0, 0.85)
	end

	if(bg) then 
		bg:SetVertexColor(0,0,0,0)
	end

	if self.ResurrectIcon then 
		self.ResurrectIcon:SetAlpha(min == 0 and 1 or 0)
	end

	if self.isForced then 
		local current = random(1,max)
		health:SetValue(-current)
	end

	if(health.LowAlertFunc and UnitIsPlayer("target") and health.percent < 6 and UnitIsEnemy("target", "player") and not health.lowAlerted) then
		health.lowAlerted = true
		health.LowAlertFunc(self)
	end

	if(health.PostUpdate) then
		return health.PostUpdate(self, health.percent)
	end
end 

local RefreshHealthBar = function(self, overlay)
	if(overlay) then
		self.Health.Override = MOD.OverlayHealthUpdate;
	else
		self.Health.Override = nil;
	end 
end

function MOD:CreateHealthBar(frame, hasbg)
	local healthBar = CreateFrame("StatusBar", nil, frame)
	healthBar:SetFrameStrata("LOW")
	healthBar:SetFrameLevel(4)
	healthBar:SetStatusBarTexture(SV.Media.bar.default);
	
	if hasbg then 
		healthBar.bg = healthBar:CreateTexture(nil, "BORDER")
		healthBar.bg:SetAllPoints()
		healthBar.bg:SetTexture(SV.Media.bar.gradient)
		healthBar.bg:SetVertexColor(0.4, 0.1, 0.1)
		healthBar.bg.multiplier = 0.25
	end 

	healthBar.noupdate = false;
	healthBar.fillInverted = false;
	healthBar.gridMode = false;
	healthBar.colorTapping = true;
	healthBar.colorDisconnected = true;
	healthBar.Override = false;

	frame.RefreshHealthBar = RefreshHealthBar

	return healthBar 
end
--[[ 
########################################################## 
POWER
##########################################################
]]--
local PostUpdateAltPower = function(self, min, current, max)
	local remaining = floor(current  /  max  *  100)
	local parent = self:GetParent()
	if remaining < 35 then 
		self:SetStatusBarColor(0, 1, 0)
	elseif remaining < 70 then 
		self:SetStatusBarColor(1, 1, 0)
	else 
		self:SetStatusBarColor(1, 0, 0)
	end 
	local unit = parent.unit;
	if(unit == "player" and self.text) then 
		local apInfo = select(10, UnitAlternatePowerInfo(unit))
		if remaining > 0 then 
			self.text:SetText(apInfo..": "..format("%d%%", remaining))
		else 
			self.text:SetText(apInfo..": 0%")
		end 
	elseif(unit and unit:find("boss%d") and self.text) then 
		self.text:SetTextColor(self:GetStatusBarColor())
		if not parent.TextGrip.Power:GetText() or parent.TextGrip.Power:GetText() == "" then 
			self.text:ModPoint("BOTTOMRIGHT", parent.Health, "BOTTOMRIGHT")
		else 
			self.text:ModPoint("RIGHT", parent.TextGrip.Power, "LEFT", 2, 0)
		end 
		if remaining > 0 then 
			self.text:SetText("|cffD7BEA5[|r"..format("%d%%", remaining).."|cffD7BEA5]|r")
		else 
			self.text:SetText(nil)
		end 
	end 
end

function MOD:CreatePowerBar(frame, bg)
	local power = CreateFrame("StatusBar", nil, frame)
	power:SetStatusBarTexture(SV.Media.bar.default)
	power:SetStyle("Frame", "Bar")
	power:SetFrameStrata("LOW")
	power:SetFrameLevel(6)
	if bg then 
		power.bg = power:CreateTexture(nil, "BORDER")
		power.bg:SetAllPoints()
		power.bg:SetTexture(SV.BaseTexture)
		power.bg.multiplier = 0.2 
	end 
	power.colorDisconnected = false;
	power.colorTapping = false;
	power.PostUpdate = MOD.PostUpdatePower;
	return power 
end 

function MOD:CreateAltPowerBar(frame)
	local altPower = CreateFrame("StatusBar", nil, frame)
	altPower:SetStatusBarTexture(SV.Media.bar.default)
	altPower:SetStyle("Frame", "Bar")
	altPower:GetStatusBarTexture():SetHorizTile(false)
	altPower:SetFrameStrata("LOW")
	altPower:SetFrameLevel(8)
	altPower.text = altPower:CreateFontString(nil, "OVERLAY")
	altPower.text:SetPoint("CENTER")
	altPower.text:SetJustifyH("CENTER")
	altPower.text:SetFontObject(SVUI_Font_Unit)
	altPower.PostUpdate = PostUpdateAltPower;
	return altPower 
end

function MOD:PostUpdatePower(unit, value, max)
	local db = SV.db.UnitFrames[unit]
	local powerType, _, _, _, _ = UnitPowerType(unit)
	local parent = self:GetParent()
	if parent.isForced then
		value = random(1, max)
		powerType = random(0, 4)
		self:SetValue(value)
	end 
	local colors = oUF_SVUI.colors.power[token[powerType]]
	local mult = self.bg.multiplier or 1;
	local isPlayer = UnitPlayerControlled(unit)
	if isPlayer and self.colorClass then 
		local _, class = UnitClassBase(unit);
		colors = oUF_SVUI["colors"].class[class]
	elseif not isPlayer then 
		local react = UnitReaction("player", unit)
		colors = oUF_SVUI["colors"].reaction[react]
	end 
	if not colors then return end
	self:SetStatusBarColor(colors[1], colors[2], colors[3])
	self.bg:SetVertexColor(colors[1] * mult, colors[2] * mult, colors[3] * mult)
end
--[[ 
########################################################## 
PORTRAIT
##########################################################
]]--
function MOD:CreatePortrait(frame,smallUnit,isPlayer)
	-- 3D Portrait
	local portrait3D = CreateFrame("PlayerModel",nil,frame)
	portrait3D:SetFrameStrata("LOW")
	portrait3D:SetFrameLevel(2)

	if smallUnit then 
		portrait3D:SetStyle("Frame", "UnitSmall")
	else 
		portrait3D:SetStyle("Frame", "UnitLarge")
	end 

	local overlay = CreateFrame("Frame",nil,portrait3D)
	overlay:SetAllPoints(portrait3D.Panel)
	overlay:SetFrameLevel(3)
	portrait3D.overlay = overlay;
	portrait3D.UserRotation = 0;
	portrait3D.UserCamDistance = 1.3;

	-- 2D Portrait
	local portrait2Danchor = CreateFrame('Frame',nil,frame)
	portrait2Danchor:SetFrameStrata("LOW")
	portrait2Danchor:SetFrameLevel(2)

	local portrait2D = portrait2Danchor:CreateTexture(nil,'OVERLAY')
	portrait2D:SetTexCoord(0.15,0.85,0.15,0.85)
	portrait2D:SetAllPoints(portrait2Danchor)
	portrait2D.anchor = portrait2Danchor;
	if smallUnit then 
		portrait2Danchor:SetStyle("!_Frame", "UnitSmall")
	else 
		portrait2Danchor:SetStyle("!_Frame", "UnitLarge")
	end 
	portrait2D.Panel = portrait2Danchor.Panel;

	local overlay = CreateFrame("Frame",nil,portrait2Danchor)
	overlay:SetAllPoints(portrait2D.Panel)
	overlay:SetFrameLevel(3)
	portrait2D.overlay = overlay;

	-- Assign To Frame
	frame.PortraitModel = portrait3D;
	frame.PortraitTexture = portrait2D;
end