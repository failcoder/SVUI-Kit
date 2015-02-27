--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor;
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--BLIZZARD API
local ReloadUI              = _G.ReloadUI;
local GetLocale             = _G.GetLocale;
local CreateFrame           = _G.CreateFrame;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
local InCombatLockdown      = _G.InCombatLockdown;
local GetAddOnInfo          = _G.GetAddOnInfo;
local LoadAddOn             = _G.LoadAddOn;
local SendAddonMessage      = _G.SendAddonMessage;
local LibStub               = _G.LibStub;
local GetAddOnMetadata      = _G.GetAddOnMetadata;
local GetCVarBool           = _G.GetCVarBool;
local GameTooltip           = _G.GameTooltip;
local StaticPopup_Hide      = _G.StaticPopup_Hide;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local InboxFrame_OnClick 	= _G.InboxFrame_OnClick;

local SV = select(2, ...);
local L = SV.L;

local MailMinion = _G["SVUI_MailMinion"];
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local takingOnlyCash = false;
local deletedelay = 0.5;
local mailElapsed = 0;
local GetAllMail, GetAllMailCash, OpenMailItem, WaitForMail, DeleteAllMail, DeleteMailItem, WaitForDelete, StopOpeningMail;
local lastopened, lastdeleted, needsToWait, waitToDelete, total_cash, baseInboxFrame_OnClick;
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
function GetAllMail()
	if(GetInboxNumItems() == 0) then return end 
	MailMinion.GetMail:SetScript("OnClick", nil)
	MailMinion.GetGold:SetScript("OnClick", nil)
	MailMinion.Delete:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = SV.fubar
	MailMinion.GetMail:RegisterEvent("UI_ERROR_MESSAGE")
	OpenMailItem(GetInboxNumItems())
end 

function GetAllMailCash()
	takingOnlyCash = true;
	GetAllMail()
end

function OpenMailItem(mail)
	if not InboxFrame:IsVisible()then return StopOpeningMail("Mailbox Minion Needs a Mailbox!")end 
	if mail==0 then 
		MiniMapMailFrame:Hide()
		return StopOpeningMail("Finished getting your mail!")
	end 
	local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(mail)
	if not takingOnlyCash then 
		if money > 0 or itemCount and itemCount > 0 and CODAmount <= 0 then 
			AutoLootMailItem(mail)
			needsToWait=true 
		end 
	elseif money > 0 then 
		TakeInboxMoney(mail)
		needsToWait=true;
		if total_cash then total_cash = total_cash - money end 
	end 
	local numMail = GetInboxNumItems()
	if itemCount and itemCount > 0 or numMail > 1 and mail <= numMail then 
		lastopened = mail;
		MailMinion.GetMail:SetScript("OnUpdate",WaitForMail)
	else 
		MiniMapMailFrame:Hide()
		StopOpeningMail()
	end 
end

function WaitForMail(_, elapsed)
	mailElapsed = mailElapsed + elapsed;
	if not needsToWait or mailElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopOpeningMail("The Mailbox Minion Needs a Mailbox!") end 
		mailElapsed = 0;
		needsToWait = false;
		MailMinion.GetMail:SetScript("OnUpdate", nil)
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastopened)
		if money > 0 or not takingOnlyCash and CODAmount <= 0 and itemCount and itemCount > 0 then
			OpenMailItem(lastopened)
		else
			OpenMailItem(lastopened - 1)
		end 
	end 
end 

function DeleteAllMail()
	if(GetInboxNumItems() == 0) then return end 
	MailMinion.GetMail:SetScript("OnClick", nil)
	MailMinion.GetGold:SetScript("OnClick", nil)
	MailMinion.Delete:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = SV.fubar
	DeleteMailItem(GetInboxNumItems())
end 

function DeleteMailItem(mail)
	if not InboxFrame:IsVisible()then return StopOpeningMail("Mailbox Minion Needs a Mailbox!")end 
	if mail==0 then 
		MiniMapMailFrame:Hide()
		return StopOpeningMail("Finished deleting your mail!")
	end 
	local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(mail)
	if(((not money) or (money and money == 0)) or ((not itemCount) or (itemCount and itemCount > 0))) then 
		DeleteInboxItem(mail)
		waitToDelete = true
	end
	local numMail = GetInboxNumItems()
	if(numMail > 1 and waitToDelete) then 
		lastdeleted = mail;
		MailMinion.Delete:SetScript("OnUpdate", WaitForDelete)
	else 
		MiniMapMailFrame:Hide()
		StopOpeningMail()
	end 
