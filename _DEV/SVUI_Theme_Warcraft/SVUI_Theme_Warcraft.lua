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
local THEME = SV:GetTheme("Warcraft");
local LSM = LibStub("LibSharedMedia-3.0");
--[[ 
########################################################## 
AFK
##########################################################
]]--
THEME.AFK = _G["SVUI_WarcraftTheme_AFKFrame"];
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
		if(SV.db.THEME["Warcraft"].afk == '1') then
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
		if(SV.db.THEME["Warcraft"].afk == '1') then
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
	narr:SetTexture("Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\artwork\\Template\\AFK-NARRATIVE")
	narr:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", 15, -15)

	self.Model:ClearAllPoints()
	self.Model:SetSize(600,600)
	self.Model:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 64, -64)
	self.Model:SetUnit("player")
	self.Model:SetCamDistanceScale(1.15)
	self.Model:SetFacing(6)

	local splash = self.Model:CreateTexture(nil, "OVERLAY")
	splash:SetSize(350, 175)
	splash:SetTexture("Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\artwork\\Template\\PLAYER-AFK")
	splash:SetPoint("BOTTOMRIGHT", self.Model, "CENTER", -75, 75)

	self:Hide()
	if(SV.db.THEME["Warcraft"].afk ~= 'NONE') then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PET_BATTLE_OPENING_START")
		self:SetScript("OnEvent", AFK_OnEvent)
	end
end

function THEME.AFK:Toggle()
	if(SV.db.THEME["Warcraft"].afk ~= 'NONE') then
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
DRUNK
##########################################################
]]--
THEME.Drunk = _G["SVUI_WarcraftTheme_BoozedUpFrame"];
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
THEME.Drunk.YeeHaw = _G["SVUI_WarcraftTheme_DrunkenYeeHaw"]
THEME.Drunk.YeeHaw:SetParent(THEME.Drunk)
THEME.Drunk:Hide()
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
	PlayMusic([[Interface\AddOns\SVUI_Theme_Warcraft\assets\sounds\beer30.mp3]])
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
	if(not SV.db.THEME["Warcraft"].drunk) then 
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
THEME.GameMenu = _G["SVUI_WarcraftTheme_GameMenuFrame"];
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
	if(SV.db.THEME["Warcraft"].gamemenu == 'NONE') then
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

	if(SV.db.THEME["Warcraft"].gamemenu == '1') then
		self.ModelRight:SetDisplayInfo(49084)
		self.ModelRight:SetRotation(-1)
		self.ModelRight:SetCamDistanceScale(1.9)
		self.ModelRight:SetFacing(6)
		self.ModelRight:SetPosition(0,0,-0.3)
	elseif(SV.db.THEME["Warcraft"].gamemenu == '2') then
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
	-- splash:SetTexture("Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\artwork\\SPLASH-BLACK")
	-- splash:SetBlendMode("ADD")
	-- splash:SetPoint("TOP", 0, 0)

	self:SetScript("OnShow", Activate)
end

function THEME.GameMenu:Toggle()
	if(SV.db.THEME["Warcraft"].gamemenu ~= 'NONE') then
		self:Show()
		self:SetScript("OnShow", Activate)
	else
		self:Hide()
		self:SetScript("OnShow", nil)
	end
end
--[[ 
########################################################## 
MISC
##########################################################
]]--
local _SetDockButtonTheme = function(_, button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("Button")

	local sparks = button:CreateTexture(nil, "OVERLAY", nil, 2)
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
	backdrop:SetBackdrop({
	    bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], 
	    tile = false, 
	    tileSize = 0, 
	    edgeFile = [[Interface\Glues\COMMON\TextPanel-Border]],
	    edgeSize = 15,
	    insets = 
	    {
	        left = 0, 
	        right = 0, 
	        top = 0, 
	        bottom = 0, 
	    }, 
	});
	backdrop:SetBackdropColor(0,0,0,0.5);
	backdrop:SetBackdropBorderColor(1,1,1,1);

	return backdrop 
end

local SetFrameBorderColor = function(self, r, g, b, reset)
    if(reset) then
        r,g,b = 1,1,1
    end
    self.__border:SetBackdropBorderColor(r,g,b)
end

local ShowAlertFlash = function(self)
    self:ColorBorder(1,0.9,0)
    SV.Animate:Flash(self.__border, 0.75, true)
end

local HideAlertFlash = function(self)
    SV.Animate:StopFlash(self.__border)
    self:ColorBorder(1,0.9,0,true)
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

local _CreateDockButton = function(self, frame, inverse, inverted, styleName)
    if(not frame or (frame and frame.Panel)) then return end

    styleName = styleName or "DockButton";
    self:APPLY(frame, styleName, inverse)

    if(inverted) then
        frame.Panel:SetAttribute("panelGradient", "darkest2")
    else
        frame.Panel:SetAttribute("panelGradient", "darkest")
    end

    if(not frame.__border) then
        local border = CreateFrame("Frame", nil, frame)
        border:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, -5)
        border:SetBackdrop({
            bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]], 
            edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], 
            tile = false, 
            tileSize = 0, 
            edgeSize = 20, 
            insets = 
            {
                left = 0, 
                right = 0, 
                top = 0, 
                bottom = 0, 
            }, 
        });
        border:SetBackdropBorderColor(1,1,1,1)

        frame.__border = border
        frame.__border.__previous = 'light';
        frame.ColorBorder = SetFrameBorderColor
        frame.StartAlert = ShowAlertFlash
        frame.StopAlert = HideAlertFlash
    end
