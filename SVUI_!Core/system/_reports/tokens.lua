--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################

STATS:Extend EXAMPLE USAGE: Reports:NewReportType(newStat,eventList,onEvents,update,click,focus,blur)

########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local tinsert 	= _G.tinsert;
local table     = _G.table;
local twipe     = table.wipe; 
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local Reports = SV.Reports;
--[[ 
########################################################## 
GOLD STATS
##########################################################
]]--
local playerName = UnitName("player");
local playerRealm = GetRealmName();

local TokenEvents = {'PLAYER_ENTERING_WORLD','PLAYER_MONEY','CURRENCY_DISPLAY_UPDATE'};

local function TokenInquiry(id, weekly, capped)
  local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)
  local r, g, b = 1, 1, 1
  for i = 1, GetNumWatchedTokens() do
    local _, _, _, itemID = GetBackpackCurrencyInfo(i)
    if id == itemID then r, g, b = 0.23, 0.88, 0.27 end
  end
  local texStr = ("\124T%s:12\124t %s"):format(tex, name)
  local altStr = ""
  if weekly then
    if discovered then
      if id == 390 then
        altStr = ("Current: %d | Weekly: %d / %d"):format(amount, week, weekmax)
      else
        altStr = ("Current: %d / %d | Weekly: %d / %d"):format(amount, maxed, week, weekmax)
      end
      Reports.ReportTooltip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
    end
  elseif capped then
    if id == 392 or id == 395 then maxed = 4000 end
    if id == 396 then maxed = 3000 end
    if discovered then
      altStr = ("%d / %d"):format(amount, maxed)
      Reports.ReportTooltip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
    end
  else
    if discovered then
      Reports.ReportTooltip:AddDoubleLine(texStr, amount, r, g, b, r, g, b)
    end
  end
end

local function TokensEventHandler(self, event,...)
    if(not IsLoggedIn() or (not self)) then return end
    local id = self.TokenKey or 738;
    local _, current, tex = GetCurrencyInfo(id)
    local currentText = ("\124T%s:12\124t %s"):format(tex, current);
    self.text:SetText(currentText)
end 

local function AddToTokenMenu(parent, id, key)
	local name, _, tex, _, _, _, _ = GetCurrencyInfo(id)
	local itemName = "\124T"..tex..":12\124t "..name;
	local fn = function() 
		Reports.Accountant["tokens"][playerName][key] = id;
    parent.TokenKey = id
		TokensEventHandler(parent)
	end  
	tinsert(parent.TokenList, {text = itemName, func = fn});
end

local function CacheTokenData(self)
    twipe(self.TokenList);
    local prof1, prof2, archaeology, _, cooking = GetProfessions();
    local key = self:GetName();
    if archaeology then
        AddToTokenMenu(self, 398, key)
        AddToTokenMenu(self, 384, key)
        AddToTokenMenu(self, 393, key)
        AddToTokenMenu(self, 677, key)
        AddToTokenMenu(self, 400, key)
        AddToTokenMenu(self, 394, key)
        AddToTokenMenu(self, 397, key)
        AddToTokenMenu(self, 676, key)
        AddToTokenMenu(self, 401, key)
        AddToTokenMenu(self, 385, key)
        AddToTokenMenu(self, 399, key)
        AddToTokenMenu(self, 821, key)
        AddToTokenMenu(self, 829, key)
        AddToTokenMenu(self, 944, key)
    end
    if cooking then
        AddToTokenMenu(self, 81, key)
        AddToTokenMenu(self, 402, key)
    end
    if(prof1 == 9 or prof2 == 9) then
        AddToTokenMenu(self, 61, key)
        AddToTokenMenu(self, 361, key)
        AddToTokenMenu(self, 698, key)

        AddToTokenMenu(self, 910, key)
        AddToTokenMenu(self, 999, key)
        AddToTokenMenu(self, 1020, key)
        AddToTokenMenu(self, 1008, key)
        AddToTokenMenu(self, 1017, key)
    end
    AddToTokenMenu(self, 697, key)
    AddToTokenMenu(self, 738, key)
    AddToTokenMenu(self, 615, key)
    AddToTokenMenu(self, 614, key)
    AddToTokenMenu(self, 395, key)
    AddToTokenMenu(self, 396, key)
    AddToTokenMenu(self, 390, key)
    AddToTokenMenu(self, 392, key)
    AddToTokenMenu(self, 391, key)
    AddToTokenMenu(self, 241, key)
    AddToTokenMenu(self, 416, key)
    AddToTokenMenu(self, 515, key)
    AddToTokenMenu(self, 776, key)
    AddToTokenMenu(self, 777, key)
    AddToTokenMenu(self, 789, key)
    AddToTokenMenu(self, 823, key)
    AddToTokenMenu(self, 824, key)