end 

function WaitForDelete(_, elapsed)
	mailElapsed = mailElapsed + elapsed;
	if not waitToDelete or mailElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopOpeningMail("The Mailbox Minion Needs a Mailbox!") end 
		mailElapsed = 0;
		waitToDelete = false;
		MailMinion.Delete:SetScript("OnUpdate", nil)
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastdeleted)
		if(((not money) or (money and money == 0)) or ((not itemCount) or (itemCount and itemCount > 0))) then
			DeleteMailItem(lastdeleted)
		else
			DeleteMailItem(lastdeleted - 1)
		end
	end 
end

function StopOpeningMail(msg, ...)
	MailMinion.GetMail:SetScript("OnUpdate", nil)
	MailMinion.Delete:SetScript("OnUpdate", nil)
	MailMinion.GetMail:SetScript("OnClick", GetAllMail)
	MailMinion.Delete:SetScript("OnClick", DeleteAllMail)
	MailMinion.GetGold:SetScript("OnClick", GetAllMailCash)
	if baseInboxFrame_OnClick then
		InboxFrame_OnClick = baseInboxFrame_OnClick 
	end 
	MailMinion.GetMail:UnregisterEvent("UI_ERROR_MESSAGE")
	takingOnlyCash = false;
	total_cash = nil;
	needsToWait = false;
	waitToDelete = false;
	if msg then
		SV:AddonMessage(msg)
	end 
end

local function FancifyMoneys(cash)
	if cash > 10000 then
		return("%d|cffffd700g|r%d|cffc7c7cfs|r%d|cffeda55fc|r"):format((cash / 10000), ((cash / 100) % 100), (cash % 100))
	elseif cash > 100 then 
		return("%d|cffc7c7cfs|r%d|cffeda55fc|r"):format(((cash / 100) % 100), (cash % 100))
	else
		return("%d|cffeda55fc|r"):format(cash%100)
	end 
end

local MailButton_OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(("%d messages"):format(GetInboxNumItems()), 1, 1, 1)
	GameTooltip:Show()
end

local MailButton_OnLeave = function(self)
	GameTooltip:Hide()
end

local MailButton_OnEvent = function(self, event, subEvent)
	if(event == "UI_ERROR_MESSAGE") then 
		if((subEvent == ERR_INV_FULL) or (subEvent == ERR_ITEM_MAX_COUNT)) then 
			StopOpeningMail("Your bags are too full!")
		end 
	end 
end

local GoldButton_OnEnter = function(self)
	if(not total_cash) then 
		total_cash = 0;
		for i = 0, GetInboxNumItems() do 
			total_cash = total_cash + select(5, GetInboxHeaderInfo(i))
		end 
	end 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(FancifyMoneys(total_cash), 1, 1, 1)
	GameTooltip:Show()
end
--[[ 
########################################################## 
MAIL HELPER
##########################################################
]]--
function SV:ToggleMailMinions()
	if not SV.db.Extras.mailOpener then 
		MailMinion:Hide()
	else
		MailMinion:Show()
	end 
end 
--[[ 
########################################################## 
LOAD BY TRIGGER
##########################################################
]]--
local function LoadMailMinions()
	if IsAddOnLoaded("Postal") then 
		SV.db.Extras.mailOpener = false
	else
		MailMinion:Show()

		MailMinion.GetMail:SetStyle()
		MailMinion.GetMail:SetScript("OnClick",GetAllMail)
		MailMinion.GetMail:SetScript("OnEnter", MailButton_OnEnter)
		MailMinion.GetMail:SetScript("OnLeave", MailButton_OnLeave)
		MailMinion.GetMail:SetScript("OnEvent", MailButton_OnEvent)
		
		MailMinion.GetGold:SetStyle()
		MailMinion.GetGold:SetScript("OnClick", GetAllMailCash)
		MailMinion.GetGold:SetScript("OnEnter", GoldButton_OnEnter)
		MailMinion.GetGold:SetScript("OnLeave", MailButton_OnLeave)

		MailMinion.Delete:SetStyle(1, 1, "red")
		MailMinion.Delete:SetScript("OnClick", DeleteAllMail)
		MailMinion.Delete:SetScript("OnEnter", MailButton_OnEnter)
		MailMinion.Delete:SetScript("OnLeave", MailButton_OnLeave)

		SV:ToggleMailMinions()
	end
end

SV.Events:On("CORE_INITIALIZED", LoadMailMinions);