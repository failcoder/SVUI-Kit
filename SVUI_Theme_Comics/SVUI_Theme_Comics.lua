--[[
##############################################################################
S U P E R - V I L L A I N - T H E M E   By: Munglunch                        
##############################################################################
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
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
local THEME = SV:GetTheme("Comics");
--[[ 
########################################################## 
AFK
##########################################################
]]--
THEME.AFK = _G["SVUI_ComicsTheme_AFKFrame"];
local AFK_SEQUENCES = {
	[1] = 120,
	[2] = 141,
	[3] = 119,
	[4] = 5,
};

function THEME.AFK:Activate(enabled)
	if(InCombatLockdown()) then return end
	if(enabled) then
		local sequence = random(1, 4);
		if(SV.db.THEME["Comics"].afk == '1') then
			MoveViewLeftStart(0.05);
		end
		self:Show();
		UIParent:Hide();
		self:SetAlpha(1);
		self.Model:SetAnimation(AFK_SEQUENCES[sequence])
		DoEmote("READ")
	else
		UIParent:Show();
		self:SetAlpha(0);
		self:Hide();
		if(SV.db.THEME["Comics"].afk == '1') then
			MoveViewLeftStop();
		end
	end
end

local AFK_OnEvent = function(self, event)
	if(event == "PLAYER_FLAGS_CHANGED") then
		if(UnitIsAFK("player")) then
			self:Activate(true)
		else
			self:Activate(false)
		end
	else
		self:Activate(false)
	end
end

function THEME.AFK:Initialize()
	local classToken = select(2,UnitClass("player"))
	local color = CUSTOM_CLASS_COLORS[classToken]
	self.BG:SetVertexColor(color.r, color.g, color.b)
	self.BG:ClearAllPoints()
	self.BG:SetSize(500,600)
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

	self:SetFrameLevel(0)
	self:SetAllPoints(SV.Screen)

	local narr = self.Model:CreateTexture(nil, "OVERLAY")
	narr:SetSize(300, 150)
	narr:SetTexture("Interface\\AddOns\\SVUI_Theme_Comics\\assets\\artwork\\Template\\AFK-NARRATIVE")
	narr:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", 15, -15)

	self.Model:ClearAllPoints()
	self.Model:SetSize(600,600)
	self.Model:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 64, -64)
	self.Model:SetUnit("player")
	self.Model:SetCamDistanceScale(1.15)
	self.Model:SetFacing(6)

	local splash = self.Model:CreateTexture(nil, "OVERLAY")
	splash:SetSize(350, 175)
	splash:SetTexture("Interface\\AddOns\\SVUI_Theme_Comics\\assets\\artwork\\Template\\PLAYER-AFK")
	splash:SetPoint("BOTTOMRIGHT", self.Model, "CENTER", -75, 75)

	self:Hide()
	if(SV.db.THEME["Comics"].afk ~= 'NONE') then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PET_BATTLE_OPENING_START")
		self:SetScript("OnEvent", AFK_OnEvent)
	end
end

function THEME.AFK:Toggle()
	if(SV.db.THEME["Comics"].afk ~= 'NONE') then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PET_BATTLE_OPENING_START")
		self:RegisterEvent("PLAYER_DEAD")
		self:SetScript("OnEvent", AFK_OnEvent)
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PET_BATTLE_OPENING_START")
		self:UnregisterEvent("PLAYER_DEAD")
		self:SetScript("OnEvent", nil)
	end
end
--[[ 
########################################################## 
COMIX
##########################################################
]]--
THEME.Comix = _G["SVUI_ComicsTheme_ComixFrame"];
local animReady = true;
local COMIX_DATA = {
	{
		{0,0.25,0,0.25},
		{0.25,0.5,0,0.25},
		{0.5,0.75,0,0.25},
		{0.75,1,0,0.25},
		{0,0.25,0.25,0.5},
		{0.25,0.5,0.25,0.5},
		{0.5,0.75,0.25,0.5},
		{0.75,1,0.25,0.5},
		{0,0.25,0.5,0.75},
		{0.25,0.5,0.5,0.75},
		{0.5,0.75,0.5,0.75},
		{0.75,1,0.5,0.75},
		{0,0.25,0.75,1},
		{0.25,0.5,0.75,1},
		{0.5,0.75,0.75,1},
		{0.75,1,0.75,1}
	},
	{
		{220, 210, 50, -50, 220, 210, -1, 5},
	    {230, 210, 50, 5, 280, 210, -5, 1},
	    {280, 160, 1, 50, 280, 210, -1, 5},
	    {220, 210, 50, -50, 220, 210, -1, 5},
	    {210, 190, 50, 50, 220, 210, -1, 5},
	    {220, 210, 50, -50, 220, 210, -1, 5},
	    {230, 210, 50, 5, 280, 210, -5, 1},
	    {280, 160, 1, 50, 280, 210, -1, 5},
	    {220, 210, 50, -50, 220, 210, -1, 5},
	    {210, 190, 50, 50, 220, 210, -1, 5},
	    {220, 210, 50, -50, 220, 210, -1, 5},
	    {230, 210, 50, 5, 280, 210, -5, 1},
	    {280, 160, 1, 50, 280, 210, -1, 5},
	    {220, 210, 50, -50, 220, 210, -1, 5},
	    {210, 190, 50, 50, 220, 210, -1, 5},
	    {210, 190, 50, 50, 220, 210, -1, 5}
	}
};

local function ComixReadyState(state)
	if(state == nil) then return animReady end
	animReady = state
end

local Comix_OnUpdate = function() ComixReadyState(true) end
local Toasty_OnUpdate = function(self) ComixReadyState(true); self.parent:SetAlpha(0) end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function THEME.Comix:LaunchPremiumPopup()
	ComixReadyState(false)

	local rng = random(1, 16);
	local coords = COMIX_DATA[1][rng];
	local offsets = COMIX_DATA[2][rng]

	self.Premium.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
	self.Premium.bg.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
	self.Premium.anim[1]:SetOffset(offsets[1],offsets[2])
	self.Premium.anim[2]:SetOffset(offsets[3],offsets[4])
	self.Premium.anim[3]:SetOffset(0,0)
	self.Premium.bg.anim[1]:SetOffset(offsets[5],offsets[6])
	self.Premium.bg.anim[2]:SetOffset(offsets[7],offsets[8])
	self.Premium.bg.anim[3]:SetOffset(0,0)
	self.Premium.anim:Play()
	self.Premium.bg.anim:Play() 
end

function THEME:ToastyKombat()
	ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
	ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
	ComixToastyPanelBG.anim:Play()
	PlaySoundFile([[Interface\AddOns\SVUI_Theme_Comics\assets\sounds\toasty.mp3]])
end

_G.SlashCmdList["KOMBAT"] = function(msg)
	THEME:ToastyKombat()
end
_G.SLASH_KOMBAT1 = "/kombat"

function THEME.Comix:LaunchPopup()
	ComixReadyState(false)

	local coords, step1_x, step1_y, step2_x, step2_y, size;
	local rng = random(1, 32);

	if(rng == 32) then
		if(SV.db.THEME["Comics"].comix == '1') then
			ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
			ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
			ComixToastyPanelBG.anim:Play()
			PlaySoundFile([[Interface\AddOns\SVUI_Theme_Comics\assets\sounds\toasty.mp3]])
		end
	elseif(rng > 16) then
		local key = rng - 16;
		coords = COMIX_DATA[1][key];
		step1_x = random(-150, 150);
		if(step1_x > -20 and step1_x < 20) then step1_x = step1_x * 3 end
		step1_y = random(50, 150);
		step2_x = step1_x * 0.5;
		step2_y = step1_y * 0.75;
		self.Deluxe.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4]);
		self.Deluxe.anim[1]:SetOffset(step1_x, step1_y);
		self.Deluxe.anim[2]:SetOffset(step2_x, step2_y);
		self.Deluxe.anim[3]:SetOffset(0,0);
		self.Deluxe.anim:Play();
	else
		coords = COMIX_DATA[1][rng];
		step1_x = random(-100, 100);
		step1_y = random(-50, 1);
		size = random(96,128);
		self.Basic:SetSize(size,size);
		self.Basic.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4]);
		self.Basic:ClearAllPoints();
		self.Basic:SetPoint("CENTER", SV.Screen, "CENTER", step1_x, step1_y);
		self.Basic.anim:Play();
	end
