if(select(2, UnitClass('player')) ~= 'DRUID') then return end
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local error         = _G.error;
local print         = _G.print;
local pairs         = _G.pairs;
local next          = _G.next;
local tostring      = _G.tostring;
local type  		= _G.type;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
--TABLE
local table         = _G.table;
local wipe          = _G.wipe;
--BLIZZARD API
local BEAR_FORM       		= _G.BEAR_FORM;
local CAT_FORM 				= _G.CAT_FORM;
local SPELL_POWER_MANA      = _G.SPELL_POWER_MANA;
local UnitClass         	= _G.UnitClass;
local UnitPower         	= _G.UnitPower;
local UnitReaction         	= _G.UnitReaction;
local UnitPowerMax         	= _G.UnitPowerMax;
local UnitIsPlayer      	= _G.UnitIsPlayer;
local UnitPlayerControlled  = _G.UnitPlayerControlled;
local GetShapeshiftFormID 	= _G.GetShapeshiftFormID;

local _, ns = ...
local oUF = ns.oUF or oUF

local ECLIPSE_BAR_SOLAR_BUFF_ID = _G.ECLIPSE_BAR_SOLAR_BUFF_ID
local ECLIPSE_BAR_LUNAR_BUFF_ID = _G.ECLIPSE_BAR_LUNAR_BUFF_ID
local SPELL_POWER_ECLIPSE = _G.SPELL_POWER_ECLIPSE
local MOONKIN_FORM = _G.MOONKIN_FORM
local ALERTED = false;
local TextColors = {
	[1]={1,0.1,0.1},
	[2]={1,0.5,0.1},
	[3]={1,1,0.1},
	[4]={0.5,1,0.1},
	[5]={0.1,1,0.1}
};

local function ManaBarState(mana)
	if mana.ManaBar:GetValue() < UnitPowerMax('player', SPELL_POWER_MANA) then
		mana:Show()
	else
		mana:Hide()
	end
end

local UPDATE_VISIBILITY = function(self, event)
	local bar = self.Druidness
	local chicken = bar.Chicken
	local cat = bar.Cat
	local mana = bar.Mana

	-- check form/mastery
	local form = GetShapeshiftFormID()

	if(not form) then
		local ptt = GetSpecialization()
		if(ptt and ptt == 1) then -- player has balance spec
			chicken:Show()
		else
			chicken:Hide()
		end
		mana:Hide()
		cat:Hide()
	elseif(form == MOONKIN_FORM) then
		chicken:Show()
		mana:Hide()
		cat:Hide()
	elseif (form == BEAR_FORM or form == CAT_FORM) then
		chicken:Hide()
		if(form == CAT_FORM) then
			cat:Show()
		else
			cat:Hide()
		end
		ManaBarState(mana)
	else
		chicken:Hide()
		cat:Hide()
		mana:Hide()
	end

	if(bar.PostUpdateVisibility) then
		return bar:PostUpdateVisibility(self.unit)
	end
end

