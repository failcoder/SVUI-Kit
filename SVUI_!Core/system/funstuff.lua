--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry");
local L = SV.L;
--[[ 
########################################################## 
AFK
##########################################################
]]--
SV.AFK = _G["SVUI_AFKFrame"];
local AFK_SEQUENCES = {
	[1] = 120,
	[2] = 141,
	[3] = 119,
	[4] = 5,
};

function SV.AFK:Activate(enabled)
	if(InCombatLockdown()) then return end
	if(enabled) then
		local sequence = random(1, 4);
		if(SV.db.FunStuff.afk == '1') then
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
		if(SV.db.FunStuff.afk == '1') then
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

function SV.AFK:Toggle()
	if(SV.db.FunStuff.afk ~= 'NONE') then
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
SV.Comix = _G["SVUI_ComixFrame"];
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

function SV.Comix:LaunchPremiumPopup()
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

function SV:ToastyKombat()
	ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
	ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
	ComixToastyPanelBG.anim:Play()
	PlaySoundFile([[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])
end

_G.SlashCmdList["KOMBAT"] = function(msg)
	SV:ToastyKombat()
end
_G.SLASH_KOMBAT1 = "/kombat"

function SV.Comix:LaunchPopup()
	ComixReadyState(false)

	local coords, step1_x, step1_y, step2_x, step2_y, size;
	local rng = random(0, 32);

	if(rng == 0) then
		if(SV.db.FunStuff.comix == '1') then
			ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
			ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
			ComixToastyPanelBG.anim:Play()
			PlaySoundFile([[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])
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

function SV.Comix:Toggle()
	if(SV.db.FunStuff.comix == 'NONE') then 
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", nil)
	else 
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", Comix_OnEvent)
	end 
end
--[[ 
########################################################## 
DRUNK MODE
##########################################################
]]--
SV.Drunk = _G["SVUI_BoozedUpFrame"];
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
SV.Drunk.YeeHaw = _G["SVUI_DrunkenYeeHaw"]
SV.Drunk.YeeHaw:SetParent(SV.Drunk)
SV.Drunk:Hide()

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

function SV.Drunk:PartysOver()
	SetCVar("Sound_MusicVolume", 0)
	SetCVar("Sound_EnableMusic", 0)
	StopMusic()
	SV.Drunk:Hide()
	SV.Drunk.PartyMode = nil
	SV:AddonMessage("Party's Over...")
	--GetDressed()
end

function SV.Drunk:LetsParty()
	--GetNekkid()
	self.PartyMode = true
	SetCVar("Sound_MusicVolume", 100)
	SetCVar("Sound_EnableMusic", 1)
	StopMusic()
	PlayMusic([[Interface\AddOns\SVUI_!Core\assets\sounds\beer30.mp3]])
	self:Show()
	self.ScreenEffect1:ClearModel()
	self.ScreenEffect1:SetModel(DRUNK_EFFECT)
	self.ScreenEffect2:ClearModel()
	self.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	self.ScreenEffect3:ClearModel()
	self.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	SV:AddonMessage("YEEEEEEEEE-HAW!!!")
	DoEmote("dance")
	-- SV.Timers:ExecuteTimer(PartysOver, 60)
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

function SV.Drunk:Toggle()
	if(not SV.db.FunStuff.drunk) then 
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", nil)
	else 
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", DrunkAgain_OnEvent)
	end 
end
--[[ 
########################################################## 
GAMEMENU
##########################################################
]]--
SV.GameMenu = _G["SVUI_GameMenuFrame"];
--[[
4    - walk
5    - run
26   - attack stance
40   - falling loop
52   - casting loop
55   - roar pose (paused)
65   - shrug
69   - dance
74   - roar
111  - attack ready
119  - stealth walk
120  - stealth standing loop
125  - spell2
138  - craft loop
141  - kneel loop
203  - cannibalize
225  - cower loop
]]--
local Sequences = {26, 52, 111, 69};

local GameMenu_Activate = function(self)
	if(SV.db.FunStuff.gamemenu == 'NONE') then
		self:Toggle()
		return
	end

	local key = random(1, 4)
	local emote = Sequences[key]
	self:SetAlpha(1)
	self.ModelLeft:SetAnimation(emote)
	self.ModelRight:SetAnimation(69)
end

function SV.GameMenu:Toggle()
	if(SV.db.FunStuff.gamemenu ~= 'NONE') then
		self:Show()
		self:SetScript("OnShow", GameMenu_Activate)
	else
		self:Hide()
		self:SetScript("OnShow", nil)
	end
end
--[[ 
########################################################## 
LOAD BY TRIGGER
##########################################################
]]--
local function InitializeFunStuff()
	--[[ AFK SCREEN ]]--
	local afk = SV.AFK;
	local classToken = select(2,UnitClass("player"))
	local color = CUSTOM_CLASS_COLORS[classToken]
	if(not SV.db.general.customClassColor) then
		color = RAID_CLASS_COLORS[classToken]
	end

	afk.BG:SetVertexColor(color.r, color.g, color.b)
	afk.BG:ClearAllPoints()
	afk.BG:SetSize(500,600)
	afk.BG:SetPoint("BOTTOMRIGHT", afk, "BOTTOMRIGHT", 0, 0)

	afk:SetFrameLevel(0)
	afk:SetAllPoints(SV.Screen)

	local narr = afk.Model:CreateTexture(nil, "OVERLAY")
	narr:SetSize(300, 150)
	narr:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\AFK-NARRATIVE]])
	narr:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", 15, -15)

	afk.Model:ClearAllPoints()
	afk.Model:SetSize(600,600)
	afk.Model:SetPoint("BOTTOMRIGHT", afk, "BOTTOMRIGHT", 64, -64)
	afk.Model:SetUnit("player")
	afk.Model:SetCamDistanceScale(1.15)
	afk.Model:SetFacing(6)

	local splash = afk.Model:CreateTexture(nil, "OVERLAY")
	splash:SetSize(350, 175)
	splash:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\PLAYER-AFK]])
	splash:SetPoint("BOTTOMRIGHT", afk.Model, "CENTER", -75, 75)

	afk:Hide()
	if(SV.db.FunStuff.afk ~= 'NONE') then
		afk:RegisterEvent("PLAYER_FLAGS_CHANGED")
		afk:RegisterEvent("PLAYER_REGEN_DISABLED")
		afk:RegisterEvent("PLAYER_ENTERING_WORLD")
		afk:RegisterEvent("PET_BATTLE_OPENING_START")
		afk:SetScript("OnEvent", AFK_OnEvent)
	end

	--[[ COMIX POPUPS ]]--
	local comix = SV.Comix
	comix.Basic = _G["SVUI_ComixPopup1"]
	comix.Deluxe = _G["SVUI_ComixPopup2"]
	comix.Premium = _G["SVUI_ComixPopup3"]

	comix.Basic:SetParent(SV.Screen)
	comix.Basic:SetSize(128,128)
	comix.Basic.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:Kapow(comix.Basic, true, true)
	comix.Basic:SetAlpha(0)
	comix.Basic.anim[2]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Deluxe:SetParent(SV.Screen)
	comix.Deluxe:SetSize(128,128)
	comix.Deluxe.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(comix.Deluxe, true)
	comix.Deluxe:SetAlpha(0)
	comix.Deluxe.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Premium:SetParent(SV.Screen)
	comix.Premium.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(comix.Premium, true)
	comix.Premium:SetAlpha(0)
	comix.Premium.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Premium.bg.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(comix.Premium.bg, false)
	comix.Premium.bg:SetAlpha(0)
	comix.Premium.bg.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	local toasty = CreateFrame("Frame", "ComixToastyPanelBG", SV.Screen)
	toasty:SetSize(256, 256)
	toasty:SetFrameStrata("DIALOG")
	toasty:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	toasty.tex = toasty:CreateTexture(nil, "ARTWORK")
	toasty.tex:InsetPoints(toasty)
	toasty.tex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\TOASTY]])
	SV.Animate:Slide(toasty, 256, -256, true)
	toasty:SetAlpha(0)
	toasty.anim[4]:SetScript("OnFinished", Toasty_OnUpdate)

	ComixReadyState(true)

	comix:Toggle()

	--[[ DRUNK MODE ]]--
	local drunk = SV.Drunk;
	drunk:SetParent(SV.Screen)
	drunk:ClearAllPoints()
	drunk:SetAllPoints(SV.Screen)

	drunk.ScreenEffect1:SetParent(drunk)
	drunk.ScreenEffect1:SetAllPoints(SV.Screen)
	drunk.ScreenEffect1:SetModel(DRUNK_EFFECT)
	drunk.ScreenEffect1:SetCamDistanceScale(1)

	drunk.ScreenEffect2:SetParent(drunk)
	drunk.ScreenEffect2:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", 0, 0)
	drunk.ScreenEffect2:SetPoint("TOPRIGHT", SV.Screen, "TOP", 0, 0)
	drunk.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	drunk.ScreenEffect2:SetCamDistanceScale(0.25)

	drunk.ScreenEffect3:SetParent(drunk)
	drunk.ScreenEffect3:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	drunk.ScreenEffect3:SetPoint("TOPLEFT", SV.Screen, "TOP", 0, 0)
	drunk.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	drunk.ScreenEffect3:SetCamDistanceScale(0.25)

	drunk.YeeHaw:SetSize(512,350)
	drunk.YeeHaw:SetPoint("TOP", SV.Screen, "TOP", 0, -50);

	drunk:Hide()

	drunk:Toggle()

	--[[ GAME MENU ]]--
	local gamemenu = SV.GameMenu;
	gamemenu:SetFrameLevel(0)
	gamemenu:SetAllPoints(SV.Screen)

	gamemenu.ModelLeft:SetUnit("player")
	gamemenu.ModelLeft:SetRotation(1)
	gamemenu.ModelLeft:SetPortraitZoom(0.05)
	gamemenu.ModelLeft:SetPosition(0,0,-0.25)

	if(SV.db.FunStuff.gamemenu == '1') then
		gamemenu.ModelRight:SetDisplayInfo(49084)
		gamemenu.ModelRight:SetRotation(-1)
		gamemenu.ModelRight:SetCamDistanceScale(1.9)
		gamemenu.ModelRight:SetFacing(6)
		gamemenu.ModelRight:SetPosition(0,0,-0.3)
	elseif(SV.db.FunStuff.gamemenu == '2') then
		gamemenu.ModelRight:SetUnit("player")
		gamemenu.ModelRight:SetRotation(-1)
		gamemenu.ModelRight:SetCamDistanceScale(1.9)
		gamemenu.ModelRight:SetFacing(6)
		gamemenu.ModelRight:SetPosition(0,0,-0.3)
	end

	gamemenu:SetScript("OnShow", GameMenu_Activate)
end

SV.Events:On("CORE_INITIALIZED", InitializeFunStuff);