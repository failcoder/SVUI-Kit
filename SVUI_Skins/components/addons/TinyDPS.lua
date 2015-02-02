--[[
##########################################################
S V U I   By: S.Jackson
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
TINYDPS
##########################################################
]]--
local function StyleTinyDPS()
	assert(tdpsFrame, "AddOn Not Loaded")

	MOD:ApplyFrameStyle(tdpsFrame)
	
	tdpsFrame:HookScript("OnShow", function()
		if InCombatLockdown() then return end 
		if MOD:ValidateDocklet("TinyDPS") then
			MOD.Docklet:Show()
		end
	end)

	if tdpsStatusBar then
		tdpsStatusBar:SetBackdrop({bgFile = SV.BaseTexture, edgeFile = S.Blank, tile = false, tileSize = 0, edgeSize = 1})
		tdpsStatusBar:SetStatusBarTexture(SV.BaseTexture)
	end

	tdpsRefresh()
end

MOD:SaveAddonStyle("TinyDPS", StyleTinyDPS)

function MOD:Docklet_TinyDPS(parent)
	if not tdpsFrame then return end 
	tdps.hideOOC = false;
	tdps.hideIC = false;
	tdps.hideSolo = false;
	tdps.hidePvP = false;
	tdpsFrame:ClearAllPoints()
	tdpsFrame:SetAllPoints(parent)
	tdpsRefresh()

	parent.Framelink = tdpsFrame
end