local UNIT_POWER = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end
	local bar = self.Druidness
	local chicken = bar.Chicken
	local mana = bar.Mana

	if(chicken:IsShown() or powerType == 'ECLIPSE') then
		local power = UnitPower('player', SPELL_POWER_ECLIPSE)
		local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

		if(chicken.LunarBar) then
			chicken.LunarBar:SetMinMaxValues(-maxPower, maxPower)
			chicken.LunarBar:SetValue(power)
		end

		if(chicken.SolarBar) then
			chicken.SolarBar:SetMinMaxValues(-maxPower, maxPower)
			chicken.SolarBar:SetValue(power * -1)
		end

		if(chicken.PostUpdatePower) then
			return chicken:PostUpdatePower(unit)
		end
	end
	
	if not (mana.ManaBar) then return end
	
	if(mana.PreUpdate) then
		mana:PreUpdate(unit)
	end
	local min, max = UnitPower('player', SPELL_POWER_MANA), UnitPowerMax('player', SPELL_POWER_MANA)

	mana.ManaBar:SetMinMaxValues(0, max)
	mana.ManaBar:SetValue(min)

	local r, g, b, t
	if(mana.colorPower) then
		t = self.colors.power["MANA"]
	elseif(mana.colorClass and UnitIsPlayer(unit)) or
		(mana.colorClassNPC and not UnitIsPlayer(unit)) or
		(mana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif(mana.colorReaction and UnitReaction(unit, 'player')) then
		t = self.colors.reaction[UnitReaction(unit, "player")]
	elseif(mana.colorSmooth) then
		r, g, b = self.ColorGradient(min / max, unpack(mana.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		mana.ManaBar:SetStatusBarColor(r, g, b)

		local bg = mana.bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
	
	UPDATE_VISIBILITY(self)
	
	if(mana.PostUpdatePower) then
		return mana:PostUpdatePower(unit, min, max)
	end
end

local UNIT_AURA = function(self, event, unit)
	if((not unit) or (unit and self.unit ~= unit)) then return end
	local bar = self.Druidness
	local chicken = bar.Chicken
	local mana = bar.Mana

	if(chicken and chicken:IsShown()) then
		local i = 1
		local hasSolarEclipse, hasLunarEclipse
		repeat
			local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, i, 'HELPFUL')

			if(spellID == ECLIPSE_BAR_SOLAR_BUFF_ID) then
				hasSolarEclipse = true
			elseif(spellID == ECLIPSE_BAR_LUNAR_BUFF_ID) then
				hasLunarEclipse = true
			end

			i = i + 1
		until not spellID
		chicken.hasSolarEclipse = hasSolarEclipse
		chicken.hasLunarEclipse = hasLunarEclipse
	end

	if(bar.PostUnitAura) then
		return bar:PostUnitAura(unit)
	end
end

local ECLIPSE_DIRECTION_CHANGE = function(self, event, status)
	local bar = self.Druidness
	local chicken = bar.Chicken

	if(status and chicken:IsVisible() and chicken.PostDirectionChange[status]) then
		return chicken.PostDirectionChange[status](chicken)
	end
end 

local UPDATE_POINTS = function(self, event, unit)
	if(unit == 'pet') then return end
	local bar = self.Druidness;
	local cpoints = bar.Cat;

	if(bar.PreUpdate) then
		bar:PreUpdate()
	end

	local current = 0
	if(UnitHasVehicleUI'player') then
		current = GetComboPoints('vehicle', 'target')
	else
		current = GetComboPoints('player', 'target')
	end

	if(cpoints) then
		for i=1, MAX_COMBO_POINTS do
			if(i <= current) then
				cpoints[i]:Show()
				if(bar.PointShow) then
					bar.PointShow(cpoints[i])
				end
			else
				cpoints[i]:Hide()
				if(bar.PointHide) then
					bar.PointHide(cpoints[i], i)
				end
			end
		end
	end

	if(bar.PostUpdate) then
		return bar:PostUpdate(current)
	end
end

local Update = function(self, ...)
	UNIT_POWER(self, ...)
	UNIT_AURA(self, ...)
	UPDATE_POINTS(self, ...)
	return UPDATE_VISIBILITY(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit, 'ECLIPSE')
end

local function Enable(self)
	local bar = self.Druidness
	
	if(bar) then
		local chicken = bar.Chicken
		local mana = bar.Mana
		chicken.__owner = self
		chicken.ForceUpdate = ForceUpdate

		if(chicken.LunarBar and chicken.LunarBar:IsObjectType'StatusBar' and not chicken.LunarBar:GetStatusBarTexture()) then
			chicken.LunarBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(chicken.SolarBar and chicken.SolarBar:IsObjectType'StatusBar' and not chicken.SolarBar:GetStatusBarTexture()) then
			chicken.SolarBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		local power = UnitPower('player', SPELL_POWER_ECLIPSE)
		local maxPower = UnitPowerMax('player', SPELL_POWER_ECLIPSE)

		if(chicken.LunarBar) then
			chicken.LunarBar:SetMinMaxValues(-maxPower, maxPower)
			chicken.LunarBar:SetValue(power)
		end

		if(chicken.SolarBar) then
			chicken.SolarBar:SetMinMaxValues(-maxPower, maxPower)
			chicken.SolarBar:SetValue(power * -1)
		end

		self:RegisterEvent('ECLIPSE_DIRECTION_CHANGE', ECLIPSE_DIRECTION_CHANGE, true)
		self:RegisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY, true)
		self:RegisterEvent('UNIT_AURA', UNIT_AURA)
		self:RegisterEvent('UNIT_POWER', UNIT_POWER)
		self:RegisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY, true)
		self:RegisterEvent('UNIT_COMBO_POINTS', UPDATE_POINTS, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UPDATE_POINTS, true)
		UPDATE_VISIBILITY(self)
		return true
	end
end

local function Disable(self)
	local bar = self.Druidness
	
	if(bar) then
		local chicken = bar.Chicken
		local mana = bar.Mana
		chicken:Hide()
		mana:Hide()
		self:UnregisterEvent('ECLIPSE_DIRECTION_CHANGE', ECLIPSE_DIRECTION_CHANGE)
		self:UnregisterEvent('PLAYER_TALENT_UPDATE', UPDATE_VISIBILITY)
		self:UnregisterEvent('UNIT_AURA', UNIT_AURA)
		self:UnregisterEvent('UNIT_POWER', UNIT_POWER)
		self:UnregisterEvent('UNIT_MAXPOWER', UNIT_POWER)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UPDATE_VISIBILITY)
		self:UnregisterEvent('UNIT_COMBO_POINTS', UPDATE_POINTS)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', UPDATE_POINTS)
	end
end

oUF:AddElement('BoomChicken', Update, Enable, Disable)
