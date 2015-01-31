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
local SV = _G["SVUI"];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
AUCTIONLITE
##########################################################
]]--
local function BGHelper(parent)
  parent.bg = CreateFrame("Frame", nil, parent)
  parent.bg:SetStylePanel("!_Frame", "Inset")
  parent.bg:ModPoint("TOPLEFT", parent, "TOPLEFT", 16, -103)
  parent.bg:ModPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 36)
  parent.bg:SetFrameLevel(parent.bg:GetFrameLevel() - 1)
end

local function StyleAuctionLite(event, ...)
  assert(AuctionFrameTab4, "AddOn Not Loaded")
  if(not event or (event and event == 'PLAYER_ENTERING_WORLD')) then return; end

  BuyName:SetStylePanel("Editbox")
  BuyQuantity:SetStylePanel("Editbox")
  SellStacks:SetStylePanel("Editbox")
  SellSize:SetStylePanel("Editbox")
  SellBidPriceGold:SetStylePanel("Editbox")
  SellBidPriceSilver:SetStylePanel("Editbox")
  SellBidPriceCopper:SetStylePanel("Editbox")
  SellBuyoutPriceGold:SetStylePanel("Editbox")
  SellBuyoutPriceSilver:SetStylePanel("Editbox")
  SellBuyoutPriceCopper:SetStylePanel("Editbox")

  BuySearchButton:SetStylePanel("Button")
  BuyBidButton:SetStylePanel("Button")
  BuyBuyoutButton:SetStylePanel("Button")
  BuyCancelSearchButton:SetStylePanel("Button")
  BuyCancelAuctionButton:SetStylePanel("Button")
  BuyScanButton:SetStylePanel("Button")
  SellCreateAuctionButton:SetStylePanel("Button")

  MOD:ApplyPaginationStyle(BuyAdvancedButton)
  MOD:ApplyPaginationStyle(SellRememberButton)

  MOD:ApplyTabStyle(AuctionFrameTab4)
  MOD:ApplyTabStyle(AuctionFrameTab5)

  if(_G["AuctionFrameBuy"]) then
    BGHelper(_G["AuctionFrameBuy"])
  end
  if(_G["AuctionFrameSell"]) then
    BGHelper(_G["AuctionFrameSell"])
  end

  MOD:SafeEventRemoval("AuctionLite", event)
end

MOD:SaveAddonStyle("AuctionLite", StyleAuctionLite, nil, nil, "AUCTION_HOUSE_SHOW")