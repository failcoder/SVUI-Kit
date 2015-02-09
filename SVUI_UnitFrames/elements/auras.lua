--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = math;
local floor         = math.floor
local ceil         	= math.ceil
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;
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

local AURA_FONT = [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]];
local AURA_FONTSIZE = 11;
local AURA_OUTLINE = "OUTLINE";
local BASIC_TEXTURE = SV.Media.bar.default;
local CanSteal = (SV.class == "MAGE");
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local AuraIcon_OnClick = function(self)
	if not IsShiftKeyDown() then return end 
	local name = self.name;

	local filterKey = tostring(self.spellID)
	if name and filterKey then 
		SV:AddonMessage((L["The spell '%s' has been added to the BlackList unitframe aura filter."]):format(name))
		SV.filters["BlackList"][filterKey] = {["enable"] = true}
		MOD:RefreshUnitFrames()
	end
end

local AuraIcon_OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local AuraIcon_OnLeave = function()
	GameTooltip:Hide()
end

local Aura_UpdateTooltip = function(self)
	GameTooltip:SetUnitAura(self.parent.__owner.unit, self:GetID(), self.filter)
end

local _hook_AuraBGBorderColor = function(self, ...) self.bg:SetBackdropBorderColor(...) end

local CreateAuraIcon = function(icons, index)
	local baseSize = icons.size or 16
	local aura = CreateFrame("Button", nil, icons)
	aura:RemoveTextures()
	aura:EnableMouse(true)
	aura:RegisterForClicks('RightButtonUp')

	aura:SetWidth(baseSize)
	aura:SetHeight(baseSize)

	aura:SetBackdrop({
    	bgFile = [[Interface\BUTTONS\WHITE8X8]], 
		tile = false, 
		tileSize = 0, 
		edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
        edgeSize = 1, 
        insets = {
            left = 0, 
            right = 0, 
            top = 0, 
            bottom = 0
        }
    })
    aura:SetBackdropColor(0, 0, 0, 0)
    aura:SetBackdropBorderColor(0, 0, 0)

    local bg = CreateFrame("Frame", nil, aura)
    bg:SetFrameStrata("BACKGROUND")
    bg:SetFrameLevel(0)
    bg:WrapPoints(aura, 2, 2)
    bg:SetBackdrop(SV.Media.backdrop.aura)
    bg:SetBackdropColor(0, 0, 0, 0)
    bg:SetBackdropBorderColor(0, 0, 0, 0)
    aura.bg = bg;

    --hooksecurefunc(aura, "SetBackdropBorderColor", _hook_AuraBGBorderColor)

    local fontgroup = "SVUI_Font_UnitAura";
    if(baseSize < 18) then
    	fontgroup = "SVUI_Font_UnitAura_Small";
    end
    --print(baseSize)
    --print(fontgroup)

	local cd = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate");
	cd:InsetPoints(aura, 1, 1);
	cd.noOCC = true;
	cd.noCooldownCount = true;
	cd:SetReverse(true);
	cd:SetHideCountdownNumbers(true);

	local fg = CreateFrame("Frame", nil, aura)
    fg:WrapPoints(aura, 2, 2)

	local text = fg:CreateFontString(nil, 'OVERLAY');
	text:SetFontObject(_G[fontgroup]);
	text:SetPoint('CENTER', aura, 'CENTER', 1, 1);
	text:SetJustifyH('CENTER');

	local count = fg:CreateFontString(nil, "OVERLAY");
	count:SetFontObject(_G[fontgroup]);
	count:SetPoint("CENTER", aura, "BOTTOMRIGHT", -3, 3);

	local icon = aura:CreateTexture(nil, "BACKGROUND");
	icon:SetAllPoints(aura);
	icon:InsetPoints(aura, 1, 1);
    icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

	local overlay = aura:CreateTexture(nil, "OVERLAY");
	overlay:InsetPoints(aura, 1, 1);
	overlay:SetTexture(BASIC_TEXTURE);
	overlay:SetVertexColor(0, 0, 0);
	overlay:Hide();

	-- local stealable = aura:CreateTexture(nil, 'OVERLAY')
	-- stealable:SetTexture("")
	-- stealable:SetPoint('TOPLEFT', -3, 3)
	-- stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	-- aura.stealable = stealable

	aura.UpdateTooltip = Aura_UpdateTooltip;
	aura:SetScript("OnEnter", AuraIcon_OnEnter);
	aura:SetScript("OnLeave", AuraIcon_OnLeave);
	aura:SetScript("OnClick", AuraIcon_OnClick);

	tinsert(icons, aura);

	aura.parent = icons;
	aura.cd = cd;
	aura.text = text;
	aura.icon = icon;
	aura.count = count;
	aura.overlay = overlay;

	return aura
