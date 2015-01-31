--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--MATH
local math          = _G.math;
local floor         = math.floor
--BLIZZARD API
local UnitPower     	= _G.UnitPower;
local UnitPowerMax 		= _G.UnitPowerMax;
local UnitHasVehicleUI 	= _G.UnitHasVehicleUI;
local GetSpecialization = _G.GetSpecialization;

if select(2, UnitClass('player')) ~= "WARLOCK" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

assert(oUF, 'oUF_WarlockShards was unable to locate oUF install')

local MAX_POWER_PER_EMBER = 10
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY

local shardColor = {
	[1] = {0.57,0.08,1},
	[2] = {1,0,0},
	[3] = {1,0.25,0}
}

local Update = function(self, event, unit, powerType)
	local bar = self.WarlockShards;
	local fury = bar.DemonicFury;
	local maxBars = bar.MaxCount or 4;

	if(bar.PreUpdate) then bar:PreUpdate(unit) end
	
	if UnitHasVehicleUI("player") then
		bar:Hide()
	else
		bar:Show()
	end
	
	local spec = GetSpecialization()

	if spec then
		if not bar:IsShown() then 
			bar:Show()
		end

		if((not bar.CurrentSpec) or (bar.CurrentSpec ~= spec and bar.UpdateTextures)) then
			bar:UpdateTextures(spec)
		end

		local colors = shardColor[spec]

		if (spec == SPEC_WARLOCK_DESTRUCTION) then
			if fury:IsShown() then fury:Hide() end;
			local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
			local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
			local numEmbers = power / MAX_POWER_PER_EMBER
			local numBars = floor(maxPower / MAX_POWER_PER_EMBER)

			for i = 1, maxBars do
				if((i == maxBars) and (numBars == 3)) then
					bar[i]:Hide()
				else
					bar[i]:Show()
					bar[i]:SetStatusBarColor(unpack(colors))
					bar[i]:SetMinMaxValues((MAX_POWER_PER_EMBER * i) - MAX_POWER_PER_EMBER, MAX_POWER_PER_EMBER * i)
					bar[i]:SetValue(power)
					if(bar[i].Update) then
						local filled = (power >= MAX_POWER_PER_EMBER * i) and 1 or 0
						bar[i]:Update(filled)
					end
				end
			end
		elseif ( spec == SPEC_WARLOCK_AFFLICTION ) then
			if fury:IsShown() then fury:Hide() end;
			local numShards = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
			local maxShards = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

			for i = 1, maxBars do
				if((i == maxBars) and (maxShards == 3)) then
					bar[i]:Hide()
				else
					bar[i]:Show()
					bar[i]:SetStatusBarColor(unpack(colors))
					bar[i]:SetMinMaxValues(0, 1)
					local filled = (i <= numShards) and 1 or 0
					bar[i]:SetValue(filled)
					if(bar[i].Update) then
						bar[i]:Update(filled)
					end
				end
			end
		elseif spec == SPEC_WARLOCK_DEMONOLOGY then
			if not fury:IsShown() then fury:Show() end;
			local power = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
			local maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			local percent = (power / maxPower) * 100

			for i = 1, maxBars do
				bar[i]:Hide()
			end
			
			fury.bar:SetStatusBarColor(unpack(colors))
			fury.bar:SetMinMaxValues(0, maxPower)
			fury.bar:SetValue(power)
			fury.text:SetText(power)
			if(percent > 99) then
				fury.text:SetTextColor(1,0,0)
			elseif(percent > 80) then
				fury.text:SetTextColor(1,0.5,0)
			elseif(percent > 50) then
				fury.text:SetTextColor(1,1,0)
			else
				fury.text:SetTextColor(1,1,1)
			end
			
			if(fury.bar.Update) then
				local filled = (percent > 80) and 1 or 0
				fury.bar:Update(filled)
			end
		end
	else
		if bar:IsShown() then bar:Hide() end;
		if fury:IsShown() then fury:Hide() end;
	end

	if(bar.PostUpdate) then
		return bar:PostUpdate(unit, spec)
	end
end

local Path = function(self, ...)
	return (self.WarlockShards.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'SOUL_SHARDS')
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end
	
	local bar = self.WarlockShards
	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		
		local maxBars = bar.MaxCount or 4;
		for i = 1, maxBars do
			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
		end

		return true
	end
end

local function Disable(self)
	local bar = self.WarlockShards
	if(bar) then
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar:Hide()
	end
end

oUF:AddElement('WarlockShards', Path, Enable, Disable)