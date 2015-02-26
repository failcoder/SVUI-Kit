--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local next    	= _G.next;
local time 		= _G.time;
local date 		= _G.date;
local ceil, modf = math.ceil, math.modf;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local format = string.format;
local internalTest = false;

local GuildFrameList = {	
	"GuildNewPerksFrame",
	"GuildFrameInset",
	"GuildFrameBottomInset",
	"GuildAllPerksFrame",
	"GuildMemberDetailFrame",
	"GuildMemberNoteBackground",
	"GuildInfoFrameInfo",
	"GuildLogContainer",
	"GuildLogFrame",
	"GuildRewardsFrame",
	"GuildMemberOfficerNoteBackground",
	"GuildTextEditContainer",
	"GuildTextEditFrame",
	"GuildRecruitmentRolesFrame",
	"GuildRecruitmentAvailabilityFrame",
	"GuildRecruitmentInterestFrame",
	"GuildRecruitmentLevelFrame",
	"GuildRecruitmentCommentFrame",
	"GuildRecruitmentCommentInputFrame",
	"GuildInfoFrameApplicantsContainer",
	"GuildInfoFrameApplicants",
	"GuildNewsBossModel",
	"GuildNewsBossModelTextFrame"
};

local GuildButtonList = {
	"GuildPerksToggleButton",
	"GuildMemberRemoveButton",
	"GuildMemberGroupInviteButton",
	"GuildAddMemberButton",
	"GuildViewLogButton",
	"GuildControlButton",
	"GuildRecruitmentListGuildButton",
	"GuildTextEditFrameAcceptButton",
	"GuildRecruitmentInviteButton",
	"GuildRecruitmentMessageButton",
	"GuildRecruitmentDeclineButton"
};

local GuildCheckBoxList = {
	"GuildRecruitmentQuestButton",
	"GuildRecruitmentDungeonButton",
	"GuildRecruitmentRaidButton",
	"GuildRecruitmentPvPButton",
	"GuildRecruitmentRPButton",
	"GuildRecruitmentWeekdaysButton",
	"GuildRecruitmentWeekendsButton",
	"GuildRecruitmentLevelAnyButton",
	"GuildRecruitmentLevelMaxButton"
};

local CalendarIconList = {
	[CALENDAR_EVENTTYPE_PVP] = "Interface\\Calendar\\UI-Calendar-Event-PVP",
	[CALENDAR_EVENTTYPE_MEETING] = "Interface\\Calendar\\MeetingIcon",
	[CALENDAR_EVENTTYPE_OTHER] = "Interface\\Calendar\\UI-Calendar-Event-Other"
};

local LFGFrameList = {  
  "LookingForGuildPvPButton",
  "LookingForGuildWeekendsButton",
  "LookingForGuildWeekdaysButton",
  "LookingForGuildRPButton",
  "LookingForGuildRaidButton",
  "LookingForGuildQuestButton",
  "LookingForGuildDungeonButton"
};

local function GCTabHelper(tab)
	tab.Panel:Hide()
	tab.bg1 = tab:CreateTexture(nil,"BACKGROUND")
	tab.bg1:SetDrawLayer("BACKGROUND",4)
	tab.bg1:SetTexture(SV.BaseTexture)
	tab.bg1:SetVertexColor(unpack(SV.media.color.default))
	tab.bg1:InsetPoints(tab.Panel,1)
	tab.bg3 = tab:CreateTexture(nil,"BACKGROUND")
	tab.bg3:SetDrawLayer("BACKGROUND",2)
	tab.bg3:SetTexture(0,0,0,1)
	tab.bg3:SetAllPoints(tab.Panel) 
end

