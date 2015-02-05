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
local table     = _G.table;
local string     = _G.string;
local math      = _G.math;
--[[ MATH METHODS ]]--
local floor, abs, min, max = math.floor, math.abs, math.min, math.max;
local parsefloat, ceil = math.parsefloat, math.ceil;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat, tdump = table.remove, table.copy, table.wipe, table.sort, table.concat, table.dump;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local SVUILib = Librarian("Registry");
--[[ 
########################################################## 
LOCALS
##########################################################
]]--
local MAC_DISPLAY;
local BASE_MOD = 0.64;
local SCREEN_MOD = 1;
local DEFAULT_BG_COLOR = {0.18,0.18,0.18,1};
local DEFAULT_BORDER_COLOR = {0,0,0,1};
local LIVE_UPDATE_FRAMES = {};
--[[ 
########################################################## 
LOOKUP TABLE
##########################################################
]]--
SV.API = {};
SV.API.Themes = {};
SV.API.Templates = {
    ["Default"]     = "SVUI_CoreStyle_Default",
    ["Transparent"] = "SVUI_CoreStyle_Transparent",
    ["Button"]      = "SVUI_CoreStyle_Button",
    ["DockButton"]  = "SVUI_CoreStyle_DockButton",
    ["ActionSlot"]  = "SVUI_CoreStyle_ActionSlot",
    ["Lite"]        = "SVUI_CoreStyle_Lite",
    ["Icon"]        = "SVUI_CoreStyle_Icon",
    ["Bar"]         = "SVUI_CoreStyle_Bar",
    ["Checkbox"]    = "SVUI_CoreStyle_Checkbox",
    ["Inset"]       = "SVUI_CoreStyle_Inset",
    ["Blackout"]    = "SVUI_CoreStyle_Blackout",
    ["Component"]   = "SVUI_CoreStyle_Component",
    ["Paper"]       = "SVUI_CoreStyle_Paper",
    ["Container"]   = "SVUI_CoreStyle_Container",
    ["Pattern"]     = "SVUI_CoreStyle_Pattern",
    ["Premium"]     = "SVUI_CoreStyle_Premium",
    ["Model"]       = "SVUI_CoreStyle_Model",
    ["ModelBorder"] = "SVUI_CoreStyle_ModelBorder",
    ["Composite1"]  = "SVUI_CoreStyle_Composite1",
    ["Composite2"]  = "SVUI_CoreStyle_Composite2",
};
SV.API.Methods = {};
--[[ 
########################################################## 
UI SCALING
##########################################################
]]--
local function ScreenUpdate()
    local rez = GetCVar("gxResolution")
    local height = rez:match("%d+x(%d+)")
    local width = rez:match("(%d+)x%d+")
    local gxHeight = tonumber(height)
    local gxWidth = tonumber(width)
    local gxMod = (768 / gxHeight)
    local customScale = false;
    if(IsMacClient()) then
        if(not MAC_DISPLAY) then
            MAC_DISPLAY = SVUILib:NewGlobal("Display");
            if(not MAC_DISPLAY.Y or (MAC_DISPLAY.Y and type(MAC_DISPLAY.Y) ~= "number")) then 
                MAC_DISPLAY.Y = gxHeight;
            end
            if(not MAC_DISPLAY.X or (MAC_DISPLAY.X and type(MAC_DISPLAY.X) ~= "number")) then 
                MAC_DISPLAY.X = gxWidth;
            end
        end
        if(MAC_DISPLAY and MAC_DISPLAY.Y and MAC_DISPLAY.X) then
            if(gxHeight ~= MAC_DISPLAY.Y or gxWidth ~= MAC_DISPLAY.X) then 
                gxHeight = MAC_DISPLAY.Y;
                gxWidth = MAC_DISPLAY.X; 
            end
        end
    end

    local gxScale;
    if(SV.db.screen.advanced) then
        BASE_MOD = 0.64
        local ADJUSTED_SCALE = SV.db.screen.scaleAdjust;
        if(ADJUSTED_SCALE) then
            if(type(ADJUSTED_SCALE) ~= "number") then
                ADJUSTED_SCALE = tonumber(ADJUSTED_SCALE);
            end
            if(ADJUSTED_SCALE and ADJUSTED_SCALE ~= BASE_MOD) then 
                BASE_MOD = ADJUSTED_SCALE;
                customScale = true;
            end
        end

        gxScale = BASE_MOD;
    else
        if(SV.db.screen.autoScale) then
            gxScale = max(0.64, min(1.15, gxMod));
        else
            gxScale = max(0.64, min(1.15, GetCVar("uiScale") or UIParent:GetScale() or gxMod));
        end
    end

    SCREEN_MOD = (gxMod / gxScale);

    return gxWidth, gxHeight, gxScale, customScale
end
--[[ 
########################################################## 
APPENDED POSITIONING METHODS
##########################################################
]]--
local function _scale(value)
    return SCREEN_MOD * floor(value / SCREEN_MOD + .5);
end

local ModSize = function(self, width, height)
    if(type(width) == "number") then
        local h = (height and type(height) == "number") and height or width
        self:SetSize(_scale(width), _scale(h))
    end
end

local ModWidth = function(self, width)
    if(type(width) == "number") then
        self:SetWidth(_scale(width))
    end
end

local ModHeight = function(self, height)
    if(type(height) == "number") then
        self:SetHeight(_scale(height))
    end
end

local WrapPoints = function(self, parent, x, y)
    x = type(x) == "number" and x or 1
    y = y or x
    local nx = _scale(x);
    local ny = _scale(y);
    parent = parent or self:GetParent()
    if self:GetPoint() then 
        self:ClearAllPoints()
    end 
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", -nx, ny)
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", nx, -ny)
end 

