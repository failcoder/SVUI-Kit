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
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local Librarian = _G.Librarian;
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local TIP_RIGHT_PATTERN = " and %s";
local DOCK_EMBEDS = {};
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local function RequestEmbedded(addon)
	local embed1 = SV.private.Docks.Embed1 or "None";
	local embed2 = SV.private.Docks.Embed2 or "None";
	local enabled1 = (embed1 ~= "None")
	local enabled2 = ((embed2 ~= "None") and (embed2 ~= embed1))
	
	if(addon) then
		local valid = false;
		if(embed1:find(addon) or embed2:find(addon)) then
			valid = true 
		end
		return valid, enabled1, enabled2
	end
	
	return embed1, embed2, enabled1, enabled2
end
--[[ 
########################################################## 
SKADA
##########################################################
]]--
DOCK_EMBEDS["Skada"] = function(self)
	if((not IsAddOnLoaded("Skada")) or (not _G.Skada)) then return false end

	local embedded = false;
	local assigned = self:EmbedCheck();
	local height = SV.Dock.BottomRight.Window:GetHeight();

	if(assigned) then
		for index,window in pairs(Skada:GetWindows()) do
			if(window) then
				local wname = window.db.name or "Skada"
				local key = "SkadaBarWindow" .. wname
				if(assigned:find(key)) then
					local width = self:GetWidth()
					local db = window.db

					if(db) then
						local curHeight = 0
						if(db.enabletitle) then 
							curHeight = db.title.height 
						end
						db.barspacing = 1;
						db.barwidth = width - 10;
						db.background.height = (height - curHeight) - 12;
						db.spark = false;
						db.barslocked = true;
					end

					window.bargroup:ClearAllPoints()
					window.bargroup:InsetPoints(self, 3, 3)
					window.bargroup:SetParent(self)
					window.bargroup:SetFrameStrata('LOW')

					local bgroup = window.bargroup.backdrop;
					if(bgroup) then 
						bgroup:Show()
						if(not bgroup.Panel) then
							bgroup:SetStyle("!_Frame", 'Transparent', true)
						end
					end

					self.FrameLink = window;

					Skada.displays['bar']:ApplySettings(window)

					embedded = true
					break;
				else
					window.db.barslocked = false;
				end
			end
		end
	end

	return embedded
end
--[[ 
########################################################## 
RECOUNT
##########################################################
]]--
DOCK_EMBEDS["Recount"] = function(self)
	if((not IsAddOnLoaded("Recount")) or (not _G.Recount)) then return false end 

	Recount.db.profile.Locked = true;
	Recount.db.profile.Scaling = 1;
	Recount.db.profile.ClampToScreen = true;
	Recount.db.profile.FrameStrata = '2-LOW'
	Recount.MainWindow:ClearAllPoints()
	Recount.MainWindow:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 7)
	Recount.MainWindow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	Recount.MainWindow:SetParent(self)
	Recount:SetStrataAndClamp()
	Recount:LockWindows(true)
	Recount:ResizeMainWindow()
	Recount_MainWindow_ScrollBar:Hide()

	Recount.MainWindow:Show()

	self.Framelink = Recount.MainWindow
	return true
