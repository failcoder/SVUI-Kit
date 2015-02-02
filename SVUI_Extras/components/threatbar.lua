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
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local tinsert 	= _G.tinsert;
local math 		= _G.math;
local wipe 		= _G.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Extras;
--[[ 
########################################################## 
THREAT THERMOMETER
##########################################################
]]--
local CurrentThreats = {};
local BARFILE = [[Interface\AddOns\SVUI_Extras\assets\THREAT-BAR]];
local TEXTUREFILE = [[Interface\AddOns\SVUI_Extras\assets\THREAT-BAR-ELEMENTS]];

local function UMadBro(scaledPercent)
	local highestThreat,unitWithHighestThreat = 0,nil;
	for unit,threat in pairs(CurrentThreats)do 
		if threat > highestThreat then 
			highestThreat = threat;
			unitWithHighestThreat = unit 
		end 
	end 
	return (scaledPercent - highestThreat),unitWithHighestThreat 
end 

local function GetThreatBarColor(unitWithHighestThreat)
	local react = UnitReaction(unitWithHighestThreat,'player')
	local _,unitClass = UnitClass(unitWithHighestThreat)
	if UnitIsPlayer(unitWithHighestThreat)then 
		local colors = RAID_CLASS_COLORS[unitClass]
		if not colors then return 15,15,15 end 
		return colors.r*255, colors.g*255, colors.b*255 
	elseif(react and SV.oUF) then 
		local reaction = SV.oUF['colors'].reaction[react]
		return reaction[1]*255, reaction[2]*255, reaction[3]*255 
	else 
		return 15,15,15 
	end 
end 

local function ThreatBar_OnEvent(self, event)
	local isTanking, status, scaledPercent = UnitDetailedThreatSituation('player','target')
	if scaledPercent and scaledPercent > 0 then 
		self:Show()
		if scaledPercent==100 then 
			if(UnitExists('pet')) then 
				CurrentThreats['pet']=select(3,UnitDetailedThreatSituation('pet','target'))
			end 
			if(IsInRaid()) then 
				for i=1,40 do 
					if UnitExists('raid'..i) and not UnitIsUnit('raid'..i,'player') then 
						CurrentThreats['raid'..i]=select(3,UnitDetailedThreatSituation('raid'..i,'target'))
					end 
				end 
			else 
				for i=1,4 do 
					if UnitExists('party'..i) then 
						CurrentThreats['party'..i]=select(3,UnitDetailedThreatSituation('party'..i,'target'))
					end 
				end 
			end 
			local highestThreat,unitWithHighestThreat = UMadBro(scaledPercent)
			if highestThreat > 0 and unitWithHighestThreat ~= nil then 
				local r,g,b = GetThreatBarColor(unitWithHighestThreat)
				if SV.ClassRole == 'T' then 
					self:SetStatusBarColor(0,0.839,0)
					self:SetValue(highestThreat)
				else 
					self:SetStatusBarColor(GetThreatStatusColor(status))
					self:SetValue(scaledPercent)
				end 
			else 
				self:SetStatusBarColor(GetThreatStatusColor(status))
				self:SetValue(scaledPercent)
			end 
		else 
			self:SetStatusBarColor(0.3,1,0.3)
			self:SetValue(scaledPercent)
		end 
		self.text:SetFormattedText('%.0f%%',scaledPercent)
	else 
		self:Hide()
	end 
	wipe(CurrentThreats);
end 

function MOD:LoadThreatBar()
	if(SV.db.Extras.threatbar == true) then
		local anchor = _G.SVUI_Target
		local ThreatBar = CreateFrame('StatusBar', 'SVUI_ThreatBar', UIParent);
		ThreatBar:SetStatusBarTexture(BARFILE)
		ThreatBar:SetSize(50, 100)
		ThreatBar:SetFrameStrata('MEDIUM')
		ThreatBar:SetOrientation("VERTICAL")
		ThreatBar:SetMinMaxValues(0, 100)
		if(anchor) then
			ThreatBar:ModPoint('LEFT', _G.SVUI_Target, 'RIGHT', 0, 10)
		else
			ThreatBar:ModPoint('LEFT', UIParent, 'CENTER', 50, -50)
		end
		ThreatBar.backdrop = ThreatBar:CreateTexture(nil,"BACKGROUND")
		ThreatBar.backdrop:SetAllPoints(ThreatBar)
		ThreatBar.backdrop:SetTexture(TEXTUREFILE)
		ThreatBar.backdrop:SetTexCoord(0.5,0.75,0,0.5)
		ThreatBar.backdrop:SetBlendMode("ADD")
		ThreatBar.overlay = ThreatBar:CreateTexture(nil,"OVERLAY",nil,1)
		ThreatBar.overlay:SetAllPoints(ThreatBar)
		ThreatBar.overlay:SetTexture(TEXTUREFILE)
		ThreatBar.overlay:SetTexCoord(0.75,1,0,0.5)
		ThreatBar.text = ThreatBar:CreateFontString(nil,'OVERLAY')
		ThreatBar.text:SetFont(SV.Media.font.numbers, 10, "OUTLINE")
		ThreatBar.text:SetPoint('TOP',ThreatBar,'BOTTOM',0,0)
		ThreatBar:RegisterEvent('PLAYER_TARGET_CHANGED');
		ThreatBar:RegisterEvent('UNIT_THREAT_LIST_UPDATE')
		ThreatBar:RegisterEvent('GROUP_ROSTER_UPDATE')
		ThreatBar:RegisterEvent('UNIT_PET')
		ThreatBar:SetScript("OnEvent", ThreatBar_OnEvent)
		SV.Layout:Add(ThreatBar, "Threat Bar");
	end
end
--[[ 
########################################################## 
LOAD BY TRIGGER
##########################################################
]]--
SV.Events:On("CORE_INITIALIZED", "ThreatBar", LoadThreatBar);