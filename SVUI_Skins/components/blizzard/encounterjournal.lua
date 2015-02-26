--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
ENCOUNTERJOURNAL MODR
##########################################################
]]--
local PVP_LOST = [[Interface\WorldMap\Skull_64Red]]

local function Tab_OnEnter(this)
  this.backdrop:SetPanelColor("highlight")
  this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Tab_OnLeave(this)
  this.backdrop:SetPanelColor("dark")
  this.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this, xOffset, yOffset)
  this:SetNormalTexture(SV.NoTexture)
  this:SetPushedTexture(SV.NoTexture)
  this:SetDisabledTexture(SV.NoTexture)
  this:SetHighlightTexture(SV.NoTexture)

  this.backdrop = CreateFrame("Frame", nil, this)
  this.backdrop:InsetPoints(this)
  this.backdrop:SetFrameLevel(0)

  this.backdrop:SetStyle("Frame")
  this.backdrop:SetPanelColor("dark")
  this:HookScript("OnEnter",Tab_OnEnter)
  this:HookScript("OnLeave",Tab_OnLeave)

  local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = this:GetPoint()
  this:ClearAllPoints()
  this:ModPoint(initialAnchor, anchorParent, relativeAnchor, xOffset or 0, yOffset or 0)
end

local function Outline(frame, noHighlight)
    if(frame.Outlined) then return; end
    local offset = noHighlight and 30 or 5
    local mod = noHighlight and 50 or 5

    local panel = CreateFrame('Frame', nil, frame)
    panel:ModPoint('TOPLEFT', frame, 'TOPLEFT', 1, -1)
    panel:ModPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -1, 1)

    --[[ UNDERLAY BORDER ]]--
    local borderLeft = panel:CreateTexture(nil, "BORDER")
    borderLeft:SetTexture(0, 0, 0)
    borderLeft:SetPoint("TOPLEFT")
    borderLeft:SetPoint("BOTTOMLEFT")
    borderLeft:SetWidth(offset)

    local borderRight = panel:CreateTexture(nil, "BORDER")
    borderRight:SetTexture(0, 0, 0)
    borderRight:SetPoint("TOPRIGHT")
    borderRight:SetPoint("BOTTOMRIGHT")
    borderRight:SetWidth(offset)

    local borderTop = panel:CreateTexture(nil, "BORDER")
    borderTop:SetTexture(0, 0, 0)
    borderTop:SetPoint("TOPLEFT")
    borderTop:SetPoint("TOPRIGHT")
    borderTop:SetHeight(mod)

    local borderBottom = panel:CreateTexture(nil, "BORDER")
    borderBottom:SetTexture(0, 0, 0)
    borderBottom:SetPoint("BOTTOMLEFT")
    borderBottom:SetPoint("BOTTOMRIGHT")
    borderBottom:SetHeight(mod)

    if(not noHighlight) then
      local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
      highlight:SetTexture(0, 1, 1, 0.35)
      highlight:SetAllPoints(panel)
    end

    frame.Outlined = true
end