end
--[[ 
########################################################## 
OMEN
##########################################################
]]--
DOCK_EMBEDS["Omen"] = function(self)
	if((not IsAddOnLoaded("Omen")) or (not _G.Omen)) then return false end

	local db = Omen.db;

	--[[ General Settings ]]--
	db.profile.FrameStrata = '2-LOW';
	db.profile.Locked = true;
	db.profile.Scale = 1;
	db.profile.ShowWith.UseShowWith = false;

	--[[ Background Settings ]]--
	db.profile.Background.BarInset = 3;
	db.profile.Background.EdgeSize = 1;
	db.profile.Background.Texture = "None"

	--[[ Bar Settings ]]--
	db.profile.Bar.Font = "SVUI Default Font";
	db.profile.Bar.FontOutline = "None";
	db.profile.Bar.FontSize = 11;
	db.profile.Bar.Height = 14;
	db.profile.Bar.ShowHeadings = false;
	db.profile.Bar.ShowTPS = false;
	db.profile.Bar.Spacing = 1;
	db.profile.Bar.Texture = "SVUI MultiColorBar";

	--[[ Titlebar Settings ]]--  
	db.profile.TitleBar.BorderColor.g = 0;
	db.profile.TitleBar.BorderColor.r = 0;
	db.profile.TitleBar.BorderTexture = "None";
	db.profile.TitleBar.EdgeSize = 1;
	db.profile.TitleBar.Font = "Arial Narrow";
	db.profile.TitleBar.FontSize = 12;
	db.profile.TitleBar.Height = 23;
	db.profile.TitleBar.ShowTitleBar = true;
	db.profile.TitleBar.Texture = "None";
	db.profile.TitleBar.UseSameBG = false;

	Omen:OnProfileChanged(nil,db)
	OmenTitle:RemoveTextures()
	OmenTitle.Panel = nil
	OmenTitle:SetStyle("Frame", "Transparent")
	--OmenTitle:SetPanelColor("class")
	--OmenTitle:GetFontString():SetFont(SV.media.font.default, 12, "OUTLINE")
	OmenBarList:RemoveTextures()
	OmenAnchor:SetStyle("!_Frame", 'Transparent')
	OmenAnchor:ClearAllPoints()
	OmenAnchor:SetAllPoints(self)
	OmenAnchor:SetParent(self)

	self.Framelink = OmenAnchor
	return true
end
--[[ 
########################################################## 
ALDAMAGEMETER
##########################################################
]]--
DOCK_EMBEDS["alDamageMeter"] = function(self)
	if((not IsAddOnLoaded("alDamageMeter")) or (not _G.alDamagerMeterFrame)) then return false end 

	local w,h = self:GetSize();
	local count = dmconf.maxbars or 10;
	local spacing = dmconf.spacing or 1;

	dmconf.barheight = floor((h / count) - spacing);
	dmconf.width = w;

	alDamageMeterFrame:ClearAllPoints()
	alDamageMeterFrame:SetAllPoints(self)
	alDamageMeterFrame.backdrop:SetStyle("!_Frame", 'Transparent')
	alDamageMeterFrame.bg:Die()
	alDamageMeterFrame:SetFrameStrata('LOW')

	self.Framelink = alDamageMeterFrame
	return true
end
--[[ 
########################################################## 
TINYDPS
##########################################################
]]--
DOCK_EMBEDS["TinyDPS"] = function(self)
	if((not IsAddOnLoaded("TinyDPS")) or (not _G.tdpsFrame)) then return false end

	tdps.hideOOC = false;
	tdps.hideIC = false;
	tdps.hideSolo = false;
	tdps.hidePvP = false;
	tdpsFrame:ClearAllPoints()
	tdpsFrame:SetAllPoints(self)
	tdpsRefresh()

	self.Framelink = tdpsFrame
	return true
end
--[[ 
########################################################## 
DOCK EMBED METHODS
##########################################################
]]--
local DOCK_EmbedAddon = function(self, request)
	if(not request) then return false end
	local dock = self:GetParent()
	for addon,fn in pairs(dock.EmbedMethods) do
		if(request:find(addon)) then
			local activated = fn(self)
			dock.Embedded[addon] = self
			return activated, addon
		end
	end
	return false
end

local DOCK_EmbedCheck = function(self, request)
	if(not request) then return false end
	local data = SV.private.Docks[self.EmbedKey]
	local dock = self:GetParent()
	if(data and (data ~= "None")) then
		return data
	end
	return false
end

local PARENT_IsEmbedded = function(self, request)
	if(not self.Embedded) then return false end
	for addon,owner in pairs(self.Embedded) do
		if(owner and self[owner] and request:find(addon)) then
			return true
		end
	end
	return false
end

