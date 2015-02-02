--[[
##############################################################################
S V U I   By: S.Jackson
############################################################################## ]]-- 
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table; 
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local random 		= math.random;
local min 			= math.min;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetProfessions       	= _G.GetProfessions;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local hooksecurefunc     	= _G.hooksecurefunc;
--[[ 
########################################################## 
ADDON
##########################################################
]]--
local SV = select(2, ...);
local L = SV.L;
local MOD = SV:NewClass("Dock", L["Docks"]);
MOD.Border = {};
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local ORDER_TEMP, ORDER_TEST, DOCK_REGISTRY, DOCK_DROPDOWN_OPTIONS = {}, {}, {}, {};
local DOCK_LOCATIONS = {
	["BottomLeft"] = {1, "LEFT", true, "ANCHOR_TOPLEFT"},
	["BottomRight"] = {-1, "RIGHT", true, "ANCHOR_TOPLEFT"},
	["TopLeft"] = {1, "LEFT", false, "ANCHOR_BOTTOMLEFT"},
	["TopRight"] = {-1, "RIGHT", false, "ANCHOR_BOTTOMLEFT"},
};
DOCK_DROPDOWN_OPTIONS["BottomLeft"] = { text = "To BottomLeft", func = function(button) MOD.BottomLeft.Bar:Add(button) end };
DOCK_DROPDOWN_OPTIONS["BottomRight"] = { text = "To BottomRight", func = function(button) MOD.BottomRight.Bar:Add(button) end };
DOCK_DROPDOWN_OPTIONS["TopLeft"] = { text = "To TopLeft", func = function(button) MOD.TopLeft.Bar:Add(button) end };
--DOCK_DROPDOWN_OPTIONS["TopRight"] = { text = "To TopRight", func = function(button) MOD.TopRight.Bar:Add(button) end };
--[[ 
########################################################## 
THEMEABLE ITEMS
##########################################################
]]--
MOD.ButtonSound = SV.Sounds:Blend("DockButton", "Buttons", "Levers");
MOD.ErrorSound = SV.Sounds:Blend("Malfunction", "Sparks", "Wired");

function MOD.SetThemeDockStyle(dock, isBottom)
	if dock.backdrop then return end
	local backdrop = CreateFrame("Frame", nil, dock)
	backdrop:SetAllPoints(dock)
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop:SetBackdrop({
	    bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\BUTTONS\WHITE8X8]],
	    edgeSize = 1,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    }, 
	});
	backdrop:SetBackdropColor(0,0,0,0.5);
	backdrop:SetBackdropBorderColor(0,0,0,0.8);
	return backdrop 
end

function MOD:SetButtonTheme(button, ...)
	button:SetStyle("DockButton")
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
_G.ToggleSuperDockLeft = function(self, button)
	GameTooltip:Hide()
	if(button and IsAltKeyDown()) then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	elseif(button and button == 'RightButton') then
		if(InCombatLockdown()) then
			MOD.ErrorSound()
			SV:AddonMessage(ERR_NOT_IN_COMBAT)
			return
		end
		MOD.ButtonSound()
		local userSize = SV.db.Dock.dockLeftHeight
		if(not MOD.private.LeftExpanded) then
			MOD.private.LeftExpanded = true
			MOD.BottomLeft.Window:SetHeight(userSize + 300)
		else
			MOD.private.LeftExpanded = nil
			MOD.BottomLeft.Window:SetHeight(userSize)
		end
		MOD.BottomLeft.Bar:Update()
		MOD:UpdateDockBackdrops()
	else
		if MOD.private.LeftFaded then 
			MOD.private.LeftFaded = nil;
			MOD.BottomLeft:FadeIn(0.2, MOD.BottomLeft:GetAlpha(), 1)
			MOD.BottomLeft.Bar:FadeIn(0.2, MOD.BottomLeft.Bar:GetAlpha(), 1)
			SV.Events:Trigger("DOCK_LEFT_FADE_IN");
			PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
		else 
			MOD.private.LeftFaded = true;
			MOD.BottomLeft:FadeOut(0.2, MOD.BottomLeft:GetAlpha(), 0)
			MOD.BottomLeft.Bar:FadeOut(0.2, MOD.BottomLeft.Bar:GetAlpha(), 0)
			SV.Events:Trigger("DOCK_LEFT_FADE_OUT");
			PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
		end
	end
end

_G.ToggleSuperDockRight = function(self, button)
	GameTooltip:Hide()
	if(button and IsAltKeyDown()) then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	elseif(button and button == 'RightButton') then
		if(InCombatLockdown()) then
			MOD.ErrorSound()
			SV:AddonMessage(ERR_NOT_IN_COMBAT)
			return
		end
		MOD.ButtonSound()
		local userSize = SV.db.Dock.dockRightHeight
		if(not MOD.private.RightExpanded) then
			MOD.private.RightExpanded = true
			MOD.BottomRight.Window:SetHeight(userSize + 300)
		else
			MOD.private.RightExpanded = nil
			MOD.BottomRight.Window:SetHeight(userSize)
		end
		MOD.BottomRight.Bar:Update()
		MOD:UpdateDockBackdrops()
	else
		if MOD.private.RightFaded then 
			MOD.private.RightFaded = nil;
			MOD.BottomRight:FadeIn(0.2, MOD.BottomRight:GetAlpha(), 1)
			MOD.BottomRight.Bar:FadeIn(0.2, MOD.BottomRight.Bar:GetAlpha(), 1)
			SV.Events:Trigger("DOCK_RIGHT_FADE_IN");
			PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
		else 
			MOD.private.RightFaded = true;
			MOD.BottomRight:FadeOut(0.2, MOD.BottomRight:GetAlpha(), 0)
			MOD.BottomRight.Bar:FadeOut(0.2, MOD.BottomRight.Bar:GetAlpha(), 0)
			SV.Events:Trigger("DOCK_RIGHT_FADE_OUT");
			PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
		end
	end
