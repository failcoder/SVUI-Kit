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
local table         = _G.table;
local string        = _G.string;
local math          = _G.math;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--[[ STRING METHODS ]]--
local match, format = string.match, string.format;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local floor, modf = math.floor, math.modf;

local iLevelFilter = ITEM_LEVEL:gsub( "%%d", "(%%d+)" )
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
--[[ 
########################################################## 
FRAME VISIBILITY MANAGEMENT
##########################################################
]]--
do
    local FRAMELIST = {};

    function SV:ManageVisibility(frame)
        if(not frame) then return end
        if(frame.GetParent) then
            FRAMELIST[frame] = frame:GetParent()
        end 
    end 

    function SV:AuditVisibility(hidden)
        if(hidden) then
          self.NeedsFrameAudit = true 
          if(InCombatLockdown()) then return end 
          for frame, _ in pairs(FRAMELIST)do 
              frame:SetParent(self.Hidden) 
          end
        else
          if(InCombatLockdown()) then return end
          for frame, parent in pairs(FRAMELIST) do
              frame:SetParent(parent or UIParent) 
          end
          self.NeedsFrameAudit = false
        end
    end
end
--[[ 
########################################################## 
MISC UTILITY FUNCTIONS
##########################################################
]]--
local RefClassRoles, RefUnitRoles;
local PlayerClass = select(2,UnitClass("player"));
local PlayerName = UnitName("player");

if(PlayerClass == "PRIEST") then
    RefClassRoles = {"C", "C", "C"}
    RefUnitRoles = {"HEALER", "HEALER", "DAMAGER"}
elseif(PlayerClass == "WARLOCK") then
    RefClassRoles = {"C", "C", "C"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "DAMAGER"}
elseif(PlayerClass == "WARRIOR") then
    RefClassRoles = {"M", "M", "T"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "TANK"}
elseif(PlayerClass == "HUNTER") then
    RefClassRoles = {"M", "M", "M"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "DAMAGER"}
elseif(PlayerClass == "ROGUE") then
    RefClassRoles = {"M", "M", "M"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "DAMAGER"}
elseif(PlayerClass == "MAGE") then
    RefClassRoles = {"C", "C", "C"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "DAMAGER"}
elseif(PlayerClass == "DEATHKNIGHT") then
    RefClassRoles = {"T", "M", "M"}
    RefUnitRoles = {"TANK", "DAMAGER", "DAMAGER"}
elseif(PlayerClass == "DRUID") then
    RefClassRoles = {"C", "M", "T", "C"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "TANK", "HEALER"}
elseif(PlayerClass == "SHAMAN") then
    RefClassRoles = {"C", "M", "C"}
    RefUnitRoles = {"DAMAGER", "DAMAGER", "HEALER"}
elseif(PlayerClass == "MONK") then
    RefClassRoles = {"T", "C", "M"}
    RefUnitRoles = {"TANK", "HEALER", "DAMAGER"}
elseif(PlayerClass == "PALADIN") then
    RefClassRoles = {"C", "T", "M"}
    RefUnitRoles = {"HEALER", "TANK", "DAMAGER"}
end

function SV:DisbandRaidGroup()
    if InCombatLockdown() then return end
    if UnitInRaid("player") then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if(online and (name ~= PlayerName)) then
                UninviteUnit(name)
            end
        end
    else
        for i = MAX_PARTY_MEMBERS, 1, -1 do
            if UnitExists("party"..i) then
                UninviteUnit(UnitName("party"..i))
            end
        end
    end
    LeaveParty()
end

function SV:PlayerInfoUpdate()
    local spec = GetSpecialization()
    local role, unitRole;
    if spec then
        if(self.CurrentSpec == spec) then return end
        role = RefClassRoles[spec]
        unitRole = RefUnitRoles[spec]
        if role == "T" and UnitLevel("player") == MAX_PLAYER_LEVEL then
            local bonus, pvp = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN), false;
            if bonus > GetDodgeChance() and bonus > GetParryChance() then 
                role = "M"
            end 
        end
        self.CurrentSpec = spec
        self.RoleIsSet = true
    else
        local intellect = select(2, UnitStat("player", 4))
        local agility = select(2, UnitStat("player", 2))
        local baseAP, posAP, negAP = UnitAttackPower("player")
        local totalAP = baseAP  +  posAP  +  negAP;
        if totalAP > intellect or agility > intellect then 
            role = "M"
        else 
            role = "C"
        end 
    end
    if self.UnitRole ~= unitRole then 
        self.UnitRole = unitRole
    end  
    if self.ClassRole ~= role then 
        self.ClassRole = role;
        if self.RoleChangedCallback then
            self.RoleChangedCallback()
        end
    end

    self:GearSwap()
