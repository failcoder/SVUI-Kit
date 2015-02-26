--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
credit: Elv.                      original logic from ElvUI. Adapted to SVUI #
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

local MAX_NUM_ITEMS = _G.MAX_NUM_ITEMS
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local QuestFrameList = {
	"QuestLogPopupDetailFrame",
	"QuestLogPopupDetailFrameAbandonButton",
	"QuestLogPopupDetailFrameShareButton",
	"QuestLogPopupDetailFrameTrackButton",
	"QuestLogPopupDetailFrameCancelButton",
	"QuestLogPopupDetailFrameCompleteButton"
};

local function QuestScrollHelper(b, c, d, e)
	b:SetStyle("Frame[INSET]", "Transparent")
	b.spellTex = b:CreateTexture(nil, 'ARTWORK')
	b.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
	if e then
		 b.spellTex:SetPoint("TOPLEFT", 2, -2)
	else
		 b.spellTex:SetPoint("TOPLEFT")
	end 
	b.spellTex:ModSize(c or 506, d or 615)
	b.spellTex:SetTexCoord(0, 1, 0.02, 1)
end

local QuestRewardScrollFrame_OnShow = function(self)
	if(not self.Panel) then
		self:SetStyle("Frame", "Default")
		QuestScrollHelper(self, 509, 630, false)
		self:ModHeight(self:GetHeight() - 2)
	end
	if(self.spellTex) then
		self.spellTex:ModHeight(self:GetHeight() + 217)
	end
end

local function StyleQuestRewards()
	local rewardsFrame = QuestInfoFrame.rewardsFrame
	if(not rewardsFrame) then return end
	local parentName = rewardsFrame:GetName()
	for i = 1, 10 do
		local name = ("%sQuestInfoItem%d"):format(parentName,i)
		SV.API:Set("!_QuestItem", _G[name])
	end
	if(rewardsFrame:GetName() == 'MapQuestInfoRewardsFrame') then
		SV.API:Set("!_QuestItem", rewardsFrame.XPFrame)
		SV.API:Set("!_QuestItem", rewardsFrame.SpellFrame)
		SV.API:Set("!_QuestItem", rewardsFrame.MoneyFrame)
		SV.API:Set("!_QuestItem", rewardsFrame.SkillPointFrame)
		SV.API:Set("!_QuestItem", rewardsFrame.PlayerTitleFrame)
	end
end

local Hook_QuestInfoItem_OnClick = function(self)
	_G.QuestInfoItemHighlight:ClearAllPoints()
	_G.QuestInfoItemHighlight:SetAllPoints(self)
end

local Hook_QuestNPCModel = function(self, _, _, _, x, y)
	_G.QuestNPCModel:ClearAllPoints()
	_G.QuestNPCModel:SetPoint("TOPLEFT", self, "TOPRIGHT", x + 18, y)
end

local _hook_GreetingPanelShow = function(self)
	self:RemoveTextures()

	_G.QuestFrameGreetingGoodbyeButton:SetStyle("Button")
	_G.QuestGreetingFrameHorizontalBreak:Die()
end

local _hook_DetailScrollShow = function(self)
	if not self.Panel then
		self:SetStyle("Frame", "Default")
		QuestScrollHelper(self, 509, 630, false)
	end 
	self.spellTex:ModHeight(self:GetHeight() + 217)
end

local _hook_QuestLogPopupDetailFrameShow = function(self)
	local QuestLogPopupDetailFrameScrollFrame = _G.QuestLogPopupDetailFrameScrollFrame;
	if not QuestLogPopupDetailFrameScrollFrame.spellTex then
		QuestLogPopupDetailFrameScrollFrame:SetStyle("Frame", "Default")
		QuestLogPopupDetailFrameScrollFrame.spellTex = QuestLogPopupDetailFrameScrollFrame:CreateTexture(nil, 'ARTWORK')
		QuestLogPopupDetailFrameScrollFrame.spellTex:SetTexture([[Interface\QuestFrame\QuestBookBG]])
		QuestLogPopupDetailFrameScrollFrame.spellTex:SetPoint("TOPLEFT", 2, -2)
		QuestLogPopupDetailFrameScrollFrame.spellTex:ModSize(514, 616)
		QuestLogPopupDetailFrameScrollFrame.spellTex:SetTexCoord(0, 1, 0.02, 1)
		QuestLogPopupDetailFrameScrollFrame.spellTex2 = QuestLogPopupDetailFrameScrollFrame:CreateTexture(nil, 'BORDER')
		QuestLogPopupDetailFrameScrollFrame.spellTex2:SetTexture([[Interface\FrameGeneral\UI-Background-Rock]])
		QuestLogPopupDetailFrameScrollFrame.spellTex2:InsetPoints()
	end