end

local Comix_OnEvent = function(self, event, ...)
	local _, subEvent, _, guid = ...;
	if((subEvent == "PARTY_KILL" and guid == UnitGUID('player')) and ComixReadyState()) then
		self:LaunchPopup()
	end  
end

function THEME.Comix:Toggle()
	if(SV.db.THEME["Comics"].comix == 'NONE') then 
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", nil)
	else 
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", Comix_OnEvent)
	end 
end 

function THEME.Comix:Initialize()
	self.Basic = _G["SVUI_ComicsTheme_ComixPopup1"]
	self.Deluxe = _G["SVUI_ComicsTheme_ComixPopup2"]
	self.Premium = _G["SVUI_ComicsTheme_ComixPopup3"]

	self.Basic:SetParent(SV.Screen)
	self.Basic:SetSize(128,128)
	self.Basic.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:Kapow(self.Basic, true, true)
	self.Basic:SetAlpha(0)
	self.Basic.anim[2]:SetScript("OnFinished", Comix_OnUpdate)

	self.Deluxe:SetParent(SV.Screen)
	self.Deluxe:SetSize(128,128)
	self.Deluxe.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(self.Deluxe, true)
	self.Deluxe:SetAlpha(0)
	self.Deluxe.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	self.Premium:SetParent(SV.Screen)
	self.Premium.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(self.Premium, true)
	self.Premium:SetAlpha(0)
	self.Premium.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	self.Premium.bg.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(self.Premium.bg, false)
	self.Premium.bg:SetAlpha(0)
	self.Premium.bg.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	--MOD
	local toasty = CreateFrame("Frame", "ComixToastyPanelBG", SV.Screen)
	toasty:SetSize(256, 256)
	toasty:SetFrameStrata("DIALOG")
	toasty:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	toasty.tex = toasty:CreateTexture(nil, "ARTWORK")
	toasty.tex:InsetPoints(toasty)
	toasty.tex:SetTexture([[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Doodads\TOASTY]])
	SV.Animate:Slide(toasty, 256, -256, true)
	toasty:SetAlpha(0)
	toasty.anim[4]:SetScript("OnFinished", Toasty_OnUpdate)

	ComixReadyState(true)

	self:Toggle()
