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
GOSSIP MODR
##########################################################
]]--
local function GossipStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.gossip ~= true then return end 

	SV.API:Set("Window", GossipFrame, true, true)

	ItemTextFrame:RemoveTextures(true)
	ItemTextScrollFrame:RemoveTextures()
	SV.API:Set("CloseButton", GossipFrameCloseButton)
	SV.API:Set("PageButton", ItemTextPrevPageButton)
	SV.API:Set("PageButton", ItemTextNextPageButton)
	ItemTextPageText:SetTextColor(1, 1, 1)
	hooksecurefunc(ItemTextPageText, "SetTextColor", function(q, k, l, m)
		if k ~= 1 or l ~= 1 or m ~= 1 then 
			ItemTextPageText:SetTextColor(1, 1, 1)
		end 
	end)
	ItemTextFrame:SetStyle("Frame", "Pattern")
	ItemTextFrameInset:Die()
	SV.API:Set("ScrollFrame", ItemTextScrollFrameScrollBar)
	SV.API:Set("CloseButton", ItemTextFrameCloseButton)
	local r = {"GossipFrameGreetingPanel", "GossipFrameInset", "GossipGreetingScrollFrame"}
	SV.API:Set("ScrollFrame", GossipGreetingScrollFrameScrollBar, 5)
	for s, t in pairs(r)do 
		_G[t]:RemoveTextures()
	end 
	GossipFrame:SetStyle("Frame", "Window")
	GossipGreetingScrollFrame:SetStyle("Frame[INSET]", "Transparent", true)
	GossipGreetingScrollFrame.spellTex = GossipGreetingScrollFrame:CreateTexture(nil, "ARTWORK")
	GossipGreetingScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	GossipGreetingScrollFrame.spellTex:SetPoint("TOPLEFT", 2, -2)
	GossipGreetingScrollFrame.spellTex:ModSize(506, 615)
	GossipGreetingScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
	_G["GossipFramePortrait"]:Die()
	_G["GossipFrameGreetingGoodbyeButton"]:RemoveTextures()
	_G["GossipFrameGreetingGoodbyeButton"]:SetStyle("Button")
	SV.API:Set("CloseButton", GossipFrameCloseButton, GossipFrame.Panel)

	NPCFriendshipStatusBar:RemoveTextures()
	NPCFriendshipStatusBar:SetStatusBarTexture(SV.media.statusbar.default)
	NPCFriendshipStatusBar:SetStyle("Frame", "Transparent")

	NPCFriendshipStatusBar:ClearAllPoints()
	NPCFriendshipStatusBar:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 58, -34)

	NPCFriendshipStatusBar.icon:ModSize(32,32)
	NPCFriendshipStatusBar.icon:ClearAllPoints()
	NPCFriendshipStatusBar.icon:SetPoint("RIGHT", NPCFriendshipStatusBar, "LEFT", 0, -2)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(GossipStyle)