end
--[[ 
########################################################## 
QUEST MODRS
##########################################################
]]--
local function QuestGreetingStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.greeting ~= true then
		return 
	end
	_G.QuestFrameGreetingPanel:HookScript("OnShow", _hook_GreetingPanelShow)
end 

local function QuestFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.quest ~= true then return end

	SV.API:Set("Window", QuestLogPopupDetailFrame, true, true)
	SV.API:Set("Window", QuestFrame, true, true)

	QuestLogPopupDetailFrameScrollFrame:RemoveTextures()
	QuestProgressScrollFrame:RemoveTextures()
	
	local width = QuestLogPopupDetailFrameScrollFrame:GetWidth()
	QuestLogPopupDetailFrame.ShowMapButton:SetWidth(width)
	QuestLogPopupDetailFrame.ShowMapButton:SetStyle("Button")

	SV.API:Set("Window", QuestLogPopupDetailFrame)

	QuestLogPopupDetailFrameInset:Die()

	for _,i in pairs(QuestFrameList)do
		if(_G[i]) then
			_G[i]:SetStyle("Button")
			_G[i]:SetFrameLevel(_G[i]:GetFrameLevel() + 2)
		end
	end
	QuestLogPopupDetailFrameScrollFrame:HookScript('OnShow', _hook_DetailScrollShow)
	QuestLogPopupDetailFrame:HookScript("OnShow", _hook_QuestLogPopupDetailFrameShow)

	SV.API:Set("CloseButton", QuestLogPopupDetailFrameCloseButton)
	SV.API:Set("ScrollFrame", QuestLogPopupDetailFrameScrollFrameScrollBar, 5)
	SV.API:Set("ScrollFrame", QuestRewardScrollFrameScrollBar)

	QuestGreetingScrollFrame:RemoveTextures()
	SV.API:Set("ScrollFrame", QuestGreetingScrollFrameScrollBar)

	for i = 1, 10 do
		local name = ("QuestInfoRewardsFrameQuestInfoItem%d"):format(i)
		SV.API:Set("!_QuestItem", _G[name])
	end

	for i = 1, 10 do
		local name = ("MapQuestInfoRewardsFrameQuestInfoItem%d"):format(i)
		SV.API:Set("!_QuestItem", _G[name])
	end

	QuestInfoSkillPointFrame:RemoveTextures()
	QuestInfoSkillPointFrame:ModWidth(QuestInfoSkillPointFrame:GetWidth() - 4)

	local curLvl = QuestInfoSkillPointFrame:GetFrameLevel() + 1
	QuestInfoSkillPointFrame:SetFrameLevel(curLvl)
	QuestInfoSkillPointFrame:SetStyle("Frame", "Outline")
	QuestInfoSkillPointFrame:SetBackdropColor(1, 1, 0, 0.5)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:SetPoint("TOPLEFT", 2, -2)
	QuestInfoSkillPointFrameIconTexture:ModSize(QuestInfoSkillPointFrameIconTexture:GetWidth()-2, QuestInfoSkillPointFrameIconTexture:GetHeight()-2)
	QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")
	QuestInfoItemHighlight:RemoveTextures()
	QuestInfoItemHighlight:SetStyle("Frame", "Outline")
	QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:ModSize(142, 40)

	hooksecurefunc("QuestInfoItem_OnClick", Hook_QuestInfoItem_OnClick)
	hooksecurefunc("QuestInfo_Display", StyleQuestRewards)

	QuestRewardScrollFrame:HookScript("OnShow", QuestRewardScrollFrame_OnShow)

	QuestFrameInset:Die()
	QuestFrameDetailPanel:RemoveTextures(true)
	QuestDetailScrollFrame:RemoveTextures(true)
	QuestScrollHelper(QuestDetailScrollFrame, 506, 615, true)
	QuestProgressScrollFrame:SetStyle("Frame")
	QuestScrollHelper(QuestProgressScrollFrame, 506, 615, true)
	QuestGreetingScrollFrame:SetStyle("Frame")
	QuestScrollHelper(QuestGreetingScrollFrame, 506, 615, true)
	QuestDetailScrollChildFrame:RemoveTextures(true)
	QuestRewardScrollFrame:RemoveTextures(true)
	QuestRewardScrollChildFrame:RemoveTextures(true)
	QuestFrameProgressPanel:RemoveTextures(true)
	QuestFrameRewardPanel:RemoveTextures(true)

	QuestFrameAcceptButton:SetStyle("Button")
	QuestFrameDeclineButton:SetStyle("Button")
	QuestFrameCompleteButton:SetStyle("Button")
	QuestFrameGoodbyeButton:SetStyle("Button")
	QuestFrameCompleteQuestButton:SetStyle("Button")

	SV.API:Set("CloseButton", QuestFrameCloseButton, QuestFrame.Panel)

	for j = 1, 6 do 
		local i = _G["QuestProgressItem"..j]
		local texture = _G["QuestProgressItem"..j.."IconTexture"]
		i:RemoveTextures()
		i:SetStyle("Frame[INSET]", "Transparent")
		i:ModWidth(_G["QuestProgressItem"..j]:GetWidth() - 4)
		texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		texture:SetDrawLayer("OVERLAY")
		texture:SetPoint("TOPLEFT", 2, -2)
		texture:ModSize(texture:GetWidth() - 2, texture:GetHeight() - 2)
		_G["QuestProgressItem"..j.."Count"]:SetDrawLayer("OVERLAY")
	end

	QuestNPCModel:RemoveTextures()
	QuestNPCModel:SetStyle("Frame", "PatternComic")

	QuestNPCModelTextFrame:RemoveTextures()
	QuestNPCModelTextFrame:SetStyle("Frame", "Default")
	QuestNPCModelTextFrame.Panel:SetPoint("TOPLEFT", QuestNPCModel.Panel, "BOTTOMLEFT", 0, -2)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", Hook_QuestNPCModel)