end

local function Tokens_OnEnter(self)
	Reports:SetDataTip(self)
	Reports.ReportTooltip:AddLine(playerName .. "\'s Tokens")

	Reports.ReportTooltip:AddLine(" ")
	Reports.ReportTooltip:AddLine("Common")
	TokenInquiry(241)
	TokenInquiry(416)
	TokenInquiry(515)
	TokenInquiry(776)
	TokenInquiry(777)
	TokenInquiry(789)

  Reports.ReportTooltip:AddLine(" ")
  Reports.ReportTooltip:AddLine("Garrison")
  TokenInquiry(823)
  TokenInquiry(824)
  TokenInquiry(910)
  TokenInquiry(999)
  TokenInquiry(1020)
  TokenInquiry(1008)
  TokenInquiry(1017)

	Reports.ReportTooltip:AddLine(" ")
	Reports.ReportTooltip:AddLine("Raiding and Dungeons")
	TokenInquiry(697, false, true)
	TokenInquiry(738)
	TokenInquiry(615)
	TokenInquiry(614)
	TokenInquiry(395, false, true)
	TokenInquiry(396, false, true)

	Reports.ReportTooltip:AddLine(" ")
	Reports.ReportTooltip:AddLine("PvP")
	TokenInquiry(390, true)
	TokenInquiry(392, false, true)
	TokenInquiry(391)

	local prof1, prof2, archaeology, _, cooking = GetProfessions()
	if(archaeology or cooking or prof1 == 9 or prof2 == 9) then
		Reports.ReportTooltip:AddLine(" ")
		Reports.ReportTooltip:AddLine("Professions")
	end
	if cooking then
		TokenInquiry(81)
		TokenInquiry(402)
	end
	if(prof1 == 9 or prof2 == 9) then
		TokenInquiry(61)
		TokenInquiry(361)
		TokenInquiry(698)
	end
	if archaeology then
    TokenInquiry(821)
    TokenInquiry(829)
    TokenInquiry(944)
		TokenInquiry(398)
		TokenInquiry(384)
		TokenInquiry(393)
		TokenInquiry(677)
		TokenInquiry(400)
		TokenInquiry(394)
		TokenInquiry(397)
		TokenInquiry(676)
		TokenInquiry(401)
		TokenInquiry(385)
		TokenInquiry(399)
	end
	Reports.ReportTooltip:AddLine(" ")
  Reports.ReportTooltip:AddDoubleLine("[Shift + Click]", "Change Watched Token", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end 

local function Tokens_OnClick(self, button)
  CacheTokenData(self);
	SV.Dropdown:Open(self, self.TokenList) 
end

local function Tokens_OnInit(self)
  Reports:SetAccountantData('tokens', 'table', {})
  local key = self:GetName()
  Reports.Accountant["tokens"][playerName][key] = Reports.Accountant["tokens"][playerName][key] or 738;
  self.TokenKey = Reports.Accountant["tokens"][playerName][key]
  CacheTokenData(self);
end

Reports:NewReportType('Tokens', TokenEvents, TokensEventHandler, nil,  Tokens_OnClick,  Tokens_OnEnter, nil, Tokens_OnInit)