end

local UpdateAuraTimer = function(self, elapsed)
	self.expiration = self.expiration - elapsed;

	if(self.nextUpdate > 0) then 
		self.nextUpdate = self.nextUpdate - elapsed;
		return;
	end

	if(self.expiration <= 0) then 
		self:SetScript("OnUpdate", nil)
		self.text:SetText('')
		return;
	end

	local expires = self.expiration;
	local calc, timeLeft = 0, 0;
	local timeFormat;
	if expires < 60 then 
		if expires >= 4 then
			timeLeft = floor(expires)
			timeFormat = "|cffffff00%d|r"
			self.nextUpdate = 0.51
		else
			timeLeft = expires
			timeFormat = "|cffff0000%.1f|r"
			self.nextUpdate = 0.051
		end 
	elseif expires < 3600 then
		timeFormat = "|cffffffff%d|r|cffCC8811m|r"
		timeLeft = ceil(expires / 60);
		calc = floor((expires / 60) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
	elseif expires < 86400 then
		timeFormat = "|cff66ffff%d|r|cffAA5511h|r"
		timeLeft = ceil(expires / 3600);
		calc = floor((expires / 3600) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
	else
		timeFormat = "|cff6666ff%d|r|cff991100d|r"
		timeLeft = ceil(expires / 86400);
		calc = floor((expires / 86400) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 86400);
	end

	self.text:SetFormattedText(timeFormat, timeLeft)
end 

local PostUpdateAuraIcon = function(self, unit, button, index, offset)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)
	local isFriend = (UnitIsFriend('player', unit) == 1) and true or false
	if button.isDebuff then
		if(not isFriend and button.owner and button.owner ~= "player" and button.owner ~= "vehicle") then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1, 1)
			button.bg:SetBackdropColor(1, 0, 0, 1)
			button.bg:SetBackdropBorderColor(0, 0, 0, 1)
			button.icon:SetDesaturated((unit and not unit:find('arena%d')) and true or false)
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and SV.class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94, 1)
				button.bg:SetBackdropColor(0, 0.9, 1, 1)
				button.bg:SetBackdropBorderColor(0, 0, 0, 1)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
				button.bg:SetBackdropColor(color.r, color.g, color.b, 1)
				button.bg:SetBackdropBorderColor(0, 0, 0, 1)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not isFriend then
			button:SetBackdropBorderColor(0.92, 0.91, 0.55, 1)
			button.bg:SetBackdropColor(1, 1, 0.5, 1)
			button.bg:SetBackdropBorderColor(0, 0, 0, 1)
		else
			button:SetBackdropBorderColor(0, 0, 0, 1)
			button.bg:SetBackdropColor(0, 0, 0, 0)
			button.bg:SetBackdropBorderColor(0, 0, 0, 0)		
		end	
	end

	local size = button:GetParent().size
	if size then
		button:ModSize(size)
	end
	
	button.spell = name
	button.isStealable = isStealable
	if(expiration and duration ~= 0) then
		if(not button:GetScript('OnUpdate')) then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextUpdate = -1
			button:SetScript('OnUpdate', UpdateAuraTimer)
		elseif(button.expirationTime ~= expiration) then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextUpdate = -1
		end
	end	
	if((duration == 0) or (expiration == 0)) then
		button:SetScript('OnUpdate', nil)
		button.text:SetText('')
	end