end
--[[ 
########################################################## 
DRUNK
##########################################################
]]--
THEME.Drunk = _G["SVUI_ComicsTheme_BoozedUpFrame"];
local WORN_ITEMS = {};
local DRUNK_EFFECT = [[Spells\Largebluegreenradiationfog.m2]];
local DRUNK_EFFECT2 = [[Spells\Monk_drunkenhaze_impact.m2]];
local TIPSY_FILTERS = {
	[DRUNK_MESSAGE_ITEM_SELF1] = true,
	[DRUNK_MESSAGE_ITEM_SELF2] = true,
	[DRUNK_MESSAGE_SELF1] = true,
	[DRUNK_MESSAGE_SELF2] = true,
};
local DRUNK_FILTERS = {
	[DRUNK_MESSAGE_ITEM_SELF3] = true,
	[DRUNK_MESSAGE_ITEM_SELF4] = true,
	[DRUNK_MESSAGE_SELF3] = true,
	[DRUNK_MESSAGE_SELF4] = true,
};
--[[ 
########################################################## 
DRUNK MODE
##########################################################
]]--
local function GetNekkid()
	for c = 1, 19 do
		if CursorHasItem() then 
			ClearCursor()
		end
		local item = GetInventoryItemID("player", c);
		WORN_ITEMS[c] = item;
		PickupInventoryItem(c);
		for b = 1, 4 do 
			if CursorHasItem() then
				PutItemInBag(b)
			end  
		end 
	end
end

local function GetDressed()
	for c, item in pairs(WORN_ITEMS) do 
		if(item) then
			EquipItemByName(item)
			WORN_ITEMS[c] = false
		end
	end
end

function THEME.Drunk:PartysOver()
	SetCVar("Sound_MusicVolume", 0)
	SetCVar("Sound_EnableMusic", 0)
	StopMusic()
	THEME.Drunk:Hide()
	THEME.Drunk.PartyMode = nil
	SV:AddonMessage("Party's Over...")
	--GetDressed()
end