local InsetPoints = function(self, parent, x, y)
    x = type(x) == "number" and x or 1
    y = y or x
    local nx = _scale(x);
    local ny = _scale(y);
    parent = parent or self:GetParent()
    if self:GetPoint() then 
        self:ClearAllPoints()
    end 
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", nx, -ny)
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -nx, ny)
end

local ModPoint= function(self, ...)
    for i = 1, select('#', ...) do
        local arg = select(i, ...)
        if(arg and type(arg) == "number") then 
            arg = _scale(arg)
        end 
    end 
    self:SetPoint(...)
end
--[[ 
########################################################## 
APPENDED DESTROY METHODS
##########################################################
]]--
local _purgatory = CreateFrame("Frame", nil)
_purgatory:Hide()

local Die = function(self)
    if(self.UnregisterAllEvents) then 
        self:UnregisterAllEvents()
        self:SetParent(_purgatory)
    else 
        self:Hide()
        self.Show = SV.fubar
    end
end

local RemoveTextures = function(self, option)
    if(self.Panel) then return end
    local region, layer, texture
    for i = 1, self:GetNumRegions()do 
        region = select(i, self:GetRegions())
        if(region and (region:GetObjectType() == "Texture")) then

            layer = region:GetDrawLayer()
            texture = region:GetTexture()

            if(option) then
                if(type(option) == "boolean") then 
                    if region.UnregisterAllEvents then 
                        region:UnregisterAllEvents()
                        region:SetParent(_purgatory)
                    else 
                        region.Show = region.Hide 
                    end 
                    region:Hide()
                elseif(type(option) == "string" and ((layer == option) or (texture ~= option))) then
                    region:SetTexture(0,0,0,0)
                end
            else 
                region:SetTexture(0,0,0,0)
            end
        end 
    end
end 
--[[ 
########################################################## 
SECURE FADING
##########################################################
]]--
local FRAMES_TO_HIDE = {};
local FRAMES_TO_SHOW = {};

local FadeEventManager_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        for frame in pairs(FRAMES_TO_HIDE) do
            frame:Hide()
            if(frame.___forcehidefunc) then
                local _, catch = pcall(frame.___forcehidefunc, frame)
                if(catch) then
                    frame.___forcehidefunc = nil
                end
            end
        end
        wipe(FRAMES_TO_HIDE)
        for frame in pairs(FRAMES_TO_SHOW) do
            frame:Show()
            if(frame.___forceshowfunc) then
                local _, catch = pcall(frame.___forceshowfunc, frame)
                if(catch) then
                    frame.___forceshowfunc = nil
                end
            end
        end
        wipe(FRAMES_TO_SHOW)
    end
end

local FadeEventManager = CreateFrame('Frame')
FadeEventManager:SetScript("OnEvent", FadeEventManager_OnEvent)

local SecureFade_OnUpdate = function(self, elasped)
    local frame = self.owner;
    if(frame) then
        local state = frame.___fadeset;
        state[4] = (state[4] or 0) + elasped;
        if(state[4] < state[3]) then 

            if(frame.___fademode == "IN") then 
                frame:SetAlpha((state[4] / state[3]) * (state[2] - state[1]) + state[1])
            elseif(frame.___fademode == "OUT") then 
                frame:SetAlpha(((state[3] - state[4]) / state[3]) * (state[1] - state[2]) + state[2])
            end 

        else
            state[4] = 0
            frame:SetAlpha(state[2])
            local canfade = (not InCombatLockdown()) or (InCombatLockdown() and (not frame:IsProtected()))
            if(frame.___fadehide) then
                if(canfade) then 
                    frame:Hide()
                    if(frame.___fadefunc) then
                        local _, catch = pcall(frame.___fadefunc, frame)
                        if(not catch) then
                            frame.___fadefunc = nil
                        end
                    end

                    self.Running = false;
                    self:SetScript("OnUpdate", nil);
                else
                    FRAMES_TO_HIDE[frame] = true;
                    FadeEventManager:RegisterEvent("PLAYER_REGEN_ENABLED");
                end
            else
                if(frame.___fadefunc) then
                    local _, catch = pcall(frame.___fadefunc, frame)
                    if(not catch) then
                        frame.___fadefunc = nil
                    end
                end

                self.Running = false;
                self:SetScript("OnUpdate", nil);
            end
        end
    end
end

local SecureFadeIn = function(self, duration, alphaStart, alphaEnd)
    local alpha1 = alphaStart or 0;
    local alpha2 = alphaEnd or 1;
    local timer = duration or 0.1;

    local canfade = (not InCombatLockdown()) or (InCombatLockdown() and (not self:IsProtected()))
    if((not self:IsShown()) and canfade) then
        self:Show() 
    end

    if((not self:IsShown()) and (not canfade)) then
        FRAMES_TO_SHOW[self] = true
    end

    if(self:IsShown() and self:GetAlpha() == alpha2) then return end
    if(not self.___fadehandler) then 
        self.___fadehandler = CreateFrame("Frame", nil)
        self.___fadehandler.owner = self;
    end
    if(not self.___fademode or (self.___fademode and self.___fademode ~= "IN")) then
        if(FRAMES_TO_HIDE[self]) then
            FRAMES_TO_HIDE[self] = nil
        end

        self.___fademode = "IN";
        self.___fadehide = false;
        self.___fadefunc = nil;

        if(not self.___fadeset) then
            self.___fadeset = {};
        end
        self.___fadeset[1] = alpha1;
        self.___fadeset[2] = alpha2;
        self.___fadeset[3] = timer;

        self:SetAlpha(alpha1)
    end
    if(not self.___fadehandler.Running) then
        self.___fadehandler.Running = true;
        self.___fadehandler:SetScript("OnUpdate", SecureFade_OnUpdate)
    end
