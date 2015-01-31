--[[
##############################################################################
M O D K I T   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor;
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;

local SV = _G['SVUI']
local L = SV.L
local THEME = SV:GetTheme("Comics");
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local HenchmenFrame = CreateFrame("Frame", "HenchmenFrame", UIParent);
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT
local OPTION_LEFT = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-OPTION-LEFT]];
local OPTION_RIGHT = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-OPTION-RIGHT]];
local OPTION_SUB = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-SUBOPTION]];
local SWITCH = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-MINION-SWITCH]];
local BUBBLE = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-SPEECH]];
local CALLOUTICON = [[Interface\Addons\SVUI_Theme_Comics\assets\textures\HENCHMEN-CALLOUT]];
local SUBOPTIONS = {};
local HENCHMEN_DATA = {
	{
		{0,"Adjust My Colors!","Color Themes","Click here to change your current color theme to one of the default sets."},
		{20,"Adjust My Frames!","Frame Styles","Click here to change your current frame styles to one of the default sets."},
		{40,"Adjust My Bars!","Bar Layouts","Click here to change your current actionbar layout to one of the default sets."},
		{-40,"Adjust My Auras!","Aura Layouts","Click here to change your buff/debuff layout to one of the default sets."},
		{-20,"Show Me All Options!","Config Screen","Click here to access the entire SVUI configuration."}
	},
	{
		{0,"Accept Quests","Your minions will automatically accept quests for you", "autoquestaccept"},
		{20,"Complete Quests","Your minions will automatically complete quests for you", "autoquestcomplete"},
		{40,"Select Rewards","Your minions will automatically select quest rewards for you", "autoquestreward"},
		{-40,"Greed Roll","Your minions will automatically roll greed (or disenchant if available) on green quality items for you", "autoRoll"},
		{-20,"Watch Factions","Your minions will automatically change your tracked reputation to the last faction you were awarded points for", "autorepchange"}
	}
}

THEME.YOUR_HENCHMEN = {
	{49084,67,113,69,70,73,75}, --Rascal Bot
	{29404,67,113,69,70,73,75}, --Macabre Marionette
	{45613,0,5,10,69,10,69}, 	--Bishibosh
	{34770,70,82,70,82,70,82}, 	--Gilgoblin
	{45562,69,69,69,69,69,69}, 	--Burgle
	{37339,60,60,60,60,60,60}, 	--Augh
	{2323,67,113,69,70,73,75}, 	--Defias Henchman
}
--[[ 
########################################################## 
SCRIPT HANDLERS
##########################################################
]]--
local ColorFunc = function(self) SV.Setup:ColorTheme(self.value, true); SV:ToggleHenchman() end 
local UnitFunc = function(self) SV.Setup:UnitframeLayout(self.value, true); SV:ToggleHenchman() end 
local BarFunc = function(self) SV.Setup:BarLayout(self.value, true); SV:ToggleHenchman() end 
local AuraFunc = function(self) SV.Setup:Auralayout(self.value, true); SV:ToggleHenchman() end 
local ConfigFunc = function() SV:ToggleConfig(); SV:ToggleHenchman() end 
local speechTimer;

local Tooltip_Show = function(self)
	GameTooltip:SetOwner(HenchmenFrame,"ANCHOR_TOP",0,12)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)
	GameTooltip:Show()
end 

local Tooltip_Hide = function(self)
	GameTooltip:Hide()
end 

local Minion_OnMouseUp = function(self) 
	if(not self.setting()) then
		self.indicator:SetTexCoord(0,1,0.5,1)
		self.setting(true)
	else
		self.indicator:SetTexCoord(0,1,0,0.5)
		self.setting(false)
	end
end 

local Option_OnMouseUp = function(self)
	if(type(self.callback) == "function") then
		self:callback()
	end
end 

local SubOption_OnMouseUp = function(self)
	if not InCombatLockdown()then 
		local name=self:GetName()
		for _,frame in pairs(SUBOPTIONS) do 
			frame.anim:Finish()
			frame:Hide()
		end 
		if not self.isopen then 
			for i=1, self.suboptions do 
				_G[name.."Sub"..i]:Show()
				_G[name.."Sub"..i].anim:Play()
				_G[name.."Sub"..i].anim:Finish()
			end 
			self.isopen=true 
		else
			self.isopen=false 
		end 
	end 
end