end


--[[ AURABAR HANDLERS ]]--

local AuraBar_OnClick = function(self)
	if not IsShiftKeyDown() then return end
	local parent = self:GetParent()
	local name = parent.aura.name

	local filterKey = tostring(parent.aura.spellID)
	if name and filterKey then 
		SV:AddonMessage((L["The spell '%s' has been added to the BlackList unitframe aura filter."]):format(name))
		SV.filters["BlackList"][filterKey] = {["enable"] = true}
		MOD:RefreshUnitFrames()
	end 
end

local PostCreateAuraBars = function(self)
	self.spelltime = self:CreateFontString(nil, 'ARTWORK')
	self.spelltime:SetFontObject(SVUI_Font_UnitAura);
	self.spelltime:SetTextColor(1 ,1, 1)
	self.spelltime:SetShadowOffset(1, -1)
  	self.spelltime:SetShadowColor(0, 0, 0)
	self.spelltime:SetJustifyH'RIGHT'
	self.spelltime:SetJustifyV'CENTER'
	self.spelltime:SetPoint'RIGHT'

	self.spellname = self:CreateFontString(nil, 'ARTWORK')
	self.spellname:SetFontObject(SVUI_Font_UnitAura_Bar);
	self.spellname:SetTextColor(1, 1, 1)
	self.spellname:SetShadowOffset(1, -1)
  	self.spellname:SetShadowColor(0, 0, 0)
	self.spellname:SetJustifyH'LEFT'
	self.spellname:SetJustifyV'CENTER'
	self.spellname:SetPoint'LEFT'
	self.spellname:SetPoint('RIGHT', self.spelltime, 'LEFT')
	self.iconHolder:RegisterForClicks("RightButtonUp")
	self.iconHolder:SetScript("OnClick", AuraBar_OnClick)
end 

local ColorizeAuraBars = function(self)
	local bars = self.bars;
	for i = 1, #bars do 
		local auraBar = bars[i]
		if not auraBar:IsVisible()then break end 
		local color
		local spellID = auraBar.statusBar.aura.spellID;
		local filterKey = tostring(spellID)
		if(SV.filters["Defense"][filterKey]) then 
			color = oUF_SVUI.colors.shield_bars
		elseif(SV.filters.AuraBars[filterKey]) then
			color = SV.filters.AuraBars[filterKey]
		end 
		if color then 
			auraBar.statusBar:SetStatusBarColor(unpack(color))
			auraBar:SetBackdropColor(color[1] * 0.25, color[2] * 0.25, color[3] * 0.25, 0.5)
		else
			local r, g, b = auraBar.statusBar:GetStatusBarColor()
			auraBar:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25, 0.5)
		end 
	end 
end

--[[ AURA FILTERING ]]--