function THEME.Drunk:LetsParty()
	--GetNekkid()
	self.PartyMode = true
	SetCVar("Sound_MusicVolume", 100)
	SetCVar("Sound_EnableMusic", 1)
	StopMusic()
	PlayMusic([[Interface\AddOns\SVUI_Theme_Comics\assets\sounds\beer30.mp3]])
	self:Show()
	self.ScreenEffect1:ClearModel()
	self.ScreenEffect1:SetModel(DRUNK_EFFECT)
	self.ScreenEffect2:ClearModel()
	self.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	self.ScreenEffect3:ClearModel()
	self.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	SV:AddonMessage("YEEEEEEEEE-HAW!!!")
	DoEmote("dance")
	-- THEME.Timers:ExecuteTimer(PartysOver, 60)
end 

local DrunkAgain_OnEvent = function(self, event, message, ...)
	if(self.PartyMode) then
		for pattern,_ in pairs(TIPSY_FILTERS) do
			if(message:find(pattern)) then
				self:PartysOver()
				break
			end
		end
	else
		for pattern,_ in pairs(DRUNK_FILTERS) do
			if(message:find(pattern)) then
				self:LetsParty()
				break
			end
		end
	end 
end

function THEME.Drunk:Toggle()
	if(not SV.db.THEME["Comics"].drunk) then 
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", nil)
	else 
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", DrunkAgain_OnEvent)
	end 
end

function THEME.Drunk:Initialize()
	self:SetParent(SV.Screen)
	self:ClearAllPoints()
	self:SetAllPoints(SV.Screen)

	self.ScreenEffect1:SetParent(self)
	self.ScreenEffect1:SetAllPoints(SV.Screen)
	self.ScreenEffect1:SetModel(DRUNK_EFFECT)
	self.ScreenEffect1:SetCamDistanceScale(1)

	self.ScreenEffect2:SetParent(self)
	self.ScreenEffect2:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", 0, 0)
	self.ScreenEffect2:SetPoint("TOPRIGHT", SV.Screen, "TOP", 0, 0)
	--self.ScreenEffect2:SetSize(350, 600)
	self.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	self.ScreenEffect2:SetCamDistanceScale(0.25)
	--self.ScreenEffect2:SetPosition(-0.21,-0.15,0)

	self.ScreenEffect3:SetParent(self)
	self.ScreenEffect3:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	self.ScreenEffect3:SetPoint("TOPLEFT", SV.Screen, "TOP", 0, 0)
	--self.ScreenEffect3:SetSize(350, 600)
	self.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	self.ScreenEffect3:SetCamDistanceScale(0.25)
	--self.ScreenEffect3:SetPosition(-0.21,-0.15,0)

	self.YeeHaw = _G["SVUI_ComicsTheme_DrunkenYeeHaw"]
	self.YeeHaw:SetParent(self)
	self.YeeHaw:SetSize(512,350)
	self.YeeHaw:SetPoint("TOP", SV.Screen, "TOP", 0, -50);

	self:Hide()

	self:Toggle()
end
--[[ 
########################################################## 
GAMEMENU
##########################################################
]]--
THEME.GameMenu = _G["SVUI_ComicsTheme_GameMenuFrame"];
--[[
141 - kneel loop
138 - craft loop
120 - half-crouch loop
119 - stealth walk
111 - attack ready
55 - roar pose (paused)
40 - falling loop
203 - cannibalize
225 - cower loop

]]--
local Sequences = {
	--{65, 1000}, --shrug
	--{120, 1000}, --stealth
	--{74, 1000}, --roar
	--{203, 1000}, --cannibalize
	--{119, 1000}, --stealth walk
	--{125, 1000}, --spell2
	--{225, 1000}, --cower
	{26, 1000}, --attack
	{52, 1000}, --attack
	--{138, 1000}, --craft
	{111, 1000}, --attack ready
	--{4, 1000}, --walk
	--{5, 1000}, --run
	{69, 1000}, --dance
};

