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

local SV = _G['SVUI']
local L = SV.L
local MOD = SV.Extras;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local takingOnlyCash,deletedelay,mailElapsed,childCount=false,0.5,0,-1;
local GetAllMail, GetAllMailCash, OpenMailItem, DeleteAllMail, DeleteMailItem, WaitForMail, WaitForDelete, StopOpeningMail, FancifyMoneys, lastopened, lastdeleted, needsToWait, waitToDelete, total_cash, baseInboxFrame_OnClick;
local incpat 	  = gsub(gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local changedpat  = gsub(gsub(FACTION_STANDING_CHANGED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local decpat	  = gsub(gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local standing    = ('%s:'):format(STANDING);
local reputation  = ('%s:'):format(REPUTATION);
local hideStatic = false;
local AutomatedEvents = {
	"CHAT_MSG_COMBAT_FACTION_CHANGE",
	"MERCHANT_SHOW",
	"QUEST_COMPLETE",
	"QUEST_GREETING",
	"GOSSIP_SHOW",
	"QUEST_DETAIL",
	"QUEST_ACCEPT_CONFIRM",
	"QUEST_PROGRESS"
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local InboxFrame_OnClick = _G.InboxFrame_OnClick;
--DeleteInboxItem
function GetAllMail()
	if(GetInboxNumItems() == 0) then return end 
	SVUI_GetMailButton:SetScript("OnClick", nil)
	SVUI_GetGoldButton:SetScript("OnClick", nil)
	SVUI_DeleteMailButton:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = SV.fubar
	SVUI_GetMailButton:RegisterEvent("UI_ERROR_MESSAGE")
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
		SVUI_GetMailButton:SetScript("OnUpdate",WaitForMail)
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
		SVUI_GetMailButton:SetScript("OnUpdate", nil)
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
	SVUI_GetMailButton:SetScript("OnClick", nil)
	SVUI_GetGoldButton:SetScript("OnClick", nil)
	SVUI_DeleteMailButton:SetScript("OnClick", nil)
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
		SVUI_DeleteMailButton:SetScript("OnUpdate", WaitForDelete)
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
		SVUI_DeleteMailButton:SetScript("OnUpdate", nil)
		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastdeleted)
		if(((not money) or (money and money == 0)) or ((not itemCount) or (itemCount and itemCount > 0))) then
			DeleteMailItem(lastdeleted)
		else
			DeleteMailItem(lastdeleted - 1)
		end
	end 
end

function StopOpeningMail(msg, ...)
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

function FancifyMoneys(cash)
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
function MOD:ToggleMailMinions()
	if not SV.db.Extras.mailOpener then 
		SVUI_MailMinion:Hide()
	else
		SVUI_MailMinion:Show()
	end 
end 

function MOD:LoadMailMinions()
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
end 
--[[ 
########################################################## 
INVITE AUTOMATONS
##########################################################
]]--
function MOD:PARTY_INVITE_REQUEST(event, invitedBy)
	if(not SV.db.Extras.autoAcceptInvite) then return; end

	if(QueueStatusMinimapButton:IsShown() or IsInGroup()) then return end
	if(GetNumFriends() > 0) then 
		ShowFriends() 
	end
	if(IsInGuild()) then 
		GuildRoster() 
	end

	hideStatic = true;
	local invited = false;

	for f = 1, GetNumFriends() do 
		local friend = gsub(GetFriendInfo(f), "-.*", "")
		if(friend == invitedBy) then 
			AcceptGroup()
			invited = true;
			SV:AddonMessage("Accepted an Invite From Your Friends!")
			break;
		end 
	end

	if(not invited) then 
		for b = 1, BNGetNumFriends() do 
			local _, _, _, _, friend = BNGetFriendInfo(b)
			invitedBy = invitedBy:match("(.+)%-.+") or invitedBy;
			if(friend == invitedBy) then 
				AcceptGroup()
				invited = true;
				SV:AddonMessage("Accepted an Invite From Your Friends!")
				break;
			end 
		end 
	end

	if(not invited) then 
		for g = 1, GetNumGuildMembers(true) do 
			local guildMate = gsub(GetGuildRosterInfo(g), "-.*", "")
			if(guildMate == invitedBy) then 
				AcceptGroup()
				invited = true;
				SV:AddonMessage("Accepted an Invite From Your Guild!")
				break;
			end 
		end 
	end

	if(invited) then
		local popup = StaticPopup_FindVisible("PARTY_INVITE")
		if(popup) then
			popup.inviteAccepted = 1
			StaticPopup_Hide("PARTY_INVITE")
		else
			popup = StaticPopup_FindVisible("PARTY_INVITE_XREALM")
			if(popup) then
				popup.inviteAccepted = 1
				StaticPopup_Hide("PARTY_INVITE_XREALM")
			end
		end
	end 
end
--[[ 
########################################################## 
REPAIR AUTOMATONS
##########################################################
]]--
function MOD:MERCHANT_SHOW()
	if(SV.Inventory and SV.db.Extras.vendorGrays) then 
		SV.Inventory:VendorGrays(nil, true) 
	end
	local autoRepair = SV.db.Extras.autoRepair;
	local guildRepair = (autoRepair == "GUILD");
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then return end 
	local repairCost,canRepair = GetRepairAllCost()
		 
	if repairCost > 0 then
		local loan = GetGuildBankWithdrawMoney()
		if(guildRepair and ((not CanGuildBankRepair()) or (loan ~= -1 and (repairCost > loan)))) then 
			guildRepair = false 
		end
		if canRepair then 
			RepairAllItems(guildRepair)
			local x,y,z= repairCost % 100,floor((repairCost % 10000)/100), floor(repairCost / 10000)
			if(guildRepair) then 
				SV:AddonMessage("Repairs Complete! ...Using Guild Money!\n"..GetCoinTextureString(repairCost,12))
			else 
				SV:AddonMessage("Repairs Complete!\n"..GetCoinTextureString(repairCost,12))
			end 
		else 
			SV:AddonMessage("The Minions Say You Are Too Broke To Repair! They Are Laughing..")
		end 
	end 
end
--[[ 
########################################################## 
REP AUTOMATONS
##########################################################
]]--
function MOD:CHAT_MSG_COMBAT_FACTION_CHANGE(event, msg)
	if not SV.db.Extras.autorepchange then return end 
	local _, _, faction, amount = msg:find(incpat)
	if not faction then 
		_, _, faction, amount = msg:find(changedpat) or msg:find(decpat) 
	end
	if faction and faction ~= GUILD_REPUTATION then
		local active = GetWatchedFactionInfo()
		for factionIndex = 1, GetNumFactions() do
			local name = GetFactionInfo(factionIndex)
			if name == faction and name ~= active then
				SetWatchedFactionIndex(factionIndex)
				local strMsg = ("Watching Faction: %s"):format(name)
				SV:AddonMessage(strMsg)
				break
			end
		end
	end
end
--[[ 
########################################################## 
QUEST AUTOMATONS
##########################################################
]]--
function MOD:AutoQuestProxy()
	if(IsShiftKeyDown()) then return false; end
    if((not QuestIsDaily() or not QuestIsWeekly()) and (SV.db.Extras.autodailyquests)) then return false; end
    if(QuestFlagsPVP() and (not SV.db.Extras.autopvpquests)) then return false; end
    return true
end

function MOD:QUEST_GREETING()
    if(SV.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        local active,available = GetNumActiveQuests(), GetNumAvailableQuests()
        if(active + available == 0) then return end
        if(available > 0) then
            SelectAvailableQuest(1)
        end
        if(active > 0) then
            SelectActiveQuest(1)
        end
    end
end

function MOD:GOSSIP_SHOW()
    if(SV.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        if GetGossipAvailableQuests() then
            SelectGossipAvailableQuest(1)
        elseif GetGossipActiveQuests() then
            SelectGossipActiveQuest(1)
        end
    end
end

function MOD:QUEST_DETAIL()
    if(SV.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then 
        if not QuestGetAutoAccept() then
			AcceptQuest()
		else
			CloseQuest()
		end
    end
end

function MOD:QUEST_ACCEPT_CONFIRM()
    if(SV.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        ConfirmAcceptQuest()
        StaticPopup_Hide("QUEST_ACCEPT_CONFIRM")
    end
end

function MOD:QUEST_PROGRESS()
	if(IsShiftKeyDown()) then return false; end
    if(SV.db.Extras.autoquestcomplete == true and IsQuestCompletable()) then
        CompleteQuest()
    end
end

function MOD:QUEST_COMPLETE()
	if(not SV.db.Extras.autoquestcomplete and (not SV.db.Extras.autoquestreward)) then return end 
	if(IsShiftKeyDown()) then return false; end
	local rewards = GetNumQuestChoices()
	local rewardsFrame = QuestInfoFrame.rewardsFrame;
	if(rewards > 1) then
		local auto_select = QuestFrameRewardPanel.itemChoice or QuestInfoFrame.itemChoice;
		local selection, value = 1, 0;
		
		for i = 1, rewards do 
			local iLink = GetQuestItemLink("choice", i)
			if iLink then 
				local iValue = select(11,GetItemInfo(iLink))
				if iValue and iValue > value then 
					value = iValue;
					selection = i 
				end 
			end 
		end

		local chosenItem = QuestInfo_GetRewardButton(rewardsFrame, selection)
		
		if chosenItem.type == "choice" then 
			QuestInfoItemHighlight:ClearAllPoints()
			QuestInfoItemHighlight:SetAllPoints(chosenItem)
			QuestInfoItemHighlight:Show()
			QuestInfoFrame.itemChoice = chosenItem:GetID()
			SV:AddonMessage("A Minion Has Chosen Your Reward!")
		end

		auto_select = selection

		if SV.db.Extras.autoquestreward == true then
			GetQuestReward(auto_select)
		end
	else
		if(SV.db.Extras.autoquestcomplete == true) then
			GetQuestReward(rewards)
		end
	end
end 
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:Load()
	if IsAddOnLoaded("Postal") then 
		SV.db.Extras.mailOpener = false
	else
		self:LoadMailMinions()
		self:ToggleMailMinions()
	end 

	self:RegisterEvent('PARTY_INVITE_REQUEST')

	for _,event in pairs(AutomatedEvents) do
		self:RegisterEvent(event)
	end

	if SV.db.Extras.pvpautorelease then 
		local autoReleaseHandler = CreateFrame("frame")
		autoReleaseHandler:RegisterEvent("PLAYER_DEAD")
		autoReleaseHandler:SetScript("OnEvent",function(self,event)
			local isInstance, instanceType = IsInInstance()
			if(isInstance and instanceType == "pvp") then 
				local spell = GetSpellInfo(20707)
				if(SV.class ~= "SHAMAN" and not(spell and UnitBuff("player",spell))) then 
					RepopMe()
				end 
			end 
			for i=1,GetNumWorldPVPAreas() do 
				local _,localizedName, isActive = GetWorldPVPAreaInfo(i)
				if(GetRealZoneText() == localizedName and isActive) then RepopMe() end 
			end 
		end)
	end 

	if(SV.db.Extras.skipcinematics) then
		local skippy = CreateFrame("Frame")
		skippy:RegisterEvent("CINEMATIC_START")
		skippy:SetScript("OnEvent", function(self, event)
			CinematicFrame_CancelCinematic()
		end)

		MovieFrame:SetScript("OnEvent", function() GameMovieFinished() end)
	end

	self:CreateTotemBar()
	self:SetMountCheckButtons()
	self:ToggleReactions()
	self:LoadDressupHelper()
end 