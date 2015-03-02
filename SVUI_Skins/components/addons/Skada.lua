--[[
##########################################################
S V U I   By: Munglunch
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
local twipe = table.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local activePanels = {};
local StupidSkada = function() return end
--[[ 
########################################################## 
SKADA
##########################################################
]]--
local function skada_panel_loader(dock, window, heightOverride)
  local height = heightOverride or MOD.Docklet:GetHeight()
  local width = dock:GetWidth()
  local db = window.db
  local curHeight = 0
  if(db) then
    if(db.enabletitle) then curHeight = db.title.height end
    db.barspacing = 1;
    db.barwidth = width - 10;
    db.background.height = (height - curHeight) - 12;
    db.spark = false;
    db.barslocked = true;
  end
  window.bargroup:ClearAllPoints()
  window.bargroup:InsetPoints(dock, 3, 3)
  window.bargroup:SetFrameStrata('LOW')

  local bgroup = window.bargroup.backdrop;
  if (bgroup) then 
    bgroup:Show()
    if(not bgroup.Panel) then
      bgroup:SetStyle("!_Frame", 'Transparent', true)
    end
  end

  dock.FrameLink = window;
end

function MOD:Docklet_Skada(_, heightOverride)
  if not Skada then return end

  local dock1,dock2,enabled1,enabled2 = MOD:FetchDocklets();

  for index,window in pairs(Skada:GetWindows()) do
    if(window) then
      local wname = window.db.name or "Skada"
      local key = "SkadaBarWindow" .. wname

      if(enabled1 and dock1:find(key)) then
        skada_panel_loader(MOD.Docklet.Dock1, window, heightOverride);
        Skada.displays['bar']:ApplySettings(window)
      elseif(enabled2 and dock2:find(key)) then
        skada_panel_loader(MOD.Docklet.Dock2, window, heightOverride);
        Skada.displays['bar']:ApplySettings(window)
      else
        window.db.barslocked = false;
      end
    end
  end
end

local function Skada_ShowPopup(self)
  MOD:LoadAlert('Do you want to reset Skada?', function(self) Skada:Reset() self:GetParent():Hide() end)
end

local function StyleSkada()
  assert(Skada, "AddOn Not Loaded")
  Skada.ShowPopup = Skada_ShowPopup
  
  local SkadaDisplayBar = Skada.displays['bar']

  hooksecurefunc(SkadaDisplayBar, 'AddDisplayOptions', function(self, window, options)
    options.baroptions.args.barspacing = nil
    options.titleoptions.args.texture = nil
    options.titleoptions.args.bordertexture = nil
    options.titleoptions.args.thickness = nil
    options.titleoptions.args.margin = nil
    options.titleoptions.args.color = nil
    options.windowoptions = nil
  end)

  hooksecurefunc(SkadaDisplayBar, 'ApplySettings', function(self, window)
    local skada = window.bargroup
    if not skada then return end
    local panelAnchor = skada
    skada:SetSpacing(1)
    skada:SetFrameLevel(5)
    skada:SetBackdrop(nil)

    if(window.db.enabletitle) then
      panelAnchor = skada.button
      skada.button:ModHeight(22)
      skada.button:RemoveTextures()
      skada.button:SetStyle("Frame", "Transparent")
      --skada.button:SetPanelColor("class")
      local titleFont = skada.button:GetFontString()
      titleFont:SetFont(SV.media.font.dialog, 13, "NONE")
      titleFont:SetShadowColor(0, 0, 0, 1)
      titleFont:SetShadowOffset(1, -1)
    end

    skada:SetStyle("Frame", "Transparent")
    skada.Panel:ClearAllPoints()
    skada.Panel:SetPoint('TOPLEFT', panelAnchor, 'TOPLEFT', -3, 3)
    skada.Panel:SetPoint('BOTTOMRIGHT', skada, 'BOTTOMRIGHT', 3, -3)
  end)

  hooksecurefunc(Skada, 'CreateWindow', function()
    if MOD:ValidateDocklet("Skada") then
      MOD:Docklet_Skada()
    end
  end)

  hooksecurefunc(Skada, 'DeleteWindow', function()
    if MOD:ValidateDocklet("Skada") then
      MOD:Docklet_Skada()
    end
  end)
end

MOD:SaveAddonStyle("Skada", StyleSkada, nil, true)