local function rng()
	return random(1, #Sequences)
end

local Activate = function(self)
	if(SV.db.THEME["Comics"].gamemenu == 'NONE') then
		self:Toggle()
		return
	end

	local key = rng()
	local emote = Sequences[key][1]
	self:SetAlpha(1)
	self.ModelLeft:SetAnimation(emote)
	self.ModelRight:SetAnimation(69)
end

function THEME.GameMenu:Initialize()
	self:SetFrameLevel(0)
	self:SetAllPoints(SV.Screen)

	self.ModelLeft:SetUnit("player")
	self.ModelLeft:SetRotation(1)
	self.ModelLeft:SetPortraitZoom(0.05)
	self.ModelLeft:SetPosition(0,0,-0.25)

	if(SV.db.THEME["Comics"].gamemenu == '1') then
		self.ModelRight:SetDisplayInfo(49084)
		self.ModelRight:SetRotation(-1)
		self.ModelRight:SetCamDistanceScale(1.9)
		self.ModelRight:SetFacing(6)
		self.ModelRight:SetPosition(0,0,-0.3)
	elseif(SV.db.THEME["Comics"].gamemenu == '2') then
		self.ModelRight:SetUnit("player")
		self.ModelRight:SetRotation(-1)
		self.ModelRight:SetCamDistanceScale(1.9)
		self.ModelRight:SetFacing(6)
		self.ModelRight:SetPosition(0,0,-0.3)
	end

	-- local effectFrame = CreateFrame("PlayerModel", nil, self.ModelRight)
	-- effectFrame:SetAllPoints(self.ModelRight)
	-- effectFrame:SetCamDistanceScale(1)
	-- effectFrame:SetPortraitZoom(0)
	-- effectFrame:SetModel([[Spells\Blackmagic_precast_base.m2]])

	-- local splash = self:CreateTexture(nil, "OVERLAY")
	-- splash:SetSize(600, 300)
	-- splash:SetTexture("Interface\\AddOns\\SVUI_Theme_Comics\\assets\\artwork\\SPLASH-BLACK")
	-- splash:SetBlendMode("ADD")
	-- splash:SetPoint("TOP", 0, 0)

	self:SetScript("OnShow", Activate)
end

function THEME.GameMenu:Toggle()
	if(SV.db.THEME["Comics"].gamemenu ~= 'NONE') then
		self:Show()
		self:SetScript("OnShow", Activate)
	else
		self:Hide()
		self:SetScript("OnShow", nil)
	end
end

local _SetDockButtonTheme = function(button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("DockButton")

	local sparks = button.__border:CreateTexture(nil, "OVERLAY", nil, 2)
	sparks:ModSize(sparkSize, sparkSize)
	sparks:SetPoint("CENTER", button, "BOTTOMRIGHT", -sparkOffset, 4)
	sparks:SetTexture(THEME.media.dockSparks[1])
	sparks:SetVertexColor(0.7, 0.6, 0.5)
	sparks:SetBlendMode("ADD")
	sparks:SetAlpha(0)

	SV.Animate:Sprite8(sparks, 0.08, 2, false, true)

	button.Sparks = sparks;

	button.ClickTheme = function(self)
		self.Sparks:SetTexture(THEME.media.dockSparks[random(1,3)])
		self.Sparks.anim:Play()
	end
end

local _SetDockStyleTheme = function(dock, isBottom)
	if dock.backdrop then return end

	local backdrop = CreateFrame("Frame", nil, dock)
	backdrop:SetAllPoints(dock)
	backdrop:SetFrameStrata("BACKGROUND")

	backdrop.bg = backdrop:CreateTexture(nil, "BORDER")
	backdrop.bg:InsetPoints(backdrop)
	backdrop.bg:SetTexture(1, 1, 1, 1)
	
	if(isBottom) then
		backdrop.bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.8, 0, 0, 0, 0)
	else
		backdrop.bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.8)
	end

	backdrop.left = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.left:SetTexture(1, 1, 1, 1)
	backdrop.left:ModPoint("TOPLEFT", 1, -1)
	backdrop.left:ModPoint("BOTTOMLEFT", -1, -1)
	backdrop.left:ModWidth(4)
	if(isBottom) then
		backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
	else
		backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	end

	backdrop.right = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.right:SetTexture(1, 1, 1, 1)
	backdrop.right:ModPoint("TOPRIGHT", -1, -1)
	backdrop.right:ModPoint("BOTTOMRIGHT", -1, -1)
	backdrop.right:ModWidth(4)
	if(isBottom) then
		backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
	else
		backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	end

	backdrop.bottom = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.bottom:ModPoint("BOTTOMLEFT", 1, -1)
	backdrop.bottom:ModPoint("BOTTOMRIGHT", -1, -1)
	if(isBottom) then
		backdrop.bottom:SetTexture(0, 0, 0, 1)
		backdrop.bottom:ModHeight(4)
	else
		backdrop.bottom:SetTexture(0, 0, 0, 0)
		backdrop.bottom:SetAlpha(0)
		backdrop.bottom:ModHeight(1)
	end

	backdrop.top = backdrop:CreateTexture(nil, "OVERLAY")
	backdrop.top:ModPoint("TOPLEFT", 1, -1)
	backdrop.top:ModPoint("TOPRIGHT", -1, 1)
	if(isBottom) then
		backdrop.top:SetTexture(0, 0, 0, 0)
		backdrop.top:SetAlpha(0)
		backdrop.top:ModHeight(1)
	else
		backdrop.top:SetTexture(0, 0, 0, 1)
		backdrop.top:ModHeight(4)
	end

	return backdrop 
