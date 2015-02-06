--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local type 		= _G.type;
local tostring 	= _G.tostring;
local print 	= _G.print;
local pcall 	= _G.pcall;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format,find = string.format, string.find;
--[[ MATH METHODS ]]--
local floor = math.floor;
--[[ TABLE METHODS ]]--
local twipe, tcopy = table.wipe, table.copy;
local IsAddOnLoaded = _G.IsAddOnLoaded;
local LoadAddOn = _G.LoadAddOn;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L
local MOD = SV.Skins;
if(not MOD) then return end;
local NewHook = hooksecurefunc;
local Schema = MOD.Schema;
local VERSION = MOD.Version;
--[[ 
########################################################## 
CORE DATA
##########################################################
]]--
MOD.AddOnQueue = {};
MOD.AddOnEvents = {};
MOD.CustomQueue = {};
MOD.EventListeners = {};
MOD.OnLoadAddons = {};
MOD.SkinsdAddons = {};
MOD.Debugging = false;
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local charming = {"Spiffy", "Pimped Out", "Fancy", "Awesome", "Bad Ass", "Sparkly", "Gorgeous", "Handsome", "Shiny"}
local styleMessage = '|cffFFAA00[Skinned]|r |cff00FF77%s|r Is Now %s!'

local function SendAddonMessage(msg, prefix)
	if(type(msg) == "table") then 
        msg = tostring(msg) 
    end

    if(not msg) then return end

    if(prefix) then
    	local outbound = ("%s %s"):format(prefix, msg);
    	print(outbound)
    else
    	print(msg)
    end
end

function MOD:LoadAlert(MainText, Function)
	self.Alert.Text:SetText(MainText)
	self.Alert.Accept:SetScript('OnClick', Function)
	self.Alert:Show()
end

