--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, match, split, join = string.find, string.format, string.match, string.split, string.join;
--[[ MATH METHODS ]]--
local ceil, floor, round = math.ceil, math.floor, math.round;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local MOD = SV:NewPackage("Inventory", L["Gear Managment"]);
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local NewHook = hooksecurefunc;
--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, Inventory has to continuously 
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
local COLOR_KEYS = { [0] = "|cffff0000", [1] = "|cff00ff00", [2] = "|cffffff88" };
local LIVESET, EQUIP_SET, SPEC_SET, SHOW_LEVEL, SHOW_DURABILITY, ONLY_DAMAGED, AVG_LEVEL, MAX_LEVEL;
local EquipmentSlots = {
    ["HeadSlot"] = {true,true},
    ["NeckSlot"] = {true,false},
    ["ShoulderSlot"] = {true,true},
    ["BackSlot"] = {true,false},
    ["ChestSlot"] = {true,true},
    ["WristSlot"] = {true,true},
    ["MainHandSlot"] = {true,true,true},
    ["SecondaryHandSlot"] = {true,true},
    ["HandsSlot"] = {true,true,true},
    ["WaistSlot"] = {true,true,true},
    ["LegsSlot"] = {true,true,true},
    ["FeetSlot"] = {true,true,true},
    ["Finger0Slot"] = {true,false,true},
    ["Finger1Slot"] = {true,false,true},
    ["Trinket0Slot"] = {true,false,true},
    ["Trinket1Slot"] = {true,false,true}
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function SetItemLevelDisplay(globalName, iLevel)
	local frame = _G[globalName]
	if(not frame) then return; end
	frame.ItemLevel:SetText()
	if(SHOW_LEVEL) then 
		local key = (iLevel < (AVG_LEVEL - 10)) and 0 or (iLevel > (AVG_LEVEL + 10)) and 1 or 2;
		frame.ItemLevel:SetFormattedText("%s%d|r", COLOR_KEYS[key], iLevel) 
	end
end

local function SetItemDurabilityDisplay(globalName, slotId)
	local frame = _G[globalName]
	if(not frame) then return; end
	if(SHOW_DURABILITY) then
		local current,total,actual,perc,r,g,b;
		current,total = GetInventoryItemDurability(slotId)
		if(current and total) then
			frame.DurabilityInfo.bar:SetMinMaxValues(0, 100)
			if(current == total and ONLY_DAMAGED) then
				frame.DurabilityInfo:Hide()
			else
				if(current ~= total) then
					actual = current / total;
					perc = actual * 100;
					r,g,b = SV:ColorGradient(actual,1,0,0,1,1,0,0,1,0)
					frame.DurabilityInfo.bar:SetValue(perc)
					frame.DurabilityInfo.bar:SetStatusBarColor(r,g,b)
					if not frame.DurabilityInfo:IsShown() then
						frame.DurabilityInfo:Show()
					end
				else
					frame.DurabilityInfo.bar:SetValue(100)
					frame.DurabilityInfo.bar:SetStatusBarColor(0, 1, 0)
				end
			end 
		else
			frame.DurabilityInfo:Hide()
		end
	else
		frame.DurabilityInfo:Hide()
	end
end

local function GetActiveGear()
	local count = GetNumEquipmentSets()
	local resultSpec = GetActiveSpecGroup()
	local resultSet
	EQUIP_SET = SV.db.Inventory.equipmentset
	SPEC_SET = nil
	if(resultSpec and GetSpecializationInfo(resultSpec)) then
		SPEC_SET = resultSpec == 1 and SV.db.Inventory.primary or SV.db.Inventory.secondary
	end
	if(count == 0) then 
		return resultSpec,false
	end 
	for i=1, count do 
		local setName,_,_,setUsed = GetEquipmentSetInfo(i)
		if setUsed then 
			resultSet = setName
			break
		end
	end 
	return resultSpec,resultSet 
end

local function SetDisplayStats(arg)
	for slotName, flags in pairs(EquipmentSlots) do
		local globalName = format("%s%s", arg, slotName)
		local frame = _G[globalName]

		if(flags[1]) then 
			frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
			frame.ItemLevel:ModPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, 1)
			frame.ItemLevel:SetFontObject(SVUI_Font_Default)
		end 
		
		if(arg == "Character" and flags[2]) then
			frame.DurabilityInfo = CreateFrame("Frame", nil, frame)
			frame.DurabilityInfo:ModWidth(7)
			if flags[3] then
				frame.DurabilityInfo:ModPoint("TOPRIGHT", frame, "TOPLEFT", -1, 1)
				frame.DurabilityInfo:ModPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -1, -1)
			else
				frame.DurabilityInfo:ModPoint("TOPLEFT", frame, "TOPRIGHT", 1, 1)
				frame.DurabilityInfo:ModPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 1, -1)
			end
			frame.DurabilityInfo:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.DurabilityInfo:SetBackdrop({
				bgFile = [[Interface\BUTTONS\WHITE8X8]], 
				edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\GLOW]], 
				tile = false, 
				tileSize = 0, 
				edgeSize = 2, 
				insets = {
					left = 0, 
					right = 0, 
					top = 0,
					bottom = 0
				}
			})
			frame.DurabilityInfo:SetBackdropColor(0, 0, 0, 0.5)
			frame.DurabilityInfo:SetBackdropBorderColor(0, 0, 0, 0.8)
			frame.DurabilityInfo.bar = CreateFrame("StatusBar", nil, frame.DurabilityInfo)
			frame.DurabilityInfo.bar:InsetPoints(frame.DurabilityInfo, 2, 2)
			frame.DurabilityInfo.bar:SetStatusBarTexture(SV.Media.bar.default)
			frame.DurabilityInfo.bar:SetOrientation("VERTICAL")
			frame.DurabilityInfo.bg = frame.DurabilityInfo:CreateTexture(nil, "BORDER")
			frame.DurabilityInfo.bg:InsetPoints(frame.DurabilityInfo, 2, 2)
			frame.DurabilityInfo.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
			frame.DurabilityInfo.bg:SetVertexColor("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
		end 
	end 
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local function RefreshInspectedGear()
	if(not MOD.PreBuildComplete) then return end 
	if(InCombatLockdown()) then 
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED", RefreshInspectedGear)
		return 
	else 
		MOD:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end 

	local unit = InspectFrame and InspectFrame.unit or "player";
	if(not unit or (unit and not CanInspect(unit,false))) then return end 

	if(SHOW_LEVEL) then 
		SV:ParseGearSlots(unit, true, SetItemLevelDisplay)
	else
		SV:ParseGearSlots(unit, true)
	end
end

local function RefreshGear()
	if(not MOD.PreBuildComplete) then return end 
	if(InCombatLockdown()) then 
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED", RefreshGear)
		return 
	else 
		MOD:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end 
	MOD:UpdateLocals()
	if(SHOW_LEVEL) then 
		SV:ParseGearSlots("player", false, SetItemLevelDisplay, SetItemDurabilityDisplay)
	else
		SV:ParseGearSlots("player", false, nil, SetItemDurabilityDisplay)
	end
end

local Gear_UpdateTabs = function() 
	SV.Timers:ExecuteTimer(RefreshInspectedGear, 0.2)
end

local function GearSwap()
	if(InCombatLockdown()) then return; end
	local gearSpec, gearSet = GetActiveGear()
	if(not gearSet) then return; end
	if SV.db.Inventory.battleground.enable then 
		local inDungeon,dungeonType = IsInInstance()
		if(inDungeon and dungeonType == "pvp" or dungeonType == "arena") then 
			if EQUIP_SET ~= "none" and EQUIP_SET ~= gearSet then 
				LIVESET = EQUIP_SET;
				UseEquipmentSet(EQUIP_SET)
			end 
			return 
		end 
	end
	if(SPEC_SET and SPEC_SET ~= "none" and SPEC_SET ~= gearSet) then 
		LIVESET = SPEC_SET;
		UseEquipmentSet(SPEC_SET)
	end
end

function MOD:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SHOW_LEVEL = SV.db.Inventory.itemlevel.enable
	SHOW_DURABILITY = SV.db.Inventory.durability.enable
	ONLY_DAMAGED = SV.db.Inventory.durability.onlydamaged
	MAX_LEVEL, AVG_LEVEL = GetAverageItemLevel()
	LoadAddOn("Blizzard_InspectUI")
	SetDisplayStats("Character")
	SetDisplayStats("Inspect")
	NewHook('InspectFrame_UpdateTabs', Gear_UpdateTabs)
	SV.Timers:ExecuteTimer(RefreshGear, 10)
	GearSwap()
	self.PreBuildComplete = true
end

local MSG_PREFIX = "You have equipped equipment set: "
local GearSwapComplete = function()
	if LIVESET then
		local strMsg = ("%s%s"):format(MSG_PREFIX, LIVESET)
		SV:AddonMessage(strMsg)
		LIVESET = nil 
	end 
end

function MOD:UpdateLocals()
	SHOW_LEVEL = SV.db.Inventory.itemlevel.enable
	SHOW_DURABILITY = SV.db.Inventory.durability.enable
	ONLY_DAMAGED = SV.db.Inventory.durability.onlydamaged
	MAX_LEVEL, AVG_LEVEL = GetAverageItemLevel()
end

function MOD:ReLoad()
	RefreshGear()
end

function MOD:Load()
	MSG_PREFIX = L["You have equipped equipment set: "]
	self.PreBuildComplete = false
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", RefreshGear)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", RefreshGear)
	self:RegisterEvent("SOCKET_INFO_UPDATE", RefreshGear)
	self:RegisterEvent("COMBAT_RATING_UPDATE", RefreshGear)
	self:RegisterEvent("MASTERY_UPDATE", RefreshGear)
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", GearSwap)
	self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", GearSwapComplete)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end