local PARENT_UpdateEmbeds = function(self, ...)
	if(not self.Embedded) then return end
	for addon,owner in pairs(self.Embedded) do
		if(owner and self[owner]) then
			local fn = self.EmbedMethods[addon];
			if(fn) then
				fn(self[owner], ...)
			end
		end
	end
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:SetEmbedHandlers(parent)
	parent.EmbedMethods     = DOCK_EMBEDS;
	parent.UpdateEmbeds     = PARENT_UpdateEmbeds;
	parent.IsEmbedded       = PARENT_IsEmbedded;

	parent.Dock1.EmbedKey   = "Embed1";
	parent.Dock1.EmbedAddon = DOCK_EmbedAddon;
	parent.Dock1.EmbedCheck = DOCK_EmbedCheck;
	
	parent.Dock2.EmbedKey   = "Embed2";
	parent.Dock2.EmbedAddon = DOCK_EmbedAddon;
	parent.Dock2.EmbedCheck = DOCK_EmbedCheck;
end

function MOD:RegisterAddonDocklets()
	local embed1,embed2,enabled1,enabled2 = RequestEmbedded();
  	local addon1, addon2, extraTip = "", "", "";
  	local active1, active2 = false, false;

  	self.Docklet.Embedded = {}
  	self.Docklet.Dock1.FrameLink = nil;
  	self.Docklet.Dock1.ExpandCallback = nil;
  	self.Docklet.Dock2.FrameLink = nil;
  	self.Docklet.Dock2.ExpandCallback = nil;

  	if(enabled1) then
  		Librarian:LockLibrary('LibWindow');
  		local width = self.Docklet:GetWidth();

		if(enabled2) then
			self.Docklet.Dock1:SetWidth(width * 0.5)
			self.Docklet.Dock2:SetWidth(width * 0.5)

			active2, addon2 = self.Docklet.Dock2:EmbedAddon(embed2)
		end

		if(not active2) then
			self.Docklet.Dock1:SetWidth(width)
		end

		active1, addon1 = self.Docklet.Dock1:EmbedAddon(embed1)
	else
		Librarian:UnlockLibrary('LibWindow');
	end

	if(active1) then
		self.Docklet:Enable();
		if(active2) then
			extraTip = TIP_RIGHT_PATTERN:format(addon2)
			self.Docklet.Dock1:Show()
			self.Docklet.Dock2:Show()
		else
			self.Docklet.Dock1:Show()
			self.Docklet.Dock2:Hide()
		end

		self.Docklet.DockButton:SetAttribute("tipText", ("%s%s"):format(addon1, extraTip));
		self.Docklet.DockButton:MakeDefault();
	else
		self.Docklet.Dock1:Hide()
		self.Docklet.Dock2:Hide()
		self.Docklet:Disable()

		self.Docklet.Parent.Bar:UnsetDefault();
	end 
end

function MOD:GetDockables()
	local test = SV.private.Docks.Embed1;

	local t = {
		{ title = "Docked Addon", divider = true },
		{text = "Remove All", func = function() SV.private.Docks.Embed1 = "None"; MOD:RegisterAddonDocklets() end}
	};

	for addon,_ in pairs(EMBEDS) do
		if (not test or (test and not test:find(addon))) then
			if(addon:find("Skada") and _G.Skada) then
				for index,window in pairs(_G.Skada:GetWindows()) do
					local keyName = window.db.name
				    local key = "SkadaBarWindow" .. keyName
				    local name = (keyName == "Skada") and "Skada - Main" or "Skada - " .. keyName;
				    tinsert(t,{text = name, func = function() SV.private.Docks.Embed1 = key; MOD:RegisterAddonDocklets() end});
				end
			else
				if IsAddOnLoaded(addon) or IsAddOnLoaded(addon) then 
					tinsert(t,{text = addon, func = function() SV.private.Docks.Embed1 = addon; MOD:RegisterAddonDocklets() end});
				end
			end
		end
	end
	return t;
end