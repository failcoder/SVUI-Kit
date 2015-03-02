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
HELPERS
##########################################################
]]--
local FrameSuffix = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right"
};
local FriendsFrameList1 = {
	"ScrollOfResurrectionSelectionFrame",
	"ScrollOfResurrectionSelectionFrameList",
	"FriendsListFrame",
	"FriendsTabHeader",
	"FriendsFrameFriendsScrollFrame",
	"WhoFrameColumnHeader1",
	"WhoFrameColumnHeader2",
	"WhoFrameColumnHeader3",
	"WhoFrameColumnHeader4",
	"ChannelListScrollFrame",
	"ChannelRoster",
	"FriendsFramePendingButton1",
	"FriendsFramePendingButton2",
	"FriendsFramePendingButton3",
	"FriendsFramePendingButton4",
	"ChannelFrameDaughterFrame",
	"AddFriendFrame",
	"AddFriendNoteFrame"
};
-- local FriendsFrameList2 = {
-- 	"FriendsFrameBroadcastInputLeft",
-- 	"FriendsFrameBroadcastInputRight",
-- 	"FriendsFrameBroadcastInputMiddle",
-- 	"ChannelFrameDaughterFrameChannelNameLeft",
-- 	"ChannelFrameDaughterFrameChannelNameRight",
-- 	"ChannelFrameDaughterFrameChannelNameMiddle",
-- 	"ChannelFrameDaughterFrameChannelPasswordLeft",
-- 	"ChannelFrameDaughterFrameChannelPasswordRight",
-- 	"ChannelFrameDaughterFrameChannelPasswordMiddle"
-- };
local FriendsFrameButtons = {
	"FriendsFrameAddFriendButton",
	"FriendsFrameSendMessageButton",
	"WhoFrameWhoButton",
	"WhoFrameAddFriendButton",
	"WhoFrameGroupInviteButton",
	"ChannelFrameNewButton",
	"FriendsFrameIgnorePlayerButton",
	"FriendsFrameUnsquelchButton",
	"FriendsFramePendingButton1AcceptButton",
	"FriendsFramePendingButton1DeclineButton",
	"FriendsFramePendingButton2AcceptButton",
	"FriendsFramePendingButton2DeclineButton",
	"FriendsFramePendingButton3AcceptButton",
	"FriendsFramePendingButton3DeclineButton",
	"FriendsFramePendingButton4AcceptButton",
	"FriendsFramePendingButton4DeclineButton",
	"ChannelFrameDaughterFrameOkayButton",
	"ChannelFrameDaughterFrameCancelButton",
	"AddFriendEntryFrameAcceptButton",
	"AddFriendEntryFrameCancelButton",
	"AddFriendInfoFrameContinueButton",
	"ScrollOfResurrectionSelectionFrameAcceptButton",
	"ScrollOfResurrectionSelectionFrameCancelButton"
};

local function TabCustomHelper(this)
	if not this then return end 
	for _,prop in pairs(FrameSuffix) do 
		local frame = _G[this:GetName()..prop]
		frame:SetTexture("")
	end 
	this:GetHighlightTexture():SetTexture("")
	this.backdrop = CreateFrame("Frame", nil, this)
	this.backdrop:SetStyle("!_Frame", "Default")
	this.backdrop:SetFrameLevel(this:GetFrameLevel()-1)
	this.backdrop:ModPoint("TOPLEFT", 3, -8)
	this.backdrop:ModPoint("BOTTOMRIGHT", -6, 0)
end 

local function ChannelList_OnUpdate()
	for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do 
		local btn = _G["ChannelButton"..i]
		if btn then
			btn:RemoveTextures()
			btn:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
			_G["ChannelButton"..i.."Text"]:SetFontObject(SVUI_Font_Default)
		end 
	end 
