--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
LOSSOFCONTROL MODR
##########################################################
]]--
local _hook_LossOfControl = function(self, ...)
  self.Icon:ClearAllPoints()
  self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)
  self.AbilityName:ClearAllPoints()
  self.AbilityName:SetPoint("BOTTOM", self, 0, -28)
  self.AbilityName.scrollTime = nil;
  self.AbilityName:SetFont(SV.media.font.dialog, 20, 'OUTLINE')
  self.TimeLeft.NumberText:ClearAllPoints()
  self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 4, -58)
  self.TimeLeft.NumberText.scrollTime = nil;
  self.TimeLeft.NumberText:SetFont(SV.media.font.number, 20, 'OUTLINE')
  self.TimeLeft.SecondsText:ClearAllPoints()
  self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -80)
  self.TimeLeft.SecondsText.scrollTime = nil;
  self.TimeLeft.SecondsText:SetFont(SV.media.font.default, 20, 'OUTLINE')
  if self.Anim:IsPlaying() then
     self.Anim:Stop()
  end 
end

local function LossOfControlStyle()
  if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.losscontrol ~= true then return end 
  local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
  IconBackdrop:WrapPoints(LossOfControlFrame.Icon)
  IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel()-1)
  IconBackdrop:SetStyle("Frame", "Icon")
  LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
  LossOfControlFrame:RemoveTextures()
  LossOfControlFrame.AbilityName:ClearAllPoints()
  --local bg = CreateFrame("Frame", nil, LossOfControlFrame)
  hooksecurefunc("LossOfControlFrame_SetUpDisplay", _hook_LossOfControl)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(LossOfControlStyle)