--[[
##############################################################################
S V U I   By: S.Jackson
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

local SV = _G['SVUI']
local L = SV.L
local MOD = SV.Extras;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local takingOnlyCash = false;
local deletedelay = 0.5;
local mailElapsed = 0;
local lastopened, lastdeleted, needsToWait, waitToDelete, total_cash, baseInboxFrame_OnClick;
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function GetAllMail()
	if(GetInboxNumItems() == 0) then return end 
	SVUI_GetMailButton:SetScript("OnClick", nil)
	SVUI_GetGoldButton:SetScript("OnClick", nil)
	SVUI_DeleteMailButton:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = SV.fubar
	SVUI_GetMailButton:RegisterEvent("UI_ERROR_MESSAGE")
	OpenMailItem(GetInboxNumItems())
end 

local function GetAllMailCash()
	takingOnlyCash = true;
	GetAllMail()
end

local function OpenMailItem(mail)
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
		SVUI_GetMailButton:SetScript("OnUpdate",WaitForMail)
	else 
		MiniMapMailFrame:Hide()
		StopOpeningMail()
	end 
end

local function WaitForMail(_, elapsed)
	mailElapsed = mailElapsed + elapsed;
	if not needsToWait or mailElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopOpeningMail("The Mailbox Minion Needs a Mailbox!") end 
		mailElapsed = 0;
		needsToWait = false;
		SVUI_GetMailButton:SetScript("OnUpdate", nil)
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastopened)
		if money > 0 or not takingOnlyCash and CODAmount <= 0 and itemCount and itemCount > 0 then
			OpenMailItem(lastopened)
		else
			OpenMailItem(lastopened - 1)
		end 
	end 
end 

local function DeleteAllMail()
	if(GetInboxNumItems() == 0) then return end 
	SVUI_GetMailButton:SetScript("OnClick", nil)
	SVUI_GetGoldButton:SetScript("OnClick", nil)
	SVUI_DeleteMailButton:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = SV.fubar
	DeleteMailItem(GetInboxNumItems())
end 

local function DeleteMailItem(mail)
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
		SVUI_DeleteMailButton:SetScript("OnUpdate", WaitForDelete)
	else 
		MiniMapMailFrame:Hide()
		StopOpeningMail()
	end 
end 

local function WaitForDelete(_, elapsed)
	mailElapsed = mailElapsed + elapsed;
	if not waitToDelete or mailElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopOpeningMail("The Mailbox Minion Needs a Mailbox!") end 
		mailElapsed = 0;
		waitToDelete = false;
		SVUI_DeleteMailButton:SetScript("OnUpdate", nil)
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastdeleted)
		if(((not money) or (money and money == 0)) or ((not itemCount) or (itemCount and itemCount > 0))) then
			DeleteMailItem(lastdeleted)
		else
			DeleteMailItem(lastdeleted - 1)
		end
	end 
end

