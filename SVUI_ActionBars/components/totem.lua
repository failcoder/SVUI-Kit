--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local tinsert 	= _G.tinsert;
local math 		= _G.math;
local cos, deg, rad, sin = math.cos, math.deg, math.rad, math.sin;
local hooksecurefunc = _G.hooksecurefunc;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.ActionBars;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local PlayerClass = select(2, UnitClass('player'))
local TOTEM_PRIORITIES = STANDARD_TOTEM_PRIORITIES;
local MOVER_NAME = L["Totem Bar"];
if(PlayerClass == "SHAMAN") then
	TOTEM_PRIORITIES = SHAMAN_TOTEM_PRIORITIES
elseif(PlayerClass == "DEATHKNIGHT") then
	MOVER_NAME = L["Ghoul Bar"]
elseif(PlayerClass == "DRUID") then
	MOVER_NAME = L["Mushroom Bar"]
end
--[[ 
########################################################## 
TOTEMS
##########################################################
]]--
local Totems = CreateFrame("Frame", "SVUI_TotemBar", UIParent);

function Totems:Refresh() 
	for i = 1, MAX_TOTEMS do
		if self[i] then
			local haveTotem, name, start, duration, icon = GetTotemInfo(i)
			if(haveTotem and icon and icon ~= "") then 
				self[i]:Show()
				self[i].Icon:SetTexture(icon)
				CooldownFrame_SetTimer(self[i].CD, start, duration, 1)
				local id = self[i]:GetID()
				local blizztotem = _G["TotemFrameTotem"..id]
				if(blizztotem) then 
					blizztotem:ClearAllPoints()
					blizztotem:SetParent(self[i].Anchor)
					blizztotem:SetAllPoints(self[i].Anchor)
				end 
			else 
				self[i]:Hide()
			end
		end
	end
end

function Totems:Update()
	local settings = SV.db.ActionBars.Totem;
	local totemSize = settings.buttonsize;
	local totemSpace = settings.buttonspacing;
	local totemGrowth = settings.showBy;
	local totemSort = settings.sortDirection;

	for i = 1, MAX_TOTEMS do 
		local button = self[i]
		if(button) then
			local lastButton = self[i - 1]
			button:ModSize(totemSize)
			button:ClearAllPoints()
			if(totemGrowth == "HORIZONTAL" and totemSort == "ASCENDING") then 
				if(i == 1) then 
					button:SetPoint("LEFT", self, "LEFT", totemSpace, 0)
				elseif lastButton then 
					button:SetPoint("LEFT", lastButton, "RIGHT", totemSpace, 0)
				end 
			elseif(totemGrowth == "VERTICAL" and totemSort == "ASCENDING") then
				if(i == 1) then 
					button:SetPoint("TOP", self, "TOP", 0, -totemSpace)
				elseif lastButton then 
					button:SetPoint("TOP", lastButton, "BOTTOM", 0, -totemSpace)
				end 
			elseif(totemGrowth == "HORIZONTAL" and totemSort == "DESCENDING") then 
				if(i == 1) then 
					button:SetPoint("RIGHT", self, "RIGHT", -totemSpace, 0)
				elseif lastButton then 
					button:SetPoint("RIGHT", lastButton, "LEFT", -totemSpace, 0)
				end 
			else 
				if(i == 1) then 
					button:SetPoint("BOTTOM", self, "BOTTOM", 0, totemSpace)
				elseif lastButton then 
					button:SetPoint("BOTTOM", lastButton, "TOP", 0, totemSpace)
				end 
			end
		end
	end

	local calcWidth, calcHeight;
	if(totemGrowth == "HORIZONTAL") then
		calcWidth = ((totemSize * MAX_TOTEMS) + (totemSpace * MAX_TOTEMS) + totemSpace);
		calcHeight = (totemSize + (totemSpace * 2));
	else
		calcWidth = (totemSize + (totemSpace * 2));
		calcHeight = ((totemSize * MAX_TOTEMS) + (totemSpace * MAX_TOTEMS) + totemSpace);
	end

	self:ModSize(calcWidth, calcHeight);
	self:Refresh()
end

local Totems_OnEvent = function(self, event) 
	self:Refresh()
end

local Totem_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetTotem(self:GetID())
end

local Totem_OnLeave = function()
	GameTooltip:Hide()
end

local _hook_TotemFrame_OnUpdate = function()
	for i=1, MAX_TOTEMS do
		local id = TOTEM_PRIORITIES[i]
		local blizztotem = _G["TotemFrameTotem"..id]
		local slot = blizztotem.slot
		if(slot and slot > 0) then
			blizztotem:ClearAllPoints()
			blizztotem:SetAllPoints(_G["TotemsTotem"..id])
		end
	end
end

function MOD:InitializeTotemBar()
	if(not SV.db.ActionBars.Totem.enable) then return; end

	local xOffset = SV.db.Dock.dockLeftWidth + 12

	Totems:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", xOffset, 40)

	for i = 1, MAX_TOTEMS do
		local id = TOTEM_PRIORITIES[i]
		local totem = CreateFrame("Button", "SVUI_TotemBarTotem"..id, Totems)
		totem:SetID(id)
		totem:Hide()
		
		totem.Icon = totem:CreateTexture(nil, "ARTWORK")
		totem.Icon:InsetPoints()
		totem.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		totem.CD = CreateFrame("Cooldown", "SVUI_TotemBarTotem"..id.."Cooldown", totem, "CooldownFrameTemplate")
		totem.CD:SetReverse(true)

		totem.Anchor = CreateFrame("Frame", nil, totem)
		totem.Anchor:SetAllPoints()

		totem:SetStyle("Button")

		totem:EnableMouse(true)
		totem:SetScript('OnEnter', Totem_OnEnter)
		totem:SetScript('OnLeave', Totem_OnLeave)

		local blizztotem = _G["TotemFrameTotem"..id]
		if(blizztotem) then
			blizztotem:ClearAllPoints()
			blizztotem:SetParent(totem.Anchor)
			blizztotem:SetAllPoints(totem.Anchor)
			blizztotem:SetFrameLevel(totem.Anchor:GetFrameLevel() + 1)
			blizztotem:SetFrameStrata(totem.Anchor:GetFrameStrata())
			blizztotem:SetAlpha(0)
		end

		Totems[i] = totem 
	end 

	hooksecurefunc("TotemFrame_Update", _hook_TotemFrame_OnUpdate)

	Totems:Show()
	Totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
	Totems:RegisterEvent("PLAYER_ENTERING_WORLD")
	Totems:SetScript("OnEvent", Totems_OnEvent)
	Totems:Update()

	SV:NewAnchor(Totems, MOVER_NAME)
end