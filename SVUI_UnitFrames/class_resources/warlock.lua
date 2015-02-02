--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local assert 	= _G.assert;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random, floor = math.random, math.floor;
local CreateFrame = _G.CreateFrame;
local GetSpecialization = _G.GetSpecialization;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end 

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
if(SV.class ~= "WARLOCK") then return end 

SV.SpecialFX:Register("affliction", [[Spells\Warlock_bodyofflames_medium_state_shoulder_right_purple.m2]], -12, 12, 12, -12, 0.22, 0, 0.52)
SV.SpecialFX:Register("overlay_demonbar", [[Spells\Warlock_destructioncharge_impact_chest.m2]], -20, -1, 20, -50, 0.9, 0, 0.8)
SV.SpecialFX:Register("underlay_demonbar", [[Spells\Fill_fire_cast_01.m2]], 3, -2, -3, 2, 0.5, -0.45, 1)
local specEffects = { [1] = "affliction", [2] = "none", [3] = "fire" };
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local FURY_FONT = [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]]
local shardColors = {
	[1] = {{0.67,0.42,0.93,1}, {0,0,0,0.9}},
	[2] = {{0,0,0,0}, {0,0,0,0}},
	[3] = {{1,1,0,1}, {0.1,0,0,0.9}},
	[4] = {{0.5,1,0,1}, {0,0.15,0,0.9}}
}
local shardTextures = {
	[1] = {
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-BG]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-FG]],
		"affliction"
	},
	[2] = {
		SV.NoTexture,
		SV.NoTexture,
		SV.NoTexture,
		"none"
	},
	[3] = {
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER-FG]], 
		"fire"
	},
}
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
--[[ 
########################################################## 
POSITIONING
##########################################################
]]--
local OnMove = function()
	SV.db.UnitFrames.player.classbar.detachFromFrame = true
end

local Reposition = function(self)
	local db = SV.db.UnitFrames.player
	local bar = self.WarlockShards;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;
	local dbOffset = (size * 0.15)
	bar.Holder:ModSize(width, size)
    if(not db.classbar.detachFromFrame) then
    	SV.Layout:Reset(L["Classbar"], true)
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)

	for i = 1, max do 
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		if(i == 1) then 
			bar[i]:SetPoint("LEFT", bar)
		else 
			bar[i]:ModPoint("LEFT", bar[i - 1], "RIGHT", -2, 0)
		end 
	end

	local barHeight = bar.Holder:GetHeight()
	local fontSize = floor(barHeight * 0.45)
	local offset = fontSize * 2

	bar.DemonicFury:ClearAllPoints()
	bar.DemonicFury:SetPoint("TOPLEFT", bar.Holder, "TOPLEFT", 0, 0)
	bar.DemonicFury:SetPoint("BOTTOMRIGHT", bar.Holder, "BOTTOMRIGHT", -offset, 6)
	bar.DemonicFury.text:SetFont(FURY_FONT, fontSize, 'OUTLINE')
end 
--[[ 
########################################################## 
CUSTOM HANDLERS
##########################################################
]]--
local UpdateTextures = function(self, spec)
	local max = self.MaxCount;
	local colors = shardColors[spec];
	local textures = shardTextures[spec];
	if(spec == SPEC_WARLOCK_DESTRUCTION and IsSpellKnown(101508)) then
		colors = shardColors[4]
	end
	for i = 1, max do
		self[i]:SetStatusBarTexture(textures[1])
		self[i]:GetStatusBarTexture():SetHorizTile(false)
		self[i].overlay:SetTexture(textures[3])
		self[i].overlay:SetVertexColor(unpack(colors[1]))
		self[i].bg:SetTexture(textures[2])
		self[i].bg:SetVertexColor(unpack(colors[2]))
		if(textures[4] ~= none) then
			self[i].FX:SetEffect(textures[4])
		end
	end
	self.CurrentSpec = spec
end 

local ShardUpdate = function(self, value)
	if (value and value == 1) then
		if(self.overlay) then
			self.overlay:Show()
			SV.Animate:Flash(self.overlay,1,true)
		end
		if(not self.FX:IsShown()) then	
			self.FX:Show()
		end
		self.FX:UpdateEffect()
	else
		if(self.overlay) then
			SV.Animate:StopFlash(self.overlay)
			self.overlay:Hide()
		end
		self.FX:Hide()
	end