local function Tab_OnEnter(this)
	this.backdrop:SetBackdropColor(0.1, 0.8, 0.8)
	this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Tab_OnLeave(this)
	this.backdrop:SetBackdropColor(0,0,0,1)
	this.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this)
	this:RemoveTextures()
	local nTex = this:GetNormalTexture()
	if(nTex) then
		nTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		nTex:InsetPoints()
	end

	this.pushed = true;

	this.backdrop = CreateFrame("Frame", nil, this)
	this.backdrop:WrapPoints(this,1,1)
	this.backdrop:SetFrameLevel(0)
	this.backdrop:SetBackdrop(SV.media.backdrop.glow);
    this.backdrop:SetBackdropColor(0,0,0,1)
	this.backdrop:SetBackdropBorderColor(0,0,0,1)
	this:SetScript("OnEnter", Tab_OnEnter)
	this:SetScript("OnLeave", Tab_OnLeave)

	local a,b,c,d,e = this:GetPoint()
	this:ModPoint(a,b,c,1,e)
end 

local function StyleSortingButton(button)
	if button.styled then return end 

	local outer = button:CreateTexture(nil, "OVERLAY")
	outer:WrapPoints(button, 6, 6)
	outer:SetTexture(SV.media.button.round)
	outer:SetGradient("VERTICAL", 0.4, 0.47, 0.5, 0.3, 0.33, 0.35) 
	
	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:WrapPoints(button, 6, 6)

	if button.SetNormalTexture then 
		local iconTex = button:GetNormalTexture()
		iconTex:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
		SetPortraitToTexture(icon, iconTex)
		hooksecurefunc(icon, "SetTexture", SetPortraitToTexture)
	end

	local hover = button:CreateTexture(nil, "HIGHLIGHT")
	hover:WrapPoints(button, 6, 6)
	hover:SetTexture(SV.media.button.round)
	hover:SetGradient(unpack(SV.media.gradient.yellow))

	if button.SetPushedTexture then 
		local pushed = button:CreateTexture(nil, "BORDER")
		pushed:WrapPoints(button, 6, 6)
		pushed:SetTexture(SV.media.button.round)
		pushed:SetGradient(unpack(SV.media.gradient.highlight))
		button:SetPushedTexture(pushed)
	end 

	if button.SetCheckedTexture then 
		local checked = button:CreateTexture(nil, "BORDER")
		checked:WrapPoints(button, 6, 6)
		checked:SetTexture(SV.media.button.round)
		checked:SetGradient(unpack(SV.media.gradient.green))
		button:SetCheckedTexture(checked)
	end 

	if button.SetDisabledTexture then 
		local disabled = button:CreateTexture(nil, "BORDER")
		disabled:WrapPoints(button, 6, 6)
		disabled:SetTexture(SV.media.button.round)
		disabled:SetGradient(unpack(SV.media.gradient.default))
		button:SetDisabledTexture(disabled)
	end 

	local cd = button:GetName() and _G[button:GetName().."Cooldown"]
	if cd then 
		cd:ClearAllPoints()
		cd:InsetPoints()
	end 
	button.styled = true
end

local _hook_RankOrder_OnUpdate = function()
	for i = 1, GuildControlGetNumRanks()do 
		local frame = _G["GuildControlUIRankOrderFrameRank"..i]
		if frame then 
			frame.downButton:SetStyle("Button")
			frame.upButton:SetStyle("Button")
			frame.deleteButton:SetStyle("Button")
			if not frame.nameBox.Panel then 
				frame.nameBox:SetStyle("Editbox")
			end 
			frame.nameBox.Panel:ModPoint("TOPLEFT",-2,-4)
			frame.nameBox.Panel:ModPoint("BOTTOMRIGHT",-4,4)
		end 
	end 
end 