end 

local SecureFadeOut = function(self, duration, alphaStart, alphaEnd, hideOnFinished)
    local alpha1 = alphaStart or 1;
    local alpha2 = alphaEnd or 0;
    local timer = duration or 0.1;

    if(not self:IsShown() or self:GetAlpha() == alpha2) then return end
    if(not self.___fadehandler) then 
        self.___fadehandler = CreateFrame("Frame", nil)
        self.___fadehandler.owner = self;
    end
    if(not self.___fademode or (self.___fademode and self.___fademode ~= "OUT")) then
        if(FRAMES_TO_SHOW[self]) then
            FRAMES_TO_SHOW[self] = nil
        end

        self.___fademode = "OUT";
        self.___fadehide = hideOnFinished;
        self.___fadefunc = nil;

        if(not self.___fadeset) then
            self.___fadeset = {};
        end

        self.___fadeset[1] = alpha1;
        self.___fadeset[2] = alpha2;
        self.___fadeset[3] = timer;

        self:SetAlpha(alpha1)
    end
    if(not self.___fadehandler.Running) then
        self.___fadehandler.Running = true;
        self.___fadehandler:SetScript("OnUpdate", SecureFade_OnUpdate)
    end
end

local SecureFadeCallback = function(self, callback, onForceHide, onForceShow)
    if(onForceHide) then
        self.___forcehidefunc = callback;
    elseif(onForceShow) then
        self.___forceshowfunc = callback;
    else
        self.___fadefunc = callback;
    end
end
--[[ 
########################################################## 
TEMPLATE INTERNAL HANDLERS
##########################################################
]]--
local HookPanelBorderColor = function(self,r,g,b,a)
    if self.BorderLeft then 
        self.BorderLeft:SetVertexColor(r,g,b,a)
        self.BorderRight:SetVertexColor(r,g,b,a)
        self.BorderTop:SetVertexColor(r,g,b,a)
        self.BorderBottom:SetVertexColor(r,g,b,a) 
    end
    if self.Shadow then
        local alpha = self.Shadow:GetAttribute("shadowAlpha") or 0.5
        self.Shadow:SetBackdropBorderColor(r,g,b,alpha)
    end 
end 

local HookBackdrop = function(self,...)
    if(self.Panel) then
        self.Panel:SetBackdrop(...)
    end
end 

local HookBackdropColor = function(self,...) 
    if(self.Panel) then
        self.Panel:SetBackdropColor(...)
    end
end 

local HookBackdropBorderColor = function(self,...)
    if(self.Panel) then
        self.Panel:SetBackdropBorderColor(...)
    end
end 

local HookVertexColor = function(self,...) 
    if(self.Panel) then
        self.Panel.Skin:SetVertexColor(...)
    end
end 

local HookCustomBackdrop = function(self)
    if(self.Panel) then
        local bgid = self.Panel:GetAttribute("panelID")
        local newBgFile = SV.Media.bg[bgid]
        local newBorderFile = SV.Media.border[bgid]
        if(newBgFile and newBorderFile) then
            local edgeSize = self.Panel:GetAttribute("panelPadding") or 1
            self:SetBackdrop({
                bgFile = newBgFile, 
                edgeFile = newBorderFile, 
                tile = false, 
                tileSize = 0, 
                edgeSize = edgeSize, 
                insets = 
                {
                    left = 0, 
                    right = 0, 
                    top = 0, 
                    bottom = 0, 
                }, 
            })
        end
    end
end

local HookFrameLevel = function(self, level)
    if(self.Panel) then
        local adjustment = level - 1;
        if(adjustment < 0) then adjustment = 0 end
        self.Panel:SetFrameLevel(adjustment)
    end
end

local Cooldown_ForceUpdate = function(self)
    self.nextUpdate = 0;
    self:Show()
end 

local Cooldown_StopTimer = function(self)
    self.enable = nil;
    self:Hide()
end 