end

local function SetButtonBasics(frame)
    if(frame.Left) then 
        frame.Left:SetAlpha(0)
    end 

    if(frame.Middle) then 
        frame.Middle:SetAlpha(0)
    end 

    if(frame.Right) then 
        frame.Right:SetAlpha(0)
    end 

    if(frame.SetNormalTexture) then 
        frame:SetNormalTexture("")
    end 

    if(frame.SetDisabledTexture) then 
        frame:SetDisabledTexture("")
    end

    if(frame.SetCheckedTexture) then 
        frame:SetCheckedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover) 
    end 
end

local SetFrameBorderColor = function(self, r, g, b, setPrevious, reset)
    if(setPrevious) then
        self.__border.__previous = setPrevious
    elseif(reset) then
        r,g,b = unpack(SV.Media.color[self.__border.__previous])
    end
    self.__border[1]:SetTexture(r, g, b)
    self.__border[2]:SetTexture(r, g, b)
    self.__border[3]:SetTexture(r, g, b)
    self.__border[4]:SetTexture(r, g, b)
end

local ShowAlertFlash = function(self)
    self:ColorBorder(1,0.9,0)
    SV.Animate:Flash(self.__border, 0.75, true)
end

local HideAlertFlash = function(self)
    SV.Animate:StopFlash(self.__border)
    self:ColorBorder(1,0.9,0, nil, true)
end

local _CreateDockButton = function(self, inverse, inverted, styleName)
    if(not self or (self and self.Panel)) then return end

    local borderSize = 2
    styleName = styleName or "DockButton";
    CreatePanelTemplate(self, styleName, inverse, false, 0, -borderSize, -borderSize)

    if(inverted) then
        self.Panel:SetAttribute("panelGradient", "darkest2")
    else
        self.Panel:SetAttribute("panelGradient", "darkest")
    end

    if(not self.__border) then
        local t = SV.Media.color.default
        local r,g,b = t[1], t[2], t[3]

        local border = CreateFrame("Frame", nil, self)
        border:SetAllPoints()

        border[1] = border:CreateTexture(nil,"BORDER")
        border[1]:SetTexture(r,g,b)
        border[1]:SetPoint("TOPLEFT", -1, 1)
        border[1]:SetPoint("BOTTOMLEFT", -1, -1)
        border[1]:SetWidth(borderSize)

        local leftoutline = border:CreateTexture(nil,"BORDER")
        leftoutline:SetTexture(0,0,0)
        leftoutline:SetPoint("TOPLEFT", -2, 2)
        leftoutline:SetPoint("BOTTOMLEFT", -2, -2)
        leftoutline:SetWidth(1)

        border[2] = border:CreateTexture(nil,"BORDER")
        border[2]:SetTexture(r,g,b)
        border[2]:SetPoint("TOPRIGHT", 1, 1)
        border[2]:SetPoint("BOTTOMRIGHT", 1, -1)
        border[2]:SetWidth(borderSize)

        local rightoutline = border:CreateTexture(nil,"BORDER")
        rightoutline:SetTexture(0,0,0)
        rightoutline:SetPoint("TOPRIGHT", 2, 2)
        rightoutline:SetPoint("BOTTOMRIGHT", 2, -2)
        rightoutline:SetWidth(1)

        border[3] = border:CreateTexture(nil,"BORDER")
        border[3]:SetTexture(r,g,b)
        border[3]:SetPoint("TOPLEFT", -1, 1)
        border[3]:SetPoint("TOPRIGHT", 1, 1)
        border[3]:SetHeight(borderSize)

        local topoutline = border:CreateTexture(nil,"BORDER")
        topoutline:SetTexture(0,0,0)
        topoutline:SetPoint("TOPLEFT", -2, 2)
        topoutline:SetPoint("TOPRIGHT", 2, 2)
        topoutline:SetHeight(1)

        border[4] = border:CreateTexture(nil,"BORDER")
        border[4]:SetTexture(r,g,b)
        border[4]:SetPoint("BOTTOMLEFT", -1, -1)
        border[4]:SetPoint("BOTTOMRIGHT", 1, -1)
        border[4]:SetHeight(borderSize)

        local bottomoutline = border:CreateTexture(nil,"BORDER")
        bottomoutline:SetTexture(0,0,0)
        bottomoutline:SetPoint("BOTTOMLEFT", -2, -2)
        bottomoutline:SetPoint("BOTTOMRIGHT", 2, -2)
        bottomoutline:SetHeight(1)

        self.__border = border
        self.__border.__previous = 'default';
        self.ColorBorder = SetFrameBorderColor
        self.StartAlert = ShowAlertFlash
        self.StopAlert = HideAlertFlash
    end

    SetButtonBasics(self)

    if(not self.__registered) then
        SV.API.LiveUpdates[self] = true
        self.__registered = true
    end
