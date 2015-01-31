--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
BUGSACK
##########################################################
]]--
local function StyleBugSack(event, addon)
	assert(BugSack, "AddOn Not Loaded")
	hooksecurefunc(BugSack, "OpenSack", function()
		if BugSackFrame.Panel then return end
		BugSackFrame:RemoveTextures()
		BugSackFrame:SetStylePanel("Frame", 'Transparent')
		MOD:ApplyTabStyle(BugSackTabAll)
		BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
		MOD:ApplyTabStyle(BugSackTabSession)
		MOD:ApplyTabStyle(BugSackTabLast)
		BugSackNextButton:SetStylePanel("Button")
		BugSackSendButton:SetStylePanel("Button")
		BugSackPrevButton:SetStylePanel("Button")
		MOD:ApplyScrollBarStyle(BugSackScrollScrollBar)
	end)
end

MOD:SaveAddonStyle("Bugsack", StyleBugSack)