--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--BLIZZARD API
local UnitAura       	 = _G.UnitAura;
local UnitCanAssist      = _G.UnitCanAssist;
local GetSpellInfo       = _G.GetSpellInfo;
local GetSpecialization  = _G.GetSpecialization;
local GetActiveSpecGroup = _G.GetActiveSpecGroup;

local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end
 
local playerClass = select(2,UnitClass("player"))
local CanDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Magic = false, Curse = true },
	PALADIN = { Magic = false, Poison = true, Disease = true },
	MAGE = { Curse = true },
	DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
	MONK = { Magic = false, Poison = true, Disease = true }
}

local AfflictedColor = { };
AfflictedColor["none"] = { r = 1, g = 0, b = 0 };
AfflictedColor["Magic"]    = { r = 0, g = 0.4, b = 1 };
AfflictedColor["Curse"]    = { r = 0.4, g = 0, b = 1 };
AfflictedColor["Disease"]  = { r = 1, g = 0.4, b = 0 };
AfflictedColor["Poison"]   = { r = 0.4, g = 1, b = 0 };
AfflictedColor[""] = AfflictedColor["none"];

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)
local dispellist = CanDispel[playerClass] or {}
local blackList = {
	[GetSpellInfo(140546)] = true, --Fully Mutated
	[GetSpellInfo(136184)] = true, --Thick Bones
	[GetSpellInfo(136186)] = true, --Clear mind
	[GetSpellInfo(136182)] = true, --Improved Synapses
	[GetSpellInfo(136180)] = true, --Keen Eyesight
}
local function GetDebuffType(unit, filter)
	if not unit or not UnitCanAssist("player", unit) then return nil end
	local i = 1
	while true do
		local name, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
		if not texture then break end
		if debufftype and (not filter or (filter and dispellist[debufftype])) and not blackList[name] then
			return debufftype, texture
		end
		i = i + 1
	end
end

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end
 
local function CheckSpec(self, event, levels)
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end
	if playerClass == "PRIEST" then
		if CheckTalentTree(3) then
			dispellist.Disease = false
		else
			dispellist.Disease = true	
		end		
	elseif playerClass == "PALADIN" then
		if CheckTalentTree(1) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "SHAMAN" then
		if CheckTalentTree(3) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "DRUID" then
		if CheckTalentTree(4) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end
	elseif playerClass == "MONK" then
		if CheckTalentTree(2) then
			dispellist.Magic = true
		else
			dispellist.Magic = false	
		end		
	end
end

local function CheckSymbiosis()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		dispellist.Disease = true
	else
		dispellist.Disease = false
	end
end
 
local function Update(object, event, unit)
	if unit ~= object.unit then return; end
	local debuffType, texture  = GetDebuffType(unit, object.AfflictedFilter)
	if debuffType then
		local color = AfflictedColor[debuffType]
		object.Afflicted:SetVertexColor(color.r, color.g, color.b, object.AfflictedAlpha or .5)
	else
		object.Afflicted:SetVertexColor(0,0,0,0)
	end
end
 
local function Enable(object)
	if not object.Afflicted then
		return
	end
	if object.AfflictedFilter and not CanDispel[playerClass] then
		return
	end
	object:RegisterEvent("UNIT_AURA", Update)
	object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	object:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
	CheckSpec(object)

	object:RegisterUnitEvent("UNIT_AURA", object.unit)
	if playerClass == "DRUID" then
		object:RegisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end 
	return true
end
 
local function Disable(object)
	object:UnregisterEvent("UNIT_AURA", Update)
	object:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	object:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)

	if playerClass == "DRUID" then
		object:UnregisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
	object.Afflicted:SetVertexColor(0,0,0,0)	
end
 
oUF:AddElement('Afflicted', Update, Enable, Disable)