local function GuildInfoEvents_SetButton(button, eventIndex)
	local dateData = date("*t")
	local month, day, weekday, hour, minute, eventType, title, calendarType, textureName = CalendarGetGuildEventInfo(eventIndex)
	local formattedTime = GameTime_GetFormattedTime(hour, minute, true)
	local unformattedText;
	if dateData["day"] == day and dateData["month"] == month then
		unformattedText = NORMAL_FONT_COLOR_CODE..GUILD_EVENT_TODAY..FONT_COLOR_CODE_CLOSE 
	else
		local year = dateData["year"]
		if month < dateData["month"] then
			year = year + 1 
		end 
		local newTime = time{year = year, month = month, day = day}
		if(((newTime - time()) < 518400) and CALENDAR_WEEKDAY_NAMES[weekday]) then
			unformattedText = CALENDAR_WEEKDAY_NAMES[weekday]
		elseif CALENDAR_WEEKDAY_NAMES[weekday]and day and month then 
			unformattedText = format(GUILD_NEWS_DATE, CALENDAR_WEEKDAY_NAMES[weekday], day, month)
		end 
	end 
	if button.text and unformattedText then
		button.text:SetFormattedText(GUILD_EVENT_FORMAT, unformattedText, formattedTime, title)
	end 
	button.index = eventIndex;
	if button.icon.type ~= "event" then
		button.icon.type = "event"
		button.icon:SetTexCoord(0, 1, 0, 1)
		button.icon:SetWidth(14)
		button.icon:SetHeight(14)
	end 
	if CalendarIconList[eventType] then
		button.icon:SetTexture(CalendarIconList[eventType])
	else
		button.icon:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureName)
	end 
end

local _hook_UIRankOrder = function(self)
	SV.Timers:ExecuteTimer(1, _hook_RankOrder_OnUpdate)
end

local _hook_GuildBankFrame_Update = function(self)
	if GuildBankFrame.mode ~= "bank" then return end 
	local curTab = GetCurrentGuildBankTab()
	local numSlots = NUM_SLOTS_PER_GUILDBANK_GROUP
	local maxSlots = MAX_GUILDBANK_SLOTS_PER_TAB
	local button, btnName, btnID, slotID, itemLink;
	for i = 1, maxSlots do
		btnID = i % numSlots
		if btnID == 0 then
			btnID = numSlots 
		end
		slotID = ceil((i - 0.5) / numSlots)
		btnName = ("GuildBankColumn%dButton%d"):format(slotID, btnID)
		button = _G[btnName]
		if(button) then
			itemLink = GetGuildBankItemLink(curTab, i)
			local r, g, b, a = 0,0,0,1
			if(itemLink) then
				local quality = select(3, GetItemInfo(itemLink))
				if(quality > 1) then
					r, g, b = GetItemQualityColor(quality)
				end
			end 
			button:SetBackdropBorderColor(r, g, b, a)
		end
	end 
end

local _hook_BankTabPermissions = function(self)
	local tab, tabs, baseName, ownedName, purchase, view, stack, deposit, update

	tabs = GetNumGuildBankTabs()

	if tabs < MAX_BUY_GUILDBANK_TABS then 
		tabs = tabs + 1 
	end

	for i = 1, tabs do 
		baseName = ("GuildControlBankTab%d"):format(i)
		ownedName = ("%sOwned"):format(baseName)
		tab = _G[ownedName]
		
		if(tab) then
			if(tab.tabIcon) then tab.tabIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS)) end
			if(tab.editBox) then tab.editBox:SetStyle("Editbox") end

			if internalTest == false then
				purchase =  _G[baseName.."BuyPurchaseButton"]
				if(purchase) then
					purchase:SetStyle("Button")
				end
				view =  _G[ownedName.."ViewCheck"]
				if(view) then
					view:SetStyle("Checkbox")
					GCTabHelper(view)
				end
				stack =  _G[ownedName.."StackBox"]
				if(stack) then
					stack:SetStyle("Editbox")
					GCTabHelper(stack)
				end
				deposit =  _G[ownedName.."DepositCheck"]
				if(deposit) then
					deposit:SetStyle("Checkbox")
					GCTabHelper(deposit)
				end
				update =  _G[ownedName.."UpdateInfoCheck"]
				if(update) then
					update:SetStyle("Checkbox")
					GCTabHelper(update)
				end
			end
		end
	end 
	internalTest = true 