end  
--[[ 
########################################################## 
POSITIONING UTILITY FUNCTIONS
##########################################################
]]--
SV.PointIndexes = {
    ["TOP"] = "TOP",
    ["BOTTOM"] = "BOTTOM",
    ["LEFT"] = "LEFT",
    ["RIGHT"] = "RIGHT",
    ["TOPRIGHT"] = "UP AND RIGHT",
    ["TOPLEFT"] = "UP AND LEFT",
    ["BOTTOMRIGHT"] = "DOWN AND RIGHT",
    ["BOTTOMLEFT"] = "DOWN AND LEFT",
    ["CENTER"] = "CENTER",
    ["RIGHTTOP"] = "RIGHT AND UP",
    ["LEFTTOP"] = "LEFT AND UP",
    ["RIGHTBOTTOM"] = "RIGHT AND DOWN",
    ["LEFTBOTTOM"] = "LEFT AND DOWN",
    ["INNERRIGHT"] = "INNER RIGHT",
    ["INNERLEFT"] = "INNER LEFT",
    ["INNERTOPRIGHT"] = "INNER TOP RIGHT",
    ["INNERTOPLEFT"] = "INNER TOP LEFT",
    ["INNERBOTTOMRIGHT"] = "INNER BOTTOM RIGHT",
    ["INNERBOTTOMLEFT"] = "INNER BOTTOM LEFT",
}

do
    local _inverted = {
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOPRIGHT = "BOTTOMRIGHT",
        TOPLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "TOPLEFT",
        CENTER = "CENTER",
        RIGHTTOP = "TOPLEFT",
        LEFTTOP = "TOPRIGHT",
        RIGHTBOTTOM = "BOTTOMLEFT",
        LEFTBOTTOM = "BOTTOMRIGHT",
        INNERRIGHT = "RIGHT",
        INNERLEFT = "LEFT",
        INNERTOPRIGHT = "TOPRIGHT",
        INNERTOPLEFT = "TOPLEFT",
        INNERBOTTOMRIGHT = "BOTTOMRIGHT",
        INNERBOTTOMLEFT = "BOTTOMLEFT",
    }
    setmetatable(_inverted, { __index = function(t, k)
        return "CENTER"
    end})

    local _translated = {
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT",
        TOPRIGHT = "TOPRIGHT",
        TOPLEFT = "TOPLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        CENTER = "CENTER",
        RIGHTTOP = "TOPRIGHT",
        LEFTTOP = "TOPLEFT",
        RIGHTBOTTOM = "BOTTOMRIGHT",
        LEFTBOTTOM = "BOTTOMLEFT",
        INNERRIGHT = "RIGHT",
        INNERLEFT = "LEFT",
        INNERTOPRIGHT = "TOPRIGHT",
        INNERTOPLEFT = "TOPLEFT",
        INNERBOTTOMRIGHT = "BOTTOMRIGHT",
        INNERBOTTOMLEFT = "BOTTOMLEFT",
    }
    setmetatable(_translated, { __index = function(t, k)
        return "CENTER"
    end})

    function SV:GetReversePoint(point)
        return _inverted[point];
    end

    function SV:SetReversePoint(frame, point, target, x, y)
        if((not frame) or (not point)) then return; end
        target = target or frame:GetParent()
        if(not target) then print(frame:GetName()) return; end
        local anchor = _inverted[point];
        local relative = _translated[point];
        x = x or 0;
        y = y or 0;
        frame:SetPoint(anchor, target, relative, x, y)
        --[[ auto-set specific properties to save on logic ]]--
        frame.initialAnchor = anchor;
    end
end

function SV:GetScreenXY(frame)
    local screenHeight = GetScreenHeight();
    local screenWidth = GetScreenWidth();
    local screenX, screenY = frame:GetCenter();
    local isLeft = (screenX < (screenHeight * 0.5));
    if (screenY < (screenWidth * 0.5)) then
        if(isLeft) then
            return "BOTTOMLEFT", "TOPLEFT"
        else
            return "BOTTOMRIGHT", "TOPRIGHT"
        end
    else
        if(isLeft) then
            return "TOPLEFT", "BOTTOMLEFT"
        else
            return "TOPRIGHT", "BOTTOMRIGHT"
        end
    end