end;

function THEME:Load()
	SV.defaults["font"]["default"]     	= {file = "Arial Narrow",  size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["dialog"]      	= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["title"]       	= {file = "Arial Narrow",  size = 16,  outline = "OUTLINE"}; 
	SV.defaults["font"]["number"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["number_big"]   = {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};
	SV.defaults["font"]["header"]      	= {file = "Friz Quadrata TT",   size = 18,  outline = "OUTLINE"};  
	SV.defaults["font"]["combat"]      	= {file = "Morpheus",   size = 64,  outline = "OUTLINE"}; 
	SV.defaults["font"]["alert"]       	= {file = "Skurri",    size = 20,  outline = "OUTLINE"};
	SV.defaults["font"]["zone"]      	= {file = "Morpheus",     size = 16,  outline = "OUTLINE"};
	SV.defaults["font"]["caps"]      	= {file = "Skurri",     size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["aura"]      	= {file = "Friz Quadrata TT",   size = 10,  outline = "OUTLINE"};
	SV.defaults["font"]["data"]      	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["narrator"]    	= {file = "Arial Narrow", size = 12,  outline = "OUTLINE"};
	SV.defaults["font"]["lootdialog"]   = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["lootnumber"]   = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};
	SV.defaults["font"]["rolldialog"]   = {file = "Arial Narrow",  size = 14,  outline = "OUTLINE"};
	SV.defaults["font"]["rollnumber"]   = {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"};

	if(SV.defaults.UnitFrames) then
		SV.defaults["font"]["unitprimary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitsecondary"]   	= {file = "Friz Quadrata TT",   size = 11,  outline = "OUTLINE"}
		SV.defaults["font"]["unitaurabar"]   	= {file = "Skurri",  	size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauramedium"]  	= {file = "Arial Narrow",  size = 10,  outline = "OUTLINE"}
		SV.defaults["font"]["unitauralarge"]   	= {file = "Friz Quadrata TT",   size = 10,  outline = "OUTLINE"}
	end

	SV.API.Methods["DockButton"] = _CreateDockButton;

	SV.API.Themes["Warcraft"] = {
		["Default"]     = "SVUI_WarcraftTheme_Default",
		["DockButton"]  = "SVUI_WarcraftTheme_DockButton",
		["Composite1"]  = "SVUI_WarcraftTheme_Composite1",
		["Composite2"]  = "SVUI_WarcraftTheme_Composite2",
		["UnitLarge"]   = "SVUI_WarcraftTheme_UnitLarge",
		["UnitSmall"]   = "SVUI_WarcraftTheme_UnitSmall",
		["Minimap"] 	= "SVUI_WarcraftTheme_Minimap",
		["ActionPanel"] = "SVUI_WarcraftTheme_ActionPanel",
	};

	SV.Media["font"]["default"]   = LSM:Fetch("font", "Arial Narrow");
	SV.Media["font"]["combat"]    = LSM:Fetch("font", "Morpheus");
	SV.Media["font"]["narrator"]  = LSM:Fetch("font", "Arial Narrow");
	SV.Media["font"]["zones"]     = LSM:Fetch("font", "Morpheus");
	SV.Media["font"]["alert"]     = LSM:Fetch("font", "Skurri");
	SV.Media["font"]["numbers"]   = LSM:Fetch("font", "Friz Quadrata TT");
	SV.Media["font"]["caps"]      = LSM:Fetch("font", "Friz Quadrata TT");
	SV.Media["font"]["flash"]     = LSM:Fetch("font", "Skurri");
	SV.Media["font"]["dialog"]    = LSM:Fetch("font", "Arial Narrow");

	SV.Media.misc.splash = "Interface\\AddOns\\SVUI_Theme_Warcraft\\assets\\artwork\\SPLASH";
	SV.Media.dock.durabilityLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-DUR]];
	SV.Media.dock.reputationLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-REP]];
	SV.Media.dock.experienceLabel = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\LABEL-XP]];
	SV.Media.dock.hearthIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-HEARTH]];
	SV.Media.dock.raidToolIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-RAIDTOOL]];
	SV.Media.dock.garrisonToolIcon = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\DOCK-ICON-GARRISON]];
	SV.Media.dock.professionIconFile = [[Interface\AddOns\SVUI_Theme_Warcraft\assets\artwork\Dock\PROFESSIONS]];
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

	SV.Dock.SetButtonTheme = _SetDockButtonTheme
	SV.Dock.SetThemeDockStyle = _SetDockStyleTheme

	self.AFK:Initialize()
	self.GameMenu:Initialize()
	self.Drunk:Initialize()
	self:LoadUFOverrides()
end 