end;

function THEME:Load()
	if(GetLocale() == "enUS") then
		SV.defaults["font"]["dialog"] = {file = "SVUI Dialog Font",  size = 10,  outline = "OUTLINE"};
		SV.defaults["font"]["title"] = {file = "SVUI Dialog Font",  size = 16,  outline = "OUTLINE"};
		SV.Media["font"]["dialog"] = LSM:Fetch("font", "SVUI Dialog Font")
	end

	SV.defaults["font"]["number"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["number_big"]   = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};
	SV.defaults["font"]["header"]      	= {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"};  
	SV.defaults["font"]["combat"]      	= {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"}; 
	SV.defaults["font"]["alert"]       	= {file = "SVUI Alert Font",    size = 20,  outline = "OUTLINE"};
	SV.defaults["font"]["zone"]      	= {file = "SVUI Zone Font",     size = 16,  outline = "OUTLINE"};
	SV.defaults["font"]["aura"]      	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["data"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["narrator"]    	= {file = "SVUI Narrator Font", size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["lootnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["rollnumber"]   = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"};

	if(SV.defaults.UnitFrames) then
		SV.defaults["font"]["unitprimary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitsecondary"]   	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaurabar"]   	= {file = "SVUI Alert Font",  	size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauramedium"]  	= {file = "SVUI Default Font",  size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauralarge"]   	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"}
	end

	SV.defaults["media"]["textures"]["unitlarge"]   = "SVUI UnitBG 1";
	SV.defaults["media"]["textures"]["unitsmall"]   = "SVUI SmallUnitBG 1";
	SV.defaults["media"]["borders"]["unitlarge"]    = "SVUI UnitBorder 1";
	SV.defaults["media"]["borders"]["unitsmall"]    = "SVUI SmallBorder 1";

	if(SV.defaults.Maps) then
		SV.defaults.Maps.locationText = "CUSTOM";
		SV.defaults.Maps.bordersize = 6;
		SV.defaults.Maps.bordercolor = "light";
	end

	SV.API.Methods["DockButton"] = _CreateDockButton;

	SV.API.Themes["Comics"] = {
		["Default"]     = "SVUI_ComicsTheme_Default",
		["DockButton"]  = "SVUI_ComicsTheme_DockButton",
		["Composite1"]  = "SVUI_ComicsTheme_Composite1",
		["Composite2"]  = "SVUI_ComicsTheme_Composite2",
		["UnitLarge"]   = "SVUI_ComicsTheme_UnitLarge",
		["UnitSmall"]   = "SVUI_ComicsTheme_UnitSmall",
		["Minimap"] 	= "SVUI_ComicsTheme_Minimap",
		["ActionPanel"] = "SVUI_ComicsTheme_ActionPanel",
	};

	SV.Media["font"]["combat"]    = LSM:Fetch("font", "SVUI Combat Font");
	SV.Media["font"]["narrator"]  = LSM:Fetch("font", "SVUI Narrator Font");
	SV.Media["font"]["zones"]     = LSM:Fetch("font", "SVUI Zone Font");
	SV.Media["font"]["alert"]     = LSM:Fetch("font", "SVUI Alert Font");
	SV.Media["font"]["numbers"]   = LSM:Fetch("font", "SVUI Number Font");
	SV.Media["font"]["flash"]     = LSM:Fetch("font", "SVUI Flash Font");

	SV.Media.misc.splash = "Interface\\AddOns\\SVUI_Theme_Comics\\assets\\artwork\\SPLASH";
	SV.Media.dock.durabilityLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-DUR]];
	SV.Media.dock.reputationLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-REP]];
	SV.Media.dock.experienceLabel = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\LABEL-XP]];
	SV.Media.dock.hearthIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-HEARTH]];
	SV.Media.dock.raidToolIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
	SV.Media.dock.garrisonToolIcon = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\DOCK-ICON-GARRISON]];
	SV.Media.dock.professionIconFile = [[Interface\AddOns\SVUI_Theme_Comics\assets\artwork\Dock\PROFESSIONS]];
	SV.Media.dock.professionIconCoords = {
		[171] 	= {0,0.25,0,0.25}, 				-- PRO-ALCHEMY
	    [794] 	= {0.25,0.5,0,0.25,80451}, 		-- PRO-ARCHAELOGY
	    [164] 	= {0.5,0.75,0,0.25}, 			-- PRO-BLACKSMITH
	    [185] 	= {0.75,1,0,0.25,818,67097}, 	-- PRO-COOKING
	    [333] 	= {0,0.25,0.25,0.5,13262}, 		-- PRO-ENCHANTING
	    [202] 	= {0.25,0.5,0.25,0.5}, 			-- PRO-ENGINEERING
	    [129] 	= {0.5,0.75,0.25,0.5}, 			-- PRO-FIRSTAID
	    [773] 	= {0,0.25,0.5,0.75,51005}, 		-- PRO-INSCRIPTION
	    [755] 	= {0.25,0.5,0.5,0.75,31252},	-- PRO-JEWELCRAFTING
	    [165] 	= {0.5,0.75,0.5,0.75}, 			-- PRO-LEATHERWORKING
	    [186] 	= {0.75,1,0.5,0.75}, 			-- PRO-MINING
	    [197] 	= {0.25,0.5,0.75,1}, 			-- PRO-TAILORING
	}

	SV.Options.args.Themes.args.Comics = {
		type = "group",
		name = L["Comics Theme"],
		guiInline = true,  
		args = {
			themeGroup = {
				order = 1, 
				type = "group", 
				guiInline = true, 
				name = L["Fun Stuff"],
				args = {
					comix = {
						order = 1,
						type = 'select',
						name = L["Super Comic Popups"],
						get = function(j)return SV.db.THEME["Comics"].comix end,
						set = function(j,value) SV.db.THEME["Comics"].comix = value; THEME.Comix:Toggle() end,
						values = {
							['NONE'] = NONE,
							['1'] = 'All Popups',
							['2'] = 'Only Small Popups',
						}
					},
					afk = {
						order = 2,
						type = 'select',
						name = L["Super AFK Screen"],
						get = function(j)return SV.db.THEME["Comics"].afk end,
						set = function(j,value) SV.db.THEME["Comics"].afk = value; THEME.AFK:Toggle() end,
						values = {
							['NONE'] = NONE,
							['1'] = 'Fully Enabled',
							['2'] = 'Enabled (No Spinning)',
						}
					},
					gamemenu = {
						order = 3,
						type = 'select',
						name = L["Super Game Menu"],
						get = function(j)return SV.db.THEME["Comics"].gamemenu end,
						set = function(j,value) SV.db.THEME["Comics"].gamemenu = value; SV:StaticPopup_Show("RL_CLIENT") end,
						values = {
							['NONE'] = NONE,
							['1'] = 'You + Henchman',
							['2'] = 'You x2',
						}
					},
				}
			},
		}
	};

	SV.Dock.SetButtonTheme = _SetDockButtonTheme
	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme

	self.AFK:Initialize()
	self.Comix:Initialize()
	self.GameMenu:Initialize()
	self.Drunk:Initialize()
	self:InitializeHenchmen()
	self:LoadUFOverrides()
	self:LoadMapOverrides()
end 