end 
--[[ 
########################################################## 
WARLOCK
##########################################################
]]--
local EffectModel_OnShow = function(self)
	self:SetEffect("overlay_demonbar");
end

function MOD:CreateClassBar(playerFrame)
	local max = 4;
	local textures = shardTextures[1];
	local colors = shardColors[1];
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i = 1, max do 
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i].noupdate = true;
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetStatusBarTexture(textures[1])
		bar[i]:GetStatusBarTexture():SetHorizTile(false)

		bar[i].bg = bar[i]:CreateTexture(nil,'BORDER',nil,1)
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture(textures[2])
		bar[i].bg:SetVertexColor(unpack(colors[2]))

		bar[i].overlay = bar[i]:CreateTexture(nil,'OVERLAY')
		bar[i].overlay:SetAllPoints(bar[i])
		bar[i].overlay:SetTexture(textures[3])
		bar[i].overlay:SetBlendMode("BLEND")
		bar[i].overlay:Hide()
		bar[i].overlay:SetVertexColor(unpack(colors[1]))

		SV.SpecialFX:SetFXFrame(bar[i], textures[4], true)
		bar[i].Update = ShardUpdate
	end 

	local demonicFury = CreateFrame("Frame", nil, bar)
	demonicFury:SetFrameStrata("BACKGROUND")
	demonicFury:SetFrameLevel(0)
	SV.SpecialFX:SetFXFrame(demonicFury, "underlay_demonbar")
	demonicFury.FX:SetFrameStrata("BACKGROUND")
	demonicFury.FX:SetFrameLevel(0)

	local bgFrame = CreateFrame("Frame", nil, demonicFury)
	bgFrame:InsetPoints(demonicFury)

	local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(bgFrame)
	bgTexture:SetTexture(0.1,0,0,0.75)

	local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
    borderB:SetTexture(0,0,0)
    borderB:SetPoint("BOTTOMLEFT")
    borderB:SetPoint("BOTTOMRIGHT")
    borderB:SetHeight(2)

    local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
    borderT:SetTexture(0,0,0)
    borderT:SetPoint("TOPLEFT")
    borderT:SetPoint("TOPRIGHT")
    borderT:SetHeight(2)

    local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
    borderL:SetTexture(0,0,0)
    borderL:SetPoint("TOPLEFT")
    borderL:SetPoint("BOTTOMLEFT")
    borderL:SetWidth(2)

    local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
    borderR:SetTexture(0,0,0)
    borderR:SetPoint("TOPRIGHT")
    borderR:SetPoint("BOTTOMRIGHT")
    borderR:SetWidth(2)

    local demonBar = CreateFrame("StatusBar", nil, bgFrame)
	demonBar.noupdate = true;
	demonBar:InsetPoints(bgFrame,2,2)
	demonBar:SetOrientation("HORIZONTAL")
	demonBar:SetStatusBarTexture(SV.Media.bar.default)

	demonicFury.text = demonicFury:CreateFontString(nil, "OVERLAY")
	demonicFury.text:SetPoint("LEFT", demonicFury, "RIGHT", 0, 0)
	demonicFury.text:SetFont(FURY_FONT, 16, 'OUTLINE')
	demonicFury.text:SetJustifyH('LEFT')
	demonicFury.text:SetTextColor(1,1,0)
	demonicFury.text:SetText("0")

    SV.SpecialFX:SetFXFrame(demonBar, "overlay_demonbar", true)
	demonBar.FX:SetScript("OnShow", EffectModel_OnShow)

	demonBar.Update = ShardUpdate;

	demonicFury.bg = bgTexture;
	demonicFury.bar = demonBar;

	bar.DemonicFury = demonicFury;
	bar.UpdateTextures = UpdateTextures;
	bar.MaxCount = max;

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:ModPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV.Layout:Add(bar.Holder, L["Classbar"], nil, OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.WarlockShards = bar
	return 'WarlockShards' 
end