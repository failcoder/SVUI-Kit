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
SIMPLE BUTTON CONSTRUCT
##########################################################
]]--
local Button_OnEnter = function(self, ...)
    if InCombatLockdown() then return end 
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(self.TText, 1, 1, 1)
    GameTooltip:Show()
end 

local function CreateSimpleButton(frame, label, anchor, x, y, width, height, tooltip)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetWidth(width)
    button:SetHeight(height) 
    button:SetPoint(anchor, x, y)
    button:SetText(label) 
    button:RegisterForClicks("AnyUp") 
    button:SetHitRectInsets(0, 0, 0, 0);
    button:SetFrameStrata("FULLSCREEN_DIALOG");
    button.TText = tooltip
    button:SetStylePanel("Button")
    button:SetScript("OnEnter", Button_OnEnter)        
    button:SetScript("OnLeave", GameTooltip_Hide)
    return button
end
--[[ 
########################################################## 
TAINT FIX HACKS
##########################################################
]]--
LFRParentFrame:SetScript("OnHide", nil)
--[[ 
########################################################## 
MERCHANT MAX STACK
##########################################################
]]--
local BuyMaxStack = function(self, ...)
	if ( IsAltKeyDown() ) then
		local itemLink = GetMerchantItemLink(self:GetID())
		if not itemLink then return end
		local maxStack = select(8, GetItemInfo(itemLink))
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end
end

local MaxStackTooltip = function(self)
	wipe(GameTooltip.InjectedDouble)
	local itemLink = GetMerchantItemLink(self:GetID())
	if not itemLink then return end
	local maxStack = select(8, GetItemInfo(itemLink))
	if(not (maxStack > 1)) then return end
    GameTooltip.InjectedDouble[1] = "[Alt + Click]"
    GameTooltip.InjectedDouble[2] = "Buy a full stack."
    GameTooltip.InjectedDouble[3] = 0
    GameTooltip.InjectedDouble[4] = 0.5
    GameTooltip.InjectedDouble[5] = 1
    GameTooltip.InjectedDouble[6] = 0.5
    GameTooltip.InjectedDouble[7] = 1
    GameTooltip.InjectedDouble[8] = 0.5
end

-- hooksecurefunc(GameTooltip, "SetMerchantItem", MaxStackTooltip);
hooksecurefunc("MerchantItemButton_OnEnter", MaxStackTooltip);
hooksecurefunc("MerchantItemButton_OnModifiedClick", BuyMaxStack);
--[[ 
########################################################## 
RAIDMARKERS
##########################################################
]]--
local ButtonIsDown;
local RaidMarkFrame=CreateFrame("Frame", "SVUI_RaidMarkFrame", UIParent)
RaidMarkFrame:EnableMouse(true)
RaidMarkFrame:SetSize(100, 100)
RaidMarkFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
RaidMarkFrame:SetFrameStrata("DIALOG")

local RaidMarkButton_OnEnter = function(self)
	self.Texture:ClearAllPoints()
	self.Texture:ModPoint("TOPLEFT",-10,10)
	self.Texture:ModPoint("BOTTOMRIGHT",10,-10)
end 

local RaidMarkButton_OnLeave = function(self)
	self.Texture:SetAllPoints()
end 

local RaidMarkButton_OnClick = function(self, button)
	PlaySound("UChatScrollButton")
	SetRaidTarget("target",button ~= "RightButton" and self:GetID() or 0)
	self:GetParent():Hide()
end 

for i=1,8 do 
	local raidMark = CreateFrame("Button", "RaidMarkIconButton"..i, RaidMarkFrame)
	raidMark:SetSize(40, 40)
	raidMark:SetID(i)
	raidMark.Texture = raidMark:CreateTexture(raidMark:GetName().."NormalTexture","ARTWORK")
	raidMark.Texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	raidMark.Texture:SetAllPoints()
	SetRaidTargetIconTexture(raidMark.Texture,i)
	raidMark:RegisterForClicks("LeftbuttonUp","RightbuttonUp")
	raidMark:SetScript("OnClick",RaidMarkButton_OnClick)
	raidMark:SetScript("OnEnter",RaidMarkButton_OnEnter)
	raidMark:SetScript("OnLeave",RaidMarkButton_OnLeave)
	if(i == 8) then 
		raidMark:SetPoint("CENTER")
	else 
		local radian = 360 / 7 * i;
		raidMark:SetPoint("CENTER", sin(radian) * 60, cos(radian) * 60)
	end 
end 

RaidMarkFrame:Hide()

local function RaidMarkAllowed()
	if not RaidMarkFrame then
		return false 
	end 
	if GetNumGroupMembers()>0 then
		if UnitIsGroupLeader('player') or UnitIsGroupAssistant("player") then 
			return true 
		elseif IsInGroup() and not IsInRaid() then 
			return true 
		else
			UIErrorsFrame:AddMessage(L["You don't have permission to mark targets."], 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME)
			return false 
		end 
	else
		return true 
	end 
end 

local function RaidMarkShowIcons()
	if not UnitExists("target") or UnitIsDead("target") then return end 
	local x,y = GetCursorPosition()
	local scale = SV.Screen:GetEffectiveScale()
	RaidMarkFrame:SetPoint("CENTER", SV.Screen, "BOTTOMLEFT", (x / scale), (y / scale))
	RaidMarkFrame:Show()
end

_G.RaidMark_HotkeyPressed = function(button)
	ButtonIsDown = button == "down" and RaidMarkAllowed()
	if(RaidMarkFrame) then
		if ButtonIsDown then 
			RaidMarkShowIcons()
		else
			RaidMarkFrame:Hide()
		end
	end
end

RaidMarkFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
RaidMarkFrame:SetScript("OnEvent", function(self, event)
	if ButtonIsDown then 
		RaidMarkShowIcons()
	end 
end)
--[[ 
########################################################## 
DRESSUP HELPERS by: Leatrix
##########################################################
]]--
local helmet, cloak;
local htimer = 0
local hshow, cshow, hchek, cchek


local function LockItem(item,lock)
	if lock then
		item:Disable()
		item:SetAlpha(0.3)
	else
		item:Enable()
		item:SetAlpha(1.0)
	end
end

local function SetVanityPlacement()
	helmet:ClearAllPoints();
	helmet:SetPoint("TOPLEFT", 166, -326)
	helmet:SetHitRectInsets(0, -10, 0, 0);
	helmet.text:SetText("H");
	cloak:ClearAllPoints();
	cloak:SetPoint("TOPLEFT", 206, -326)
	cloak:SetHitRectInsets(0, -10, 0, 0);
	cloak.text:SetText("C");
	helmet:SetAlpha(0.7);
	cloak:SetAlpha(0.7);
end

local MouseEventHandler = function(self, btn)
	if btn == "RightButton" and IsShiftKeyDown() then
		SetVanityPlacement();
	end
end

local DressUpdateHandler = function(self, elapsed)
	htimer = htimer + elapsed;
	while (htimer > 0.05) do
		if UnitIsDeadOrGhost("player") then
			LockItem(helmet,true)
			LockItem(cloak,true)
			return
		else
			LockItem(helmet,false)
			LockItem(cloak,false)
		end
		hshow, cshow, hchek, cchek = ShowingHelm(), ShowingCloak(), helmet:GetChecked(), cloak:GetChecked()
		if hchek ~= hshow then
			if helmet:IsEnabled() then
				helmet:Disable()
			end
		else
			if not helmet:IsEnabled() then
				helmet:Enable()
			end
		end
		if cchek ~= cshow then
			if cloak:IsEnabled() then
				cloak:Disable()
			end
		else
			if not cloak:IsEnabled() then
				cloak:Enable()
			end
		end
		helmet:SetChecked(hshow);
		cloak:SetChecked(cshow);
		htimer = 0;
	end
end

local DressUp_OnEnter = function(self)
	if InCombatLockdown() then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.TText, 1, 1, 1)
	GameTooltip:Show()
end

local DressUp_OnLeave = function(self)
	if InCombatLockdown() then return end
	if(GameTooltip:IsShown()) then GameTooltip:Hide() end
end

function MOD:LoadDressupHelper()
	if IsAddOnLoaded("DressingRoomFunctions") then return end
	--[[ PAPER DOLL ENHANCEMENT ]]--
	local tabard1 = CreateSimpleButton(DressUpFrame, "Tabard", "BOTTOMLEFT", 12, 12, 80, 22, "")
	tabard1:SetScript("OnClick", function()
		DressUpModel:UndressSlot(19)
	end)

	local nude1 = CreateSimpleButton(DressUpFrame, "Nude", "BOTTOMLEFT", 104, 12, 80, 22, "")
	nude1:SetScript("OnClick", function()
		DressUpFrameResetButton:Click()
		for i = 1, 19 do
			DressUpModel:UndressSlot(i)
		end
	end)

	local BtnStrata, BtnLevel = SideDressUpModelResetButton:GetFrameStrata(), SideDressUpModelResetButton:GetFrameLevel()

	-- frame, label, anchor, x, y, width, height, tooltip

	local tabard2 = CreateSimpleButton(SideDressUpFrame, "Tabard", "BOTTOMLEFT", 14, 20, 60, 22, "")
	tabard2:SetFrameStrata(BtnStrata);
	tabard2:SetFrameLevel(BtnLevel);
	tabard2:SetScript("OnClick", function()
		SideDressUpModel:UndressSlot(19)
	end)

	local nude2 = CreateSimpleButton(SideDressUpFrame, "Nude", "BOTTOMRIGHT", -18, 20, 60, 22, "")
	nude2:SetFrameStrata(BtnStrata);
	nude2:SetFrameLevel(BtnLevel);
	nude2:SetScript("OnClick", function()
		SideDressUpModelResetButton:Click()
		for i = 1, 19 do
			SideDressUpModel:UndressSlot(i)
		end
	end)

	--[[ CLOAK AND HELMET TOGGLES ]]--
	helmet = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
	helmet:SetSize(16, 16)
	--helmet:RemoveTextures()
	--helmet:SetStylePanel("Checkbox")
	helmet.text = helmet:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
	helmet.text:SetPoint("LEFT", 24, 0)
	helmet.TText = "Show/Hide Helmet"
	helmet:SetScript('OnEnter', DressUp_OnEnter)
	helmet:SetScript('OnLeave', DressUp_OnLeave)
	helmet:SetScript('OnUpdate', DressUpdateHandler)

	cloak = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
	cloak:SetSize(16, 16)
	--cloak:RemoveTextures()
	--cloak:SetStylePanel("Checkbox")
	cloak.text = cloak:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
	cloak.text:SetPoint("LEFT", 24, 0)
	cloak.TText = "Show/Hide Cloak"
	cloak:SetScript('OnEnter', DressUp_OnEnter)
	cloak:SetScript('OnLeave', DressUp_OnLeave)

	helmet:SetScript('OnClick', function(self, btn)
		ShowHelm(helmet:GetChecked())
	end)
	cloak:SetScript('OnClick', function(self, btn)
		ShowCloak(cloak:GetChecked())
	end)

	helmet:SetScript('OnMouseDown', MouseEventHandler)
	cloak:SetScript('OnMouseDown', MouseEventHandler)
	CharacterModelFrame:HookScript("OnShow", SetVanityPlacement)
end