local Cooldown_OnUpdate = function(self, elapsed)
    if self.nextUpdate > 0 then 
        self.nextUpdate = self.nextUpdate - elapsed;
        return 
    end
    local now = GetTime();
    local start = self.start;
    local remaining = now - start;
    local expires = (self.duration - (now - start));
    if expires > 0.05 then 
        if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < 0.5 then 
            self.text:SetText('')
            self.nextUpdate = 500 
        else 
            local timeLeft = 0;
            local calc = 0;
            if expires < 4 then
                self.nextUpdate = 0.051
                self.text:SetFormattedText("|cffff0000%.1f|r", expires)
            elseif expires < 60 then 
                self.nextUpdate = 0.51
                self.text:SetFormattedText("|cffffff00%d|r", floor(expires)) 
            elseif expires < 3600 then
                timeLeft = ceil(expires / 60);
                calc = floor((expires / 60) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
                self.text:SetFormattedText("|cffffffff%dm|r", timeLeft)
            elseif expires < 86400 then
                timeLeft = ceil(expires / 3600);
                calc = floor((expires / 3600) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
                self.text:SetFormattedText("|cff66ffff%dh|r", timeLeft)
            else
                timeLeft = ceil(expires / 86400);
                calc = floor((expires / 86400) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 85680);
                if(timeLeft > 7) then
                    self.text:SetFormattedText("|cff6666ff%s|r", "long")
                else
                    self.text:SetFormattedText("|cff6666ff%dd|r", timeLeft)
                end
            end
        end
    else 
        Cooldown_StopTimer(self)
    end 
end

local Cooldown_OnSizeChanged = function(self, width, height)
    local frame = self.timer
    local override = self.SizeOverride
    local newSize = floor(width + .5) / 36;
    override = override or frame:GetParent():GetParent().SizeOverride;
    if override then
        newSize = override / 20 
    end 
    if newSize == frame.fontScale then 
        return 
    end 
    frame.fontScale = newSize;
    if newSize < 0.5 and not override then 
        frame:Hide()
    else 
        frame:Show()
        frame.text:SetFont(SV.Media.font.numbers, newSize * 15, 'OUTLINE')
        if frame.enable then
            Cooldown_ForceUpdate(frame)
        end 
    end
end

local CreateCooldownTimer = function(self)
    local timer = CreateFrame('Frame', nil, self)
    timer:SetAllPoints()
    timer:SetScript('OnUpdate', Cooldown_OnUpdate)

    local timeText = timer:CreateFontString(nil,'OVERLAY')
    timeText:SetPoint('CENTER',1,1)
    timeText:SetJustifyH("CENTER")
    timer.text = timeText;

    timer:Hide()

    self.timer = timer;

    local width, height = self:GetSize()
    Cooldown_OnSizeChanged(self, width, height)
    self:SetScript('OnSizeChanged', Cooldown_OnSizeChanged)
    
    return self.timer 
end

local _hook_Cooldown_SetCooldown = function(self, start, duration, elapsed)
    if start > 0 and duration > 2.5 then 
        local timer = self.timer or CreateCooldownTimer(self)
        timer.start = start;
        timer.duration = duration;
        timer.enable = true;
        timer.nextUpdate = 0;
        
        if timer.fontScale >= 0.5 then 
            timer:Show()
        end 
    else 
        local timer = self.timer;
        if timer then 
            Cooldown_StopTimer(timer)
        end 
    end 
    if self.timer then 
        if elapsed and elapsed > 0 then 
            self.timer:SetAlpha(0)
        else
            self.timer:SetAlpha(0.8)
        end 
    end 
end

local SetFrameBorderColor = function(self, r, g, b, setPrevious, reset)
    if(setPrevious) then
        self.Panel.__previous = setPrevious
    elseif(reset) then
        r,g,b = unpack(SV.Media.color[self.Panel.__previous])
    end
    self.Panel.Shadow:SetBackdropBorderColor(r, g, b)
end

local ShowAlertFlash = function(self)
    self:ColorBorder(1,0.9,0)
    SV.Animate:Flash(self.Panel.Shadow, 0.75, true)
end

local HideAlertFlash = function(self)
    SV.Animate:StopFlash(self.Panel.Shadow)
    self:ColorBorder(1,0.9,0, nil, true)
end
--[[ 
########################################################## 
TEMPLATE HELPERS
##########################################################
]]--
function SV.API:Initialize()
    local active = SV.db.THEME.active;
    local theme;

    if(active and active ~= 'NONE') then
        theme = self.Themes[active]
        if(theme) then
            for templateName, templateFile in pairs(self.Templates) do
                local replacement = theme[templateName]
                if(replacement) then
                    self.Templates[templateName] = replacement
                end
            end
        end
    end
end

function SV.API:FLASH(frame)
    if(frame.Panel.Shadow) then
        frame.Panel.__previous = 'darkest';
        frame.ColorBorder = SetFrameBorderColor
        frame.StartAlert = ShowAlertFlash
        frame.StopAlert = HideAlertFlash
    end
end

function SV.API:CD(button, noSwipe)
    local bn = button:GetName()
    if(bn) then
        local cooldown = _G[bn.."Cooldown"];
        if(cooldown) then
            if(not SV.db.general or (SV.db.general and (not SV.db.general.cooldown))) then return end
            cooldown:ClearAllPoints()
            cooldown:InsetPoints()
            cooldown:SetDrawEdge(false)
            if(not noSwipe) then
                cooldown:SetSwipeColor(0, 0, 0, 1)
            end

            if(not cooldown.HookedCooldown) then
                hooksecurefunc(cooldown, "SetCooldown", _hook_Cooldown_SetCooldown)
                cooldown.HookedCooldown = true
            end
        end
    end
end

function SV.API:APPLY(frame, templateName, underlay, padding, xOffset, yOffset, defaultColor)
    local xmlTemplate = self.Templates[templateName] or self.Templates.Default;

    local borderColor = {0,0,0,1}

    local panel = CreateFrame('Frame', nil, frame, xmlTemplate)

    local level = frame:GetFrameLevel()
    if(level == 0 and not InCombatLockdown()) then
        frame:SetFrameLevel(1)
        level = 1
    end

    local adjustment = level - 1;

    if(adjustment < 0) then adjustment = 0 end

    panel:SetFrameLevel(adjustment)

    hooksecurefunc(frame, "SetFrameLevel", HookFrameLevel)

    if(defaultColor) then
        panel:SetAttribute("panelColor", defaultColor)
    end

    local colorName     = panel:GetAttribute("panelColor")
    local gradientName  = panel:GetAttribute("panelGradient")
    local forcedOffset  = panel:GetAttribute("panelOffset")

    if(forcedOffset) then
        xOffset = xOffset or forcedOffset
        yOffset = yOffset or forcedOffset
    else
        xOffset = xOffset or 0
        yOffset = yOffset or 0
    end

    --panel:WrapPoints(frame, xOffset, yOffset)
    panel:SetPoint("TOPLEFT", frame, "TOPLEFT", -xOffset, yOffset)
    panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", xOffset, -yOffset)

    padding = padding or panel:GetAttribute("panelPadding")
    
    if(padding and panel.BorderLeft) then 
        panel.BorderLeft:SetWidth(padding)
        panel.BorderRight:SetWidth(padding)
        panel.BorderTop:SetHeight(padding)
        panel.BorderBottom:SetHeight(padding)
    end

    if(panel.Shadow) then
        panel.Shadow:SetPoint('TOPLEFT', panel, 'TOPLEFT', -3, 3)
        panel.Shadow:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 3, -3)

        local alpha = panel.Shadow:GetAttribute("shadowAlpha") or 0.5
        panel.Shadow:SetBackdropBorderColor(0,0,0,alpha)

        local level = panel.Shadow:GetFrameLevel() - 1
        if(level >= 0) then 
            panel.Shadow:SetFrameLevel(level)
        else 
            panel.Shadow:SetFrameLevel(0)
        end
    end

    local bgColor = SV.Media.color[colorName] or DEFAULT_BG_COLOR
    local borderColor = DEFAULT_BORDER_COLOR
    if(panel:GetAttribute("panelBorderColor")) then
        local bdrColor = panel:GetAttribute("panelBorderColor")
        borderColor = SV.Media.color[bdrColor] or DEFAULT_BORDER_COLOR
    end

    if(panel:GetBackdrop()) then
        if(underlay) then
            panel:SetBackdropColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4] or 1)
            panel:SetBackdropBorderColor(borderColor[1],borderColor[2],borderColor[3],borderColor[4] or 1)
        else
            local bd = panel:GetBackdrop()
            frame:SetBackdrop(bd)
            frame:SetBackdropColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4] or 1)
            frame:SetBackdropBorderColor(borderColor[1],borderColor[2],borderColor[3],borderColor[4] or 1)

            panel:SetBackdrop(nil)
        end

        if(templateName ~= 'Transparent') then
            hooksecurefunc(panel, "SetBackdropBorderColor", HookPanelBorderColor)
            hooksecurefunc(frame, "SetBackdropBorderColor", HookBackdropBorderColor)
            if(underlay) then
                frame:SetBackdrop(nil)
                frame.SetBackdrop = panel.SetBackdrop
                --hooksecurefunc(frame, "SetBackdrop", HookBackdrop)
                hooksecurefunc(frame, "SetBackdropColor", HookBackdropColor)
            end
            frame.BackdropNeedsUpdate = true
            frame.UpdateBackdrop = HookCustomBackdrop
        end
    end

    if(panel.Skin) then
        panel.Skin:ClearAllPoints()
        panel.Skin:SetAllPoints(panel)
        if(not underlay) then
            panel.Skin:SetParent(frame)
        end
        if(gradientName and SV.Media.gradient[gradientName]) then
            panel.Skin:SetGradient(unpack(SV.Media.gradient[gradientName]))
        else 
            panel.Skin:SetVertexColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 1)
        end

        if((not panel:GetAttribute("panelSkipUpdate")) and panel:GetAttribute("panelTexUpdate")) then
            frame.TextureNeedsUpdate = true
            if(panel:GetAttribute("panelHookVertex")) then
                frame.UpdateColor = HookVertexColor
                frame.NoColorUpdate = true
            end
        end
    end

    local overrideName = panel:GetAttribute("panelKeyOverride")
    if(overrideName) then
        frame[overrideName] = panel;
    end

    frame.Panel = panel;
