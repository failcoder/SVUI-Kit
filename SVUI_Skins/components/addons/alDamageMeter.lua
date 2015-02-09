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
ALDAMAGEMETER
##########################################################
]]--
local function StyleALDamageMeter()
  assert(_G['alDamagerMeterFrame'], "AddOn Not Loaded")
  
  alDamageMeterFrame.bg:Die()
  SV.API:Set("Frame", alDamageMeterFrame)
  alDamageMeterFrame:HookScript('OnShow', function()
    if InCombatLockdown() then return end 
    if MOD:ValidateDocklet("alDamageMeter") then
      MOD.Docklet:Show()
    end
  end)
end
MOD:SaveAddonStyle("alDamageMeter", StyleALDamageMeter)

function MOD:Docklet_alDamageMeter(parent)
  if not _G['alDamagerMeterFrame'] then return end 
  local parentFrame=_G['alDamagerMeterFrame']:GetParent();
  dmconf.barheight=floor(parentFrame:GetHeight()/dmconf.maxbars-dmconf.spacing)
  dmconf.width=parentFrame:GetWidth()
  alDamageMeterFrame:ClearAllPoints()
  alDamageMeterFrame:SetAllPoints(parent)
  alDamageMeterFrame.backdrop:SetStyle("!_Frame", 'Transparent',true)
  alDamageMeterFrame.bg:Die()
  alDamageMeterFrame:SetFrameStrata('LOW')

  parent.Framelink = alDamageMeterFrame
end 