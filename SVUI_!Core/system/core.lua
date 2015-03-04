--[[
##############################################################################
S V U I   By: Munglunch
############################################################################## ]]-- 

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
local split         = string.split;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe          = _G.wipe;
--BLIZZARD API
local ReloadUI              = _G.ReloadUI;
local GetLocale             = _G.GetLocale;
local CreateFrame           = _G.CreateFrame;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
local InCombatLockdown      = _G.InCombatLockdown;
local GetAddOnInfo          = _G.GetAddOnInfo;
local LoadAddOn             = _G.LoadAddOn;
local LibStub               = _G.LibStub;
local GetAddOnMetadata      = _G.GetAddOnMetadata;
local GetCVarBool           = _G.GetCVarBool;
local GameTooltip           = _G.GameTooltip;
local StaticPopup_Hide      = _G.StaticPopup_Hide;

local IsInInstance          = _G.IsInInstance;
local hooksecurefunc        = _G.hooksecurefunc;
local collectgarbage        = _G.collectgarbage;
local CombatText_AddMessage = _G.CombatText_AddMessage;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;

local RequestBattlefieldScoreData = _G.RequestBattlefieldScoreData;

--[[  CONSTANTS ]]--

_G.BINDING_HEADER_SVUI = "SuperVillain UI";
_G.BINDING_NAME_SVUI_MARKERS = "Raid Markers";
_G.BINDING_NAME_SVUI_DOCKS = "Toggle Both Docks";
_G.BINDING_NAME_SVUI_DOCKS_LEFT = "Toggle Left Dock";
_G.BINDING_NAME_SVUI_DOCKS_RIGHT = "Toggle Right Dock";
_G.BINDING_NAME_SVUI_RIDE = "Let's Ride";
_G.BINDING_NAME_SVUI_DRAENORZONE = "Draenor Zone Ability";
_G.BINDING_NAME_SVUI_FRAMEDEBUGGER = "Supervillain UI: Frame Analyzer";

_G.SlashCmdList.RELOADUI = ReloadUI
_G.SLASH_RELOADUI1 = "/rl"
_G.SLASH_RELOADUI2 = "/reloadui"

_G.SVUI_ICON_COORDS = {0.1, 0.9, 0.1, 0.9};
--:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

--[[ GET THE REGISTRY LIB ]]--

local SVUILib = Librarian("Registry");

--[[ LOCALS ]]--

local rez = GetCVar("gxResolution");
local baseHeight = tonumber(rez:match("%d+x(%d+)"))
local baseWidth = tonumber(rez:match("(%d+)x%d+"))
local defaultDockWidth = baseWidth * 0.66;
local defaultCenterWidth = min(defaultDockWidth, 900);
local callbacks = {};
local numCallbacks = 0;
local playerClass = select(2, UnitClass("player"));
local errorPattern = "|cffff0000Error -- |r|cffff9900Required addon '|r|cffffff00%s|r|cffff9900' is %s.|r";

--[[ HELPERS ]]--

local function _removedeprecated()
    --[[ BEGIN DEPRECATED ]]--

    --[[ END DEPRECATED ]]--
end

local function _explode(this, delim)
    local pattern = string.format("([^%s]+)", delim)
    local res = {}
    for line in string.gmatch(this, pattern) do
        tinsert(res, line)
    end
    return res
end

local function _needsupdate(value, lowest)
    local minimumVersion = 5;
    local version = value or '0.0';
    if(version and type(version) ~= string) then
        version = tostring(version)
    end
    if(not version) then
        return true
    end
    local vt = _explode(version, ".")
    local MAJOR,MINOR,PATCH = unpack(vt)
    if(MAJOR) then
        if(type(MAJOR) == "string") then
            MAJOR = tonumber(MAJOR)
        end
        if(type(MAJOR) == "number" and MAJOR < lowest) then
            return true
        else
            return false
        end
    else
        return true
    end
end

--[[ BUILD CLASS COLOR GLOBAL, CAN BE OVERRIDDEN BY THE ADDON !ClassColors ]]--

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS;

if(not CUSTOM_CLASS_COLORS) then
    local env = getfenv(0)
    env.CUSTOM_CLASS_COLORS = {}
    CUSTOM_CLASS_COLORS = env.CUSTOM_CLASS_COLORS

    local function RegisterCallback(self, m, h)
        assert(type(m) == "string" or type(m) == "function", "Bad argument #1 to :RegisterCallback (string or function expected)")
        if type(m) == "string" then
            assert(type(h) == "table", "Bad argument #2 to :RegisterCallback (table expected)")
            assert(type(h[m]) == "function", "Bad argument #1 to :RegisterCallback (m \"" .. m .. "\" not found)")
            m = h[m]
        end
        callbacks[m] = h or true
        numCallbacks = numCallbacks + 1
    end

    local function UnregisterCallback(self, m, h)
        assert(type(m) == "string" or type(m) == "function", "Bad argument #1 to :UnregisterCallback (string or function expected)")
        if type(m) == "string" then
            assert(type(h) == "table", "Bad argument #2 to :UnregisterCallback (table expected)")
            assert(type(h[m]) == "function", "Bad argument #1 to :UnregisterCallback (m \"" .. m .. "\" not found)")
            m = h[m]
        end
        callbacks[m] = nil
        numCallbacks = numCallbacks + 1
    end

    local function DispatchCallbacks()
        if (numCallbacks < 1) then return end 
        for m, h in pairs(callbacks) do
            local ok, err = pcall(m, h ~= true and h or nil)
            if not ok then
                print("ERROR:", err)
            end
        end
    end

    local classes = {};
    local supercolors = {
        ["HUNTER"]        = { r = 0.454, g = 0.698, b = 0 },
        ["WARLOCK"]       = { r = 0.286, g = 0,     b = 0.788 },
        ["PRIEST"]        = { r = 0.976, g = 1,     b = 0.839 },
        ["PALADIN"]       = { r = 0.956, g = 0.207, b = 0.733 },
        ["MAGE"]          = { r = 0,     g = 0.796, b = 1 },
        ["ROGUE"]         = { r = 1,     g = 0.894, b = 0.117 },
        ["DRUID"]         = { r = 1,     g = 0.513, b = 0 },
        ["SHAMAN"]        = { r = 0,     g = 0.38,  b = 1 },
        ["WARRIOR"]       = { r = 0.698, g = 0.36,  b = 0.152 },
        ["DEATHKNIGHT"]   = { r = 0.847, g = 0.117, b = 0.074 },
        ["MONK"]          = { r = 0.015, g = 0.886, b = 0.38 },
    };

    --[[ IF WE NEED TO FORCE DEFAULT COLORS, USE THIS INSTEAD ]]--

    -- local supercolors = {
    --     ["HUNTER"]        = { r = 0.67,  g = 0.83,  b = 0.45 },
    --     ["WARLOCK"]       = { r = 0.58,  g = 0.51,  b = 0.79 },
    --     ["PRIEST"]        = { r = 1,     g = 1,     b = 1 },
    --     ["PALADIN"]       = { r = 0.96,  g = 0.55,  b = 0.73 },
    --     ["MAGE"]          = { r = 0.41,  g = 0.80,  b = 0.94 },
    --     ["ROGUE"]         = { r = 1,     g = 0.96,  b = 0.41 },
    --     ["DRUID"]         = { r = 1,     g = 0.49,  b = 0.04 },
    --     ["SHAMAN"]        = { r = 0,     g = 0.44,  b = 0.87 },
    --     ["WARRIOR"]       = { r = 0.78,  g = 0.61,  b = 0.43 },
    --     ["DEATHKNIGHT"]   = { r = 0.77,  g = 0.12,  b = 0.23 },
    --     ["MONK"]          = { r = 0.33,  g = 0.54,  b = 0.52 },
    -- };

    for class in pairs(RAID_CLASS_COLORS) do
        tinsert(classes, class)
    end
    tsort(classes)
    setmetatable(CUSTOM_CLASS_COLORS,{
        __index = function(t, k)
            if k == "RegisterCallback" then return RegisterCallback end
            if k == "UnregisterCallback" then return UnregisterCallback end
            if k == "DispatchCallbacks" then return DispatchCallbacks end
        end
    });
    for i, class in ipairs(classes) do
        local color = supercolors[class]
        local r, g, b = color.r, color.g, color.b
        local hex = ("ff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
        if not CUSTOM_CLASS_COLORS[class] or not CUSTOM_CLASS_COLORS[class].r or not CUSTOM_CLASS_COLORS[class].g or not CUSTOM_CLASS_COLORS[class].b then
            CUSTOM_CLASS_COLORS[class] = {
                r = r,
                g = g,
                b = b,
                colorStr = hex,
            }
        end
    end
    classes = nil
end

--[[ CORE ENGINE CONSTRUCT ]]--

-- We have to send the names of our three SavedVariables files since the WoW API
-- has no method for parsing them in LUA.
local SV = SVUILib:NewCore("SVUI_Global", "SVUI_Errors", "SVUI_Private", "SVUI_Media", "SVUI_Filters")

SV.Scale              = 1;
SV.ConfigID           = "SVUI_!Options";
SV.class              = playerClass;
SV.Allegiance         = UnitFactionGroup("player");
SV.ClassRole          = "";
SV.UnitRole           = "NONE";
SV.ConfigurationMode  = false;

SV.Screen = CreateFrame("Frame", "SVUIParent", UIParent);
SV.Screen:SetFrameLevel(UIParent:GetFrameLevel());
SV.Screen:SetPoint("CENTER", UIParent, "CENTER");
SV.Screen:SetSize(UIParent:GetSize());

SV.Hidden = CreateFrame("Frame", nil, UIParent);
SV.Hidden:Hide();

SV.RollFrames         = {};
SV.SystemAlert        = {};
SV.filterdefaults     = {};
SV.mediadefaults      = {};
SV.defaults           = {
    ["LAYOUT"] = {},
    ["screen"] = {
        ["autoScale"] = true,
        ["multiMonitor"] = false,
        ["advanced"] = false,
        ["scaleAdjust"] = 0.64,
        ["forcedWidth"] = baseWidth,
        ["forcedHeight"] = baseHeight,
    },
    ["general"] = {
        ["loginmessage"] = true,
        ["cooldown"] = true, 
        ["saveDraggable"] = false,
        ["taintLog"] = false, 
        ["stickyFrames"] = true, 
        ["graphSize"] = 64,
        ["loot"] = true, 
        ["lootRoll"] = true, 
        ["lootRollWidth"] = 328, 
        ["lootRollHeight"] = 28,
        ["filterErrors"] = true,
        ["hideErrorFrame"] = true, 
        ["errorFilters"] = {
            [INTERRUPTED] = false,
            [ERR_ABILITY_COOLDOWN] = true,
            [ERR_ATTACK_CHANNEL] = false,
            [ERR_ATTACK_CHARMED] = false,
            [ERR_ATTACK_CONFUSED] = false,
            [ERR_ATTACK_DEAD] = false,
            [ERR_ATTACK_FLEEING] = false,
            [ERR_ATTACK_MOUNTED] = true,
            [ERR_ATTACK_PACIFIED] = false,
            [ERR_ATTACK_STUNNED] = false,
            [ERR_ATTACK_NO_ACTIONS] = false,
            [ERR_AUTOFOLLOW_TOO_FAR] = false,
            [ERR_BADATTACKFACING] = false,
            [ERR_BADATTACKPOS] = false,
            [ERR_CLIENT_LOCKED_OUT] = false,
            [ERR_GENERIC_NO_TARGET] = true,
            [ERR_GENERIC_NO_VALID_TARGETS] = true,
            [ERR_GENERIC_STUNNED] = false,
            [ERR_INVALID_ATTACK_TARGET] = true,
            [ERR_ITEM_COOLDOWN] = true,
            [ERR_NOEMOTEWHILERUNNING] = false,
            [ERR_NOT_IN_COMBAT] = false,
            [ERR_NOT_WHILE_DISARMED] = false,
            [ERR_NOT_WHILE_FALLING] = false,
            [ERR_NOT_WHILE_MOUNTED] = false,
            [ERR_NO_ATTACK_TARGET] = true,
            [ERR_OUT_OF_ENERGY] = true,
            [ERR_OUT_OF_FOCUS] = true,
            [ERR_OUT_OF_MANA] = true,
            [ERR_OUT_OF_RAGE] = true,
            [ERR_OUT_OF_RANGE] = true,
            [ERR_OUT_OF_RUNES] = true,
            [ERR_OUT_OF_RUNIC_POWER] = true,
            [ERR_SPELL_COOLDOWN] = true,
            [ERR_SPELL_OUT_OF_RANGE] = false,
            [ERR_TOO_FAR_TO_INTERACT] = false,
            [ERR_USE_BAD_ANGLE] = false,
            [ERR_USE_CANT_IMMUNE] = false,
            [ERR_USE_TOO_FAR] = false,
            [SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
            [SPELL_FAILED_BAD_TARGETS] = true,
            [SPELL_FAILED_CASTER_AURASTATE] = true,
            [SPELL_FAILED_NO_COMBO_POINTS] = true,
            [SPELL_FAILED_SPELL_IN_PROGRESS] = true,
            [SPELL_FAILED_TARGET_AURASTATE] = true,
            [SPELL_FAILED_TOO_CLOSE] = false,
            [SPELL_FAILED_UNIT_NOT_INFRONT] = false,
        }
    },
    ["Extras"] = {
        ["autoRoll"] = false, 
        ["vendorGrays"] = true, 
        ["autoAcceptInvite"] = false, 
        ["autorepchange"] = false, 
        ["pvpautorelease"] = false, 
        ["autoquestcomplete"] = false, 
        ["autoquestreward"] = false, 
        ["autoquestaccept"] = false, 
        ["autodailyquests"] = false, 
        ["autopvpquests"] = false, 
        ["skipcinematics"] = false, 
        ["mailOpener"] = true,
        ["autoRepair"] = "PLAYER",
        ["threatbar"] = false,  
        ["woot"] = true, 
        ["pvpinterrupt"] = true, 
        ["lookwhaticando"] = false,
        ["reactionChat"] = false,
        ["reactionEmote"] = false,
        ["sharingiscaring"] = false, 
        ["arenadrink"] = true, 
        ["stupidhat"] = true,
    },
    ["Gear"] = {
        ["primary"] = "none", 
        ["secondary"] = "none", 
        ["equipmentset"] = "none", 
        ["durability"] = {
            ["enable"] = true, 
            ["onlydamaged"] = true, 
        }, 
        ["itemlevel"] = {
            ["enable"] = true, 
        }, 
        ["misc"] = {
            ["setoverlay"] = true, 
        },
        ["specialization"] = {
            ["enable"] = false, 
        }, 
        ["battleground"] = {
            ["enable"] = false, 
        },
    },
    ["FunStuff"] = {
        ["drunk"] = true,
        ["comix"] = '1',
        ["gamemenu"] = '1',
        ["afk"] = '1', 
    },
    ["Dock"] = {
        ["dockLeftWidth"] = 412, 
        ["dockLeftHeight"] = 224, 
        ["dockRightWidth"] = 412, 
        ["dockRightHeight"] = 224,
        ["dockCenterWidth"] = defaultCenterWidth,
        ["dockCenterHeight"] = 20,
        ["buttonSize"] = 30, 
        ["buttonSpacing"] = 4, 
        ["leftDockBackdrop"] = true, 
        ["rightDockBackdrop"] = true, 
        ["topPanel"] = true, 
        ["bottomPanel"] = true,
        ["dockTools"] = {
            ["garrison"] = true,
            ["firstAid"] = true,
            ["cooking"] = true,
            ["archaeology"] = true,
            ["primary"] = true,
            ["secondary"] = true,
            ["hearth"] = true,
            ["specswap"] = true,
            ["leader"] = true,
            ["breakstuff"] = true,
            ["power"] = false
        },
    },
    ["Reports"] = {
        ["holders"] = {
            [1] = {
                [1] = "Experience", 
                [2] = "Time", 
                [3] = "System",
            },
            [2] = {
                [1] = "Gold", 
                [2] = "Friends", 
                [3] = "Durability", 
            }, 
            [3] = {
                [1] = "None", 
                [2] = "None", 
                [3] = "None",
            }, 
            [4] = {
                [1] = "None", 
                [2] = "None", 
                [3] = "None",
            },
        },
        ["backdrop"] = false,
        ["shortGold"] = true,
        ["localtime"] = true, 
        ["time24"] = false, 
        ["battleground"] = true,
    },
};

--[[ EMBEDDED LIBS ]]--

SV.Options = { 
    type = "group", 
    name = "|cff339fffUI Options|r", 
    args = {
        SVUI_Header = {
            order = 1, 
            type = "header", 
            name = ("Powered By |cffff9900SVUI|r - %s: |cff99ff33%s|r"):format(SV.L["Version"], SV.Version), 
            width = "full"
        },
        profiles = {
            order = 9997,
            type = "group", 
            name = SV.L["Profiles"], 
            childGroups = "tab", 
            args = {}
        },
        credits = {
            type = "group", 
            name = SV.L["Credits"], 
            order = -1, 
            args = {
                new = {
                    order = 1, 
                    type = "description", 
                    name = function() return SV.Credits end
                }
            }
        }
    }
};

--[[ BUILD LOGIN MESSAGES ]]--
local SetLoginMessage;
do
    local commandments = {
        {
            "schemes diabolical",
            "henchmen in-line",
            "entrances grand",
            "battles glorious",
            "power absolute",
        },
        {
            "traps inescapable",
            "enemies overthrown",
            "monologues short",
            "victories infamous",
            "identity a mystery",
        }
    };
    local messagePattern = "|cffFF2F00%s:|r";
    local debugPattern = "|cffFF2F00%s|r [|cff992FFF%s|r]|cffFF2F00:|r";
    local testPattern = "Version |cffAA78FF%s|r, Build |cffAA78FF%s|r."

    local function _send_message(msg, prefix)
        if(type(msg) == "table") then 
             msg = tostring(msg) 
        end
        if(not msg) then return end
        if(prefix) then
            local outbound = ("%s %s"):format(prefix, msg);
            print(outbound)
        else
            print(msg)
        end
    end

    SetLoginMessage = function(self)
        if(not self.NameID) then return end
        local prefix = (messagePattern):format(self.NameID)
        local first = commandments[1][random(1,5)]
        local second = commandments[2][random(1,5)]
        local custom_msg = (self.L["LOGIN_MSG"]):format(first, second)
        _send_message(custom_msg, prefix)
        local login_msg = (self.L["LOGIN_MSG2"]):format(self.Version)
        --local login_msg = (testPattern):format(self.Version, self.GameVersion)
        _send_message(login_msg, prefix)
    end

    function SV:SCTMessage(...)
        if not CombatText_AddMessage then return end 
        CombatText_AddMessage(...)
    end

    function SV:AddonMessage(msg)
        local outbound = (messagePattern):format(self.NameID)
        _send_message(msg, outbound) 
    end
end

local function ShowErrors(msg)
    if msg then
        if(msg == "off") then
            SV.DebugMode = false
            SV:AddonMessage("Debug Mode |cffFF0000DISABLED|r")
        elseif(msg == "on") then
            SV.DebugMode = true
            SV:AddonMessage("Debug Mode |cff00FF00ENABLED|r")
        end
    end

    if(SV.DebugMode) then
        local ERRORSTRING = table.concat(SV.ERRORLOG, "\n\n");
        SV.ScriptError:DebugOutput(ERRORSTRING)
        wipe(SV.ERRORLOG)
    else
        SV:AddonMessage("Debug Mode Not Enabled! Try using |cff00FF00/showerrors on|r")
    end
end

--[[ CORE FUNCTIONS ]]--

function SV:fubar() return end

function SV:StaticPopup_Show(arg)
    if arg == "ADDON_ACTION_FORBIDDEN" then 
        StaticPopup_Hide(arg)
    end
end

function SV:ResetAllUI(confirmed)
    if InCombatLockdown()then 
        SV:AddonMessage(ERR_NOT_IN_COMBAT)
        return 
    end 
    if(not confirmed) then 
        SV:StaticPopup_Show('RESET_UI_CHECK')
        return 
    end 
    SV.Setup:Reset()
    SV.Events:Trigger("FULL_UI_RESET");
end 

function SV:ResetUI(confirmed)
    if InCombatLockdown()then 
        self:AddonMessage(ERR_NOT_IN_COMBAT)
        return 
    end 
    if(not confirmed) then 
        self:StaticPopup_Show('RESETMOVERS_CHECK')
        return 
    end 
    self:ResetAnchors()
end

function SV:ImportProfile(key)
    self.SystemAlert["COPY_PROFILE_PROMPT"].text = "Are you sure you want to link to the profile '" .. key .. "'?"
    self.SystemAlert["COPY_PROFILE_PROMPT"].OnAccept = function() SVUILib:ImportDatabase(key, true) end
    self:StaticPopup_Show("COPY_PROFILE_PROMPT")
end

function SV:CopyProfile(key)
    self.SystemAlert["COPY_PROFILE_PROMPT"].text = "Are you sure you want to copy the profile '" .. key .. "'?"
    self.SystemAlert["COPY_PROFILE_PROMPT"].OnAccept = function() SVUILib:ImportDatabase(key) end
    self:StaticPopup_Show("COPY_PROFILE_PROMPT")
end

function SV:ToggleConfig()
    if InCombatLockdown() then 
        self:AddonMessage(ERR_NOT_IN_COMBAT) 
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return 
    end
    if not IsAddOnLoaded(self.ConfigID) then 
        local _,_,_,_,_,state = GetAddOnInfo(self.ConfigID)
        if state ~= "MISSING" and state ~= "DISABLED" then 
            LoadAddOn(self.ConfigID)
            local config_version = GetAddOnMetadata(self.ConfigID, "Version")
            if(_needsupdate(config_version, 1)) then 
                self:StaticPopup_Show("CLIENT_UPDATE_REQUEST")
            end 
        else
            local errorMessage = (errorPattern):format(self.ConfigID, state)
            self:AddonMessage(errorMessage)
            return 
        end 
    end
    local aceConfig = LibStub("AceConfigDialog-3.0", true)
    if(aceConfig) then
        local switch = not aceConfig.OpenFrames[self.NameID] and "Open" or "Close"
        aceConfig[switch](aceConfig, self.NameID)
        GameTooltip:Hide()
    end
end 

function SV:VersionCheck()
    if(_G.SVUI_TRANSFER_WIZARD) then
        local copied = SVUILib:GetSafeData("transfer_wizard_used");
        if(not copied) then
            _G.SVUI_TRANSFER_WIZARD()
        end
    else
        local version = SVUILib:GetSafeData("install_version");
        if(not version or (version and _needsupdate(version, 1))) then
            self.Setup:Install(true)
        end
    end
end

function SV:RefreshEverything(bypass)
    self:UpdateSharedMedia();
    self:UpdateAnchors();
    SVUILib:RefreshAll();
    if not bypass then
        self:VersionCheck()
    end
end

function SV:GenerateFontOptionGroup(groupName, groupCount, groupOverview, groupList)
    self.Options.args.Fonts.args.fontGroup.args[groupName] = {
        order = groupCount, 
        type = "group", 
        name = groupName,
        args = {
            overview = {
                order = 1, 
                name = groupOverview, 
                type = "description", 
                width = "full", 
            },
            spacer0 = {
                order = 2, 
                name = "", 
                type = "description", 
                width = "full", 
            },
        }, 
    };

    local orderCount = 3;
    for template, info in pairs(groupList) do
        self.Options.args.Fonts.args.fontGroup.args[groupName].args[template] = {
            order = orderCount + info.order, 
            type = "group",
            guiInline = true,
            name = info.name,
            get = function(key)
                return self.media.shared.font[template][key[#key]]
            end,
            set = function(key,value)
                self.media.shared.font[template][key[#key]] = value;
                if(groupCount == 1) then
                    self:StaticPopup_Show("RL_CLIENT")
                else
                    self.Events:Trigger("FONT_GROUP_UPDATED", template);
                end
            end,
            args = {
                description = {
                    order = 1, 
                    name = info.desc, 
                    type = "description", 
                    width = "full", 
                },
                spacer1 = {
                    order = 2, 
                    name = "", 
                    type = "description", 
                    width = "full", 
                },
                spacer2 = {
                    order = 3, 
                    name = "", 
                    type = "description", 
                    width = "full", 
                },
                file = {
                    type = "select",
                    dialogControl = 'LSM30_Font',
                    order = 4,
                    name = self.L["Font File"],
                    desc = self.L["Set the font file to use with this font-type."],
                    values = _G.AceGUIWidgetLSMlists.font,
                },
                outline = {
                    order = 5, 
                    name = self.L["Font Outline"], 
                    desc = self.L["Set the outlining to use with this font-type."], 
                    type = "select", 
                    values = {
                        ["NONE"] = self.L["None"], 
                        ["OUTLINE"] = "OUTLINE", 
                        ["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
                        ["THICKOUTLINE"] = "THICKOUTLINE"
                    },
                },
                size = {
                    order = 6,
                    name = self.L["Font Size"],
                    desc = self.L["Set the font size to use with this font-type."],
                    type = "range",
                    min = 6,
                    max = 64,
                    step = 1,
                },
            }
        }
    end
end

--[[ EVENT HANDLERS ]]--

function SV:PLAYER_ENTERING_WORLD()
    if(not self.RoleIsSet) then
        self:PlayerInfoUpdate()
    end
    if(not self.MediaInitialized) then 
        self:RefreshAllMedia() 
    end
    local _,instanceType = IsInInstance()
    if(instanceType == "pvp") then 
        self.BGTimer = self.Timers:ExecuteLoop(RequestBattlefieldScoreData, 5)
    elseif(self.BGTimer) then 
        self.Timers:RemoveLoop(self.BGTimer)
        self.BGTimer = nil 
    end

    if(not InCombatLockdown()) then
        collectgarbage("collect") 
    end
end

function SV:PET_BATTLE_CLOSE()
    self:AuditVisibility()
    SVUILib:LiveUpdate()
end

function SV:PET_BATTLE_OPENING_START()
    self:AuditVisibility(true)
end

function SV:PLAYER_REGEN_DISABLED()
    local forceClosed = false;

    if(self.OptionsLoaded) then 
        local aceConfig = LibStub("AceConfigDialog-3.0")
        if aceConfig.OpenFrames[self.NameID] then 
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            aceConfig:Close(self.NameID)
            forceClosed = true 
        end 
    end

    if(self:ForceAnchors(forceClosed) == true) then 
        self:AddonMessage(ERR_NOT_IN_COMBAT)
    end

    if(self.NeedsFrameAudit) then
        self:AuditVisibility()
    end
end

function SV:PLAYER_REGEN_ENABLED()
    self:ToggleConfig()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function SV:TaintHandler(event, taint, sourceName, sourceFunc)
    if GetCVarBool('scriptErrors') ~= 1 then return end
    local errorString = ("Error Captured: %s->%s->{%s}"):format(taint, sourceName or "Unknown", sourceFunc or "Unknown")
    self:AddonMessage(errorString)
end

--[[ LOAD FUNCTIONS ]]--

function SV:ReLoad()
    self:RefreshAllMedia();
    self:UpdateAnchors();
    if(self.DebugMode) then
        self:AddonMessage("User settings updated");
    end
end

function SV:PreLoad()
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("PET_BATTLE_CLOSE");
    self:RegisterEvent("PET_BATTLE_OPENING_START");
    self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintHandler");
    self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintHandler");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "PlayerInfoUpdate");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "PlayerInfoUpdate");
end 

function SV:Initialize()
    self:UI_SCALE_CHANGED()
    self.Events:TriggerOnce("LOAD_ALL_ESSENTIALS");
    self.Events:TriggerOnce("LOAD_ALL_WIDGETS");

    SVUILib:Launch();

    self:UI_SCALE_CHANGED("PLAYER_LOGIN")
    self:PlayerInfoUpdate();
    self:VersionCheck();
    self:RefreshAllMedia();

    SVUILib:LoadScripts();

    self.Events:TriggerOnce("CORE_INITIALIZED");

    hooksecurefunc("StaticPopup_Show", self.StaticPopup_Show);

    if self.db.general.loginmessage then
        SetLoginMessage(self);
    end

    if(self.DebugMode and self.HasErrors and self.ScriptError) then
        ShowErrors();
        wipe(self.ERRORLOG)
    end
    
    --print(p1 .. ", " .. p2:GetName() .. ", " .. p3 .. ", " .. p4 .. ", " .. p5)

    collectgarbage("collect");
end
--[[ 
########################################################## 
THE CLEANING LADY
##########################################################
]]--
local LemonPledge = 0;
local Consuela = CreateFrame("Frame")
Consuela:RegisterAllEvents()
Consuela:SetScript("OnEvent", function(self, event)
    LemonPledge = LemonPledge  +  1
    --print(event)
    if(InCombatLockdown()) then return end;
    if(LemonPledge > 10000) then
        collectgarbage("collect");
        LemonPledge = 0;
    end
end)
--[[ 
########################################################## 
REVEAL INTERNAL ERRORS
##########################################################
]]--
_G.SlashCmdList["SVUI_SHOW_ERRORS"] = ShowErrors;
_G.SLASH_SVUI_SHOW_ERRORS1 = "/showerrors"