end
--[[ 
########################################################## 
UI ELEMENT METHODS
##########################################################
]]--
SV.API.Methods["Button"] = function(self, frame, inverse, alteration, overridePadding, xOffset, yOffset, keepNormal, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end

    local padding = 1
    if(overridePadding and type(overridePadding) == "number") then
        padding = overridePadding
    end

    local x,y = -1,-1
    if(xOffset or yOffset) then
        x = xOffset or -1
        y = yOffset or -1
        inverse = true
    end

    if(alteration and (type(alteration) == 'boolean')) then
        self:APPLY(frame, "Lite", inverse, padding, x, y, defaultColor)
        frame:SetBackdropColor(0,0,0,0)
        frame:SetBackdropBorderColor(0,0,0,0)
        
        if(frame.Panel.BorderLeft) then 
            frame.Panel.BorderLeft:SetVertexColor(0,0,0,0)
            frame.Panel.BorderRight:SetVertexColor(0,0,0,0)
            frame.Panel.BorderTop:SetVertexColor(0,0,0,0)
            frame.Panel.BorderBottom:SetVertexColor(0,0,0,0)
        end
    elseif(alteration and (type(alteration) == 'string')) then
        self:APPLY(frame, alteration, inverse, padding, x, y, defaultColor)
    else
        self:APPLY(frame, "Button", inverse, padding, x, y, defaultColor)
    end

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

    if(frame.SetPushedTexture) then
        if(not frame.pushed) then 
            local pushed = frame:CreateTexture(nil, "OVERLAY")
            pushed:InsetPoints(frame.Panel)
            frame.pushed = pushed;
        end
        frame.pushed:SetTexture(0.1, 0.8, 0.1, 0.3)
        frame:SetPushedTexture(frame.pushed)
    end

    if(frame.SetCheckedTexture) then
        if(not frame.checked) then
            local checked = frame:CreateTexture(nil, "OVERLAY")
            checked:InsetPoints(frame.Panel)
            frame.checked = checked
        end
        frame.checked:SetTexture(SV.BaseTexture)
        frame.checked:SetVertexColor(0, 0.5, 0, 0.2)
        frame:SetCheckedTexture(frame.checked)
    end

    self:CD(frame)
end;

SV.API.Methods["ActionSlot"] = function(self, frame, inverse, addChecked)
    if(not frame or (frame and frame.Panel)) then return end

    local underlay = (not inverse)
    self:APPLY(frame, "ActionSlot", underlay)

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

    if(frame.SetPushedTexture) then
        if(not frame.pushed) then 
            local pushed = frame:CreateTexture(nil, "OVERLAY")
            pushed:InsetPoints(frame.Panel)
            frame.pushed = pushed;
        end
        frame.pushed:SetTexture(0.1, 0.8, 0.1, 0.3)
        frame:SetPushedTexture(frame.pushed)
    end

    if(frame.SetCheckedTexture and addChecked) then
        if(not frame.checked) then
            local checked = frame:CreateTexture(nil, "OVERLAY")
            checked:InsetPoints(frame.Panel)
            frame.checked = checked
        end
        frame.checked:SetTexture(SV.BaseTexture)
        frame.checked:SetVertexColor(0, 0.5, 0, 0.2)
        frame:SetCheckedTexture(frame.checked)
    end

    self:CD(frame, true)
end;

SV.API.Methods["Checkbox"] = function(self, frame, inverse, x, y)
    if(not frame or (frame and frame.Panel)) then return end

    local width, height = frame:GetSize()
    x = x or -2
    y = y or -2

    width = width + (x or 0)
    height = height + (y or 0)

    frame:SetSize(width, height)

    local underlay = (not inverse)
    self:APPLY(frame, "Checkbox", underlay, 1, x, y)

    if(frame.SetNormalTexture) then 
        frame:SetNormalTexture("")
    end  

    if(frame.SetPushedTexture) then
        frame:SetPushedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "OVERLAY")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        local color = SV.Media.color.highlight
        frame.hover:SetTexture(color[1], color[2], color[3], 0.5)
        frame:SetHighlightTexture(frame.hover)  
    end

    if(frame.SetCheckedTexture) then
        frame:SetCheckedTexture([[Interface\AddOns\SVUI_!Core\assets\textures\CHECK]])
        local ct = frame:GetCheckedTexture()
        ct:SetTexCoord(0, 1, 0, 1)
    end

    if(frame.SetDisabledCheckedTexture) then
        frame:SetDisabledCheckedTexture([[Interface\AddOns\SVUI_!Core\assets\textures\CHECK-DISABLED]])
        local ct = frame:GetDisabledCheckedTexture()
        ct:SetTexCoord(0, 1, 0, 1)
    end