function MOD:Style(style, fn, ...)
	local pass, catch = pcall(fn, ...)
	if(catch and self.Debugging) then
		SV:HandleError("SKINS", style, catch);
		return
	end
	if(pass and (not style:find("Blizzard")) and not self.SkinsdAddons[style]) then
		self.SkinsdAddons[style] = true
		if(SV.db.general.loginmessage) then
			local verb = charming[math.random(1,#charming)]
			SV:AddonMessage(styleMessage:format(style, verb))
		end
		self.AddOnQueue[style] = nil
	end
	self.Debugging = false
end

function MOD:IsAddonReady(addon, ...)
	if not SV.db.Skins.addons then return end
	for i = 1, select('#', ...) do
		local a = select(i, ...)
		if not a then break end
		if not IsAddOnLoaded(a) then return false end
	end

	return SV.db.Skins.addons[addon]
end

function MOD:SaveAddonStyle(addon, fn, force, passive, ...)
	self:DefineEventFunction("PLAYER_ENTERING_WORLD", addon)
	if(passive) then
		self:DefineEventFunction("ADDON_LOADED", addon)
	end
	for i=1, select("#",...) do 
		local event = select(i,...)
		if(event) then
			self:DefineEventFunction(event, addon)
		end  
	end
	if(SV.defaults.Skins.addons and SV.defaults.Skins.addons[addon] == nil) then
		SV.defaults.Skins.addons[addon] = true
	end

	if force then
		fn()
	else
		self.AddOnQueue[addon] = fn
	end
end 

function MOD:SaveBlizzardStyle(addon, fn, force)
	if force then 
		if(not IsAddOnLoaded(addon)) then
			LoadAddOn(addon)
		end
		fn()
	else
		self.OnLoadAddons[addon] = fn
	end
end 

function MOD:SaveCustomStyle(fn)
	tinsert(MOD.CustomQueue, fn)
end 

function MOD:DefineEventFunction(addonEvent, addon)
	if(not addon) then return end
	if(not self.EventListeners[addonEvent]) then
		self.EventListeners[addonEvent] = {}
	end
	self.EventListeners[addonEvent][addon] = true
	if(not self[addonEvent]) then
		self[addonEvent] = function(self, event, ...)
			for name,fn in pairs(self.AddOnQueue) do 
				if self:IsAddonReady(name) and self.EventListeners[event] and self.EventListeners[event][name] then
					self:Style(name, fn, event, ...)
				end 
			end 
		end 
		self:RegisterEvent(addonEvent);
	end
end

function MOD:SafeEventRemoval(addon, event)
	if not self.EventListeners[event] then return end 
	if not self.EventListeners[event][addon] then return end 
	self.EventListeners[event][addon] = nil;
	local defined = false;
	for name,_ in pairs(self.EventListeners[event]) do 
		if name then
			defined = true;
			break 
		end 
	end 
	if not defined then 
		self:UnregisterEvent(event) 
	end 
end

function MOD:PLAYER_ENTERING_WORLD(event, ...)
	for addonName,fn in pairs(self.OnLoadAddons) do
		if(SV.db.Skins.blizzard[addonName] == nil) then
			SV.db.Skins.blizzard[addonName] = true
		end
		if(IsAddOnLoaded(addonName) and (SV.db.Skins.blizzard[addonName] or SV.db.Skins.addons[addonName])) then 
			self:Style(addonName, fn, event, ...)
			self.OnLoadAddons[addonName] = nil
		end 
	end

	for _,fn in pairs(self.CustomQueue)do 
		fn(event, ...)
	end

	twipe(self.CustomQueue)

	local listener = self.EventListeners[event]
	for addonName,fn in pairs(self.AddOnQueue)do
		if(SV.db.Skins.addons[addonName] == nil) then
			SV.db.Skins.addons[addonName] = true
		end
		if(listener[addonName] and self:IsAddonReady(addonName)) then
			self:Style(addonName, fn, event, ...)
		end 
	end
end

function MOD:ADDON_LOADED(event, addon)
	--print(addon)
	for name, fn in pairs(self.OnLoadAddons) do
		if(addon:find(name)) then
			self:Style(name, fn, event, addon)
			self.OnLoadAddons[name] = nil
		end
	end

	local listener = self.EventListeners[event]
	if(listener) then
		for name, fn in pairs(self.AddOnQueue) do 
			if(listener[name] and self:IsAddonReady(name)) then
				self:Style(name, fn, event, addon)
			end 
		end
	end
end
--[[ 
########################################################## 
OPTIONS CREATION
##########################################################
]]--
function MOD:FetchDocklets()
	local dock1 = SV.private.Docks.Embed1 or "None";
	local dock2 = SV.private.Docks.Embed2 or "None";
	local enabled1 = (dock1 ~= "None")
	local enabled2 = ((dock2 ~= "None") and (dock2 ~= dock1))
	return dock1, dock2, enabled1, enabled2
end

function MOD:ValidateDocklet(addon)
	local dock1,dock2,enabled1,enabled2 = self:FetchDocklets();
	local valid = false;

	if(dock1:find(addon) or dock2:find(addon)) then
		valid = true 
	end

	return valid,enabled1,enabled2
end

function MOD:DockletReady(addon, dock)
	if((not addon) or (not dock)) then return false end
	if(dock:find(addon) and IsAddOnLoaded(addon)) then
		return true 
	end
	return false
end

function MOD:RegisterAddonDocklets()
	local dock1,dock2,enabled1,enabled2 = self:FetchDocklets();
  	local tipLeft, tipRight = "", "";
  	local active1, active2 = false, false;

  	self.Docklet.Dock1.FrameLink = nil;
  	self.Docklet.Dock2.FrameLink = nil;

  	if(enabled1) then
  		local width = self.Docklet:GetWidth();

		if(enabled2) then
			self.Docklet.Dock1:SetWidth(width * 0.5)
			self.Docklet.Dock2:SetWidth(width * 0.5)

			if(self:DockletReady("Skada", dock2)) then
				tipRight = " and Skada";
				self:Docklet_Skada()
				active2 = true
			elseif(self:DockletReady("Omen", dock2)) then
				tipRight = " and Omen";
				self:Docklet_Omen(self.Docklet.Dock2)
				active2 = true
			elseif(self:DockletReady("Recount", dock2)) then
				tipRight = " and Recount";
				self:Docklet_Recount(self.Docklet.Dock2)
				active2 = true
			elseif(self:DockletReady("TinyDPS", dock2)) then
				tipRight = " and TinyDPS";
				self:Docklet_TinyDPS(self.Docklet.Dock2)
				active2 = true
			elseif(self:DockletReady("alDamageMeter", dock2)) then
				tipRight = " and alDamageMeter";
				self:Docklet_alDamageMeter(self.Docklet.Dock2)
				active2 = true
			end
		end

		if(not active2) then
			self.Docklet.Dock1:SetWidth(width)
		end

		if(self:DockletReady("Skada", dock1)) then
			tipLeft = "Skada";
			self:Docklet_Skada()
			active1 = true
		elseif(self:DockletReady("Omen", dock1)) then
			tipLeft = "Omen";
			self:Docklet_Omen(self.Docklet.Dock1)
			active1 = true
		elseif(self:DockletReady("Recount", dock1)) then
			tipLeft = "Recount";
			self:Docklet_Recount(self.Docklet.Dock1)
			active1 = true
		elseif(self:DockletReady("TinyDPS", dock1)) then
			tipLeft = "TinyDPS";
			self:Docklet_TinyDPS(self.Docklet.Dock1) 
			active1 = true
		elseif(self:DockletReady("alDamageMeter", dock1)) then
			tipLeft = "alDamageMeter";
			self:Docklet_alDamageMeter(self.Docklet.Dock1)
			active1 = true
		end
	end

	if(active1) then
		self.Docklet:Enable();
		if(active2) then
			self.Docklet.Dock1:Show()
			self.Docklet.Dock2:Show()
		else
			self.Docklet.Dock1:Show()
			self.Docklet.Dock2:Hide()
		end

		self.Docklet.DockButton:SetAttribute("tipText", ("%s%s"):format(tipLeft, tipRight));
		self.Docklet.DockButton:MakeDefault();
	else
		self.Docklet.Dock1:Hide()
		self.Docklet.Dock2:Hide()
		self.Docklet:Disable()

		self.Docklet.Parent.Bar:UnsetDefault();
	end 
end

local DockableAddons = {
	["alDamageMeter"] = L["alDamageMeter"],
	["Skada"] = L["Skada"],
	["Recount"] = L["Recount"],
	["TinyDPS"] = L["TinyDPS"],
	["Omen"] = L["Omen"]
}

local function GetDockableAddons()
	local test = SV.private.Docks.Embed1;

	local t = {
		{ title = "Docked Addon", divider = true },
		{text = "Remove All", func = function() SV.private.Docks.Embed1 = "None"; MOD:RegisterAddonDocklets() end}
	};

	for n,l in pairs(DockableAddons) do
		if (not test or (test and not test:find(n))) then
			if(n:find("Skada") and _G.Skada) then
				for index,window in pairs(_G.Skada:GetWindows()) do
					local keyName = window.db.name
				    local key = "SkadaBarWindow" .. keyName
				    local name = (keyName == "Skada") and "Skada - Main" or "Skada - " .. keyName;
				    tinsert(t,{text = name, func = function() SV.private.Docks.Embed1 = key; MOD:RegisterAddonDocklets() end});
				end
			else
				if IsAddOnLoaded(n) or IsAddOnLoaded(l) then 
					tinsert(t,{text = n, func = function() SV.private.Docks.Embed1 = l; MOD:RegisterAddonDocklets() end});
				end
			end
		end
	end
	return t;
end

local AddonDockletToggle = function(self)
	if(not InCombatLockdown()) then
		self.Parent:Refresh()

		if(not self.Parent.Parent.Window:IsShown()) then
			self.Parent.Parent.Window:Show()
		end
	end

	if(not MOD.Docklet:IsShown()) then
		MOD.Docklet:Show()
	end

	if(not MOD.Docklet.Dock1:IsShown()) then
		MOD.Docklet.Dock1:Show()
	end

	if(not MOD.Docklet.Dock2:IsShown()) then
		MOD.Docklet.Dock2:Show()
	end

	self:Activate()
end

local ShowSubDocklet = function(self)
	local frame  = self.FrameLink
	if(frame and frame.Show) then
		if(InCombatLockdown() and (frame.IsProtected and frame:IsProtected())) then return end
		if(not frame:IsShown()) then
			frame:Show()
		end
	end
end

local HideSubDocklet = function(self)
	local frame  = self.FrameLink
	if(frame and frame.Hide) then
		if(InCombatLockdown() and (frame.IsProtected and frame:IsProtected())) then return end
		if(frame:IsShown()) then
			frame:Hide()
		end
	end
end

local function DockFadeInDocklet()
	local active = MOD.Docklet.DockButton:GetAttribute("isActive")
	if(active) then
		MOD.Docklet.Dock1:Show()
		MOD.Docklet.Dock2:Show()
	end
end

local function DockFadeOutDocklet()
	local active = MOD.Docklet.DockButton:GetAttribute("isActive")
	if(active) then
		MOD.Docklet.Dock1:Hide()
		MOD.Docklet.Dock2:Hide()
	end
end
--[[ 
########################################################## 
BUILD FUNCTION
##########################################################
]]--
function MOD:ReLoad()
	self:RegisterAddonDocklets()
end

function MOD:Load()
	SV.private.Docks = SV.private.Docks or {"None", "None"}

	local alert = CreateFrame('Frame', nil, UIParent);
	alert:SetStyle("!_Frame", 'Transparent');
	alert:SetSize(250, 70);
	alert:SetPoint('CENTER', UIParent, 'CENTER');
	alert:SetFrameStrata('DIALOG');
	alert.Text = alert:CreateFontString(nil, "OVERLAY");
	alert.Text:SetFont(SV.Media.font.dialog, 12);
	alert.Text:SetPoint('TOP', alert, 'TOP', 0, -10);
	alert.Accept = CreateFrame('Button', nil, alert);
	alert.Accept:SetSize(70, 25);
	alert.Accept:SetPoint('RIGHT', alert, 'BOTTOM', -10, 20);
	alert.Accept.Text = alert.Accept:CreateFontString(nil, "OVERLAY");
	alert.Accept.Text:SetFont(SV.Media.font.dialog, 10);
	alert.Accept.Text:SetPoint('CENTER');
	alert.Accept.Text:SetText(_G.YES);
	alert.Close = CreateFrame('Button', nil, alert);
	alert.Close:SetSize(70, 25);
	alert.Close:SetPoint('LEFT', alert, 'BOTTOM', 10, 20);
	alert.Close:SetScript('OnClick', function(this) this:GetParent():Hide() end);
	alert.Close.Text = alert.Close:CreateFontString(nil, "OVERLAY");
	alert.Close.Text:SetFont(SV.Media.font.dialog, 10);
	alert.Close.Text:SetPoint('CENTER');
	alert.Close.Text:SetText(_G.NO);
	alert.Accept:SetStyle("Button");
	alert.Close:SetStyle("Button");
	alert:Hide();

	self.Alert = alert;

	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_SkinsDock", self.TitleID, nil, AddonDockletToggle);
	SV.Dock.BottomRight.Bar.Button.GetMenuList = GetDockableAddons;
	self.Docklet.DockButton.GetPreMenuList = GetDockableAddons;
	self.Docklet.DockButton:SetAttribute("hasDropDown", true);

	local dockWidth = self.Docklet:GetWidth()

	self.Docklet.Dock1 = CreateFrame("Frame", "SVUI_SkinsDockAddon1", self.Docklet);
	self.Docklet.Dock1:SetPoint('TOPLEFT', self.Docklet, 'TOPLEFT', -4, 0);
	self.Docklet.Dock1:SetPoint('BOTTOMLEFT', self.Docklet, 'BOTTOMLEFT', -4, -4);
	self.Docklet.Dock1:SetWidth(dockWidth);
	self.Docklet.Dock1:SetScript('OnShow', ShowSubDocklet);
	self.Docklet.Dock1:SetScript('OnHide', HideSubDocklet);

	self.Docklet.Dock2 = CreateFrame("Frame", "SVUI_SkinsDockAddon2", self.Docklet);
	self.Docklet.Dock2:SetPoint('TOPLEFT', self.Docklet.Dock1, 'TOPRIGHT', 0, 0);
	self.Docklet.Dock2:SetPoint('BOTTOMLEFT', self.Docklet.Dock1, 'BOTTOMRIGHT', 0, 0);
	self.Docklet.Dock2:SetWidth(dockWidth * 0.5);
	self.Docklet.Dock2:SetScript('OnShow', ShowSubDocklet);
	self.Docklet.Dock2:SetScript('OnHide', HideSubDocklet);

	self.Docklet:Hide()

	self:RegisterAddonDocklets()

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ADDON_LOADED");

	SV.Events:On("DOCK_RIGHT_FADE_IN", DockFadeInDocklet, "DockFadeInDocklet");
	SV.Events:On("DOCK_RIGHT_FADE_OUT", DockFadeOutDocklet, "DockFadeOutDocklet");
end