local CommonAuraFilter = function(self, unit, icon, auraName, _, _, _, debuffType, duration, _, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura)
	local db = SV.db.UnitFrames[self.___key]
	local auraType = self.type;
	if(not auraType) then return true end 
	if((not db) or (db and not db[auraType])) then 
		return false;
	end
	local auraDB = db[auraType];
	local isPlayer = caster == "player" or caster == "vehicle";
	local isEnemy = UnitIsEnemy("player", unit);

	icon.isPlayer = isPlayer;
	icon.priority = 0;
	icon.owner = caster;
	icon.name = auraName;
	icon.spellID = spellID;

	local filterKey = tostring(spellID)

	if(auraDB.filterWhiteList and (not SV.filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.filters.BlackList[filterKey] and SV.filters.BlackList[filterKey].enable) then
		return false;
	else
		if(auraDB.filterPlayer and (not isPlayer)) then
			return false
		end

		if(auraDB.filterDispellable and (debuffType and not MOD.Dispellable[debuffType])) then 
			return false
		end

		if(auraDB.filterRaid and shouldConsolidate) then 
			return false 
		end

		if(auraDB.filterInfinite and ((not duration) or (duration and duration == 0))) then 
			return false 
		end

		local active = auraDB.useFilter
		if(active and SV.filters[active]) then
			local spellDB = SV.filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end  
		end
	end
  	return true
end

local CommonBarFilter = function(self, unit, auraName, _, _, _, debuffType, duration, _, caster, isStealable, shouldConsolidate, spellID)
	local db = SV.db.UnitFrames[self.___key]
	if((not db) or (db and not db.aurabar)) then 
		return false;
	end
	local auraDB = db.aurabar;
	local isPlayer = caster == "player" or caster == "vehicle";
	local isEnemy = UnitIsEnemy("player", unit);

	local filterKey = tostring(spellID)

	if(auraDB.filterWhiteList and (not SV.filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.filters.BlackList[filterKey] and SV.filters.BlackList[filterKey].enable) then
		return false
	else
		if(auraDB.filterPlayer and (not isPlayer)) then
			return false
		end

		if(auraDB.filterDispellable and (debuffType and not MOD.Dispellable[debuffType])) then 
			return false
		end

		if(auraDB.filterRaid and shouldConsolidate) then 
			return false 
		end

		if(auraDB.filterInfinite and ((not duration) or (duration and duration == 0))) then 
			return false 
		end

		local active = auraDB.useFilter
		if(active and SV.filters[active]) then
			local spellDB = SV.filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end  
		end
	end
  	return true
end

--[[ DETAILED AURA FILTERING ]]--

local function filter_test(setting, isEnemy)
	if((not setting) or (setting and type(setting) ~= "table")) then 
		return false;
	end
	if((setting.enemy and isEnemy) or (setting.friendly and (not isEnemy))) then 
	  return true;
	end
  	return false 
end

local DetailedAuraFilter = function(self, unit, icon, auraName, _, _, _, debuffType, duration, _, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura)
	local db = SV.db.UnitFrames[self.___key]
	local auraType = self.type;
	if(not auraType) then return true end 
	if((not db) or (db and not db[auraType])) then 
		return false;
	end
	local auraDB = db[auraType]
	local isPlayer = caster == "player" or caster == "vehicle"
	local isEnemy = UnitIsEnemy("player", unit);

	icon.isPlayer = isPlayer;
	icon.priority = 0;
	icon.owner = caster;
	icon.name = auraName;
	icon.spellID = spellID;

	local filterKey = tostring(spellID)

	if(filter_test(auraDB.filterAll, isEnemy)) then
		return false
	elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.filters.BlackList[filterKey] and SV.filters.BlackList[filterKey].enable) then
		return false
	else
		if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
			return false
		end
		if(filter_test(auraDB.filterDispellable, isEnemy)) then
			if((CanSteal and (auraType == 'buffs' and isStealable)) or (debuffType and (not MOD.Dispellable[debuffType])) or (not debuffType)) then
				return false
			end
		end
		if(filter_test(auraDB.filterRaid, isEnemy) and shouldConsolidate) then 
			return false 
		end
		if(filter_test(auraDB.filterInfinite, isEnemy) and ((not duration) or (duration and duration == 0))) then 
			return false 
		end
		local active = auraDB.useFilter
		if(active and SV.filters[active]) then
			local spellDB = SV.filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end  
		end
	end
  	return true 
end

local DetailedBarFilter = function(self, unit, auraName, _, _, _, debuffType, duration, _, caster, isStealable, shouldConsolidate, spellID)
	local db = SV.db.UnitFrames[self.___key]
	if((not db) or (db and not db.aurabar)) then 
		return false;
	end
	local auraDB = db.aurabar;
	local isPlayer = caster == "player" or caster == "vehicle";
	local isEnemy = UnitIsEnemy("player", unit);

	local filterKey = tostring(spellID)

	if(filter_test(auraDB.filterAll, isEnemy)) then
		return false
	elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.filters.BlackList[filterKey] and SV.filters.BlackList[filterKey].enable) then
		return false
	else
		if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
			return false
		end
		if(filter_test(auraDB.filterDispellable, isEnemy) and (debuffType and not MOD.Dispellable[debuffType])) then 
			return false
		end
		if(filter_test(auraDB.filterRaid, isEnemy) and shouldConsolidate) then 
			return false 
		end
		if(filter_test(auraDB.filterInfinite, isEnemy) and ((not duration) or (duration and duration == 0))) then 
			return false 
		end
		local active = auraDB.useFilter
		if(active and SV.filters[active]) then
			local spellDB = SV.filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end  
		end
	end
  	return true 