end;

SV.API.Methods["Editbox"] = function(self, frame, inverse, x, y)
    if(not frame or (frame and frame.Panel)) then return end

    if frame.TopLeftTex then frame.TopLeftTex:Die() end 
    if frame.TopRightTex then frame.TopRightTex:Die() end 
    if frame.TopTex then frame.TopTex:Die() end 
    if frame.BottomLeftTex then frame.BottomLeftTex:Die() end 
    if frame.BottomRightTex then frame.BottomRightTex:Die() end 
    if frame.BottomTex then frame.BottomTex:Die() end 
    if frame.LeftTex then frame.LeftTex:Die() end 
    if frame.RightTex then frame.RightTex:Die() end 
    if frame.MiddleTex then frame.MiddleTex:Die() end
    if frame.Left then frame.Left:Die() end 
    if frame.Right then frame.Right:Die() end 
    if frame.Middle then frame.Middle:Die() end

    local underlay = (not inverse)
    self:APPLY(frame, "Inset", underlay, 1, x, y)

    local globalName = frame:GetName();
    if globalName then 
        if _G[globalName.."Left"] then _G[globalName.."Left"]:Die() end 
        if _G[globalName.."Middle"] then _G[globalName.."Middle"]:Die() end 
        if _G[globalName.."Right"] then _G[globalName.."Right"]:Die() end 
        if _G[globalName.."Mid"] then _G[globalName.."Mid"]:Die() end

        if globalName:find("Silver") or globalName:find("Copper") or globalName:find("Gold") then
            frame.Panel:SetPoint("TOPLEFT", -3, 1)
            if globalName:find("Silver") or globalName:find("Copper") then
                frame.Panel:SetPoint("BOTTOMRIGHT", -12, -2)
            else
                frame.Panel:SetPoint("BOTTOMRIGHT", -2, -2) 
            end 
        end 
    end
end;
--[[ 
########################################################## 
CUSTOM TEMPLATING METHODS
##########################################################
]]--
SV.API.Methods["Icon"] = function(self, frame, inverse, ...)
    if(not frame or (frame and frame.Panel)) then return end
    local underlay = (not inverse)
    self:APPLY(frame, "Icon", underlay, ...)
end;

SV.API.Methods["DockButton"] = function(self, frame, inverse)
    if(not frame or (frame and frame.Panel)) then return end

    self:APPLY(frame, "DockButton", inverse)
    self:FLASH(frame)

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

    if(not frame.Panel:GetAttribute("panelSkipUpdate")) then
        frame.Panel.___Live = true
    end
end;