local function UpdateHenchmanModel(hide)
	if(not hide and not HenchmenFrameModel:IsShown()) then
		local models = THEME.YOUR_HENCHMEN
		local mod = random(1,#models)
		local emod = random(2,7)
		local id = models[mod][1]
		local emote = models[mod][emod]
		HenchmenFrameModel:ClearModel()
		HenchmenFrameModel:SetDisplayInfo(id)
		HenchmenFrameModel:SetAnimation(emote)
		HenchmenFrameModel:Show()
	else
		HenchmenFrameModel:Hide()
	end 
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local function CreateMinionOptions(i)
	local lastIndex = i - 1;
	local options = HENCHMEN_DATA[2][i]
	local offsetX = options[1] * -1
	local option = CreateFrame("Frame", "MinionOptionButton"..i, HenchmenFrame)
	option:SetSize(148,50)

	if i==1 then 
		option:ModPoint("TOPRIGHT",HenchmenFrame,"TOPLEFT",-32,-32)
	else 
		option:ModPoint("TOP",_G["MinionOptionButton"..lastIndex],"BOTTOM",offsetX,-32)
	end 

	local setting = options[4];
	local dbSet = SV.db.Extras[setting];
	option.setting = function(toggle)
		if(toggle == nil) then
			return SV.db.Extras[setting]
		else
			SV.db.Extras[setting] = toggle;
		end
	end
	SV.Animate:Slide(option,-500,-500)
	option:SetFrameStrata("DIALOG")
	option:SetFrameLevel(24)
	option:EnableMouse(true)
	option.bg = option:CreateTexture(nil,"BORDER")
	option.bg:SetPoint("TOPLEFT",option,"TOPLEFT",-4,4)
	option.bg:SetPoint("BOTTOMRIGHT",option,"BOTTOMRIGHT",4,-24)
	option.bg:SetTexture(OPTION_LEFT)
	option.bg:SetVertexColor(1,1,1,0.6)
	option.txt = option:CreateFontString(nil,"DIALOG")
	option.txt:InsetPoints(option)
	option.txt:SetFont(SV.Media.font.narrator,12,"NONE")
	option.txt:SetJustifyH("CENTER")
	option.txt:SetJustifyV("MIDDLE")
	option.txt:SetText(options[2])
	option.txt:SetTextColor(0,0,0)
	option.txthigh = option:CreateFontString(nil,"HIGHLIGHT")
	option.txthigh:InsetPoints(option)
	option.txthigh:SetFont(SV.Media.font.narrator,12,"OUTLINE")
	option.txthigh:SetJustifyH("CENTER")
	option.txthigh:SetJustifyV("MIDDLE")
	option.txthigh:SetText(options[2])
	option.txthigh:SetTextColor(0,1,1)
	option.ttText = options[3]
	option.indicator = option:CreateTexture(nil,"OVERLAY")
	option.indicator:SetSize(100,32)
	option.indicator:ModPoint("RIGHT", option , "LEFT", -5, 0)
	option.indicator:SetTexture(SWITCH)
	if(not dbSet) then
		option.indicator:SetTexCoord(0,1,0,0.5)
	else
		option.indicator:SetTexCoord(0,1,0.5,1)
	end
	
	option:SetScript("OnEnter", Tooltip_Show)
	option:SetScript("OnLeave", Tooltip_Hide)
	option:SetScript("OnMouseUp", Minion_OnMouseUp)
end 

local function CreateHenchmenOptions(i)
	local lastIndex = i - 1;
	local options = HENCHMEN_DATA[1][i]
	local offsetX = options[1]
	local option = CreateFrame("Frame", "HenchmenOptionButton"..i, HenchmenFrame)
	option:SetSize(148,50)
	if i==1 then 
		option:ModPoint("TOPLEFT",HenchmenFrame,"TOPRIGHT",32,-32)
	else 
		option:ModPoint("TOP",_G["HenchmenOptionButton"..lastIndex],"BOTTOM",offsetX,-32)
	end 
	SV.Animate:Slide(option,500,-500)
	option:SetFrameStrata("DIALOG")
	option:SetFrameLevel(24)
	option:EnableMouse(true)
	option.bg = option:CreateTexture(nil,"BORDER")
	option.bg:SetPoint("TOPLEFT",option,"TOPLEFT",-4,4)
	option.bg:SetPoint("BOTTOMRIGHT",option,"BOTTOMRIGHT",4,-24)
	option.bg:SetTexture(OPTION_RIGHT)
	option.bg:SetVertexColor(1,1,1,0.6)
	option.txt = option:CreateFontString(nil,"DIALOG")
	option.txt:InsetPoints(option)
	option.txt:SetFont(SV.Media.font.narrator,12,"NONE")
	option.txt:SetJustifyH("CENTER")
	option.txt:SetJustifyV("MIDDLE")
	option.txt:SetText(options[2])
	option.txt:SetTextColor(0,0,0)
	option.txthigh = option:CreateFontString(nil,"HIGHLIGHT")
	option.txthigh:InsetPoints(option)
	option.txthigh:SetFont(SV.Media.font.narrator,12,"OUTLINE")
	option.txthigh:SetJustifyH("CENTER")
	option.txthigh:SetJustifyV("MIDDLE")
	option.txthigh:SetText(options[2])
	option.txthigh:SetTextColor(0,1,1)
	option.ttText = options[3]
	option:SetScript("OnEnter", Tooltip_Show)
	option:SetScript("OnLeave", Tooltip_Hide)
end 

local function CreateHenchmenSubOptions(buttonIndex,optionIndex)
	local parent = _G["HenchmenOptionButton"..buttonIndex]
	local name = format("HenchmenOptionButton%dSub%d", buttonIndex, optionIndex);
	local calc = 90 * optionIndex;
	local yOffset = 180 - calc;
	local frame = CreateFrame("Frame",name,HenchmenFrame)
	frame:SetSize(122,50)
	frame:ModPoint("BOTTOMLEFT", parent, "TOPRIGHT", 75, yOffset)
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(24)
	frame:EnableMouse(true)
	frame.bg = frame:CreateTexture(nil,"BORDER")
	frame.bg:SetPoint("TOPLEFT",frame,"TOPLEFT",-12,12)
	frame.bg:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",12,-18)
	frame.bg:SetTexture(OPTION_SUB)
	frame.bg:SetVertexColor(1,1,1,0.6)
	frame.txt = frame:CreateFontString(nil,"DIALOG")
	frame.txt:InsetPoints(frame)
	frame.txt:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
	frame.txt:SetJustifyH("CENTER")
	frame.txt:SetJustifyV("MIDDLE")
	frame.txt:SetTextColor(1,1,1)
	frame.txthigh = frame:CreateFontString(nil,"HIGHLIGHT")
	frame.txthigh:InsetPoints(frame)
	frame.txthigh:SetFontObject(SVUI_Font_Default)
	frame.txthigh:SetTextColor(1,1,0)
	SV.Animate:Slide(frame,500,0)

	tinsert(SUBOPTIONS,frame)
end 

local function CreateHenchmenFrame()
	HenchmenFrame:SetParent(UIParent)
	HenchmenFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	HenchmenFrame:SetWidth(500)
	HenchmenFrame:SetHeight(500)
	HenchmenFrame:SetFrameStrata("DIALOG")
	HenchmenFrame:SetFrameLevel(24)
	SV.Animate:Slide(HenchmenFrame,0,-500)

	local model = CreateFrame("PlayerModel", "HenchmenFrameModel", HenchmenFrame)
	model:SetPoint("TOPLEFT",HenchmenFrame,25,-25)
	model:SetPoint("BOTTOMRIGHT",HenchmenFrame,-25,25)
	model:SetFrameStrata("DIALOG")
	model:SetPosition(0,0,0)
	model:Hide()

	HenchmenFrame:Hide()

	local HenchmenCalloutFrame = CreateFrame("Frame", "HenchmenCalloutFrame", UIParent)
	HenchmenCalloutFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",100,150)
	HenchmenCalloutFrame:SetWidth(256)
	HenchmenCalloutFrame:SetHeight(128)
	HenchmenCalloutFrame:SetFrameStrata("DIALOG")
	HenchmenCalloutFrame:SetFrameLevel(24)
	SV.Animate:Slide(HenchmenCalloutFrame,-356,-278)
	local HenchmenCalloutFramePic = HenchmenCalloutFrame:CreateTexture("HenchmenCalloutFramePic","ARTWORK")
	HenchmenCalloutFramePic:SetTexture(CALLOUTICON)
	HenchmenCalloutFramePic:SetAllPoints(HenchmenCalloutFrame)
	HenchmenCalloutFrame:Hide()

	local HenchmenFrameBG = CreateFrame("Frame", "HenchmenFrameBG", UIParent)
	HenchmenFrameBG:SetAllPoints(WorldFrame)
	HenchmenFrameBG:SetBackdrop({bgFile = [[Interface\BUTTONS\WHITE8X8]]})
	HenchmenFrameBG:SetBackdropColor(0,0,0,0.9)
	HenchmenFrameBG:SetFrameStrata("DIALOG")
	HenchmenFrameBG:SetFrameLevel(22)
	HenchmenFrameBG:Hide()
	HenchmenFrameBG:SetScript("OnMouseUp", SV.ToggleHenchman)

	for i=1, 5 do 
		CreateHenchmenOptions(i)
		CreateMinionOptions(i)
	end
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(1,1)
	HenchmenOptionButton1Sub1.txt:SetText("KABOOM!")
	HenchmenOptionButton1Sub1.txthigh:SetText("KABOOM!")
	HenchmenOptionButton1Sub1.value = "kaboom"
	HenchmenOptionButton1Sub1.callback = ColorFunc
	HenchmenOptionButton1Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,2)
	HenchmenOptionButton1Sub2.txt:SetText("Darkness")
	HenchmenOptionButton1Sub2.txthigh:SetText("Darkness")
	HenchmenOptionButton1Sub2.value = "dark"
	HenchmenOptionButton1Sub2.callback = ColorFunc
	HenchmenOptionButton1Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,3)
	HenchmenOptionButton1Sub3.txt:SetText("Classy")
	HenchmenOptionButton1Sub3.txthigh:SetText("Classy")
	HenchmenOptionButton1Sub3.value = "classy"
	HenchmenOptionButton1Sub3.callback = ColorFunc
	HenchmenOptionButton1Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,4)
	HenchmenOptionButton1Sub4.txt:SetText("Vintage")
	HenchmenOptionButton1Sub4.txthigh:SetText("Vintage")
	HenchmenOptionButton1Sub4.value = "default"
	HenchmenOptionButton1Sub4.callback = ColorFunc
	HenchmenOptionButton1Sub4:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton1.suboptions = 4;
	HenchmenOptionButton1.isopen = false;
	HenchmenOptionButton1:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(2,1)
	HenchmenOptionButton2Sub1.txt:SetText("SUPER: Elaborate Frames")
	HenchmenOptionButton2Sub1.txthigh:SetText("SUPER: Elaborate Frames")
	HenchmenOptionButton2Sub1.value = "super"
	HenchmenOptionButton2Sub1.callback = UnitFunc
	HenchmenOptionButton2Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(2,2)
	HenchmenOptionButton2Sub2.txt:SetText("Simple: Basic Frames")
	HenchmenOptionButton2Sub2.txthigh:SetText("Simple: Basic Frames")
	HenchmenOptionButton2Sub2.value = "simple"
	HenchmenOptionButton2Sub2.callback = UnitFunc
	HenchmenOptionButton2Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(2,3)
	HenchmenOptionButton2Sub3.txt:SetText("Compact: Minimal Frames")
	HenchmenOptionButton2Sub3.txthigh:SetText("Compact: Minimal Frames")
	HenchmenOptionButton2Sub3.value = "compact"
	HenchmenOptionButton2Sub3.callback = UnitFunc
	HenchmenOptionButton2Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton2.suboptions = 3;
	HenchmenOptionButton2.isopen = false;
	HenchmenOptionButton2:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(3,1)
	HenchmenOptionButton3Sub1.txt:SetText("One Row: Small Buttons")
	HenchmenOptionButton3Sub1.txthigh:SetText("One Row: Small Buttons")
	HenchmenOptionButton3Sub1.value = "default"
	HenchmenOptionButton3Sub1.callback = BarFunc
	HenchmenOptionButton3Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,2)
	HenchmenOptionButton3Sub2.txt:SetText("Two Rows: Small Buttons")
	HenchmenOptionButton3Sub2.txthigh:SetText("Two Rows: Small Buttons")
	HenchmenOptionButton3Sub2.value = "twosmall"
	HenchmenOptionButton3Sub2.callback = BarFunc
	HenchmenOptionButton3Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,3)
	HenchmenOptionButton3Sub3.txt:SetText("One Row: Large Buttons")
	HenchmenOptionButton3Sub3.txthigh:SetText("One Row: Large Buttons")
	HenchmenOptionButton3Sub3.value = "onebig"
	HenchmenOptionButton3Sub3.callback = BarFunc
	HenchmenOptionButton3Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,4)
	HenchmenOptionButton3Sub4.txt:SetText("Two Rows: Large Buttons")
	HenchmenOptionButton3Sub4.txthigh:SetText("Two Rows: Large Buttons")
	HenchmenOptionButton3Sub4.value = "twobig"
	HenchmenOptionButton3Sub4.callback = BarFunc
	HenchmenOptionButton3Sub4:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton3.suboptions = 4;
	HenchmenOptionButton3.isopen = false;
	HenchmenOptionButton3:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(4,1)
	HenchmenOptionButton4Sub1.txt:SetText("Icons Only")
	HenchmenOptionButton4Sub1.txthigh:SetText("Icons Only")
	HenchmenOptionButton4Sub1.value = "icons"
	HenchmenOptionButton4Sub1.callback = AuraFunc
	HenchmenOptionButton4Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(4,2)
	HenchmenOptionButton4Sub2.txt:SetText("Bars Only")
	HenchmenOptionButton4Sub2.txthigh:SetText("Bars Only")
	HenchmenOptionButton4Sub2.value = "bars"
	HenchmenOptionButton4Sub2.callback = AuraFunc
	HenchmenOptionButton4Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(4,3)
	HenchmenOptionButton4Sub3.txt:SetText("The Works: Bars and Icons")
	HenchmenOptionButton4Sub3.txthigh:SetText("The Works: Bars and Icons")
	HenchmenOptionButton4Sub3.value = "theworks"
	HenchmenOptionButton4Sub3.callback = AuraFunc
	HenchmenOptionButton4Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton4.suboptions = 3;
	HenchmenOptionButton4.isopen = false;
	HenchmenOptionButton4:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	HenchmenOptionButton5:SetScript("OnMouseUp", ConfigFunc)
	------------------------------------------------------------------------
	for _,frame in pairs(SUBOPTIONS) do 
		frame.anim:Finish()
		frame:Hide()
	end

	THEME.PostLoaded = true