local function StopOpeningMail(msg, ...)
	SVUI_GetMailButton:SetScript("OnUpdate", nil)
	SVUI_DeleteMailButton:SetScript("OnUpdate", nil)
	SVUI_GetMailButton:SetScript("OnClick", GetAllMail)
	SVUI_DeleteMailButton:SetScript("OnClick", DeleteAllMail)
	SVUI_GetGoldButton:SetScript("OnClick", GetAllMailCash)
	if baseInboxFrame_OnClick then
		InboxFrame_OnClick = baseInboxFrame_OnClick 
	end 
	SVUI_GetMailButton:UnregisterEvent("UI_ERROR_MESSAGE")
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
--[[ 
########################################################## 
MAIL HELPER
##########################################################
]]--
function SV:ToggleMailMinions()
	if not SV.db.Extras.mailOpener then 
		SVUI_MailMinion:Hide()
	else
		SVUI_MailMinion:Show()
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
		local SVUI_MailMinion = CreateFrame("Frame","SVUI_MailMinion",InboxFrame);
		SVUI_MailMinion:SetWidth(150)
		SVUI_MailMinion:SetHeight(25)
		SVUI_MailMinion:SetPoint("CENTER",InboxFrame,"TOP",-22,-400)

		local SVUI_GetMailButton=CreateFrame("Button","SVUI_GetMailButton",SVUI_MailMinion,"UIPanelButtonTemplate")
		SVUI_GetMailButton:SetWidth(70)
		SVUI_GetMailButton:SetHeight(25)
		SVUI_GetMailButton:SetStyle("Button")
		SVUI_GetMailButton:SetPoint("LEFT",SVUI_MailMinion,"LEFT",0,0)
		SVUI_GetMailButton:SetText("Get All")
		SVUI_GetMailButton:SetScript("OnClick",GetAllMail)
		SVUI_GetMailButton:SetScript("OnEnter",function()
			GameTooltip:SetOwner(SVUI_GetMailButton,"ANCHOR_RIGHT")
			GameTooltip:AddLine(string.format("%d messages",GetInboxNumItems()),1,1,1)
			GameTooltip:Show()
		end)
		SVUI_GetMailButton:SetScript("OnLeave",function()GameTooltip:Hide()end)
		SVUI_GetMailButton:SetScript("OnEvent",function(l,m,h,n,o,p)
			if m=="UI_ERROR_MESSAGE"then 
				if h==ERR_INV_FULL or h==ERR_ITEM_MAX_COUNT then 
					StopOpeningMail("Your bags are too full!")
				end 
			end 
		end)
		
		local SVUI_GetGoldButton=CreateFrame("Button","SVUI_GetGoldButton",SVUI_MailMinion,"UIPanelButtonTemplate")
		SVUI_GetGoldButton:SetWidth(70)
		SVUI_GetGoldButton:SetHeight(25)
		SVUI_GetGoldButton:SetStyle("Button")
		SVUI_GetGoldButton:SetPoint("RIGHT",SVUI_MailMinion,"RIGHT",0,0)
		SVUI_GetGoldButton:SetText("Get Gold")
		SVUI_GetGoldButton:SetScript("OnClick",GetAllMailCash)
		SVUI_GetGoldButton:SetScript("OnEnter",function()
			if not total_cash then 
				total_cash=0;
				for a=0,GetInboxNumItems()do 
					total_cash=total_cash + select(5,GetInboxHeaderInfo(a))
				end 
			end 
			GameTooltip:SetOwner(SVUI_GetGoldButton,"ANCHOR_RIGHT")
			GameTooltip:AddLine(FancifyMoneys(total_cash),1,1,1)
			GameTooltip:Show()
		end)
		SVUI_GetGoldButton:SetScript("OnLeave",function()GameTooltip:Hide()end)

		local SVUI_DeleteMailButton=CreateFrame("Button","SVUI_DeleteMailButton",SVUI_MailMinion,"UIPanelButtonTemplate")
		SVUI_DeleteMailButton:SetWidth(70)
		SVUI_DeleteMailButton:SetHeight(25)
		SVUI_DeleteMailButton:SetStyle("Button", false, false, false, false, false, "red")
		SVUI_DeleteMailButton:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT",16,-30)
		SVUI_DeleteMailButton:SetText("Delete All")
		SVUI_DeleteMailButton:SetScript("OnClick",DeleteAllMail)
		SVUI_DeleteMailButton:SetScript("OnEnter",function()
			GameTooltip:SetOwner(SVUI_DeleteMailButton,"ANCHOR_RIGHT")
			GameTooltip:AddLine(string.format("%d messages",GetInboxNumItems()),1,1,1)
			GameTooltip:Show()
		end)
		SVUI_DeleteMailButton:SetScript("OnLeave",function()GameTooltip:Hide()end)

		SV:ToggleMailMinions()
	end
end

SV.Events:On("CORE_INITIALIZED", LoadMailMinions);