--[[ Element: Health Bar
	
	THIS FILE HEAVILY MODIFIED FOR USE WITH SUPERVILLAIN UI

]]
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--MATH
local math          = _G.math;
local max         	= math.max
local random 		= math.random
--BLIZZARD API
local UnitClass     			= _G.UnitClass;
local UnitReaction     			= _G.UnitReaction;
local UnitIsEnemy     			= _G.UnitIsEnemy;
local GetCVarBool     			= _G.GetCVarBool;
local SetCVar     				= _G.SetCVar;
local UnitHealth     			= _G.UnitHealth;
local UnitHealthMax     		= _G.UnitHealthMax;
local UnitIsConnected			= _G.UnitIsConnected;
local UnitIsDeadOrGhost 		= _G.UnitIsDeadOrGhost;
local UnitIsPlayer 				= _G.UnitIsPlayer;
local UnitPlayerControlled 		= _G.UnitPlayerControlled;
local UnitIsTapped 				= _G.UnitIsTapped;
local UnitIsTappedByPlayer 		= _G.UnitIsTappedByPlayer;
local UnitIsTappedByAllThreatList = _G.UnitIsTappedByAllThreatList;


local parent, ns = ...
local oUF = ns.oUF

oUF.colors.health = {49/255, 207/255, 37/255}

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local health = self.Health

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local disconnected = not UnitIsConnected(unit)
	local invisible = ((min == max) or UnitIsDeadOrGhost(unit) or disconnected)
	if invisible then health.lowAlerted = false end

	if health.fillInverted then
		health:SetReverseFill(true)
	end

	health:SetMinMaxValues(0, max)

	local percent = 100
	if(disconnected) then
		health:SetValue(max)
		percent = 100
	else
		health:SetValue(min)
		percent = (min / max) * 100
	end

	percent = invisible and 100 or ((min / max) * 100)

	health.percent = percent
	health.disconnected = disconnected

	if health.frequentUpdates ~= health.__frequentUpdates then
		health.__frequentUpdates = health.frequentUpdates
		self:UpdateFrequentUpdates()
	end

	local bg = health.bg;
	local r, g, b, t, t2;

	if(health.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)) then
		t = oUF.colors.tapped
	elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
		t = oUF.colors.disconnected
	elseif(health.colorClass and UnitIsPlayer(unit)) or
		(health.colorClassNPC and not UnitIsPlayer(unit)) or
		(health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		local tmp = oUF.colors.class[class] or oUF.colors.health
		t = {(tmp[1] * 0.75),(tmp[2] * 0.75),(tmp[3] * 0.75)}
		if(bg and (health.colorBackdrop) and UnitIsPlayer(unit)) then
			t2 = t
		end
	elseif(health.colorReaction and UnitReaction(unit, 'player')) then
		t = oUF.colors.reaction[UnitReaction(unit, "player")]
		if(bg and (health.colorBackdrop) and not UnitIsPlayer(unit) and UnitReaction(unit, "player")) then
			t2 = t
		end
	elseif(health.colorSmooth) then
		r, g, b = oUF.ColorGradient(min, max, unpack(health.smoothGradient or oUF.colors.smooth))
	elseif(health.colorHealth) then
		t = oUF.colors.health
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		if((health.colorClass and health.colorSmooth) or (health.colorSmooth and self.isForced and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)))) then 
			r, g, b = self.ColorGradient(min,max,1,0,0,1,1,0,r,g,b)
		end
		health:SetStatusBarColor(r, g, b)
		if(bg) then 
			local mu = bg.multiplier or 1
			if(t2) then
				r, g, b = t2[1], t2[2], t2[3] 
			end
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end

	if self.ResurrectIcon then 
		self.ResurrectIcon:SetAlpha(min == 0 and 1 or 0)
	end

	if self.isForced then 
		min = random(1,max)
		health:SetValue(min)
	end

	if(health.gridMode) then 
		health:SetOrientation("VERTICAL")
	end

	if(health.LowAlertFunc and UnitIsPlayer("target") and health.percent < 6 and UnitIsEnemy("target", "player") and not health.lowAlerted) then
		health.lowAlerted = true
		health.LowAlertFunc(self)
	end

	if(health.PostUpdate) then
		return health.PostUpdate(self, health.percent)
	end
end

local Path = function(self, ...)
	return (self.Health.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local UpdateFrequentUpdates = function(self)
	local health = self.Health
	if health.frequentUpdates and not self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
		if GetCVarBool("predictedHealth") ~= 1 then
			SetCVar("predictedHealth", 1)
		end

		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)

		if self:IsEventRegistered("UNIT_HEALTH") then
			self:UnregisterEvent("UNIT_HEALTH", Path)
		end
	elseif not self:IsEventRegistered("UNIT_HEALTH") then
		self:RegisterEvent('UNIT_HEALTH', Path)

		if self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Path)
		end		
	end
end

local Enable = function(self, unit)
	local health = self.Health
	if(health) then
		health.__owner = self
		health.ForceUpdate = ForceUpdate
		health.__frequentUpdates = health.frequentUpdates
		self.UpdateFrequentUpdates = UpdateFrequentUpdates
		self:UpdateFrequentUpdates()

		self:RegisterEvent("UNIT_MAXHEALTH", Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)

		-- For tapping.
		self:RegisterEvent('UNIT_FACTION', Path)

		if(health:IsObjectType'StatusBar' and not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local health = self.Health
	if(health) then
		health:Hide()
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)

		self:UnregisterEvent('UNIT_FACTION', Path)
	end
end

oUF:AddElement('Health', Path, Enable, Disable)