end

local function QuestChoiceFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.quest ~= true then return end

	SV.API:Set("Window", QuestChoiceFrame, true, true)

	local bgFrameTop = CreateFrame("Frame", nil, QuestChoiceFrame)
	bgFrameTop:SetPoint("TOPLEFT", QuestChoiceFrame, "TOPLEFT", 42, -44)
	bgFrameTop:SetPoint("TOPRIGHT", QuestChoiceFrame, "TOPRIGHT", -42, -44)
	bgFrameTop:SetHeight(85)
	bgFrameTop:SetStyle("Frame", "PatternPaper")
	bgFrameTop:SetPanelColor("dark")

	local bgFrameBottom = CreateFrame("Frame", nil, QuestChoiceFrame)
	bgFrameBottom:SetPoint("TOPLEFT", QuestChoiceFrame, "TOPLEFT", 42, -140)
	bgFrameBottom:SetPoint("BOTTOMRIGHT", QuestChoiceFrame, "BOTTOMRIGHT", -42, 44)
	bgFrameBottom:SetStyle("Frame", "PatternPaper")


	SV.API:Set("CloseButton", QuestChoiceFrame.CloseButton)
	--QuestChoiceFrame.Option1:SetStyle("Frame[INSET]", "Transparent")
	QuestChoiceFrame.Option1.OptionButton:SetStyle("Button")
	--QuestChoiceFrame.Option2:SetStyle("Frame[INSET]", "Transparent")
	QuestChoiceFrame.Option2.OptionButton:SetStyle("Button")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(QuestFrameStyle)
MOD:SaveCustomStyle(QuestGreetingStyle)
MOD:SaveBlizzardStyle('Blizzard_QuestChoice', QuestChoiceFrameStyle)