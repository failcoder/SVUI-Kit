--[[
##############################################################################
M O D K I T   By: S.Jackson
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
--[[ 
########################################################## 
HEALTH
##########################################################
]]--
local Anim_OnUpdate = function(self)
	local parent = self.parent
	local coord = self._coords;
	parent:SetTexCoord(coord[1],coord[2],coord[3],coord[4])
end 

local Anim_OnPlay = function(self)
	local parent = self.parent
	parent:SetAlpha(1)
	if not parent:IsShown() then
		parent:Show()
	end
end 

local Anim_OnStop = function(self)
	local parent = self.parent
	parent:SetAlpha(0)
	if parent:IsShown() then
		parent:Hide()
	end
end 

local function SetNewAnimation(frame, animType, parent)
	local anim = frame:CreateAnimation(animType)
	anim.parent = parent
	return anim
end

local function SetAnim(frame, parent)
	local speed = 0.08
	frame.anim = frame:CreateAnimationGroup("Sprite")
	frame.anim.parent = parent;
	frame.anim:SetScript("OnPlay", Anim_OnPlay)
	frame.anim:SetScript("OnFinished", Anim_OnStop)
	frame.anim:SetScript("OnStop", Anim_OnStop)

	frame.anim[1] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[1]:SetOrder(1)
	frame.anim[1]:SetDuration(speed)
	frame.anim[1]._coords = {0,0.5,0,0.25}
	frame.anim[1]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[2] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[2]:SetOrder(2)
	frame.anim[2]:SetDuration(speed)
	frame.anim[2]._coords = {0.5,1,0,0.25}
	frame.anim[2]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[3] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[3]:SetOrder(3)
	frame.anim[3]:SetDuration(speed)
	frame.anim[3]._coords = {0,0.5,0.25,0.5}
	frame.anim[3]:SetScript("OnUpdate", Anim_OnUpdate)
	
	frame.anim[4] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[4]:SetOrder(4)
	frame.anim[4]:SetDuration(speed)
	frame.anim[4]._coords = {0.5,1,0.25,0.5}
	frame.anim[4]:SetScript("OnUpdate", Anim_OnUpdate)
	
	frame.anim[5] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[5]:SetOrder(5)
	frame.anim[5]:SetDuration(speed)
	frame.anim[5]._coords = {0,0.5,0.5,0.75}
	frame.anim[5]:SetScript("OnUpdate", Anim_OnUpdate)
	
	frame.anim[6] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[6]:SetOrder(6)
	frame.anim[6]:SetDuration(speed)
	frame.anim[6]._coords = {0.5,1,0.5,0.75}
	frame.anim[6]:SetScript("OnUpdate", Anim_OnUpdate)
	
	frame.anim[7] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[7]:SetOrder(7)
	frame.anim[7]:SetDuration(speed)
	frame.anim[7]._coords = {0,0.5,0.75,1}
	frame.anim[7]:SetScript("OnUpdate", Anim_OnUpdate)
	
	frame.anim[8] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[8]:SetOrder(8)
	frame.anim[8]:SetDuration(speed)
	frame.anim[8]._coords = {0.5,1,0.75,1}
	frame.anim[8]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim:SetLooping("REPEAT")
end

local _OverlayHealthUpdate = function(self, event, unit)
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

	if(invisible or not health.overlayAnimation) then
		health.animation[1].anim:Stop()
		health.animation[1]:SetAlpha(0)
	end

	if(invisible) then
		health:SetStatusBarColor(0.6,0.4,1,0.5)
		health.animation[1]:SetVertexColor(0.8,0.3,1,0.4)
	elseif(health.colorOverlay) then
		local t = SV.UnitFrames.oUF.colors.health
		health:SetStatusBarColor(t[1], t[2], t[3], 0.9)
	else
		health:SetStatusBarColor(1, 0.25 * mu, 0, 0.85)
		health.animation[1]:SetVertexColor(1, 0.1 * mu, 0, 0.5) 
	end

	if(bg) then 
		bg:SetVertexColor(0,0,0,0)
	end

	if(health.overlayAnimation and not invisible) then 
		if(mu <= 0.25) then
			health.animation[1]:SetAlpha(1)
			health.animation[1].anim:Play()
		else
			health.animation[1].anim:Stop()
			health.animation[1]:SetAlpha(0)
		end
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
		self.Health.Override = SV.UnitFrames.OverlayHealthUpdate;
	else
		self.Health.Override = nil;
	end 
end

local _CreateHealthBar = function(self, frame, hasbg)
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

	local flasher = CreateFrame("Frame", nil, frame)
	flasher:SetFrameLevel(3)
	flasher:SetAllPoints(healthBar)

	flasher[1] = flasher:CreateTexture(nil, "OVERLAY", nil, 1)
	flasher[1]:SetTexture([[Interface\Addons\SVUI_UnitFrames\assets\UNIT-HEALTH-ANIMATION]])
	flasher[1]:SetTexCoord(0, 0.5, 0, 0.25)
	flasher[1]:SetVertexColor(1, 0.3, 0.1, 0.5)
	flasher[1]:SetBlendMode("ADD")
	flasher[1]:SetAllPoints(flasher)
	SetAnim(flasher[1], flasher)
	flasher:Hide() 

	healthBar.animation = flasher
	healthBar.noupdate = false;
	healthBar.fillInverted = false;
	healthBar.gridMode = false;
	healthBar.colorTapping = true;
	healthBar.colorDisconnected = true;
	healthBar.Override = false;

	frame.RefreshHealthBar = RefreshHealthBar
	
	return healthBar 
end

local _CreateActionPanel = function(self, frame, offset)
    if(frame.ActionPanel) then return; end
    offset = offset or 2

    local panel = CreateFrame('Frame', nil, frame)
    panel:ModPoint('TOPLEFT', frame, 'TOPLEFT', -1, 1)
    panel:ModPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)
    panel:SetBackdrop({
	    bgFile = [[Interface\BUTTONS\WHITE8X8]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\BUTTONS\WHITE8X8]],
	    edgeSize = 3,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    }, 
	})
    panel:SetBackdropColor(0,0,0,1)
    panel:SetBackdropBorderColor(0,0,0,1)

    panel:SetFrameStrata("BACKGROUND")
    panel:SetFrameLevel(0)

    --[[ UNDERLAY BORDER ]]--
    local borderLeft = panel:CreateTexture(nil, "BORDER")
    borderLeft:SetTexture(0, 0, 0)
    borderLeft:SetPoint("TOPLEFT")
    borderLeft:SetPoint("BOTTOMLEFT")
    borderLeft:SetWidth(offset)

    local borderRight = panel:CreateTexture(nil, "BORDER")
    borderRight:SetTexture(0, 0, 0)
    borderRight:SetPoint("TOPRIGHT")
    borderRight:SetPoint("BOTTOMRIGHT")
    borderRight:SetWidth(offset)

    local borderTop = panel:CreateTexture(nil, "BORDER")
    borderTop:SetTexture(0, 0, 0)
    borderTop:SetPoint("TOPLEFT")
    borderTop:SetPoint("TOPRIGHT")
    borderTop:SetHeight(offset)

    local borderBottom = panel:CreateTexture(nil, "BORDER")
    borderBottom:SetTexture(0, 0, 0)
    borderBottom:SetPoint("BOTTOMLEFT")
    borderBottom:SetPoint("BOTTOMRIGHT")
    borderBottom:SetHeight(offset)

    --[[ OVERLAY BORDER ]]--
    panel.border = {}
	panel.border[1] = panel:CreateTexture(nil, "OVERLAY")
	panel.border[1]:SetTexture(0, 0, 0)
	panel.border[1]:SetPoint("TOPLEFT")
	panel.border[1]:SetPoint("TOPRIGHT")
	panel.border[1]:SetHeight(2)

	panel.border[2] = panel:CreateTexture(nil, "OVERLAY")
	panel.border[2]:SetTexture(0, 0, 0)
	panel.border[2]:SetPoint("BOTTOMLEFT")
	panel.border[2]:SetPoint("BOTTOMRIGHT")
	panel.border[2]:SetHeight(2)

	panel.border[3] = panel:CreateTexture(nil, "OVERLAY")
	panel.border[3]:SetTexture(0, 0, 0)
	panel.border[3]:SetPoint("TOPRIGHT")
	panel.border[3]:SetPoint("BOTTOMRIGHT")
	panel.border[3]:SetWidth(2)

	panel.border[4] = panel:CreateTexture(nil, "OVERLAY")
	panel.border[4]:SetTexture(0, 0, 0)
	panel.border[4]:SetPoint("TOPLEFT")
	panel.border[4]:SetPoint("BOTTOMLEFT")
	panel.border[4]:SetWidth(2)

    return panel
