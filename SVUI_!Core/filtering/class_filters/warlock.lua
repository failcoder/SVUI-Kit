--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'WARLOCK') then return end;

local SV = select(2, ...)

--[[ WARLOCK FILTERS ]]--

SV.filterdefaults["BuffWatch"] = {};