end 
--[[ 
########################################################## 
FRIENDSFRAME MODR
##########################################################
]]--FriendsFrameBattlenetFrameScrollFrame
local function FriendsFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.friends ~= true then
		 return 
	end

	SV.API:Set("Window", FriendsFrame)

	FriendsFrameInset:RemoveTextures()
	WhoFrameListInset:RemoveTextures()
	WhoFrameEditBoxInset:RemoveTextures()
	SV.API:Set("EditBox", WhoFrameEditBoxInset)
	ChannelFrameRightInset:RemoveTextures()
	ChannelFrameLeftInset:RemoveTextures()
	ChannelFrameRightInset:SetStyle("!_Frame", "Model")
	ChannelFrameLeftInset:SetStyle("!_Frame", "Model")
	LFRQueueFrameListInset:RemoveTextures()
	LFRQueueFrameRoleInset:RemoveTextures()
	LFRQueueFrameCommentInset:RemoveTextures()
	LFRQueueFrameListInset:SetStyle("!_Frame", "Model")
	FriendsFrameInset:SetStyle("!_Frame", "Model")
	--FriendsFrameFriendsScrollFrame:SetStyle("!_Frame", "Model")
	WhoFrameListInset:SetStyle("!_Frame", "Model")
	--RaidFrame:SetStyle("!_Frame", "Model")

	for _, frame in pairs(FriendsFrameButtons)do
		if(_G[frame]) then
			_G[frame]:SetStyle("Button")
		end
	end 

	-- for c, texture in pairs(FriendsFrameList2)do
	-- 	 _G[texture]:Die()
	-- end 

	for _, frame in pairs(FriendsFrameList1) do
		if(_G[frame]) then
			_G[frame]:RemoveTextures(true)
		end
	end 

	for i = 1, FriendsFrame:GetNumRegions()do 
		local a1 = select(i, FriendsFrame:GetRegions())
		if a1:GetObjectType() == "Texture"then
			a1:SetTexture("")
			a1:SetAlpha(0)
		end 
	end

	FriendsFrameFriendsScrollFrame:DisableDrawLayer("BACKGROUND")

	SV.API:Set("ScrollFrame", FriendsFrameFriendsScrollFrameScrollBar, 5)
	SV.API:Set("ScrollFrame", WhoListScrollFrameScrollBar, 5)
	SV.API:Set("ScrollFrame", ChannelRosterScrollFrameScrollBar, 5)
	
	FriendsFrameStatusDropDown:SetPoint('TOPLEFT', FriendsTabHeader, 'TOPLEFT', 0, -27)
	SV.API:Set("DropDown", FriendsFrameStatusDropDown, 70)
	FriendsFrameBattlenetFrame:RemoveTextures()
	FriendsFrameBattlenetFrame:SetHeight(22)
	FriendsFrameBattlenetFrame:SetPoint('TOPLEFT', FriendsFrameStatusDropDown, 'TOPRIGHT', 0, -1)
	FriendsFrameBattlenetFrame:SetStyle("!_Frame", "Inset")
	FriendsFrameBattlenetFrame:SetBackdropColor(0,0,0,0.8)
	
	-- FriendsFrameBattlenetFrame.BroadcastButton:GetNormalTexture():SetTexCoord(.28, .72, .28, .72)
	-- FriendsFrameBattlenetFrame.BroadcastButton:GetPushedTexture():SetTexCoord(.28, .72, .28, .72)
	-- FriendsFrameBattlenetFrame.BroadcastButton:GetHighlightTexture():SetTexCoord(.28, .72, .28, .72)
	FriendsFrameBattlenetFrame.BroadcastButton:RemoveTextures()
	FriendsFrameBattlenetFrame.BroadcastButton:SetSize(22,22)
	FriendsFrameBattlenetFrame.BroadcastButton:SetPoint('TOPLEFT', FriendsFrameBattlenetFrame, 'TOPRIGHT', 8, 0)
	FriendsFrameBattlenetFrame.BroadcastButton:SetStyle("Button")
	FriendsFrameBattlenetFrame.BroadcastButton:SetBackdropColor(0.4,0.4,0.4)
	FriendsFrameBattlenetFrame.BroadcastButton:SetNormalTexture([[Interface\FriendsFrame\UI-Toast-BroadcastIcon]])
	FriendsFrameBattlenetFrame.BroadcastButton:SetPushedTexture([[Interface\FriendsFrame\UI-Toast-BroadcastIcon]])
	FriendsFrameBattlenetFrame.BroadcastButton:SetScript('OnClick', function()
		SV:StaticPopup_Show("SET_BN_BROADCAST")
	end)
	FriendsFrameBattlenetFrame.Tag:SetFontObject(SVUI_Font_Narrator)
	AddFriendNameEditBox:SetStyle("Editbox")
	AddFriendFrame:SetStyle("!_Frame", "Transparent", true)
	ScrollOfResurrectionSelectionFrame:SetStyle("!_Frame", 'Transparent')
	ScrollOfResurrectionSelectionFrameList:SetStyle("!_Frame", 'Default')
	SV.API:Set("ScrollFrame", ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)
	ScrollOfResurrectionSelectionFrameTargetEditBox:SetStyle("Editbox")
	FriendsFrameBroadcastInput:SetStyle("Frame", "Default")
	ChannelFrameDaughterFrameChannelName:SetStyle("Frame", "Default")
	ChannelFrameDaughterFrameChannelPassword:SetStyle("Frame", "Default")
	
	ChannelFrame:HookScript("OnShow", function()
		ChannelRosterScrollFrame:RemoveTextures()
	end)

	hooksecurefunc("FriendsFrame_OnEvent", function()
		ChannelRosterScrollFrame:RemoveTextures()
	end)

	WhoFrame:HookScript("OnShow", function()
		ChannelRosterScrollFrame:RemoveTextures()
	end)

	hooksecurefunc("FriendsFrame_OnEvent", function()
		WhoListScrollFrame:RemoveTextures()
	end)

	ChannelFrameDaughterFrame:SetStyle("Frame", 'Inset')
	SV.API:Set("CloseButton", ChannelFrameDaughterFrameDetailCloseButton, ChannelFrameDaughterFrame)
	SV.API:Set("CloseButton", FriendsFrameCloseButton, FriendsFrame.Panel)
	SV.API:Set("DropDown", WhoFrameDropDown, 150)

	for i = 1, 4 do
		 SV.API:Set("Tab", _G["FriendsFrameTab"..i])
	end 

	for i = 1, 3 do
		 TabCustomHelper(_G["FriendsTabHeaderTab"..i])
	end 

	hooksecurefunc("ChannelList_Update", ChannelList_OnUpdate)
	FriendsFriendsFrame:SetStyle("Frame", 'Inset')

	_G["FriendsFriendsFrame"]:RemoveTextures()
	_G["FriendsFriendsList"]:RemoveTextures()
	_G["FriendsFriendsNoteFrame"]:RemoveTextures()

	_G["FriendsFriendsSendRequestButton"]:SetStyle("Button")
	_G["FriendsFriendsCloseButton"]:SetStyle("Button")

	FriendsFriendsList:SetStyle("Editbox")
	FriendsFriendsNoteFrame:SetStyle("Editbox")
	SV.API:Set("DropDown", FriendsFriendsFrameDropDown, 150)
	BNConversationInviteDialog:RemoveTextures()
	BNConversationInviteDialog:SetStyle("Frame", 'Transparent')
	BNConversationInviteDialogList:RemoveTextures()
	BNConversationInviteDialogList:SetStyle("!_Frame", 'Default')
	BNConversationInviteDialogInviteButton:SetStyle("Button")
	BNConversationInviteDialogCancelButton:SetStyle("Button")
	for i = 1, BN_CONVERSATION_INVITE_NUM_DISPLAYED do
		 _G["BNConversationInviteDialogListFriend"..i].checkButton:SetStyle("Checkbox")
	end 
	FriendsTabHeaderSoRButton:SetStyle("!_Frame", 'Default')
	FriendsTabHeaderSoRButton:SetStyle("Button")
	FriendsTabHeaderSoRButtonIcon:SetDrawLayer('OVERLAY')
	FriendsTabHeaderSoRButtonIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	FriendsTabHeaderSoRButtonIcon:InsetPoints()
	FriendsTabHeaderSoRButton:ModPoint('TOPRIGHT', FriendsTabHeader, 'TOPRIGHT', -8, -56)
	FriendsTabHeaderRecruitAFriendButton:SetStyle("!_Frame", 'Default')
	FriendsTabHeaderRecruitAFriendButton:SetStyle("Button")
	FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer('OVERLAY')
	FriendsTabHeaderRecruitAFriendButtonIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	FriendsTabHeaderRecruitAFriendButtonIcon:InsetPoints()
	
	FriendsFrameIgnoreScrollFrame:SetStyle("!_Frame", "Model")
	SV.API:Set("ScrollFrame", FriendsFrameIgnoreScrollFrameScrollBar, 4)
	FriendsFramePendingScrollFrame:SetStyle("!_Frame", "Inset")
	SV.API:Set("ScrollFrame", FriendsFramePendingScrollFrameScrollBar, 4)
	IgnoreListFrame:RemoveTextures()
	PendingListFrame:RemoveTextures()
	ScrollOfResurrectionFrame:RemoveTextures()
	ScrollOfResurrectionFrameAcceptButton:SetStyle("Button")
	ScrollOfResurrectionFrameCancelButton:SetStyle("Button")
	ScrollOfResurrectionFrameTargetEditBoxLeft:SetTexture("")
	ScrollOfResurrectionFrameTargetEditBoxMiddle:SetTexture("")
	ScrollOfResurrectionFrameTargetEditBoxRight:SetTexture("")
	ScrollOfResurrectionFrameNoteFrame:RemoveTextures()
	ScrollOfResurrectionFrameNoteFrame:SetStyle("!_Frame")
	ScrollOfResurrectionFrameTargetEditBox:SetStyle("!_Frame")
	ScrollOfResurrectionFrame:SetStyle("!_Frame", 'Transparent')
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(FriendsFrameStyle)