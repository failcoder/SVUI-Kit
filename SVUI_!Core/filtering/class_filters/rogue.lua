--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'ROGUE') then return end;

local SV = select(2, ...)

--[[ ROGUE FILTERS ]]--

SV.filterdefaults["BuffWatch"] = {
    ["57934"] = {-- Tricks of the Trade
        ["enable"] = true, 
        ["id"] = 57934, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.89, ["g"] = 0.09, ["b"] = 0.05},
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
};