--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
local string  = _G.string;
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
OMEN
##########################################################
]]--
local function StyleOmen()
  assert(Omen, "AddOn Not Loaded")
  
  --[[ Background Settings ]]--
  Omen.db.profile.Background.BarInset = 3
  Omen.db.profile.Background.EdgeSize = 1
  Omen.db.profile.Background.Texture = "None"
  
  --[[ Bar Settings ]]--
  Omen.db.profile.Bar.Font = "SVUI Default Font"
  Omen.db.profile.Bar.FontOutline = "None"
  Omen.db.profile.Bar.FontSize = 11
  Omen.db.profile.Bar.Height = 14
  Omen.db.profile.Bar.ShowHeadings = false
  Omen.db.profile.Bar.ShowTPS = false
  Omen.db.profile.Bar.Spacing = 1
  Omen.db.profile.Bar.Texture = "SVUI MultiColorBar"
 
 --[[ Titlebar Settings ]]--  
  Omen.db.profile.TitleBar.BorderColor.g = 0
  Omen.db.profile.TitleBar.BorderColor.r = 0
  Omen.db.profile.TitleBar.BorderTexture = "None"
  Omen.db.profile.TitleBar.EdgeSize = 1
  Omen.db.profile.TitleBar.Font = "Arial Narrow"
  Omen.db.profile.TitleBar.FontSize = 12
  Omen.db.profile.TitleBar.Height = 23
  Omen.db.profile.TitleBar.ShowTitleBar=true
  Omen.db.profile.TitleBar.Texture = "None"
  Omen.db.profile.TitleBar.UseSameBG = false

  hooksecurefunc(Omen, 'UpdateBackdrop', function(self)
    if(not MOD:ValidateDocklet("Omen")) then
      SV.API:Set("Frame", self.BarList, 'Transparent')
      self.Title:RemoveTextures()
      self.Title:SetStyle()
      self.Title:SetPanelColor("class")
    end
    self.BarList:SetPoint('TOPLEFT', self.Title, 'BOTTOMLEFT', 0, 1)
  end)

  Omen:UpdateBackdrop()
  Omen:ReAnchorBars()
  Omen:ResizeBars()
end
MOD:SaveAddonStyle("Omen", StyleOmen, nil, true)

function MOD:Docklet_Omen(parent)
  if not Omen then return end 
  local db = Omen.db;

  --[[ General Settings ]]--
  db.profile.FrameStrata='2-LOW';
  db.profile.Locked=true;
  db.profile.Scale=1;
  db.profile.ShowWith.UseShowWith=false;

  --[[ Background Settings ]]--
  db.profile.Background.BarInset=3;
  db.profile.Background.EdgeSize=1;
  db.profile.Background.Texture = "None"

  --[[ Bar Settings ]]--
  db.profile.Bar.Font = "SVUI Default Font";
  db.profile.Bar.FontOutline = "None";
  db.profile.Bar.FontSize = 11;
  db.profile.Bar.Height = 14;
  db.profile.Bar.ShowHeadings = false;
  db.profile.Bar.ShowTPS = false;
  db.profile.Bar.Spacing=1;
  db.profile.Bar.Texture = "SVUI MultiColorBar";

  --[[ Titlebar Settings ]]--  
  db.profile.TitleBar.BorderColor.g = 0;
  db.profile.TitleBar.BorderColor.r = 0;
  db.profile.TitleBar.BorderTexture = "None";
  db.profile.TitleBar.EdgeSize = 1;
  db.profile.TitleBar.Font = "Arial Narrow";
  db.profile.TitleBar.FontSize = 12;
  db.profile.TitleBar.Height = 23;
  db.profile.TitleBar.ShowTitleBar=true;
  db.profile.TitleBar.Texture = "None";
  db.profile.TitleBar.UseSameBG=false;

  Omen:OnProfileChanged(nil,db)
  OmenTitle:RemoveTextures()
  OmenTitle.Panel = nil
  OmenTitle:SetStyle("Transparent")
  --OmenTitle:SetPanelColor("class")
  --OmenTitle:GetFontString():SetFont(SV.media.font.default, 12, "OUTLINE")
  OmenBarList:RemoveTextures()
  OmenAnchor:SetStyle("Transparent")
  OmenAnchor:ClearAllPoints()
  OmenAnchor:SetAllPoints(parent)
  OmenAnchor:SetParent(parent)

  parent.Framelink = OmenAnchor
end