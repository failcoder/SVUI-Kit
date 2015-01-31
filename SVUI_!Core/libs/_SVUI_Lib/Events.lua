--[[
 /$$$$$$$$                              /$$             
| $$_____/                             | $$             
| $$    /$$    /$$ /$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$$
| $$$$$|  $$  /$$//$$__  $$| $$__  $$|_  $$_/  /$$_____/
| $$__/ \  $$/$$/| $$$$$$$$| $$  \ $$  | $$   |  $$$$$$ 
| $$     \  $$$/ | $$_____/| $$  | $$  | $$ /$$\____  $$
| $$$$$$$$\  $/  |  $$$$$$$| $$  | $$  |  $$$$//$$$$$$$/
|________/ \_/    \_______/|__/  |__/   \___/ |_______/ 
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
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
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("Events")

if not lib then return end -- No upgrade needed

--[[ ADDON DATA ]]--

local CoreName, CoreObject  = ...

--[[ LIB CALLBACK STORAGE ]]--

lib.Triggers = {};
lib.LockCallback = {};
lib.UnlockCallback = {};

--LOCAL HELPERS

local function HandleErrors(schema, action, catch)
    schema = schema or "Librarian:Events"
    action = action or "Unknown Function"
    local timestamp = date("%m/%d/%y %H:%M:%S")
    local err_message = ("%s [%s] - (%s) %s"):format(schema, action, timestamp, catch)
    if(CoreObject.DebugMode == true) then
        CoreObject:Debugger(err_message)
    end
end

function lib:Trigger(eventName, ...)
    if(not eventName) then return end;
    local eventCallabcks = self.Triggers[eventName];
    if(not eventCallabcks) then return end;
    for id, fn in pairs(eventCallabcks) do 
        if(fn and type(fn) == "function") then
            local _, catch = pcall(fn, ...)
            if(catch) then
                HandleErrors("Librarian:Events:Trigger(" .. eventName .. "):", id, catch)
            end
        end
    end
end

--[[ CONSTRUCTORS ]]--

function lib:On(event, id, callback)
    if((not event) or (not id)) then return end; 
    if(callback and type(callback) == "function") then
        if(not self.Triggers[event]) then
            self.Triggers[event] = {}
        end
        self.Triggers[event][id] = callback
    end 
end

function lib:OnLock(id, callback)
    if(not id) then return end; 
    if(callback and type(callback) == "function") then
        self.LockCallback[id] = callback
    end 
end

function lib:OnUnlock(id, callback)
    if(not id) then return end; 
    if(callback and type(callback) == "function") then
        self.UnlockCallback[id] = callback
    end 
end

--[[ COMMON EVENTS ]]--

lib.EventManager = CreateFrame("Frame", nil)
local Library_OnEvent = function(self, event, arg, ...)
    if(event == 'PLAYER_REGEN_DISABLED') then
        for id, fn in pairs(lib.LockCallback) do 
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    HandleErrors("Librarian:Events:Trigger(" .. eventName .. "):", id, catch)
                end
            end
        end
    elseif(event == "PLAYER_REGEN_ENABLED") then
        for id, fn in pairs(lib.UnlockCallback) do 
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    HandleErrors("Librarian:Events:Trigger(" .. eventName .. "):", id, catch)
                end
            end
        end
    end
end

lib.EventManager:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.EventManager:RegisterEvent("PLAYER_REGEN_ENABLED")
lib.EventManager:SetScript("OnEvent", Library_OnEvent)