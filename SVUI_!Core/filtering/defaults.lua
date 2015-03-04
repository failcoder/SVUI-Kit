--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
local _G = _G;
local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local GetSpellInfo      = _G.GetSpellInfo;
local SV = select(2, ...)

local playerClass = select(2, UnitClass("player"));
local filterClass = playerClass or "NONE";

local function safename(id)
    local n = GetSpellInfo(id)  
    if not n then
        return false
    end
    return n
end

--[[ FILTER DATA ]]--
local FilterIDs = {
    --["BlackList"] = [[36900]],

    --["WhiteList"] = [[31821]],

    ["CC"] = [[47476,91800,91807,91797,108194,115001,33786,339,78675,22570,5211,102359,99,127797,45334,114238,3355,24394,64803,19386,117405,128405,31661,118,122,82691,44572,33395,102051,20066,10326,853,105593,31935,105421,605,64044,8122,9484,15487,114404,88625,87194,2094,1776,6770,1833,1330,408,88611,51514,64695,63685,118905,118345,710,6789,118699,5484,6358,30283,115268,89766,137143,7922,105771,107566,132168,107570,118895,18498,116706,115078,119392,119381,120086,140023,25046,20549,107079]],

    ["Defense"] = [[17,47515,45243,45438,115610,48797,48792,49039,87256,55233,50461,33206,47788,62618,47585,104773,110913,108359,22812,102342,106922,61336,19263,53480,1966,31224,74001,5277,45182,98007,30823,108271,1022,6940,114039,31821,498,642,86659,31850,118038,55694,97463,12975,114029,871,114030,120954,131523,122783,122278,115213,116849,20594]],

    ["Player"] = [[17,47515,45243,45438,45438,115610,110909,12051,12472,80353,12042,32612,110960,108839,111264,108843,48797,48792,49039,87256,49222,55233,50461,49016,51271,96268,33206,47788,62618,47585,6346,10060,114239,119032,27827,104773,110913,108359,113860,113861,113858,88448,22812,102342,106922,61336,117679,102543,102558,102560,16689,132158,106898,1850,106951,29166,52610,69369,112071,124974,19263,53480,51755,54216,34471,3045,3584,131894,90355,90361,31224,74001,5277,45182,51713,114018,2983,121471,11327,108212,57933,79140,13750,98007,30823,108271,16188,2825,79206,16191,8178,58875,108281,108271,16166,114896,1044,1022,1038,6940,114039,31821,498,642,86659,20925,31850,31884,53563,31842,54428,105809,85499,118038,55694,97463,12975,114029,871,114030,18499,1719,23920,114028,46924,3411,107574,120954,131523,122783,122278,115213,116849,125174,116841,20594,59545,20572,26297,68992]],

    ["Raid"] = [[116281,116784,116417,116942,116161,117708,118303,118048,118135,117878,117949,116835,116778,116525,122761,122760,122740,123812,123180,123474,122835,123081,122125,121885,121949,117436,118091,117519,122752,123011,116161,123121,119985,119086,119775,122151,138349,137371,136767,137641,137359,137972,136903,136753,137633,137731,133767,133768,136050,138569,134691,137440,137408,137360,135000,143436,143579,147383,146124,144851,144358,144774,147207,144215,143990,144330,143494,142990,143919,143766,143773,146589,143777,143385,143974,145183]]
};

local InitAuraBars = [[2825,32182,80353,90355,86659]]

SV.filterdefaults["BlackList"] = {};
SV.filterdefaults["WhiteList"] = {};
SV.filterdefaults["Defense"] = {};
SV.filterdefaults["Player"] = {};
SV.filterdefaults["AuraBars"] = {};
SV.filterdefaults["CC"] = {};
SV.filterdefaults["Raid"] = {};
SV.filterdefaults["Custom"] = {};

for k, x in pairs(FilterIDs) do
    local src = {};
    for id in x:gmatch("([^,]+)") do
        if(id) then
            local spellID = tonumber(id);
            local n = safename(spellID);
            if(n) then
                src[id] = {['enable'] = true, ['id'] = spellID, ['priority'] = 0, ['isDefault'] = true}
            end
        end 
    end
    SV.filterdefaults[k] = src
end

for id in InitAuraBars:gmatch("([^,]+)") do
    if(id) then
        local spellID = tonumber(id);
        if(safename(spellID)) then
            SV.filterdefaults["AuraBars"][id] = {0.98, 0.57, 0.11}
        end
    end
end

local function SanitizeFilters()
    local filter = SV.filters.BuffWatch
    for id, watchData in pairs(filter) do
        if((not watchData.id) or (tonumber(id) ~= watchData.id)) then 
            SV.filters.BuffWatch[id] = nil
        end 
    end

    filter = SV.filters.PetBuffWatch
    for id, watchData in pairs(filter) do
        if((not watchData.id) or (tonumber(id) ~= watchData.id)) then 
            SV.filters.PetBuffWatch[id] = nil
        end 
    end
end

SV:NewScript(SanitizeFilters);