local function _hook_EncounterJournal_DisplayEncounter()
    local parent = EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild;
    if (parent.Bullets and #parent.Bullets > 0) then
      print(#parent.Bullets)
        for i = 1, #parent.Bullets do
            local bullet = parent.Bullets[1];
            bullet.Text:SetTextColor(1,1,1)
        end
    end
end

local function EncounterJournalStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.encounterjournal ~= true then
		 return 
	end 

	EncounterJournal:RemoveTextures(true)
  EncounterJournalInstanceSelect:RemoveTextures(true)
  EncounterJournalNavBar:RemoveTextures(true)
  EncounterJournalNavBarOverlay:RemoveTextures(true)
  EncounterJournalNavBarHomeButton:RemoveTextures(true)
  EncounterJournalInset:RemoveTextures(true)

  EncounterJournalEncounterFrame:RemoveTextures(true)
  EncounterJournalEncounterFrameInfo:RemoveTextures(true)
  EncounterJournalEncounterFrameInfoDifficulty:RemoveTextures(true)
  EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:RemoveTextures(true)
  EncounterJournalEncounterFrameInfoBossesScrollFrame:RemoveTextures(true)
  EncounterJournalInstanceSelectDungeonTab:RemoveTextures(true)
  EncounterJournalInstanceSelectRaidTab:RemoveTextures(true)
  ChangeTabHelper(EncounterJournalEncounterFrameInfoOverviewTab, 10)
  ChangeTabHelper(EncounterJournalEncounterFrameInfoLootTab, 0, -10)
  ChangeTabHelper(EncounterJournalEncounterFrameInfoBossTab, 0, -10)
  ChangeTabHelper(EncounterJournalEncounterFrameInfoModelTab, 0, -20)

  EncounterJournalEncounterFrameInfoOverviewScrollFrame:RemoveTextures()
  EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1,1,0)
  EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1,1,1)
  EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor(1,1,1)
  local bulletParent = EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild;
  if (bulletParent.Bullets and #bulletParent.Bullets > 0) then
      for i = 1, #bulletParent.Bullets do
          local bullet = bulletParent.Bullets[1];
          bullet.Text:SetTextColor(1,1,1)
      end
  end

  EncounterJournalSearchResults:RemoveTextures(true)

  EncounterJournal:SetStyle("Frame", "Window2")
  EncounterJournal:SetPanelColor("dark")
  EncounterJournalInset:SetStyle("Frame[INSET]", "Transparent")

  EncounterJournalInstanceSelectScrollFrameScrollChild:SetStyle("Frame", "Default")
  EncounterJournalInstanceSelectScrollFrameScrollChild:SetPanelColor("dark")
  EncounterJournalInstanceSelectScrollDownButton:SetStyle("Button")
  EncounterJournalInstanceSelectScrollDownButton:SetNormalTexture(SV.media.icon.move_down)

  EncounterJournalEncounterFrameInstanceFrame:SetStyle("Frame[INSET]", "Transparent")

  SV.API:Set("SkinPremium", EncounterJournalEncounterFrameInfoBossesScrollFrame, -20, 40, 0, 0)

  -- local comicHolder = CreateFrame('Frame', nil, EncounterJournal.encounter)
  -- comicHolder:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfoBossesScrollFrame, "TOPLEFT", -20, 40)
  -- comicHolder:SetPoint("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBossesScrollFrame, "BOTTOMRIGHT", 0, 0)
  -- comicHolder:SetStyle("Frame", "PatternComic")
  -- comicHolder:SetPanelColor("dark")
  -- EncounterJournal.encounter.info.encounterTitle:SetParent(comicHolder)
  -- EncounterJournal.searchResults.TitleText:SetParent(comicHolder)

  EncounterJournalNavBarHomeButton:SetStyle("Button")
  EncounterJournalEncounterFrameInfoDifficulty:SetStyle("Button")
  EncounterJournalEncounterFrameInfoDifficulty:SetFrameLevel(EncounterJournalEncounterFrameInfoDifficulty:GetFrameLevel() + 10)
  EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetStyle("Button")
  EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetFrameLevel(EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:GetFrameLevel() + 10)

  EncounterJournalInstanceSelectDungeonTab:SetStyle("Button")
  EncounterJournalInstanceSelectRaidTab:SetStyle("Button")

  SV.API:Set("ScrollBar", EncounterJournalEncounterFrameInfoLootScrollBar)

  local bgParent = EncounterJournal.encounter.instance
  local loreParent = EncounterJournal.encounter.instance.loreScroll

  bgParent.loreBG:SetPoint("TOPLEFT", bgParent, "TOPLEFT", 0, 0)
  bgParent.loreBG:SetPoint("BOTTOMRIGHT", bgParent, "BOTTOMRIGHT", 0, 90)

  loreParent:SetStyle("Frame", "Pattern", true, 1, 1, 5)
  loreParent:SetPanelColor("dark")
  loreParent.child.lore:SetTextColor(1, 1, 1)
  EncounterJournal.encounter.infoFrame.description:SetTextColor(1, 1, 1)

  loreParent:SetFrameLevel(loreParent:GetFrameLevel() + 10)

  local frame = EncounterJournal.instanceSelect.scroll.child
  local index = 1
  local instanceButton = frame["instance"..index];
  while instanceButton do
      Outline(instanceButton)
      index = index + 1;
      instanceButton = frame["instance"..index]
  end

  --hooksecurefunc("EncounterJournal_DisplayEncounter", _hook_EncounterJournal_DisplayEncounter)

  hooksecurefunc("EncounterJournal_ListInstances", function()
    local frame = EncounterJournal.instanceSelect.scroll.child
    local index = 1
    local instanceButton = frame["instance"..index];
    while instanceButton do
        Outline(instanceButton)
        index = index + 1;
        instanceButton = frame["instance"..index]
    end
  end)

  EncounterJournal.instanceSelect.raidsTab:GetFontString():SetTextColor(1, 1, 1);
  hooksecurefunc("EncounterJournal_ToggleHeaders", function()
    local usedHeaders = EncounterJournal.encounter.usedHeaders
    for key,used in pairs(usedHeaders) do
      if(not used.button.Panel) then
          used:RemoveTextures(true)
          used.button:RemoveTextures(true)
          used.button:SetStyle("Button")
      end
      used.description:SetTextColor(1, 1, 1)
      --used.button.portrait.icon:Hide()
    end
  end)
    
  hooksecurefunc("EncounterJournal_LootUpdate", function()
    local scrollFrame = EncounterJournal.encounter.info.lootScroll;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local items = scrollFrame.buttons;
    local item, index;

    local numLoot = EJ_GetNumLoot()

    for i = 1,#items do
      item = items[i];
      index = offset + i;
      if index <= numLoot then
          item.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
          if(not item.Panel) then
            item:SetStyle("Frame", "Outline")
          end
          item.slot:SetTextColor(0.5, 1, 0)
          item.armorType:SetTextColor(1, 1, 0)
          item.boss:SetTextColor(0.7, 0.08, 0)
      end
    end
  end)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_EncounterJournal', EncounterJournalStyle)