end

function SV:AnchorToCursor(frame)
    local x, y = GetCursorPosition()
    local vHold = (UIParent:GetHeight() * 0.33)
    local scale = self.Screen:GetEffectiveScale()
    local initialAnchor = "CENTER"
    local mod = 0

    if(y > (vHold * 2)) then
        initialAnchor = "TOPLEFT"
        mod = -12
    elseif(y < vHold) then
        initialAnchor = "BOTTOMLEFT"
        mod = 12
    end

    frame:ClearAllPoints()
    frame:SetPoint(initialAnchor, self.Screen, "BOTTOMLEFT", (x  /  scale), (y  /  scale) + mod)
end
--[[ 
########################################################## 
ITEM UTILITY FUNCTIONS
##########################################################
]]--
do
    local _failsafe = {0}

    local _upgrades = {
        [  1] = {8, 1, 1},  [373] = {4, 1, 2},  [374] = {8, 2, 2},  [375] = {4, 1, 3}, [376] = {4, 2, 3}, 
        [377] = {4, 3, 3},  [378] = {7, 0, 0},  [379] = {4, 1, 2},  [380] = {4, 2, 2}, [445] = {0, 0, 2}, 
        [446] = {4, 1, 2},  [447] = {8, 2, 2},  [451] = {0, 0, 1},  [452] = {8, 1, 1}, [453] = {0, 0, 2}, 
        [454] = {4, 1, 2},  [455] = {8, 2, 2},  [456] = {0, 0, 1},  [457] = {8, 1, 1}, [458] = {0, 0, 4}, 
        [459] = {4, 1, 4},  [460] = {8, 2, 4},  [461] = {12, 3, 4}, [462] = {16, 4, 4}, 
        [465] = {0, 0, 2},  [466] = {4, 1, 2},  [467] = {8, 2, 2},  [468] = {0, 0, 4}, 
        [469] = {4, 1, 4},  [470] = {8, 2, 4},  [471] = {12, 3, 4}, [472] = {16, 4, 4}, 
        [491] = {0, 0, 4},  [492] = {4, 1, 4},  [493] = {8, 2, 4},  [494] = {0, 0, 6}, 
        [495] = {4, 1, 6},  [496] = {8, 2, 6},  [497] = {12, 3, 6}, [498] = {16, 4, 6}, 
        [504] = {12, 3, 4}, [505] = {16, 4, 4}, [506] = {20, 5, 6}, [507] = {24, 6, 6}
    }

    local _heirlooms = {
        44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,50255,44103,
        44107,44095,44098,44097,44105,42951,48683,48685,42949,48687,42984,44100,
        44101,44092,48718,44091,42952,48689,44099,42991,42985,48691,44094,44093,
        42945,48716
    }

    -- DEPRECATED
    -- local _heirloom_regex = "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?";

    local _slots = {
        ["HeadSlot"] = {true, true},            ["NeckSlot"] = {true, false}, 
        ["ShoulderSlot"] = {true, true},        ["BackSlot"] = {true, false}, 
        ["ChestSlot"] = {true, true},           ["WristSlot"] = {true, true}, 
        ["MainHandSlot"] = {true, true, true},  ["SecondaryHandSlot"] = {true, true}, 
        ["HandsSlot"] = {true, true, true},     ["WaistSlot"] = {true, true, true}, 
        ["LegsSlot"] = {true, true, true},      ["FeetSlot"] = {true, true, true}, 
        ["Finger0Slot"] = {true, false, true},  ["Finger1Slot"] = {true, false, true}, 
        ["Trinket0Slot"] = {true, false, true}, ["Trinket1Slot"] = {true, false, true}
    }

    setmetatable(_upgrades, { __index = function(t, k)
        return _failsafe
    end})

    local function _justthetip()
        for i=1, #GameTooltip.shoppingTooltips do
            if(not GameTooltip.shoppingTooltips[i]:IsShown()) then
                return GameTooltip.shoppingTooltips[i]
            end
        end
    end

    local function _getHeirloomLevel(unit, itemID)
        if(not itemID) then return; end
        local baseLevel = UnitLevel(unit)
        if baseLevel > 85 then baseLevel = 85 end 
        if baseLevel > 80 then
            for i=1, #_heirlooms do 
                if(_heirlooms[i] == itemID) then 
                    baseLevel = 80;
                end
            end
            if baseLevel > 80 then 
                return (((baseLevel - 81) * 12.2) + 272)
            end
        elseif baseLevel > 67 then 
            return (((baseLevel - 68) * 6) + 130) 
        elseif baseLevel > 59 then 
            return (((baseLevel - 60) * 3) + 85) 
        end
        return baseLevel
    end

    local function _getItemInfo(itemString)
        local itemId = tonumber(itemString:match("item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+:%d+:%d+:(%d+)"))
        if itemId then
            local lvl = _upgrades[itemId][1]
            local cur = _upgrades[itemId][2]
            local max = _upgrades[itemId][3]
            return cur, max, lvl
        end
        return nil
    end

    local function _getItemLevel(unit, itemString)
        local name, link, quality, iLevel = GetItemInfo(itemString)
        local itemId = tonumber(itemString:match("item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+:%d+:%d+:(%d+)"))
        if iLevel and itemId then
            if(quality == 7) then 
                iLevel = _getHeirloomLevel(unit, itemId)
            else
                iLevel = iLevel + _upgrades[itemId][1]
            end
        end
        return iLevel
    end

    local function _scanItemLevel(unit, itemString)
        local tooltip = _justthetip();
        if(not tooltip) then return _getItemLevel(unit, itemString) end
        tooltip:SetOwner(UIParent, "ANCHOR_NONE");
        tooltip:SetHyperlink(itemString);
        tooltip:Show();

        local iLevel = 0;
        local tname = tooltip:GetName().."TextLeft%s";
        for i = 2, tooltip:NumLines() do
            local text = _G[tname:format(i)]:GetText();
            if(text and text ~= "") then
                local value = tonumber(text:match(iLevelFilter));
                if(value) then
                    iLevel = value;
                end
            end
        end
      
        tooltip:Hide();
        return iLevel
    end

    function SV:ParseGearSlots(unit, inspecting, firstCallback, secondCallback)
        local category = (inspecting) and "Inspect" or "Character";
        local averageLevel,totalSlots,upgradeAdjust = 0,0,0;
        for slotName, flags in pairs(_slots) do
            local globalName = ("%s%s"):format(category, slotName)
            local slotId = GetInventorySlotInfo(slotName)
            local iLink = GetInventoryItemLink(unit, slotId)
            if(iLink and type(iLink) == "string") then 
                local iLevel = _scanItemLevel(unit, iLink)
                if(iLevel and iLevel > 0) then
                    totalSlots = totalSlots + 1;
                    averageLevel = averageLevel + iLevel
                    if(flags[1] and firstCallback and type(firstCallback) == "function") then
                        firstCallback(globalName, iLevel)
                    end
                end
            end
            if(slotId ~= nil) then
                if((not inspecting) and flags[2] and secondCallback and type(secondCallback) == "function") then
                    secondCallback(globalName, slotId)
                end
            end
        end 
        if(averageLevel < 1 or totalSlots < 15) then 
            return 
        end 
        return floor(averageLevel / totalSlots)
    end
end 
--[[ 
########################################################## 
TIME UTILITIES
##########################################################
]]--
local SECONDS_PER_HOUR = 60 * 60
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR

function SV:ParseSeconds(seconds)
    local negative = ""

    if not seconds then
        seconds = 0
    end

    if seconds < 0 then
        negative = "-"
        seconds = -seconds
    end
    local L_DAY_ONELETTER_ABBR = _G.DAY_ONELETTER_ABBR:gsub("%s*%%d%s*", "")

    if not seconds or seconds >= SECONDS_PER_DAY * 36500 then -- 100 years
        return ("%s**%s **:**"):format(negative, L_DAY_ONELETTER_ABBR)
    elseif seconds >= SECONDS_PER_DAY then
        return ("%s%d%s %d:%02d"):format(negative, seconds / SECONDS_PER_DAY, L_DAY_ONELETTER_ABBR, math.fmod(seconds / SECONDS_PER_HOUR, 24), math.fmod(seconds / 60, 60))
    else
        return ("%s%d:%02d:%02d"):format(negative, seconds / SECONDS_PER_HOUR, math.fmod(seconds / 60, 60), math.fmod(seconds, 60))
    end
end