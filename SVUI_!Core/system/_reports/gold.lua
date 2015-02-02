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
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local error 	= _G.error;
local pcall 	= _G.pcall;
local assert 	= _G.assert;
local tostring 	= _G.tostring;
local tonumber 	= _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round, mod = math.abs, math.ceil, math.floor, math.round, math.fmod;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
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

local StatEvents = {'PLAYER_ENTERING_WORLD','PLAYER_MONEY','SEND_MAIL_MONEY_CHANGED','SEND_MAIL_COD_CHANGED','PLAYER_TRADE_MONEY','TRADE_MONEY_CHANGED'};
local gains = 0;
local loss = 0;
local recorded = 0;
local copperFormat = "%d" .. L.copperabbrev
local silverFormat = "%d" .. L.silverabbrev .. " %.2d" .. L.copperabbrev
local goldFormat = "%s" .. L.goldabbrev .. " %.2d" .. L.silverabbrev .. " %.2d" .. L.copperabbrev

local silverShortFormat = "%d" .. L.silverabbrev
local goldShortFormat = "%s" .. L["goldabbrev"]

local tiptext = join("","|cffaaaaaa",L["Reset Data: Hold Left Ctrl + Shift then Click"],"|r")
local serverGold = {};

local function FormatCurrency(amount, short)
	if not amount then return end 
	local gold, silver, copper = floor(abs(amount/10000)), abs(mod(amount/100,100)), abs(mod(amount,100))
	if(short) then
		if gold ~= 0 then
			gold = BreakUpLargeNumbers(gold)
			return goldShortFormat:format(gold)
		elseif silver ~= 0 then 
			return silverShortFormat:format(silver)
		else 
			return copperFormat:format(copper)
		end
	else
		if gold ~= 0 then
			gold = BreakUpLargeNumbers(gold)
			return goldFormat:format(gold, silver, copper)
		elseif silver ~= 0 then 
			return silverFormat:format(silver, copper)
		else 
			return copperFormat:format(copper)
		end
	end
end 

local function Gold_OnEvent(self, event,...)
	if not IsLoggedIn() then return end 
	local current = GetMoney()
	recorded = Reports.Accountant["gold"][playerName] or GetMoney();
	local adjusted = current - recorded;
	if recorded > current then 
		loss = loss - adjusted 
	else 
		gains = gains + adjusted 
	end 
	self.text:SetText(FormatCurrency(current, SV.db.Reports.shortGold))
	Reports.Accountant["gold"][playerName] = GetMoney()
end 

local function Gold_OnClick(self, button)
	if IsLeftControlKeyDown() and IsShiftKeyDown() then
		Reports.Accountant["gold"] = {};
		Reports.Accountant["gold"][playerName] = GetMoney();
		Gold_OnEvent(self)
		Reports.ReportTooltip:Hide()
	else 
		ToggleAllBags()
	end 
end 

local function Gold_OnEnter(self)
	Reports:SetDataTip(self)
	Reports.ReportTooltip:AddLine(L['Session:'])
	Reports.ReportTooltip:AddDoubleLine(L["Earned:"],FormatCurrency(gains),1,1,1,1,1,1)
	Reports.ReportTooltip:AddDoubleLine(L["Spent:"],FormatCurrency(loss),1,1,1,1,1,1)
	if gains < loss then 
		Reports.ReportTooltip:AddDoubleLine(L["Deficit:"],FormatCurrency(gains - loss),1,0,0,1,1,1)
	elseif (gains - loss) > 0 then 
		Reports.ReportTooltip:AddDoubleLine(L["Profit:"],FormatCurrency(gains - loss),0,1,0,1,1,1)
	end 
	Reports.ReportTooltip:AddLine(" ")
	local cash = Reports.Accountant["gold"][playerName];
	Reports.ReportTooltip:AddLine(L[playerName..": "])
	Reports.ReportTooltip:AddDoubleLine(L["Total: "], FormatCurrency(cash), 1,1,1,1,1,1)
	Reports.ReportTooltip:AddLine(" ")

	Reports.ReportTooltip:AddLine(L["Characters: "])
	for name,amount in pairs(serverGold)do
		if(name ~= playerName and name ~= 'total') then
			cash = cash + amount;
			Reports.ReportTooltip:AddDoubleLine(name, FormatCurrency(amount), 1,1,1,1,1,1)
		end
	end 
	Reports.ReportTooltip:AddLine(" ")
	Reports.ReportTooltip:AddLine(L["Server: "])
	Reports.ReportTooltip:AddDoubleLine(L["Total: "], FormatCurrency(cash), 1,1,1,1,1,1)
	Reports.ReportTooltip:AddLine(" ")
	Reports.ReportTooltip:AddLine(tiptext)
	Reports:ShowDataTip()
end

local function Gold_OnInit(self)
	Reports:SetAccountantData('gold', 'number', 0);

	local totalGold = 0;
	for name,amount in pairs(Reports.Accountant["gold"])do 
		if Reports.Accountant["gold"][name] then 
			serverGold[name] = amount;
			totalGold = totalGold + amount
		end 
	end

	serverGold['total'] = totalGold;
end

Reports:NewReportType('Gold', StatEvents, Gold_OnEvent, nil, Gold_OnClick, Gold_OnEnter, nil, Gold_OnInit);