end

function SV:ToggleHenchman()
	if InCombatLockdown()then return end 
	if(not THEME.PostLoaded) then
		CreateHenchmenFrame()
	end
	if not HenchmenFrame:IsShown()then 
		HenchmenFrameBG:Show()

		UpdateHenchmanModel()

		HenchmenFrame.anim:Finish()
		HenchmenFrame:Show()
		HenchmenFrame.anim:Play()
		HenchmenCalloutFrame.anim:Finish()
		HenchmenCalloutFrame:Show()
		HenchmenCalloutFrame:SetAlpha(1)
		HenchmenCalloutFrame.anim:Play()
		UIFrameFadeOut(HenchmenCalloutFrame,5)
		for i=1,5 do 
			local option=_G["HenchmenOptionButton"..i]
			option.anim:Finish()
			option:Show()
			option.anim:Play()

			local minion=_G["MinionOptionButton"..i]
			minion.anim:Finish()
			minion:Show()
			minion.anim:Play()
		end 
		THEME.DockButton.Icon:SetGradient(unpack(SV.Media.gradient.green))
	else 
		UpdateHenchmanModel(true)
		for _,frame in pairs(SUBOPTIONS)do
			frame.anim:Finish()
			frame:Hide()
		end 
		HenchmenOptionButton1.isopen=false;
		HenchmenOptionButton2.isopen=false;
		HenchmenOptionButton3.isopen=false;
		HenchmenCalloutFrame.anim:Finish()
		HenchmenCalloutFrame:Hide()
		HenchmenFrame.anim:Finish()
		HenchmenFrame:Hide()
		HenchmenFrameBG:Hide()
		for i=1,5 do 
			local option=_G["HenchmenOptionButton"..i]
			option.anim:Finish()
			option:Hide()

			local minion=_G["MinionOptionButton"..i]
			minion.anim:Finish()
			minion:Hide()
		end 
		THEME.DockButton.Icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	end 
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
local function LockdownCallback()
	if(HenchmenFrameModel and HenchmenFrame and HenchmenFrame:IsShown()) then 
        HenchmenFrame:Hide()
        HenchmenFrameBG:Hide()
    end
end

function THEME:InitializeHenchmen()
	self.DockButton = SV.Dock:SetDockButton("BottomRight", "Call Henchman!", [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-HENCHMAN]], SV.ToggleHenchman, "SVUI_Henchmen")
	SV.Events:OnLock("HenchmenFrameLock", LockdownCallback);
end 