end
--[[ 
########################################################## 
GUILDFRAME MODRS
##########################################################
]]--
local function GuildBankStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.gbank ~= true then
		return 
	end

	SV.API:Set("Window", GuildBankFrame)

	GuildBankEmblemFrame:RemoveTextures(true)
	GuildBankMoneyFrameBackground:Die()
	SV.API:Set("ScrollFrame", GuildBankPopupScrollFrameScrollBar)

	for i = 1, GuildBankFrame:GetNumChildren() do 
		local child = select(i, GuildBankFrame:GetChildren())
		if(child and child.GetPushedTexture and child:GetPushedTexture() and not child:GetName()) then
			SV.API:Set("CloseButton", child)
		end 
	end

	GuildBankFrameDepositButton:SetStyle("Button")
	GuildBankFrameWithdrawButton:SetStyle("Button")
	GuildBankInfoSaveButton:SetStyle("Button")
	GuildBankFramePurchaseButton:SetStyle("Button")

	-- local BAGS = SV.Inventory
	-- if(BAGS) then
		-- local sortButton = CreateFrame("Button", nil, GuildBankFrame)
		-- sortButton:ModPoint("BOTTOMLEFT", GuildBankFrame, "BOTTOMRIGHT", 2, 0)
		-- sortButton:ModSize(36, 36)
		-- sortButton:SetNormalTexture(BAGS.media.cleanupIcon)
		-- StyleSortingButton(sortButton)
		-- local Sort_OnClick = BAGS:RunSortingProcess(BAGS.Sort, "guild")
		-- sortButton:SetScript("OnClick", Sort_OnClick)
	-- end

	GuildBankFrameWithdrawButton:ModPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)
	GuildBankInfoScrollFrame:ModPoint('TOPLEFT', GuildBankInfo, 'TOPLEFT', -10, 12)
	GuildBankInfoScrollFrame:RemoveTextures()
	GuildBankInfoScrollFrame:ModWidth(GuildBankInfoScrollFrame:GetWidth()-8)
	GuildBankTransactionsScrollFrame:RemoveTextures()
	
	for i = 1, NUM_GUILDBANK_COLUMNS do
		local frame = _G["GuildBankColumn"..i]
		if(frame) then
			frame:RemoveTextures()
			local baseName = ("GuildBankColumn%dButton"):format(i)
			for slotID = 1, NUM_SLOTS_PER_GUILDBANK_GROUP do 
				local btnName = ("%s%d"):format(baseName, slotID)
				local button = _G[btnName]
				if(button) then
					local texture = _G[btnName.."NormalTexture"]
					if texture then
						texture:SetTexture("")
					end
					button:RemoveTextures()
					button:SetStyle("Button[SLOT]")

					local icon = _G[btnName.."IconTexture"]
					if(icon) then
						icon:InsetPoints()
						icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
					end
				end
			end
		end
	end 

	for i = 1, 8 do
		local baseName = ("GuildBankTab%d"):format(i)
		local tab = _G[baseName]
		if(tab) then
			tab:RemoveTextures(true)
			local btnName = ("%sButton"):format(baseName)
			local button = _G[btnName]
			if(button) then
				button:RemoveTextures()
				button:SetStyle("Button")
				local texture = _G[btnName.."IconTexture"]
				if(texture) then
					texture:InsetPoints()
					texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				end
			end
		end
	end 

	for i = 1, 4 do
		local baseName = ("GuildBankFrameTab%d"):format(i)
		local frame = _G[baseName]
		if(frame) then
			SV.API:Set("Tab", _G[baseName])
		end
	end 

	hooksecurefunc('GuildBankFrame_Update', _hook_GuildBankFrame_Update)

	GuildBankPopupFrame:RemoveTextures()
	GuildBankPopupScrollFrame:RemoveTextures()
	GuildBankPopupFrame:SetStyle("Frame", "Transparent", true)
	GuildBankPopupFrame:ModPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 1, -30)
	GuildBankPopupOkayButton:SetStyle("Button")
	GuildBankPopupCancelButton:SetStyle("Button")
	GuildBankPopupEditBox:SetStyle("Editbox")
	GuildBankPopupNameLeft:Die()
	GuildBankPopupNameRight:Die()
	GuildBankPopupNameMiddle:Die()
	GuildItemSearchBox:RemoveTextures()
	GuildItemSearchBox:SetStyle("Frame", "Overlay")
	GuildItemSearchBox.Panel:ModPoint("TOPLEFT", 10, -1)
	GuildItemSearchBox.Panel:ModPoint("BOTTOMRIGHT", 4, 1)

	for i = 1, 16 do
		local btnName = ("GuildBankPopupButton%d"):format(i)
		local button = _G[btnName]
		if(button) then
			button:RemoveTextures()
			button:SetStyle("Frame", "Default")
			button:SetStyle("Button")

			local icon = _G[btnName.."Icon"]
			if(icon) then
				icon:InsetPoints()
				icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			end
		end
	end 

	SV.API:Set("ScrollFrame", GuildBankTransactionsScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", GuildBankInfoScrollFrameScrollBar)
end 

local function GuildFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.guild ~= true then
		return 
	end
	
	SV.API:Set("Window", GuildFrame)

	SV.API:Set("CloseButton", GuildMemberDetailCloseButton)
	SV.API:Set("CloseButton", GuildFrameCloseButton)
	GuildRewardsFrameVisitText:ClearAllPoints()
	GuildRewardsFrameVisitText:SetPoint("TOP", GuildRewardsFrame, "TOP", 0, 30)

	for i = 1, #GuildFrameList do
		local frame = _G[GuildFrameList[i]]
		if(frame) then
			frame:RemoveTextures()
		end
	end

	for i = 1, #GuildButtonList do
		local button = _G[GuildButtonList[i]]
		if(button) then
			button:RemoveTextures(true)
			button:SetStyle("Button")
		end
	end 

	for i = 1, #GuildCheckBoxList do
		local check = _G[GuildCheckBoxList[i]]
		if(check) then check:SetStyle("Checkbox") end
	end 

	for i = 1, 5 do
		local tab = _G["GuildFrameTab"..i]
		if(tab) then
			SV.API:Set("Tab", tab)
			if i == 1 then
				tab:ModPoint("TOPLEFT", GuildFrame, "BOTTOMLEFT", -10, 3)
			end
		end
	end
	
	GuildNewsBossModel:SetStyle("Frame", 'Transparent')
	GuildNewsBossModelTextFrame:SetStyle("Frame", "Default")
	GuildNewsBossModelTextFrame.Panel:ModPoint("TOPLEFT", GuildNewsBossModel.Panel, "BOTTOMLEFT", 0, -1)
	GuildNewsBossModel:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)

	GuildRecruitmentTankButton.checkButton:SetStyle("Checkbox")
	GuildRecruitmentHealerButton.checkButton:SetStyle("Checkbox")
	GuildRecruitmentDamagerButton.checkButton:SetStyle("Checkbox")

	GuildFactionBar:RemoveTextures()
	GuildFactionBar.progress:SetTexture(SV.BaseTexture)
	GuildFactionBar:SetStyle("Frame[INSET]", "Transparent")
	GuildFactionBar.Panel:ModPoint("TOPLEFT", GuildFactionBar.progress, "TOPLEFT", -1, 1)
	GuildFactionBar.Panel:ModPoint("BOTTOMRIGHT", GuildFactionBar, "BOTTOMRIGHT", 1, 1)
	
	GuildRosterContainer:SetStyle("Frame[INSET]", "Transparent")
	SV.API:Set("ScrollFrame", GuildRosterContainerScrollBar, 4, -4)
	GuildRosterShowOfflineButton:SetStyle("Checkbox")

	for i = 1, 4 do
		local btn = _G["GuildRosterColumnButton"..i]
		if(btn) then
			btn:RemoveTextures(true)
		end
	end 

	SV.API:Set("DropDown", GuildRosterViewDropdown, 200)

	for i = 1, 14 do
		local btn = _G["GuildRosterContainerButton"..i.."HeaderButton"]
		if(btn) then
			btn:RemoveTextures()
			btn:SetStyle("Button")
		end
	end

	GuildMemberDetailFrame:SetStyle("Frame", "Default", true)
	GuildMemberNoteBackground:SetStyle("Frame", 'Transparent')
	GuildMemberOfficerNoteBackground:SetStyle("Frame", 'Transparent')

	SV.API:Set("DropDown", GuildMemberRankDropdown, 182)
	GuildMemberRankDropdown:HookScript("OnShow", function() GuildMemberDetailRankText:Hide() end)
	GuildMemberRankDropdown:HookScript("OnHide", function() GuildMemberDetailRankText:Show() end)
	GuildNewsFrame:RemoveTextures()
	GuildNewsContainer:SetStyle("Frame[INSET]", "Transparent")

	for i = 1, 17 do
		local btn = _G["GuildNewsContainerButton"..i]
		if(btn) then
			if(btn.header) then btn.header:Die() end
			btn:RemoveTextures()
			btn:SetStyle("Button")
		end 
	end 

	GuildNewsFiltersFrame:RemoveTextures()
	GuildNewsFiltersFrame:SetStyle("Frame", "Transparent", true)
	SV.API:Set("CloseButton", GuildNewsFiltersFrameCloseButton)

	for i = 1, 7 do
		local btn = _G["GuildNewsFilterButton"..i]
		if(btn) then
			btn:SetStyle("Checkbox")
		end
	end 

	GuildNewsFiltersFrame:ModPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -20)
	SV.API:Set("ScrollFrame", GuildNewsContainerScrollBar, 4, 4)
	SV.API:Set("ScrollFrame", GuildInfoDetailsFrameScrollBar, 4, 4)

	for i = 1, 3 do
		local tab = _G["GuildInfoFrameTab"..i]
		if(tab) then
			tab:RemoveTextures()
		end
	end

	local panel1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	panel1:SetPoint("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -22)
	panel1:SetPoint("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 200)
	panel1:SetStyle("Frame", 'Transparent')

	local panel2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	panel2:SetPoint("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -158)
	panel2:SetPoint("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 118)
	panel2:SetStyle("Frame", 'Transparent')

	local panel3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
	panel3:SetPoint("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -233)
	panel3:SetPoint("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 3)
	panel3:SetStyle("Frame", 'Transparent')

	GuildRecruitmentCommentInputFrame:SetStyle("Frame", "Default")
	GuildTextEditFrame:SetStyle("Frame", "Transparent", true)
	SV.API:Set("ScrollFrame", GuildTextEditScrollFrameScrollBar, 4, 4)
	GuildTextEditContainer:SetStyle("Frame", "Default")

	local editChildren = GuildTextEditFrame:GetNumChildren()

	for i = 1, editChildren do 
		local child = select(i, GuildTextEditFrame:GetChildren())
		if(child:GetName() == "GuildTextEditFrameCloseButton") then
			if(child:GetWidth() < 33) then
				SV.API:Set("CloseButton", child)
			else
				child:SetStyle("Button")
			end
		end 
	end

	SV.API:Set("ScrollFrame", GuildLogScrollFrameScrollBar, 4, 4)
	GuildLogFrame:SetStyle("Frame", 'Transparent')

	local logChildren = GuildLogFrame:GetNumChildren()

	for i = 1, logChildren do 
		local child = select(i, GuildLogFrame:GetChildren())
		if child:GetName() == "GuildLogFrameCloseButton" then 
			if(child:GetWidth() < 33) then
				SV.API:Set("CloseButton", child)
			else
				child:SetStyle("Button")
			end
		end 
	end 

	GuildRewardsFrame:SetStyle("Frame[INSET]", "Transparent")
	SV.API:Set("ScrollFrame", GuildRewardsContainerScrollBar, 4, -4)
	SV.API:Set("ScrollFrame", GuildPerksContainerScrollBar, 4, 2)

	for i = 1, 8 do 
		local button = _G["GuildPerksContainerButton"..i]
		if button then
			button:RemoveTextures()
			SV.API:Set("ItemButton", button, nil, true)
			local icon = button.icon or button.Icon
			if icon then
				icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				icon:ClearAllPoints()
				icon:ModPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
				icon:SetParent(button.Panel)
			end
		end
	end 
	
	for i = 1, 8 do 
		local button = _G["GuildRewardsContainerButton"..i]
		if button then
			button:RemoveTextures()
			SV.API:Set("ItemButton", button)
		end
	end 

	local maxCalendarEvents = CalendarGetNumGuildEvents();
	local scrollFrame = GuildInfoFrameApplicantsContainer;
  	local offset = HybridScrollFrame_GetOffset(scrollFrame);
  	local buttonIndex,counter = 0,0;

	for _,button in next, GuildInfoFrameApplicantsContainer.buttons do
		counter = counter + 1;
		buttonIndex = offset + counter;
		button.selectedTex:Die()
		button:GetHighlightTexture():Die()
		button:SetBackdrop(nil)
	end 
end 

local function GuildControlStyle()
	if SV.db.Skins.blizzard.enable~=true or SV.db.Skins.blizzard.guildcontrol~=true then return end

	GuildControlUI:RemoveTextures()
	GuildControlUIHbar:RemoveTextures()
	GuildControlUIRankBankFrameInset:RemoveTextures()
	GuildControlUIRankBankFrameInsetScrollFrame:RemoveTextures()

	SV.API:Set("Window", GuildControlUI)

	SV.API:Set("ScrollFrame", GuildControlUIRankBankFrameInsetScrollFrameScrollBar)

	hooksecurefunc("GuildControlUI_RankOrder_Update", _hook_RankOrder_OnUpdate)
	GuildControlUIRankOrderFrameNewButton:HookScript("OnClick", _hook_UIRankOrder)

	SV.API:Set("DropDown", GuildControlUINavigationDropDown)
	SV.API:Set("DropDown", GuildControlUIRankSettingsFrameRankDropDown,180)
	GuildControlUINavigationDropDownButton:ModWidth(20)
	GuildControlUIRankSettingsFrameRankDropDownButton:ModWidth(20)

	for i=1, NUM_RANK_FLAGS do
		local check = _G["GuildControlUIRankSettingsFrameCheckbox"..i]
		if(check) then check:SetStyle("Checkbox") end 
	end

	GuildControlUIRankOrderFrameNewButton:SetStyle("Button")
	GuildControlUIRankSettingsFrameGoldBox:SetStyle("Editbox")
	GuildControlUIRankSettingsFrameGoldBox.Panel:ModPoint("TOPLEFT",-2,-4)
	GuildControlUIRankSettingsFrameGoldBox.Panel:ModPoint("BOTTOMRIGHT",2,4)
	GuildControlUIRankSettingsFrameGoldBox:RemoveTextures()
	GuildControlUIRankBankFrame:RemoveTextures()

	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", _hook_BankTabPermissions)

	SV.API:Set("DropDown", GuildControlUIRankBankFrameRankDropDown, 180)

	GuildControlUIRankBankFrameRankDropDownButton:ModWidth(20)
end 


local function GuildRegistrarStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.guildregistrar ~= true then
		return 
	end

	SV.API:Set("Window", GuildRegistrarFrame, true, true)

	GuildRegistrarFrameInset:Die()
	GuildRegistrarFrameEditBox:RemoveTextures()
	GuildRegistrarGreetingFrame:RemoveTextures()

	GuildRegistrarFrameGoodbyeButton:SetStyle("Button")
	GuildRegistrarFrameCancelButton:SetStyle("Button")
	GuildRegistrarFramePurchaseButton:SetStyle("Button")
	SV.API:Set("CloseButton", GuildRegistrarFrameCloseButton)
	GuildRegistrarFrameEditBox:SetStyle("Editbox")

	for i = 1, GuildRegistrarFrameEditBox:GetNumRegions() do 
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if region and region:GetObjectType() == "Texture"then
			if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then 
				region:Die()
			end 
		end 
	end

	GuildRegistrarFrameEditBox:ModHeight(20)

	if(_G["GuildRegistrarButton1"]) then
		_G["GuildRegistrarButton1"]:GetFontString():SetTextColor(1, 1, 1)
	end
	if(_G["GuildRegistrarButton2"]) then
		_G["GuildRegistrarButton2"]:GetFontString():SetTextColor(1, 1, 1)
	end

	GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetTextColor(1, 1, 0)
end 

local function LFGuildFrameStyle()
	if(SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.lfguild ~= true) then return end

	SV.API:Set("Window", LookingForGuildFrame, true)

	for i = 1, #LFGFrameList do
		local check = _G[LFGFrameList[i]]
		if(check) then check:SetStyle("Checkbox") end
	end
	
	LookingForGuildTankButton.checkButton:SetStyle("Checkbox")
	LookingForGuildHealerButton.checkButton:SetStyle("Checkbox")
	LookingForGuildDamagerButton.checkButton:SetStyle("Checkbox")
	LookingForGuildFrameInset:RemoveTextures(false)
	LookingForGuildBrowseButton_LeftSeparator:Die()
	LookingForGuildRequestButton_RightSeparator:Die()

	SV.API:Set("ScrollFrame", LookingForGuildBrowseFrameContainerScrollBar)
	LookingForGuildBrowseButton:SetStyle("Button")
	LookingForGuildRequestButton:SetStyle("Button")

	SV.API:Set("CloseButton", LookingForGuildFrameCloseButton)
	LookingForGuildCommentInputFrame:SetStyle("Frame", "Default")
	LookingForGuildCommentInputFrame:RemoveTextures(false)

	for u = 1, 5 do
		local J = _G["LookingForGuildBrowseFrameContainerButton"..u]
		local K = _G["LookingForGuildAppsFrameContainerButton"..u]
		J:SetBackdrop(nil)
		K:SetBackdrop(nil)
	end

	for u = 1, 3 do
		local tab = _G["LookingForGuildFrameTab"..u]
		SV.API:Set("Tab", tab)
		tab:SetFrameStrata("HIGH")
		tab:SetFrameLevel(99)
	end

	GuildFinderRequestMembershipFrame:RemoveTextures(true)
	GuildFinderRequestMembershipFrame:SetStyle("Frame", "Transparent", true)
	GuildFinderRequestMembershipFrameAcceptButton:SetStyle("Button")
	GuildFinderRequestMembershipFrameCancelButton:SetStyle("Button")
	GuildFinderRequestMembershipFrameInputFrame:RemoveTextures()
	GuildFinderRequestMembershipFrameInputFrame:SetStyle("Frame", "Default")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_GuildBankUI",GuildBankStyle)
MOD:SaveBlizzardStyle("Blizzard_GuildUI",GuildFrameStyle)
MOD:SaveBlizzardStyle("Blizzard_GuildControlUI",GuildControlStyle)
MOD:SaveCustomStyle(GuildRegistrarStyle)
MOD:SaveBlizzardStyle("Blizzard_LookingForGuildUI",LFGuildFrameStyle)