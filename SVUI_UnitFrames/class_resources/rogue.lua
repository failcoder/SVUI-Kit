--[[
##########################################################
M O D K I T   By: S.Jackson
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
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end 

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
if(SV.class ~= "ROGUE") then return end 
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local TRACKER_FONT = [[Interface\AddOns\SVUI_!Core\assets\fonts\Combo.ttf]]
local ICON_BG = [[Interface\Addons\SVUI_UnitFrames\assets\Class\ROGUE-SMOKE]];
local ICON_ANTI = [[Interface\Addons\SVUI_UnitFrames\assets\Class\ROGUE-ANTICIPATION]];
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
	local bar = self.HyperCombo;
	if not db then return end
	local height = db.classbar.height
	local width = height * 3;
	local textwidth = height * 1.25;
	bar.Holder:ModSize(width, height)
    if(not db.classbar.detachFromFrame) then
    	SV.Layout:Reset(L["Classbar"])
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)

    local points = bar.Combo;
	local max = MAX_COMBO_POINTS;
	local size = height + 4
	points:ClearAllPoints()
	points:SetAllPoints(bar)
	for i = 1, max do
		points[i]:ClearAllPoints()
		points[i]:ModSize(size, size)

		if i==1 then 
			points[i]:SetPoint("LEFT", points)
		else 
			points[i]:ModPoint("LEFT", points[i - 1], "RIGHT", -8, 0) 
		end
	end

	if(bar.Guile) then
		bar.Guile:SetFont(TRACKER_FONT, height, 'OUTLINE')
	end
end
--[[ 
########################################################## 
ROGUE COMBO TRACKER
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local max = 5
	local size = 30
	local coords

	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	bar.Combo = CreateFrame("Frame",nil,bar)
	for i = 1, max do 
		local cpoint = CreateFrame('Frame', nil, bar.Combo)
		cpoint:ModSize(size,size)

		SV.SpecialFX:SetFXFrame(cpoint, "default")

		-- local icon = cpoint:CreateTexture(nil,"BACKGROUND",nil,-7)
		-- icon:SetPoint("TOPLEFT", cpoint, "TOPLEFT", -10, 8)
		-- icon:SetPoint("BOTTOMRIGHT", cpoint, "BOTTOMRIGHT", 4, -4)
		-- icon:SetTexture(ICON_BG)
		-- icon:SetBlendMode("BLEND")
		-- cpoint.Icon = icon

		local anti = CreateFrame('Frame',nil,bar.Combo)
		anti:WrapPoints(cpoint, 8, 8)
		anti:SetFrameLevel(bar.Combo:GetFrameLevel() - 2)
		local antiicon = anti:CreateTexture(nil,"BACKGROUND",nil,-1)
		antiicon:SetPoint("TOPLEFT", anti, "TOPLEFT", -8, 0)
		antiicon:SetPoint("BOTTOMRIGHT", anti, "BOTTOMRIGHT", 6, -2)
		antiicon:SetTexture(ICON_ANTI)
		anti:Hide()
		cpoint.Anticipation = anti

		bar.Combo[i] = cpoint 
	end 

	local guile = bar:CreateFontString(nil, 'OVERLAY', nil, 7)
	guile:SetPoint("RIGHT", bar, "LEFT", 0, -3)
	guile:SetFont(TRACKER_FONT, 30, 'OUTLINE')
	guile:SetTextColor(1,1,1)

	bar.Guile = guile;

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:ModPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV.Layout:Add(bar.Holder, L["Classbar"], nil, OnMove)

	playerFrame.MaxClassPower = 5;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.HyperCombo = bar
	return 'HyperCombo' 
end 