end

--[[ 
########################################################## 
BUILD FUNCTION
##########################################################
]]--
local BoolFilters = {
	['player'] = true,
	['pet'] = true,
	['boss'] = true,
	['arena'] = true,
	['party'] = true,
	['raid'] = true,
	['raidpet'] = true,	
};

function MOD:CreateBuffs(frame, unit)
	local aura = CreateFrame("Frame", nil, frame)
	aura.___key = unit
	aura.spacing = 2;
	aura.CreateIcon = CreateAuraIcon;
	aura.PostUpdateIcon = PostUpdateAuraIcon;
	if(BoolFilters[unit]) then
		aura.CustomFilter = CommonAuraFilter;
	else
		aura.CustomFilter = DetailedAuraFilter;
	end
	aura:SetFrameLevel(10)
	aura.type = "buffs"
	return aura 
end 

function MOD:CreateDebuffs(frame, unit)
	local aura = CreateFrame("Frame", nil, frame)
	aura.___key = unit
	aura.spacing = 2;
	aura.CreateIcon = CreateAuraIcon;
	aura.PostUpdateIcon = PostUpdateAuraIcon;
	if(BoolFilters[unit]) then
		aura.CustomFilter = CommonAuraFilter;
	else
		aura.CustomFilter = DetailedAuraFilter;
	end
	aura.type = "debuffs"
	aura:SetFrameLevel(10)
	return aura 
end 

function MOD:CreateAuraBarHeader(frame, unit)
	local auraBarParent = CreateFrame("Frame", nil, frame)
	auraBarParent.parent = frame;
	auraBarParent.PostCreateBar = PostCreateAuraBars;
	auraBarParent.gap = 2;
	auraBarParent.spacing = 1;
	auraBarParent.spark = true;
	if(unit == "player") then
		auraBarParent.filter = CommonBarFilter;
	else
		auraBarParent.filter = DetailedBarFilter;
	end
	auraBarParent.PostUpdate = ColorizeAuraBars;
	auraBarParent.barTexture = LSM:Fetch("statusbar", SV.db.UnitFrames.auraBarStatusbar)
	return auraBarParent 
end 
--[[ 
########################################################## 
AURA WATCH
##########################################################
]]--
local PreForcedUpdate = function(self)
	local unit = self.___key;
	if not SV.db.UnitFrames[unit] then return end 
	local db = SV.db.UnitFrames[unit].auraWatch;
	if not db then return end;
	if(unit == "pet" or unit == "raidpet") then
		self.watchFilter = SV.filters.PetBuffWatch
	else
		self.watchFilter = SV.filters.BuffWatch
	end
	self.watchEnabled = db.enable;
	self.watchSize = db.size;
end

function MOD:CreateAuraWatch(frame, unit)
	local watch = CreateFrame("Frame", nil, frame)
	watch:SetFrameLevel(frame:GetFrameLevel() + 25)
	watch:SetAllPoints(frame);
	watch.___key = unit;
	watch.watchEnabled = true;
	watch.presentAlpha = 1;
	watch.missingAlpha = 0;
	if(unit == "pet" or unit == "raidpet") then
		watch.watchFilter = SV.filters.PetBuffWatch
	else
		watch.watchFilter = SV.filters.BuffWatch
	end

	watch.PreForcedUpdate = PreForcedUpdate
	return watch
end