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
local random = math.random;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end 

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
if(SV.class ~= "SHAMAN") then return end 
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local totemMax = MAX_TOTEMS
local totemPriorities = SHAMAN_TOTEM_PRIORITIES or {1, 2, 3, 4};
local totemTextures = {
	[EARTH_TOTEM_SLOT] 	= [[Interface\Addons\SVUI_UnitFrames\assets\Class\SHAMAN-EARTH]],
	[FIRE_TOTEM_SLOT] 	= [[Interface\Addons\SVUI_UnitFrames\assets\Class\SHAMAN-FIRE]],
	[WATER_TOTEM_SLOT] 	= [[Interface\Addons\SVUI_UnitFrames\assets\Class\SHAMAN-WATER]],
	[AIR_TOTEM_SLOT] 	= [[Interface\Addons\SVUI_UnitFrames\assets\Class\SHAMAN-AIR]],
};
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
	local bar = self.TotemBars
	local size = db.classbar.height
	local width = size * totemMax
	bar.Holder:ModSize(width, size)
    if(not db.classbar.detachFromFrame) then
    	SV:ResetAnchors(L["Classbar"])
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)
	for i = 1, totemMax do
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		if i==1 then 
			bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else 
			bar[i]:ModPoint("LEFT", bar[i - 1], "RIGHT", -1, 0) 
		end
	end 
end 
--[[ 
########################################################## 
SHAMAN
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i=1, totemMax do
		local iconfile = totemTextures[totemPriorities[i]]
		bar[i] = CreateFrame("StatusBar",nil,bar)
		bar[i]:SetStatusBarTexture(iconfile)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i]:SetOrientation("VERTICAL")
		bar[i].noupdate=true;
		bar[i].backdrop = bar[i]:CreateTexture(nil,"BACKGROUND")
		bar[i].backdrop:SetAllPoints(bar[i])
		bar[i].backdrop:SetTexture(iconfile)
		bar[i].backdrop:SetDesaturated(true)
		bar[i].backdrop:SetVertexColor(0.2,0.2,0.2,0.7)
	end 

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:ModPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], nil, OnMove)

	playerFrame.MaxClassPower = totemMax;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.TotemBars = bar
	return 'TotemBars' 
end 