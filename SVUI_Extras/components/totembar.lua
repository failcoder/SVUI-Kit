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
local MOD = SV.Extras;
local toonclass = select(2, UnitClass('player'))
--[[ 
########################################################## 
TOTEMS
##########################################################
]]--
local Totems = CreateFrame("Frame");
local TotemBar;
local priorities = STANDARD_TOTEM_PRIORITIES
if(toonclass == "SHAMAN") then
	priorities = SHAMAN_TOTEM_PRIORITIES
end

local Totems_OnEvent = function(self, event)
	if not TotemBar then return end 
	local displayedTotems = 0;
	for i = 1, MAX_TOTEMS do
		if TotemBar[i] then
			local haveTotem, name, start, duration, icon = GetTotemInfo(i)
			if(haveTotem and icon and icon ~= "") then 
				TotemBar[i]:Show()
				TotemBar[i].Icon:SetTexture(icon)
				displayedTotems = displayedTotems + 1;
				CooldownFrame_SetTimer(TotemBar[i].CD, start, duration, 1)

				local id = TotemBar[i]:GetID()
				local blizztotem = _G["TotemFrameTotem"..id]
				if(blizztotem) then 
					blizztotem:ClearAllPoints()
					blizztotem:SetParent(TotemBar[i].Anchor)
					blizztotem:SetAllPoints(TotemBar[i].Anchor)
				end 
			else 
				TotemBar[i]:Hide()
			end
		end
	end
end

function MOD:UpdateTotems()
	local totemSize = SV.db.Extras.totems.size;
	local totemSpace = SV.db.Extras.totems.spacing;
	local totemGrowth = SV.db.Extras.totems.showBy;
	local totemSort = SV.db.Extras.totems.sortDirection;

	for i = 1, MAX_TOTEMS do 
		local button = TotemBar[i]
		local lastButton = TotemBar[i - 1]
		button:ModSize(totemSize)
		button:ClearAllPoints()
		if(totemGrowth == "HORIZONTAL" and totemSort == "ASCENDING") then 
			if(i == 1) then 
				button:SetPoint("LEFT", TotemBar, "LEFT", totemSpace, 0)
			elseif lastButton then 
				button:SetPoint("LEFT", lastButton, "RIGHT", totemSpace, 0)
			end 
		elseif(totemGrowth == "VERTICAL" and totemSort == "ASCENDING") then
			if(i == 1) then 
				button:SetPoint("TOP", TotemBar, "TOP", 0, -totemSpace)
			elseif lastButton then 
				button:SetPoint("TOP", lastButton, "BOTTOM", 0, -totemSpace)
			end 
		elseif(totemGrowth == "HORIZONTAL" and totemSort == "DESCENDING") then 
			if(i == 1) then 
				button:SetPoint("RIGHT", TotemBar, "RIGHT", -totemSpace, 0)
			elseif lastButton then 
				button:SetPoint("RIGHT", lastButton, "LEFT", -totemSpace, 0)
			end 
		else 
			if(i == 1) then 
				button:SetPoint("BOTTOM", TotemBar, "BOTTOM", 0, totemSpace)
			elseif lastButton then 
				button:SetPoint("BOTTOM", lastButton, "TOP", 0, totemSpace)
			end 
		end 
	end 
	local tS1 = ((totemSize * MAX_TOTEMS) + (totemSpace * MAX_TOTEMS) + totemSpace);
	local tS2 = (totemSize + (totemSpace * 2));
	local tW = (totemGrowth == "HORIZONTAL" and tS1 or tS2);
	local tH = (totemGrowth == "HORIZONTAL" and tS2 or tS1);
	TotemBar:ModSize(tW, tH);
	Totems_OnEvent()
end

local Totem_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetTotem(self:GetID())
end

local Totem_OnLeave = function()
	GameTooltip:Hide()
end

function MOD:CreateTotemBar()
	if(not SV.db.Extras.totems.enable) then return; end
	local xOffset = SV.db.Dock.dockLeftWidth + 12
	TotemBar = CreateFrame("Frame", "SVUI_TotemBar", UIParent)
	TotemBar:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", xOffset, 40)
	for i = 1, MAX_TOTEMS do
		local id = priorities[i]
		local totem = CreateFrame("Button", "TotemBarTotem"..id, TotemBar)
		totem:SetID(id)
		totem:Hide()
		
		totem.Icon = totem:CreateTexture(nil, "ARTWORK")
		totem.Icon:InsetPoints()
		totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		totem.CD = CreateFrame("Cooldown", "TotemBarTotem"..id.."Cooldown", totem, "CooldownFrameTemplate")
		totem.CD:SetReverse(true)

		totem.Anchor = CreateFrame("Frame", nil, totem)
		totem.Anchor:SetAllPoints()

		totem:SetStylePanel("Button")

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

		TotemBar[i] = totem 
	end 

	hooksecurefunc("TotemFrame_Update", function()
		for i=1, MAX_TOTEMS do
			local id = priorities[i]
			local blizztotem = _G["TotemFrameTotem"..id]
			local slot = blizztotem.slot

			if slot and slot > 0 then
				blizztotem:ClearAllPoints()
				blizztotem:SetAllPoints(_G["TotemBarTotem"..id])
			end
		end
	end)

	TotemBar:Show()
	Totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
	Totems:RegisterEvent("PLAYER_ENTERING_WORLD")
	Totems:SetScript("OnEvent", Totems_OnEvent)
	Totems_OnEvent()
	MOD:UpdateTotems()
	local frame_name;
	if toonclass == "DEATHKNIGHT" then
		frame_name = L["Ghoul Bar"]
	elseif toonclass == "DRUID" then
		frame_name = L["Mushroom Bar"]
	else
		frame_name = L["Totem Bar"]
	end
	SV.Layout:Add(TotemBar, frame_name)
end