SV.API.Methods["Frame"] = function(self, frame, inverse, styleName, noupdate, overridePadding, xOffset, yOffset, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end
    local padding = false;
    if(overridePadding and type(overridePadding) == "number") then
        padding = overridePadding
    end
    styleName = styleName or "Default";
    local underlay = (not inverse)
    self:APPLY(frame, styleName, underlay, padding, xOffset, yOffset, defaultColor)
    if(noupdate) then
        frame.Panel:SetAttribute("panelSkipUpdate", true)
    end
    if((not noupdate) and (not frame.Panel:GetAttribute("panelSkipUpdate"))) then
        frame.Panel.___Live = true
    end
end;
--[[ 
########################################################## 
TEMPLATE API
##########################################################
]]--
local SetPanelColor = function(self, ...)
    local arg1,arg2,arg3,arg4,arg5,arg6,arg7 = select(1, ...)
    if(not self.Panel or not arg1) then return; end 
    if(self.Panel.Skin and self.Panel:GetAttribute("panelGradient")) then
        if(type(arg1) == "string") then
            if(arg1 == "VERTICAL" or arg1 == "HORIZONTAL") then
                self.Panel.Skin:SetGradient(...)
            elseif(SV.Media.gradient[arg1]) then
                self.Panel.Skin:SetGradient(unpack(SV.Media.gradient[arg1]))
                if(SV.Media.color[arg1]) then
                    local t = SV.Media.color[arg1]
                    local r,g,b,a = t[1], t[2], t[3], t[4] or 1;
                    self:SetBackdropColor(r,g,b,a)
                end
            end 
        end 
    elseif(type(arg1) == "string" and SV.Media.color[arg1]) then
        local t = SV.Media.color[arg1]
        local r,g,b,a = t[1], t[2], t[3], t[4] or 1;
        self:SetBackdropColor(r,g,b)
    elseif(arg1 and type(arg1) == "number") then
        self:SetBackdropColor(...)
    end 
end

local SetStyle = function(self, method, ...)
    if(not self or (self and self.Panel)) then return end
    method = method or "Frame";
    local methodName, flags = method:gsub("!_", "");
    local inverse = (flags and flags > 0) and true or false;
    local fn = SV.API.Methods[methodName];
    if(fn) then
        local pass, catch = pcall(fn, SV.API, self, inverse, ...)
        if(catch) then
            SV:HandleError("API", "SetStyle", catch);
            return
        elseif(self.Panel and self.Panel.___Live) then
            LIVE_UPDATE_FRAMES[self] = true;
            self.Panel.___Live = nil;
        end
    end
end
--[[ 
########################################################## 
HOOKED ATLAS HIJACKER
##########################################################
]]--
local ATLAS_THIEF = {} -- Wasn't this the name of a movie?
local ATLAS_HACKS = {} -- Couldn't think of anything clever honestly.
ATLAS_HACKS["default"] = function(self)
  self:SetTexture("")
end

local StealAtlas = function(self, atlas)
    if(not self or not atlas) then return end
    local hack = ATLAS_THIEF[atlas];
    if(hack) then
        local fn = ATLAS_HACKS[hack] or ATLAS_HACKS["default"]
        local pass, catch = pcall(fn, self, atlas)
        if(catch) then
            SV:HandleError("API", "SetStyle", catch);
            return
        end
    end
end
--[[ 
########################################################## 
UPDATE CALLBACKS
##########################################################
]]--
local function FrameTemplateUpdates()
    for frame in pairs(LIVE_UPDATE_FRAMES) do
        if(frame) then
            local panelID = frame.Panel:GetAttribute("panelID")
            local colorID = frame.Panel:GetAttribute("panelColor")
            local panelColor = SV.Media.color[colorID];
            if(frame.BackdropNeedsUpdate) then
                if(frame.UpdateBackdrop) then
                    frame:UpdateBackdrop()
                end
                if(panelColor) then
                    frame:SetBackdropColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
                end
                if(frame.Panel:GetAttribute("panelBorderColor")) then
                    local bdrColor = frame.Panel:GetAttribute("panelBorderColor")
                    local borderColor = SV.Media.color[bdrColor] or DEFAULT_BORDER_COLOR
                    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
                else
                    frame:SetBackdropBorderColor(0,0,0,1)
                end
            end
            if(frame.TextureNeedsUpdate and frame.Panel.Skin) then
                local tex = SV.Media.bg[panelID]
                if(tex) then
                    frame.Panel.Skin:SetTexture(tex)
                end 
                if(not frame.NoColorUpdate) then
                    local gradient = frame.Panel:GetAttribute("panelGradient")
                    if(gradient and SV.Media.gradient[gradient]) then
                        local g = SV.Media.gradient[gradient]
                        frame.Panel.Skin:SetGradient(g[1], g[2], g[3], g[4], g[5], g[6], g[7])
                    elseif(panelColor) then
                        frame.Panel.Skin:SetVertexColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
                    end
                end
            end
        end
    end
end

SV.Events:On("MEDIA_COLORS_UPDATED", "FrameTemplateUpdates", FrameTemplateUpdates);
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function SV:SetAtlasFunc(atlas, fn)
    ATLAS_HACKS[atlas] = fn
end

function SV:SetAtlasFilter(atlas, fn)
    if(not fn) then
        fn = "default"
    end
    ATLAS_THIEF[atlas] = fn
end

function SV:UI_SCALE_CHANGED(event)
    local gxWidth, gxHeight, gxScale, customScale = ScreenUpdate();
    local needCalc = true;
    if(self.db.screen.advanced) then
        if(self.db.screen.forcedWidth ~= gxWidth) then
            gxWidth = self.db.screen.forcedWidth
            needCalc = false;
        end
        if(self.db.screen.forcedHeight ~= gxHeight) then
            gxHeight = self.db.screen.forcedHeight
            needCalc = false;
        end
    end
    if(needCalc) then
        if(gxWidth < 1600) then
            self.LowRez = true;
        elseif(gxWidth >= 3840) then
            self.LowRez = nil
            local evalwidth;
            if(self.db.screen.multiMonitor) then
                if(gxWidth < 4080) then 
                    evalwidth = 1224;
                elseif(gxWidth < 4320) then 
                    evalwidth = 1360;
                elseif(gxWidth < 4680) then 
                    evalwidth = 1400;
                elseif(gxWidth < 4800) then 
                    evalwidth = 1440;
                elseif(gxWidth < 5760) then 
                    if(gxHeight == 900) then evalwidth = 1600 else evalwidth = 1680 end 
                elseif(gxWidth < 7680) then 
                    evalwidth = 1920;
                elseif(gxWidth < 9840) then 
                    evalwidth = 2560;
                elseif(gxWidth > 9839) then 
                    evalwidth = 3280; 
                end
            else
                if(gxWidth < 4080) then 
                    evalwidth = 3840;
                elseif(gxWidth < 4320) then 
                    evalwidth = 4080;
                elseif(gxWidth < 4680) then 
                    evalwidth = 4320;
                elseif(gxWidth < 4800) then 
                    evalwidth = 4680;
                elseif(gxWidth < 5040) then 
                    evalwidth = 4800; 
                elseif(gxWidth < 5760) then 
                    evalwidth = 5040; 
                elseif(gxWidth < 7680) then 
                    evalwidth = 5760;
                elseif(gxWidth < 9840) then 
                    evalwidth = 7680;
                elseif(gxWidth > 9839) then 
                    evalwidth = 9840; 
                end
            end

            gxWidth = evalwidth;
        end
    end

    if(event == 'PLAYER_LOGIN' or event == 'UI_SCALE_CHANGED') then
        local testScale1 = parsefloat(UIParent:GetScale(), 5)
        local testScale2 = parsefloat(gxScale, 5)
        local ignoreChange = false;

        if(event == "PLAYER_LOGIN" and (testScale1 ~= testScale2)) then 
            SetCVar("useUiScale", 1)
            SetCVar("uiScale", gxScale)
            WorldMapFrame.hasTaint = true;
            ignoreChange = true;
        end

        self.Screen:ClearAllPoints()
        self.Screen:SetPoint("CENTER")

        if gxWidth then
            local width = gxWidth
            local height = gxHeight;
            if(not self.db.screen.autoScale or height > 1200) then
                height = UIParent:GetHeight();
                local ratio = gxHeight / height;
                width = gxWidth / ratio;
            end
            self.Screen:SetSize(width, height);
        else
            self.Screen:SetSize(UIParent:GetSize());
        end

        if((not customScale) and (not ignoreChange) and (event == 'UI_SCALE_CHANGED')) then
            local change = abs((testScale1 * 100) - (testScale2 * 100))
            if(change > 1) then
                if(self.db.screen.autoScale) then
                    self:StaticPopup_Show('FAILED_UISCALE')
                else
                    self:StaticPopup_Show('RL_CLIENT')
                end
            end
        end
    end
end
--[[ 
########################################################## 
API INJECTION
##########################################################
]]--
local MODIFIED_OBJECTS = {};
local CURRENT_OBJECT = CreateFrame("Frame");

local function AppendFrameMethods(OBJECT)
    local objType = OBJECT:GetObjectType()
    if(not MODIFIED_OBJECTS[objType]) then
        local META = getmetatable(OBJECT).__index
        if not OBJECT.SetStyle then META.SetStyle = SetStyle end
        if not OBJECT.SetPanelColor then META.SetPanelColor = SetPanelColor end
        if not OBJECT.ModSize then META.ModSize = ModSize end
        if not OBJECT.ModWidth then META.ModWidth = ModWidth end
        if not OBJECT.ModHeight then META.ModHeight = ModHeight end
        if not OBJECT.ModPoint then META.ModPoint = ModPoint end
        if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
        if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
        if not OBJECT.Die then META.Die = Die end
        if not OBJECT.RemoveTextures then META.RemoveTextures = RemoveTextures end
        if not OBJECT.FadeIn then META.FadeIn = SecureFadeIn end
        if not OBJECT.FadeOut then META.FadeOut = SecureFadeOut end
        if not OBJECT.FadeCallback then META.FadeCallback = SecureFadeCallback end

        MODIFIED_OBJECTS[objType] = true
    end
end

local function AppendTextureMethods(OBJECT)
    local META = getmetatable(OBJECT).__index
    if not OBJECT.ModSize then META.ModSize = ModSize end
    if not OBJECT.ModWidth then META.ModWidth = ModWidth end
    if not OBJECT.ModHeight then META.ModHeight = ModHeight end
    if not OBJECT.ModPoint then META.ModPoint = ModPoint end
    if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
    if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
    if not OBJECT.Die then META.Die = Die end
    if(OBJECT.SetAtlas) then
        hooksecurefunc(META, "SetAtlas", StealAtlas)
    end
end

local function AppendFontStringMethods(OBJECT)
    local META = getmetatable(OBJECT).__index
    if not OBJECT.ModSize then META.ModSize = ModSize end
    if not OBJECT.ModWidth then META.ModWidth = ModWidth end
    if not OBJECT.ModHeight then META.ModHeight = ModHeight end
    if not OBJECT.ModPoint then META.ModPoint = ModPoint end
    if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
    if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
end

AppendFrameMethods(CURRENT_OBJECT)
AppendTextureMethods(CURRENT_OBJECT:CreateTexture())
AppendFontStringMethods(CURRENT_OBJECT:CreateFontString())

CURRENT_OBJECT = EnumerateFrames()
while CURRENT_OBJECT do
    AppendFrameMethods(CURRENT_OBJECT)
    CURRENT_OBJECT = EnumerateFrames(CURRENT_OBJECT)
end