end

local function ADDInfoBG(frame)
	local bg = frame.InfoPanel:CreateTexture(nil, "BACKGROUND")
	bg:ModPoint("TOPLEFT", frame.ActionPanel, "BOTTOMLEFT", 0, 1)
	bg:ModPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", 0, 0)
	bg:SetTexture(1, 1, 1, 1)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.7)
end

function THEME:LoadUFOverrides()
	SV.UnitFrames.CreateHealthBar = _CreateHealthBar
	SV.UnitFrames.OverlayHealthUpdate = _OverlayHealthUpdate
	--SV.UnitFrames.CreateActionPanel = _CreateActionPanel

	function SV.UnitFrames:PostFrameForge()
		local target = _G["SVUI_Target"]
		local xray = CreateFrame("Button", "SVUI_XRayFocus", target, "SecureActionButtonTemplate")
		xray:EnableMouse(true)
		xray:RegisterForClicks("AnyUp")
		xray:SetAttribute("type", "macro")
		xray:SetAttribute("macrotext", "/focus")
		xray:ModSize(64,64)
		xray:SetFrameStrata("MEDIUM")
		xray.icon = xray:CreateTexture(nil,"ARTWORK")
		xray.icon:SetTexture("Interface\\Addons\\SVUI_!Core\\assets\\textures\\UNIT-XRAY")
		xray.icon:SetAllPoints(xray)
		xray.icon:SetAlpha(0)
		xray:SetScript("OnLeave", function(self) GameTooltip:Hide() self.icon:SetAlpha(0) end)
		xray:SetScript("OnEnter", function(self)
			self.icon:SetAlpha(1)
			local anchor1, anchor2 = SV:GetScreenXY(self) 
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(anchor1, self, anchor2)
			GameTooltip:SetText(FOCUSTARGET)
		end)
		
		target.XRay = xray
	    target.XRay:SetPoint("TOPRIGHT", 12, 12) 

	    local focus = _G["SVUI_FocusTarget"]

		local close = CreateFrame("Button", "SVUI_XRayFocusClear", focus, "SecureActionButtonTemplate")
		close:EnableMouse(true)
		close:RegisterForClicks("AnyUp")
		close:SetAttribute("type", "macro")
		close:SetAttribute("macrotext", "/clearfocus")
		close:ModSize(50,50)
		close:SetFrameStrata("MEDIUM")
		close.icon = close:CreateTexture(nil,"ARTWORK")
		close.icon:SetTexture("Interface\\Addons\\SVUI_Theme_Comics\\assets\\textures\\UNIT-XRAY-CLOSE")
		close.icon:SetAllPoints(close)
		close.icon:SetAlpha(0)
		close.icon:SetVertexColor(1,0.2,0.1)
		close:SetScript("OnLeave", function(self) GameTooltip:Hide() self.icon:SetAlpha(0) end)
		close:SetScript("OnEnter",function(self)
			self.icon:SetAlpha(1)
			local anchor1, anchor2 = SV:GetScreenXY(self) 
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(anchor1, self, anchor2)
			GameTooltip:SetText(CLEAR_FOCUS)
		end)
		focus.XRay = close
	    focus.XRay:SetPoint("RIGHT", 20, 0)

	    ADDInfoBG(SVUI_Player)
	    ADDInfoBG(SVUI_Target)
	end

	function SV.UnitFrames:PostRefreshUpdate(frame, unit)
		if(frame.XRay) then
	        if(SV.db.UnitFrames.xrayFocus) then
	            frame.XRay:Show()
	        else
	            frame.XRay:Hide()
	        end
	    end
	end
end