end

_G.ToggleSuperDocks = function()
	if(MOD.private.AllFaded) then
		MOD.private.AllFaded = nil;
		MOD.private.LeftFaded = nil;
		MOD.private.RightFaded = nil;
		MOD.BottomLeft:FadeIn(0.2, MOD.BottomLeft:GetAlpha(), 1)
		MOD.BottomLeft.Bar:FadeIn(0.2, MOD.BottomLeft.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_LEFT_FADE_IN");
		MOD.BottomRight:FadeIn(0.2, MOD.BottomRight:GetAlpha(), 1)
		MOD.BottomRight.Bar:FadeIn(0.2, MOD.BottomRight.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_RIGHT_FADE_IN");
		PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
	else
		MOD.private.AllFaded = true;
		MOD.private.LeftFaded = true;
		MOD.private.RightFaded = true;
		MOD.BottomLeft:FadeOut(0.2, MOD.BottomLeft:GetAlpha(), 0)
		MOD.BottomLeft.Bar:FadeOut(0.2, MOD.BottomLeft.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_LEFT_FADE_OUT");
		MOD.BottomRight:FadeOut(0.2, MOD.BottomRight:GetAlpha(), 0)
		MOD.BottomRight.Bar:FadeOut(0.2, MOD.BottomRight.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_RIGHT_FADE_OUT");
		PlaySoundFile([[sound\doodad\be_scryingorb_explode.ogg]])
	end
end

function MOD:EnterFade()
	if MOD.private.LeftFaded then
		self.BottomLeft:FadeIn(0.2, self.BottomLeft:GetAlpha(), 1)
		self.BottomLeft.Bar:FadeIn(0.2, self.BottomLeft.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_LEFT_FADE_IN");
	end
	if MOD.private.RightFaded then
		self.BottomRight:FadeIn(0.2, self.BottomRight:GetAlpha(), 1)
		self.BottomRight.Bar:FadeIn(0.2, self.BottomRight.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_RIGHT_FADE_IN");
	end
end 

function MOD:ExitFade()
	if MOD.private.LeftFaded then
		self.BottomLeft:FadeOut(2, self.BottomLeft:GetAlpha(), 0)
		self.BottomLeft.Bar:FadeOut(2, self.BottomLeft.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_LEFT_FADE_OUT");
	end
	if MOD.private.RightFaded then
		self.BottomRight:FadeOut(2, self.BottomRight:GetAlpha(), 0)
		self.BottomRight.Bar:FadeOut(2, self.BottomRight.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_RIGHT_FADE_OUT");
	end
end
--[[ 
########################################################## 
SET DOCKBAR FUNCTIONS
##########################################################
]]--
local RefreshDockWindows = function(self)
	--print('RefreshDockWindows')
	local dd = self.Data.Default
	local button = _G[dd]
	local default
	if(button) then
		default = button:GetAttribute("ownerFrame")
	end
	for name,window in pairs(self.Data.Windows) do
		if(window ~= default) then
			if(window.DockButton) then
				window.DockButton:Deactivate()
			end
		end
	end
end

local RefreshDockButtons = function(self)
	-- if(InCombatLockdown()) then
	-- 	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	-- 	return
	-- end
	for name,docklet in pairs(DOCK_REGISTRY) do
		if(docklet) then
			if(docklet.DockButton) then
				docklet.DockButton:Deactivate()
			end
		end
	end
end

local GetDefault = function(self)
	--print('GetDefault')
	local default = self.Data.Default
	local button = _G[default]
	if(button) then
		local window = button:GetAttribute("ownerFrame")
		if window and _G[window] then
			self:Refresh()
			self.Parent.Window.FrameLink = _G[window]
			self.Parent.Window:FadeIn()
			_G[window]:Show()
			button:Activate()
		end
	end
end

local OldDefault = function(self)
	--print('OldDefault')
	local default = self.Data.OriginalDefault
	local button = _G[default]
	if(button) then
		local window = button:GetAttribute("ownerFrame")
		if window and _G[window] then
			self:Refresh()
			self.Parent.Window.FrameLink = _G[window]
			self.Parent.Window:FadeIn()
			_G[window]:Show()
			button:Activate()
		end
	end
end

local ToggleDockletWindow = function(self, button)
	--print('ToggleDockletWindow')
	local frame  = button.FrameLink
	if(frame) then
		self.Parent.Window.FrameLink = frame
		self.Parent.Window:FadeIn()
		self:Cycle()
		--frame:FadeIn()
		button:Activate()
	else
		button:Deactivate()
		self:GetDefault()
	end
end

local AlertActivate = function(self, child)
	local size = SV.db.Dock.buttonSize or 22;
	self:ModHeight(size)
	self.backdrop:Show()
	child:ClearAllPoints()
	child:SetAllPoints(self)
end 

local AlertDeactivate = function(self)
	self.backdrop:Hide()
	self:ModHeight(1)
end

local Docklet_OnShow = function(self)
	--print('Docklet_OnShow')
	if(self.FrameLink) then
		if(not InCombatLockdown()) then
			self.FrameLink:SetFrameLevel(10)
		end
		self.FrameLink:FadeIn()
	end 
end

local Docklet_OnHide = function(self)
	--print('Docklet_OnHide')
	if(self.FrameLink) then
		if(not InCombatLockdown()) then
			self.FrameLink:SetFrameLevel(0)
			self.FrameLink:Hide()
		else
			self.FrameLink:FadeOut(0.2, 1, 0, true)
		end
	end 
end

local DockButtonMakeDefault = function(self)
	self.Parent.Data.Default = self:GetName()
	self.Parent:GetDefault()
	if(not self.Parent.Data.OriginalDefault) then
		self.Parent.Data.OriginalDefault = self:GetName()
	end
end 

local DockButtonActivate = function(self)
	--print('DockButtonActivate')
	self:SetAttribute("isActive", true)
	self:SetPanelColor("checked")
	self.Icon:SetGradient(unpack(SV.Media.gradient.checked))
	if(self.FrameLink) then
		if(not InCombatLockdown()) then
			self.FrameLink:SetFrameLevel(10)
		end
		self.FrameLink:FadeIn()
	end
end 

local DockButtonDeactivate = function(self)
	--print('DockButtonDeactivate')
	if(self.FrameLink) then
		if(not InCombatLockdown()) then
			self.FrameLink:SetFrameLevel(0)
			self.FrameLink:Hide()
		else
			self.FrameLink:FadeOut(0.2, 1, 0, true)
		end
	end
	self:SetAttribute("isActive", false)
	self:SetPanelColor("default")
	self.Icon:SetGradient(unpack(SV.Media.gradient.icon))
end

local DockButton_OnEnter = function(self, ...)
	MOD:EnterFade()

	self:SetPanelColor("highlight")
	self.Icon:SetGradient(unpack(SV.Media.gradient.highlight))

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	local tipText = self:GetAttribute("tipText")
	GameTooltip:AddDoubleLine("[Left-Click]", tipText, 0, 1, 0, 1, 1, 1)
	local tipExtraText = self:GetAttribute("tipExtraText")
	GameTooltip:AddDoubleLine("[Right-Click]", tipExtraText, 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[Alt + Click]", "Reset Dock Buttons", 0, 0.5, 1, 0.5, 1, 0.5)
	GameTooltip:Show()
end

local DockletButton_OnEnter = function(self, ...)
	MOD:EnterFade()

	self:SetPanelColor("highlight")
	self.Icon:SetGradient(unpack(SV.Media.gradient.highlight))

	local tipAnchor = self:GetAttribute("tipAnchor")
	GameTooltip:SetOwner(self, tipAnchor, 0, 4)
	GameTooltip:ClearLines()
	if(self.CustomTooltip) then
		self:CustomTooltip()
	else
		local tipText = self:GetAttribute("tipText")
		GameTooltip:AddDoubleLine("[Left-Click]", tipText, 0, 1, 0, 1, 1, 1)
	end
	if(self:GetAttribute("hasDropDown") and self.GetMenuList) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("[Alt + Click]", "Docking Options", 0, 0.5, 1, 0.5, 1, 0.5)
	end
	GameTooltip:Show()
end 

local DockletButton_OnLeave = function(self, ...)
	MOD:ExitFade()

	if(self:GetAttribute("isActive")) then
		self:SetPanelColor("checked")
		self.Icon:SetGradient(unpack(SV.Media.gradient.checked))
	else
		self:SetPanelColor("default")
		self.Icon:SetGradient(unpack(SV.Media.gradient.icon))
	end

	GameTooltip:Hide()
end

local DockletButton_OnClick = function(self, button)
	if(self.ClickTheme) then
		self:ClickTheme()
	end
	MOD.ButtonSound()
	if(IsAltKeyDown() and (not InCombatLockdown()) and self:GetAttribute("hasDropDown") and self.GetMenuList) then
		local list = self:GetMenuList();
		SV.Dropdown:Open(self, list);
	else
		if self.PostClickFunction then
			self:PostClickFunction()
		else
			self.Parent:Toggle(self)
		end
	end
end

local DockletButton_OnPostClick = function(self, button)
	if InCombatLockdown() then 
		MOD.ErrorSound()
		return 
	end
	if(self.ClickTheme) then
		self:ClickTheme()
	end
	MOD.ButtonSound()
	if(IsAltKeyDown() and self:GetAttribute("hasDropDown") and self.GetMenuList) then
		local list = self:GetMenuList();
		SV.Dropdown:Open(self, list);
	end
end

local DockletEnable = function(self)
	local dock = self.Parent;
	if(self.DockButton) then dock.Bar:Add(self.DockButton) end
end

local DockletDisable = function(self)
	local dock = self.Parent;
	if(self.DockButton) then dock.Bar:Remove(self.DockButton) end
end

local DockletButtonSize = function(self)
	local size = self.Bar.ToolBar:GetHeight() or 30;
	return size;
end

local DockletRelocate = function(self, location)
	local newParent = MOD[location];

	if(not newParent) then return end

	if(self.DockButton) then
		newParent.Bar:Add(self.DockButton) 
	end
	
	if(self.Bar) then 
		local height = newParent.Bar.ToolBar:GetHeight();
		local mod = newParent.Bar.Data[1];
		local barAnchor = newParent.Bar.Data[2];
		local barReverse = SV:GetReversePoint(barAnchor);
		local spacing = SV.db.Dock.buttonSpacing;

		self.Bar:ClearAllPoints();
		self.Bar:ModPoint(barAnchor, newParent.Bar.ToolBar, barReverse, (spacing * mod), 0)
	end
end

local GetDockablePositions = function(self)
	local button = self;
	local name = button:GetName();
	local currentLocation = MOD.private.Locations[name];
	local t;

	if(self.GetPreMenuList) then
		t = self:GetPreMenuList();
		tinsert(t, { title = "Move This", divider = true })
	else
		t = {{ title = "Move This", divider = true }};
	end

	for location,option in pairs(DOCK_DROPDOWN_OPTIONS) do
		if(currentLocation ~= location) then
		    tinsert(t, option);
		end
	end

	tinsert(t, { title = "Re-Order", divider = true });

	for i=1, #button.Parent.Data.Order do
		if(i ~= button.OrderIndex) then
			local positionText = ("Position #%d"):format(i);
		    tinsert(t, { text = positionText, func = function() button.Parent:ChangeOrder(button, i) end });
		end
	end

	return t;
end

local ChangeBarOrder = function(self, button, targetIndex)
	local targetName = button:GetName();
	local currentIndex = button.OrderIndex;
	wipe(ORDER_TEST);
	wipe(ORDER_TEMP);
	for i = 1, #self.Data.Order do
		local nextName = self.Data.Order[i];
		if(i == targetIndex) then
			if(currentIndex > targetIndex) then
				tinsert(ORDER_TEMP, targetName)
				tinsert(ORDER_TEMP, nextName)
			else
				tinsert(ORDER_TEMP, nextName)
				tinsert(ORDER_TEMP, targetName)
			end
		elseif(targetName ~= nextName) then
			tinsert(ORDER_TEMP, nextName)
		end
	end

	wipe(self.Data.Order);
	local safeIndex = 1;
	for i = 1, #ORDER_TEMP do
		local nextName = ORDER_TEMP[i];
		local nextButton = self.Data.Buttons[nextName];
		if(nextButton and (not ORDER_TEST[nextName])) then
			ORDER_TEST[nextName] = true
			tinsert(self.Data.Order, nextName);
			nextButton.OrderIndex = safeIndex;
			safeIndex = safeIndex + 1;
		end
	end

	self:Update()
end

local RefreshBarOrder = function(self)
	wipe(ORDER_TEST);
	wipe(ORDER_TEMP);
	for i = 1, #self.Data.Order do
		local nextName = self.Data.Order[i];
		tinsert(ORDER_TEMP, nextName)
	end
	wipe(self.Data.Order);
	local safeIndex = 1;
	for i = 1, #ORDER_TEMP do
		local nextName = ORDER_TEMP[i];
		local nextButton = self.Data.Buttons[nextName];
		if(nextButton and (not ORDER_TEST[nextName])) then
			ORDER_TEST[nextName] = true
			tinsert(self.Data.Order, nextName);
			nextButton.OrderIndex = safeIndex;
			safeIndex = safeIndex + 1;
		end
	end
end

local CheckBarOrder = function(self, targetName)
	local found = false;
	for i = 1, #self.Data.Order do
		if(self.Data.Order[i] == targetName) then
			found = true;
		end
	end
	if(not found) then
		tinsert(self.Data.Order, targetName);
		self:UpdateOrder();
	end
end

local RefreshBarLayout = function(self)
	local anchor = upper(self.Data.Location)
	local mod = self.Data.Modifier
	local size = self.ToolBar:GetHeight();
	local count = #self.Data.Order;
	local offset = 1;
	local safeIndex = 1;
	for i = 1, count do
		local nextName = self.Data.Order[i];
		local nextButton = self.Data.Buttons[nextName];
		if(nextButton) then
			offset = (safeIndex - 1) * (size + 6) + 6
			nextButton:ClearAllPoints();
			nextButton:SetSize(size, size);
			nextButton:SetPoint(anchor, self.ToolBar, anchor, (offset * mod), 0);
			if(not nextButton:IsShown()) then
				nextButton:Show();
			end
			nextButton.OrderIndex = safeIndex;
			safeIndex = safeIndex + 1;
		end
	end

	self.ToolBar:SetWidth(offset + size);

	if(SV.Dropdown:IsShown()) then
		ToggleFrame(SV.Dropdown)
	end
end

local AddToDock = function(self, button)
	if not button then return end
	local name = button:GetName();
	if(self.Data.Buttons[name]) then return end

	local registeredLocation = MOD.private.Locations[name]
	local currentLocation = self.Data.Location

	if(registeredLocation) then
		if(registeredLocation ~= currentLocation) then
			if(MOD[registeredLocation].Bar.Data.Buttons[name]) then
				MOD[registeredLocation].Bar:Remove(button);
			else
				MOD[registeredLocation].Bar:Add(button);
				return
			end
		end
	end

	self.Data.Buttons[name] = button;
	self:CheckOrder(name);
	
	MOD.private.Locations[name] = currentLocation;
	button.Parent = self;
	button:SetParent(self.ToolBar);

	if(button.FrameLink) then
		local frame = button.FrameLink
		local frameName = frame:GetName()
		self.Data.Windows[frameName] = frame;
		MOD.private.Locations[frameName] = currentLocation;
		frame:Show()
		frame:ClearAllPoints()
		frame:SetParent(self.Parent.Window)
		frame:InsetPoints(self.Parent.Window)
		frame.Parent = self.Parent
	end

	-- self:UpdateOrder()
	self:Update()
end

local RemoveFromDock = function(self, button)
	if not button then return end 
	local name = button:GetName();
	local registeredLocation = MOD.private.Locations[name];
	local currentLocation = self.Data.Location

	if(registeredLocation and (registeredLocation == currentLocation)) then 
		MOD.private.Locations[name] = nil;
	end

	for i = 1, #self.Data.Order do
		local nextName = self.Data.Order[i];
		if(nextName == name) then
			tremove(self.Data.Order, i);
			break;
		end
	end

	if(not self.Data.Buttons[name]) then return end

	button:Hide()
	if(button.FrameLink) then
		local frameName = button.FrameLink:GetName()
		MOD.private.Locations[frameName] = nil;
		button.FrameLink:FadeOut(0.2, 1, 0, true)
		self.Data.Windows[frameName] = nil;
	end

	button.OrderIndex = 0;
	self.Data.Buttons[name] = nil;
	self:UpdateOrder()
	self:Update()
end

local ActivateDockletButton = function(self, button, clickFunction, tipFunction, isAction)
	button.Activate = DockButtonActivate
	button.Deactivate = DockButtonDeactivate
	button.MakeDefault = DockButtonMakeDefault
	button.GetMenuList = GetDockablePositions

	if(tipFunction and type(tipFunction) == "function") then
		button.CustomTooltip = tipFunction
	end

	button.Parent = self
	button:SetPanelColor("default")
	button.Icon:SetGradient(unpack(SV.Media.gradient.icon))
	button:SetScript("OnEnter", DockletButton_OnEnter)
	button:SetScript("OnLeave", DockletButton_OnLeave)
	if(not isAction) then
		button:SetScript("OnClick", DockletButton_OnClick)
	else
		button:SetScript("PostClick", DockletButton_OnPostClick)
	end

	if(clickFunction and type(clickFunction) == "function") then
		button.PostClickFunction = clickFunction
	end
end

local CreateBasicToolButton = function(self, displayName, texture, onclick, globalName, tipFunction, primaryTemplate)
	local dockIcon = texture or [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-ADDON]];
	local size = self.ToolBar:GetHeight();
	local template = "SVUI_DockletButtonTemplate"

	if(primaryTemplate) then
		template = primaryTemplate .. ", SVUI_DockletButtonTemplate"
	end

	local button = _G[globalName .. "DockletButton"] or CreateFrame("Button", globalName, self.ToolBar, template)

	button:ClearAllPoints()
	button:SetSize(size, size) 
	MOD:SetButtonTheme(button, size)
	button.Icon:SetTexture(dockIcon)
	button:SetAttribute("tipText", displayName)
	button:SetAttribute("tipAnchor", self.Data.TipAnchor)
    button:SetAttribute("ownerFrame", globalName)

    button.OrderIndex = 0;

    self:Add(button)
	self:Initialize(button, onclick, tipFunction, primaryTemplate)
	
	return button
end
--[[ 
########################################################## 
DOCKS
##########################################################
]]--
local DockBar_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:Refresh()
    end
end

for location, settings in pairs(DOCK_LOCATIONS) do
	MOD[location] = _G["SVUI_Dock" .. location];
	MOD[location].Bar = _G["SVUI_DockBar" .. location];

	MOD[location].Alert.Activate = AlertActivate;
	MOD[location].Alert.Deactivate = AlertDeactivate;

	MOD[location].Bar.Parent = MOD[location];
	MOD[location].Bar.Refresh = RefreshDockButtons;
	MOD[location].Bar.Cycle = RefreshDockWindows;
	MOD[location].Bar.GetDefault = GetDefault;
	MOD[location].Bar.UnsetDefault = OldDefault;
	MOD[location].Bar.Toggle = ToggleDockletWindow;
	MOD[location].Bar.Update = RefreshBarLayout;
	MOD[location].Bar.UpdateOrder = RefreshBarOrder;
	MOD[location].Bar.ChangeOrder = ChangeBarOrder;
	MOD[location].Bar.CheckOrder = CheckBarOrder;
	MOD[location].Bar.Add = AddToDock;
	MOD[location].Bar.Remove = RemoveFromDock;
	MOD[location].Bar.Initialize = ActivateDockletButton;
	MOD[location].Bar.Create = CreateBasicToolButton;
	MOD[location].Bar.Data = {
		Location = location,
		Anchor = settings[2],
		Modifier = settings[1],
		TipAnchor = settings[4],
		Default = "",
		Buttons = {},
		Windows = {},
		Order = {},
	};
	--MOD[location].Bar:SetScript("OnEvent", DockBar_OnEvent)
end

MOD.TopCenter = _G["SVUI_DockTopCenter"];
MOD.BottomCenter = _G["SVUI_DockBottomCenter"];

local function InitDockButton(button, location)
	button:SetPanelColor("default")
	button.Icon:SetGradient(unpack(SV.Media.gradient.icon))
	button:SetScript("OnEnter", DockButton_OnEnter)
	button:SetScript("OnLeave", DockletButton_OnLeave)
	if(location == "BottomLeft") then
		button:SetScript("OnClick", ToggleSuperDockLeft)
	else
		button:SetScript("OnClick", ToggleSuperDockRight)
	end
end

local function BorderColorUpdates()
	SVUIDock_TopBorder:SetBackdropColor(0,0,0,0.8)
	SVUIDock_TopBorder:SetBackdropBorderColor(0,0,0,0.8)
	SVUIDock_BottomBorder:SetBackdropColor(0,0,0,0.8)
	SVUIDock_BottomBorder:SetBackdropBorderColor(0,0,0,0.8)
end

--SV.Events:On("MEDIA_COLORS_UPDATED", "BorderColorUpdates", BorderColorUpdates)
--[[ 
########################################################## 
EXTERNALLY ACCESSIBLE METHODS
##########################################################
]]--
function MOD:SetDockButton(location, displayName, texture, onclick, globalName, tipFunction, primaryTemplate)
	if(self.private.Locations[globalName]) then
		location = self.private.Locations[globalName];
	else
		self.private.Locations[globalName] = location;
	end
	local parent = self[location]
	return parent.Bar:Create(displayName, texture, onclick, globalName, tipFunction, primaryTemplate)
end

function MOD:GetDimensions(location)
	local width, height;

	if(location:find("Left")) then
		width = SV.db.Dock.dockLeftWidth;
		height = SV.db.Dock.dockLeftHeight;
		if(MOD.private.LeftExpanded) then
			height = height + 300
		end
	else
		width = SV.db.Dock.dockRightWidth;
		height = SV.db.Dock.dockRightHeight;
		if(MOD.private.RightExpanded) then
			height = height + 300
		end
	end

	return width, height;
end

function MOD:NewDocklet(location, globalName, readableName, texture, onclick)
	if(DOCK_REGISTRY[globalName]) then return end;
	
	if(self.private.Locations[globalName]) then
		location = self.private.Locations[globalName];
	else
		self.private.Locations[globalName] = location;
	end

	local newParent = self[location];
	if(not newParent) then return end
	local frame = _G[globalName] or CreateFrame("Frame", globalName, UIParent, "SVUI_DockletWindowTemplate");
	frame:SetParent(newParent.Window);
	frame:SetSize(newParent.Window:GetSize());
	frame:SetAllPoints(newParent.Window);
	frame:SetFrameStrata("BACKGROUND");
	frame.Parent = newParent
	frame.Disable = DockletDisable;
	frame.Enable = DockletEnable;
	frame.Relocate = DockletRelocate;
	frame.GetButtonSize = DockletButtonSize;
	frame:FadeCallback(function() newParent.Bar:Cycle() newParent.Bar:GetDefault() end, false, true)

	newParent.Bar.Data.Windows[globalName] = frame;

	local buttonName = ("%sButton"):format(globalName)
	frame.DockButton = newParent.Bar:Create(readableName, texture, onclick, buttonName);
	frame.DockButton.FrameLink = frame
	DOCK_REGISTRY[globalName] = frame;
	frame:SetAlpha(0)
	return frame
end

function MOD:NewAdvancedDocklet(location, globalName)
	if(DOCK_REGISTRY[globalName]) then return end;

	if(self.private.Locations[globalName]) then
		location = self.private.Locations[globalName];
	else
		self.private.Locations[globalName] = location;
	end

	local newParent = self[location];
	if(not newParent) then return end

	local frame = CreateFrame("Frame", globalName, UIParent, "SVUI_DockletWindowTemplate");
	frame:SetParent(newParent.Window);
	frame:SetSize(newParent.Window:GetSize());
	frame:SetAllPoints(newParent.Window);
	frame:SetFrameStrata("BACKGROUND");
	frame.Parent = newParent
	frame.Disable = DockletDisable;
	frame.Enable = DockletEnable;
	frame.Relocate = DockletRelocate;
	frame.GetButtonSize = DockletButtonSize;

	newParent.Bar.Data.Windows[globalName] = frame;

	local height = newParent.Bar.ToolBar:GetHeight();
	local mod = newParent.Bar.Data.Modifier;
	local barAnchor = newParent.Bar.Data.Anchor;
	local barReverse = SV:GetReversePoint(barAnchor);
	local spacing = SV.db.Dock.buttonSpacing;

	frame.Bar = CreateFrame("Frame", nil, newParent);
	frame.Bar:SetSize(1, height);
	frame.Bar:ModPoint(barAnchor, newParent.Bar.ToolBar, barReverse, (spacing * mod), 0)
	SV.Layout:Add(frame.Bar, globalName .. " Dock Bar");

	DOCK_REGISTRY[globalName] = frame;
	return frame
end
--[[ 
########################################################## 
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateDockBackdrops()
	if SV.db.Dock.rightDockBackdrop then
		MOD.BottomRight.backdrop:Show()
		MOD.BottomRight.backdrop:ClearAllPoints()
		MOD.BottomRight.backdrop:WrapPoints(MOD.BottomRight.Window, 4, 4)

		MOD.BottomRight.Alert.backdrop:ClearAllPoints()
		MOD.BottomRight.Alert.backdrop:WrapPoints(MOD.BottomRight.Alert, 4, 4)
	else
		MOD.BottomRight.backdrop:Hide()
	end
	if SV.db.Dock.leftDockBackdrop then
		MOD.BottomLeft.backdrop:Show()
		MOD.BottomLeft.backdrop:ClearAllPoints()
		MOD.BottomLeft.backdrop:WrapPoints(MOD.BottomLeft.Window, 4, 4)

		MOD.BottomLeft.Alert.backdrop:ClearAllPoints()
		MOD.BottomLeft.Alert.backdrop:WrapPoints(MOD.BottomLeft.Alert, 4, 4)
	else
		MOD.BottomLeft.backdrop:Hide()
	end
end 

function MOD:BottomBorderVisibility()
	if SV.db.Dock.bottomPanel then 
		SVUIDock_BottomBorder:Show()
	else 
		SVUIDock_BottomBorder:Hide()
	end 
end 

function MOD:TopBorderVisibility()
	if SV.db.Dock.topPanel then 
		SVUIDock_TopBorder:Show()
	else 
		SVUIDock_TopBorder:Hide()
	end 
end

function MOD:ResetAllButtons()
	wipe(MOD.private.Order)
	wipe(MOD.private.Locations)
	ReloadUI()
end

function MOD:UpdateAllDocks()
	for location, settings in pairs(DOCK_LOCATIONS) do
		local dock = self[location];
		dock.Bar:Cycle()
		dock.Bar:GetDefault()
	end
end

function MOD:Refresh()
	local buttonsize = SV.db.Dock.buttonSize;
	local spacing = SV.db.Dock.buttonSpacing;

	for location, settings in pairs(DOCK_LOCATIONS) do
		if(location ~= "TopRight") then
			local width, height = self:GetDimensions(location);
			local dock = self[location];

			dock.Bar:SetSize(width, buttonsize)
		    dock.Bar.ToolBar:SetHeight(buttonsize)
		    dock:SetSize(width, height)
		    dock.Alert:SetSize(width, 1)
		    dock.Window:SetSize(width, height)

		    if(dock.Bar.Button) then
		    	dock.Bar.Button:SetSize(buttonsize, buttonsize)
		    end

		    dock.Bar:Update()
		end
	end

	local centerWidth = SV.db.Dock.dockCenterWidth;
	local dockWidth = centerWidth * 0.5;
	local dockHeight = SV.db.Dock.dockCenterHeight;

	self.BottomCenter:SetSize(centerWidth, dockHeight);
	self.TopCenter:SetSize(centerWidth, dockHeight);

	self:BottomBorderVisibility();
	self:TopBorderVisibility();
	self:UpdateDockBackdrops();

	self:UpdateProfessionTools();
	self:UpdateGarrisonTool();
	self:UpdateRaidLeader();

	SV.Events:Trigger("DOCKS_UPDATED");
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')

	if(self.ProfessionNeedsUpdate) then
		self.ProfessionNeedsUpdate = nil;
		self:UpdateProfessionTools()
	end

	if(self.GarrisonNeedsUpdate) then
		self.GarrisonNeedsUpdate = nil;
		self:UpdateGarrisonTool()
	end

	if(self.RaidLeaderNeedsUpdate) then
		self.RaidLeaderNeedsUpdate = nil;
		self:UpdateRaidLeader()
	end
end

function MOD:Initialize()
	if(not SV.private.Docks) then
		SV.private.Docks = {}
	end

	self.private = SV.private.Docks;
	
	if(not self.private.AllFaded) then 
		self.private.AllFaded = false
	end

	if(not self.private.LeftFaded) then 
		self.private.LeftFaded = false
	end

	if(not self.private.RightFaded) then 
		self.private.RightFaded = false
	end

	if(not self.private.LeftExpanded) then 
		self.private.LeftExpanded = false
	end

	if(not self.private.RightExpanded) then 
		self.private.RightExpanded = false
	end

	if(not self.private.Order) then 
		self.private.Order = {}
	end

	if(not self.private.Locations) then 
		self.private.Locations = {}
	end

	self.private.Locations = self.private.Locations;

	local buttonsize = SV.db.Dock.buttonSize;
	local spacing = SV.db.Dock.buttonSpacing;
	local texture = [[Interface\AddOns\SVUI_!Core\assets\textures\BUTTON]];

	-- [[ TOP AND BOTTOM BORDERS ]] --

	local borderTop = CreateFrame("Frame", "SVUIDock_TopBorder", UIParent)
	borderTop:ModPoint("TOPLEFT", SV.Screen, "TOPLEFT", -1, 1)
	borderTop:ModPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", 1, 1)
	borderTop:ModHeight(10)
	borderTop:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		tileSize = 0, 
		edgeSize = 1, 
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	borderTop:SetBackdropColor(0,0,0,0)
	borderTop:SetBackdropBorderColor(0,0,0,0)
	borderTop:SetFrameLevel(0)
	borderTop:SetFrameStrata('BACKGROUND')
	borderTop:SetScript("OnShow", function(this)
		this:SetFrameLevel(0)
		this:SetFrameStrata('BACKGROUND')
	end)
	self:TopBorderVisibility()

	local borderBottom = CreateFrame("Frame", "SVUIDock_BottomBorder", UIParent)
	borderBottom:ModPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", -1, -1)
	borderBottom:ModPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 1, -1)
	borderBottom:ModHeight(10)
	borderBottom:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		tileSize = 0, 
		edgeSize = 1, 
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	borderBottom:SetBackdropColor(0,0,0,0)
	borderBottom:SetBackdropBorderColor(0,0,0,0)
	borderBottom:SetFrameLevel(0)
	borderBottom:SetFrameStrata('BACKGROUND')
	borderBottom:SetScript("OnShow", function(this)
		this:SetFrameLevel(0)
		this:SetFrameStrata('BACKGROUND')
	end)
	self:BottomBorderVisibility()

	for location, settings in pairs(DOCK_LOCATIONS) do
		local width, height = self:GetDimensions(location);
		local dock = self[location];
		local mod = settings[1];
		local anchor = upper(location);
		local reverse = SV:GetReversePoint(anchor);
		local barAnchor = settings[2];
		local barReverse = SV:GetReversePoint(barAnchor);
		local isBottom = settings[3];
		local vertMod = isBottom and 1 or -1

		dock.Bar:SetParent(SV.Screen)
		dock.Bar:ClearAllPoints()
		dock.Bar:SetSize(width, buttonsize)
		dock.Bar:SetPoint(anchor, SV.Screen, anchor, (2 * mod), (2 * vertMod))

		if(not MOD.private.Order[location]) then 
			MOD.private.Order[location] = {}
		end

		dock.Bar.Data.Order = MOD.private.Order[location];

		dock.Bar.ToolBar:ClearAllPoints()

		if(dock.Bar.Button) then
	    	dock.Bar.Button:SetSize(buttonsize, buttonsize)
	    	self:SetButtonTheme(dock.Bar.Button, buttonsize)
	    	dock.Bar.Button.Icon:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-ADDON]])
	    	dock.Bar.ToolBar:SetSize(1, buttonsize)
	    	dock.Bar.ToolBar:ModPoint(barAnchor, dock.Bar.Button, barReverse, (spacing * mod), 0)
	    	InitDockButton(dock.Bar.Button, location)
	    else
	    	dock.Bar.ToolBar:SetSize(1, buttonsize)
	    	dock.Bar.ToolBar:ModPoint(barAnchor, dock.Bar, barAnchor, 0, 0)
	    end

	    dock:SetParent(SV.Screen)
	    dock:ClearAllPoints()
	    dock:SetPoint(anchor, dock.Bar, reverse, 0, (12 * vertMod))
	    dock:SetSize(width, height)
	    dock:SetAttribute("buttonSize", buttonsize)
	    dock:SetAttribute("spacingSize", spacing)

	    dock.Alert:ClearAllPoints()
	    dock.Alert:SetSize(width, 1)
	    dock.Alert:SetPoint(anchor, dock, anchor, 0, 0)

	    dock.Window:ClearAllPoints()
	    dock.Window:SetSize(width, height)
	    dock.Window:SetPoint(anchor, dock.Alert, reverse, 0, (4 * vertMod))

		if(isBottom) then
			dock.backdrop = self.SetThemeDockStyle(dock.Window, isBottom)
			dock.Alert.backdrop = self.SetThemeDockStyle(dock.Alert, isBottom)
			dock.Alert.backdrop:Hide()
			SV.Layout:Add(dock.Bar, location .. " Dock ToolBar");
			SV.Layout:Add(dock, location .. " Dock Window")
		end
	end

	if MOD.private.LeftFaded then MOD.BottomLeft:Hide() end
	if MOD.private.RightFaded then MOD.BottomRight:Hide() end

	SV:ManageVisibility(self.BottomRight.Window)
	SV:ManageVisibility(self.TopLeft)
	SV:ManageVisibility(self.TopRight)

	local centerWidth = SV.db.Dock.dockCenterWidth;
	local dockHeight = SV.db.Dock.dockCenterHeight;

	self.TopCenter:SetParent(SV.Screen)
	self.TopCenter:ClearAllPoints()
	self.TopCenter:SetSize(centerWidth, dockHeight)
	self.TopCenter:SetPoint("TOP", SV.Screen, "TOP", 0, 0)

	self.BottomCenter:SetParent(SV.Screen)
	self.BottomCenter:ClearAllPoints()
	self.BottomCenter:SetSize(centerWidth, dockHeight)
	self.BottomCenter:SetPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 0)

	self.BottomLeft.Bar:Refresh()
	self.BottomRight.Bar:Refresh()
	self.TopLeft.Bar:Refresh()
	self.TopRight.Bar:Refresh()

	self:UpdateDockBackdrops()

	self:LoadProfessionTools();
	self:LoadGarrisonTool();
	self:LoadRaidLeaderTools();
end