--[[
##############################################################################
S V U I   By: S.Jackson
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
local RING_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-RING]]
local LVL_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-LEVEL]]
local DEFAULT_COLOR = {r = 0.25, g = 0.25, b = 0.25};
--[[ 
########################################################## 
STYLE
##########################################################
]]--
local function AddFadeBanner(frame)
	local bg = frame:CreateTexture(nil, "OVERLAY")
	bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", frame, "RIGHT", 0, 0)
	bg:SetTexture(1, 1, 1, 1)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.9)
end

local function StyleTextureIcon(frame)
	if((not frame) or (not frame.Texture)) then return end
	frame.Texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	if(not frame.IconSlot) then 
		frame.IconSlot = CreateFrame("Frame", nil, frame)
		frame.IconSlot:WrapPoints(frame.Texture)
		frame.IconSlot:SetStyle("Icon")
		frame.Texture:SetParent(frame.IconSlot)
	end
end

local function StyleListItem(item)
	if(not item) then return; end
    if(item.Icon) then
    	local size = item:GetHeight() - 8
    	local texture = item.Icon:GetTexture()
		item:RemoveTextures()
    	item:SetStyle("Inset")
    	item.Icon:SetTexture(texture)
		item.Icon:ClearAllPoints()
		item.Icon:SetPoint("TOPLEFT", item, "TOPLEFT", 4, -4)
		item.Icon:SetSize(size, size)
		item.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		item.Icon:SetDesaturated(false)
		if(not item.IconSlot) then 
			item.IconSlot = CreateFrame("Frame", nil, item)
			item.IconSlot:SetAllPoints(item.Icon)
			item.IconSlot:SetStyle("Icon")
			item.Icon:SetParent(item.IconSlot)
		end
    end
end

local function StyleAbilityIcon(frame)
	if(not frame) then return; end
    if(frame.Icon) then
    	local texture = frame.Icon:GetTexture()
    	local size = frame:GetHeight() - 2
    	frame:RemoveTextures()
    	frame.Icon:SetTexture(texture)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
		frame.Icon:SetSize(size, size)
		frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		frame.Icon:SetDesaturated(false)
		if(not frame.IconSlot) then
			frame.IconSlot = CreateFrame("Frame", nil, frame)
			frame.IconSlot:WrapPoints(frame.Icon)
			frame.IconSlot:SetStyle("Icon")
			frame.Icon:SetParent(frame.IconSlot)
		end
    end
end

local function StyleFollowerPortrait(frame, color)
	frame.PortraitRing:SetTexture('')
	frame.PortraitRingQuality:SetTexture(RING_TEXTURE)
end

local _hook_ReagentUpdate = function(self)
	local reagents = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.Reagents;
    for i = 1, #reagents do
    	if(reagents[i] and (not reagents[i].Panel)) then
    		reagents[i]:RemoveTextures()
        	reagents[i]:SetStyle("Icon")
        	if(reagents[i].Icon) then
				reagents[i].Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			end
		end
    end
end

local _hook_GarrisonBuildingListUpdate = function()
	local list = GarrisonBuildingFrame.BuildingList;
	for i=1, GARRISON_NUM_BUILDING_SIZES do
		local tab = list["Tab"..i];
		if(tab and tab.buildings) then
			for i=1, #tab.buildings do
				StyleListItem(list.Buttons[i])
			end
		end
	end
end

local _hook_GarrisonFollowerListUpdate = function(self)
    local buttons = self.FollowerList.listScroll.buttons;
    local followers = self.FollowerList.followers;
    local followersList = self.FollowerList.followersList;
    local numFollowers = #followersList;
    local scrollFrame = self.FollowerList.listScroll;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local numButtons = #buttons;
 
    for i = 1, numButtons do
        local button = buttons[i];
        local index = offset + i;
        if(index <= numFollowers) then
        	local follower = followers[followersList[index]];
	        if(not button.Panel) then
	            button:RemoveTextures()
	            button:SetStyle("Frame", 'Blackout', true, 1, 0, 0)
				if(button.XPBar) then
					button.XPBar:SetTexture(SV.media.statusbar.default)
					button.XPBar:SetGradient('HORIZONTAL', 0.5, 0, 1, 1, 0, 1)
				end
	        end
	        if(button.PortraitFrame) then
	        	local color
		        if(follower.isCollected) then
	            	color = ITEM_QUALITY_COLORS[follower.quality]
	            else
	            	color = DEFAULT_COLOR
				end
				StyleFollowerPortrait(button.PortraitFrame, color)
			end
	    end
    end
end

local _hook_GarrisonFollowerTooltipTemplate_SetGarrisonFollower = function(tooltip, data)
	local color = ITEM_QUALITY_COLORS[data.quality];
	StyleFollowerPortrait(tooltip.Portrait, color)
end

local _hook_GarrisonBuildingInfoBoxFollowerPortrait = function(owned, hasFollowerSlot, infoBox, isBuilding, canActivate, ID)
	local portraitFrame = infoBox.FollowerPortrait;
	StyleFollowerPortrait(portraitFrame)
end

local _hook_GarrisonMissionFrame_SetFollowerPortrait = function(portraitFrame, followerInfo)
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];
	StyleFollowerPortrait(portraitFrame, color)
end

local _hook_GarrisonRecruitSelectFrame_UpdateRecruits = function()
	local recruitFrame = GarrisonRecruitSelectFrame.FollowerSelection;
	local followers = C_Garrison.GetAvailableRecruits();
	for i=1, 3 do
		local follower = followers[i];
		local frame = recruitFrame["Recruit"..i];
		if(follower)then
			local color = ITEM_QUALITY_COLORS[follower.quality];
			StyleFollowerPortrait(frame.PortraitFrame, color);
		end
	end
end

local _hook_GarrisonMissionComplete_SetFollowerLevel = function(followerFrame, level, quality)
	local color = ITEM_QUALITY_COLORS[quality];
	followerFrame.PortraitFrame.PortraitRing:SetVertexColor(color.r, color.g, color.b)
end

local function _hook_SetCounterButton(self, index, info)
	local counter = self.Counters[index];
	StyleAbilityIcon(counter)
end

local function _hook_AddAbility(self, index, ability)
	local ability = self.Abilities[index];
	StyleAbilityIcon(ability)
end

local _hook_GarrisonFollowerPage_ShowFollower = function(self, followerID)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
    if(not self.XPBar.Panel) then
	    self.XPBar:RemoveTextures()
		self.XPBar:SetStatusBarTexture(SV.media.statusbar.default)
		self.XPBar:SetStyle("!_Frame", "Bar")
	end
 
    for i=1, #self.AbilitiesFrame.Abilities do
        local abilityFrame = self.AbilitiesFrame.Abilities[i];
        StyleAbilityIcon(abilityFrame.IconButton)
    end

    for i=1, #self.AbilitiesFrame.Counters do
        local abilityFrame = self.AbilitiesFrame.Counters[i];
        StyleAbilityIcon(abilityFrame)
    end
end

local _hook_GarrisonFollowerPage_UpdateMissionForParty = function(self, followerID)
	local MISSION_PAGE_FRAME = GarrisonMissionFrame.MissionTab.MissionPage;
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier = C_Garrison.GetPartyMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);
	-- for i = 1, #MISSION_PAGE_FRAME.Enemies do
	-- 	local enemyFrame = MISSION_PAGE_FRAME.Enemies[i];
	-- 	for mechanicIndex = 1, #enemyFrame.Mechanics do
	-- 		local mechanic = enemyFrame.Mechanics[mechanicIndex];
	--         StyleAbilityIcon(mechanic)
	-- 	end
	-- end
	-- PARTY BOOFS
	local buffsFrame = MISSION_PAGE_FRAME.BuffsFrame;
	local buffCount = #partyBuffs;
	if(buffCount > 0) then
		for i = 1, buffCount do
			local buff = buffsFrame.Buffs[i];
			StyleAbilityIcon(buff)
		end
	end
end

local function StyleRewardButtons(rewardButtons)
    for i = 1, #rewardButtons do
        local frame = rewardButtons[i];
        StyleListItem(frame);
    end
end

local function StyleListButtons(listButtons)
    for i = 1, #listButtons do
        local frame = listButtons[i];
        if(frame.Icon) then
	    	local size = frame:GetHeight() - 6
	    	if(not frame.Panel) then
		    	local texture = frame.Icon:GetTexture()
				frame:RemoveTextures()
		    	frame:SetStyle("!_Frame", 'Blackout', true, 3)
		    	frame.Icon:SetTexture(texture)
		    end
			frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			frame.Icon:ClearAllPoints()
			frame.Icon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
			frame.Icon:SetSize(size, size)
			frame.Icon:SetDesaturated(false)
	    end
    end
end

local _hook_GarrisonMissionFrame_CheckRewardButtons = function(rewards)
	StyleRewardButtons(rewards);
end

local function StyleUpdateRewards()
	local self = GarrisonMissionFrame
    local missionButtons = self.MissionTab.MissionList.listScroll.buttons;
    for i = 1, #missionButtons do
    	SV.API:Set("ItemButton", missionButtons[i])
        StyleListButtons(missionButtons[i].Rewards)
    end
    StyleRewardButtons(self.MissionTab.MissionPage.RewardsFrame.Rewards);
    StyleRewardButtons(self.MissionComplete.BonusRewards.Rewards);
end

local _hook_GarrisonMissionButton_SetRewards = function(self, rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		for id, reward in pairs(rewards) do
			local frame = self.Rewards[index];
	        if(frame.Icon) then
		    	local size = frame:GetHeight() - 6
		    	if(not frame.Panel) then
			    	local texture = frame.Icon:GetTexture()
					frame:RemoveTextures()
			    	frame:SetStyle("!_Frame", 'Blackout', true, 3)
			    	frame.Icon:SetTexture(texture)
			    end
				frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				frame.Icon:ClearAllPoints()
				frame.Icon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
				frame.Icon:SetSize(size, size)
				frame.Icon:SetDesaturated(false)
		    end
		    index = index + 1;
		end
	end
end

local function LoadGarrisonStyle()
	if SV.db.Skins.blizzard.enable ~= true then
		return 
	end

	SV.API:Set("Window", GarrisonMissionFrame, true, false, 1, 0, 4)
	SV.API:Set("Window", GarrisonBuildingFrame, true, false, 1, 0, 4)
	SV.API:Set("Window", GarrisonLandingPage, true, false, 1, 0, 0)

	SV.API:Set("Tab", GarrisonMissionFrameTab1)
	SV.API:Set("Tab", GarrisonMissionFrameTab2)

	GarrisonBuildingFrameFollowers:RemoveTextures()
	GarrisonBuildingFrameFollowers:SetStyle("Frame", 'Inset', true, 1, -5, -5)
	GarrisonBuildingFrameFollowers:ClearAllPoints()
	GarrisonBuildingFrameFollowers:SetPoint("LEFT", GarrisonBuildingFrame, "LEFT", 10, 0)
	GarrisonBuildingFrame.BuildingList:RemoveTextures()
	GarrisonBuildingFrame.BuildingList:SetStyle("!_Frame", 'Inset')
	GarrisonBuildingFrame.TownHallBox:RemoveTextures()
	GarrisonBuildingFrame.TownHallBox:SetStyle("!_Frame", 'Inset')
	GarrisonBuildingFrame.InfoBox:RemoveTextures()
	GarrisonBuildingFrame.InfoBox:SetStyle("!_Frame", 'Inset')
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab1)
	GarrisonBuildingFrame.BuildingList.Tab1:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab1:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab1:SetStyle("Button", -4, -10)
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab2)
	GarrisonBuildingFrame.BuildingList.Tab2:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab2:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab2:SetStyle("Button", -4, -10)
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab3)
	GarrisonBuildingFrame.BuildingList.Tab3:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab3:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab3:SetStyle("Button", -4, -10)
	GarrisonBuildingFrame.BuildingList.MaterialFrame:RemoveTextures()
	GarrisonBuildingFrame.BuildingList.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -5, -7)
	GarrisonBuildingFrameTutorialButton:Die()

	StyleUpdateRewards()

	GarrisonLandingPage.FollowerTab:RemoveTextures()
	GarrisonLandingPage.FollowerTab.AbilitiesFrame:RemoveTextures()
	GarrisonLandingPage.FollowerTab:SetStyle("Frame", "Model")

	GarrisonLandingPage.FollowerTab.Panel:ClearAllPoints()
	GarrisonLandingPage.FollowerTab.Panel:SetPoint("TOPLEFT", GarrisonLandingPage.FollowerList.SearchBox, "TOPRIGHT", 10, 6)
	GarrisonLandingPage.FollowerTab.Panel:SetPoint("BOTTOMRIGHT", GarrisonLandingPage, "BOTTOMRIGHT", -38, 30)

	GarrisonLandingPage.FollowerList:RemoveTextures()
	GarrisonLandingPage.FollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)

	local bgFrameTop = CreateFrame("Frame", nil, GarrisonLandingPage.Report)
	bgFrameTop:SetPoint("TOPLEFT", GarrisonLandingPage.Report, "TOPLEFT", 38, -91)
	bgFrameTop:SetPoint("BOTTOMRIGHT", GarrisonLandingPage.Report.List, "BOTTOMLEFT", -4, 0)
	bgFrameTop:SetStyle("Frame", "Paper")
	bgFrameTop:SetPanelColor("special")

	SV.API:Set("Tab", GarrisonLandingPageTab1, nil, 10, 4)
	SV.API:Set("Tab", GarrisonLandingPageTab2, nil, 10, 4)

	local a1, p, a2, x, y = GarrisonLandingPageTab1:GetPoint()
	GarrisonLandingPageTab1:SetPoint(a1, p, a2, x, (y - 15))

	GarrisonLandingPageReportList:RemoveTextures()
	GarrisonLandingPageReportList:SetStyle("Frame", 'Inset', false, 4, 0, 0)

	GarrisonLandingPageReport.Available:RemoveTextures(true)
	GarrisonLandingPageReport.Available:SetStyle("Button")
	GarrisonLandingPageReport.Available:GetNormalTexture().SetAtlas = function() return end

	GarrisonLandingPageReport.InProgress:RemoveTextures(true)
	GarrisonLandingPageReport.InProgress:SetStyle("Button")
	GarrisonLandingPageReport.InProgress:GetNormalTexture().SetAtlas = function() return end

	GarrisonMissionFrameMissions:RemoveTextures()
	GarrisonMissionFrameMissions:SetStyle("!_Frame", "Inset")
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame:RemoveTextures()
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame:SetStyle("Frame", 'Window', false, 4, 0, 0)
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.Stage:RemoveTextures()
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.Stage:SetStyle("!_Frame", "Model")
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton:RemoveTextures(true)
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton:SetStyle("Button")

	GarrisonMissionFrameMissionsListScrollFrame:RemoveTextures()
	SV.API:Set("ScrollFrame", GarrisonMissionFrameMissionsListScrollFrame)

	SV.API:Set("Tab", GarrisonMissionFrameMissionsTab1, nil, 10, 4)
	SV.API:Set("Tab", GarrisonMissionFrameMissionsTab2, nil, 10, 4)
	local a1, p, a2, x, y = GarrisonMissionFrameMissionsTab1:GetPoint()
	GarrisonMissionFrameMissionsTab1:SetPoint(a1, p, a2, x, (y + 8))

	GarrisonMissionFrameMissions.MaterialFrame:RemoveTextures()
	GarrisonMissionFrameMissions.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -3, -3)

	GarrisonMissionFrame.FollowerTab:RemoveTextures()
	GarrisonMissionFrame.FollowerTab:SetStyle("!_Frame", "Model")

	GarrisonMissionFrame.FollowerTab.ItemWeapon:RemoveTextures()
	StyleListItem(GarrisonMissionFrame.FollowerTab.ItemWeapon)
	GarrisonMissionFrame.FollowerTab.ItemArmor:RemoveTextures()
	StyleListItem(GarrisonMissionFrame.FollowerTab.ItemArmor)

	GarrisonMissionFrame.MissionTab:RemoveTextures()
	GarrisonMissionFrame.MissionTab.MissionPage:RemoveTextures()
	GarrisonMissionFrame.MissionTab.MissionPage:SetStyle("Frame", 'Paper', false, 4, 0, 0)
	GarrisonMissionFrame.MissionTab.MissionPage:SetPanelColor("special")

	local missionChance = GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chance;
	missionChance:SetFontObject(SVUI_Font_Number_Huge)
	local chanceLabel = GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.ChanceLabel
	chanceLabel:SetFontObject(SVUI_Font_Header)
	chanceLabel:ClearAllPoints()
	chanceLabel:SetPoint("TOP", missionChance, "BOTTOM", 0, -8)

	GarrisonMissionFrame.MissionTab.MissionPage.Panel:ClearAllPoints()
	GarrisonMissionFrame.MissionTab.MissionPage.Panel:SetPoint("TOPLEFT", GarrisonMissionFrame.MissionTab.MissionPage, "TOPLEFT", 0, 4)
	GarrisonMissionFrame.MissionTab.MissionPage.Panel:SetPoint("BOTTOMRIGHT", GarrisonMissionFrame.MissionTab.MissionPage, "BOTTOMRIGHT", 0, -20)

	GarrisonMissionFrame.MissionTab.MissionPage.Stage:RemoveTextures()
	StyleTextureIcon(GarrisonMissionFrame.MissionTab.MissionPage.Stage.MissionEnvIcon);
	AddFadeBanner(GarrisonMissionFrame.MissionTab.MissionPage.Stage)
	GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:RemoveTextures(true)
	GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:SetStyle("Button")

	GarrisonMissionFrameFollowers:RemoveTextures()
	GarrisonMissionFrameFollowers:SetStyle("Frame", 'Inset', false, 4, 0, 0)
	GarrisonMissionFrameFollowers.MaterialFrame:RemoveTextures()
	GarrisonMissionFrameFollowers.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -5, -7)
	SV.API:Set("EditBox", GarrisonMissionFrameFollowers.SearchBox)

	--GarrisonMissionFrameFollowersListScrollFrame

	local mComplete = GarrisonMissionFrame.MissionComplete;
	local mStage = mComplete.Stage;
	local mFollowers = mStage.FollowersFrame;

	mComplete:RemoveTextures()
	mComplete:SetStyle("Frame", 'Paper', false, 4, 0, 0)
	mComplete:SetPanelColor("special")
	mStage:RemoveTextures()
	mStage.MissionInfo:RemoveTextures()

	if(mFollowers.Follower1 and mFollowers.Follower1.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower1.PortraitFrame)
	end
	if(mFollowers.Follower2 and mFollowers.Follower2.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower2.PortraitFrame)
	end
	if(mFollowers.Follower3 and mFollowers.Follower3.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower3.PortraitFrame)
	end

	AddFadeBanner(mStage)
	mComplete.NextMissionButton:RemoveTextures(true)
	mComplete.NextMissionButton:SetStyle("Button")

	--GarrisonMissionFrame.MissionComplete.BonusRewards:RemoveTextures()
	--GarrisonMissionFrame.MissionComplete.BonusRewards:SetStyle("!_Frame", "Model")

	local display = GarrisonCapacitiveDisplayFrame
	display:RemoveTextures(true)
	GarrisonCapacitiveDisplayFrameInset:RemoveTextures(true)
	display.CapacitiveDisplay:RemoveTextures(true)
	display.CapacitiveDisplay:SetStyle("Frame", 'Transparent')
	display.CapacitiveDisplay.ShipmentIconFrame:SetStyle("Icon")
	display.CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	display:SetStyle("Frame", "Window2")

	local reagents = display.CapacitiveDisplay.Reagents;
    for i = 1, #reagents do
    	if(reagents[i]) then
    		reagents[i]:RemoveTextures()
        	reagents[i]:SetStyle("Icon")
        	if(reagents[i].Icon) then
				reagents[i].Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			end
		end
    end

    hooksecurefunc("GarrisonFollowerButton_AddAbility", _hook_AddAbility)
    hooksecurefunc("GarrisonFollowerButton_SetCounterButton", _hook_SetCounterButton)
    hooksecurefunc("GarrisonMissionList_Update", StyleUpdateRewards)
    hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", _hook_ReagentUpdate)
    hooksecurefunc("GarrisonFollowerList_Update", _hook_GarrisonFollowerListUpdate)
    hooksecurefunc("GarrisonMissionFrame_SetFollowerPortrait", _hook_GarrisonMissionFrame_SetFollowerPortrait)
    hooksecurefunc("GarrisonMissionComplete_SetFollowerLevel", _hook_GarrisonMissionComplete_SetFollowerLevel)
    hooksecurefunc("GarrisonFollowerPage_ShowFollower", _hook_GarrisonFollowerPage_ShowFollower)
    hooksecurefunc("GarrisonMissionPage_UpdateMissionForParty", _hook_GarrisonFollowerPage_UpdateMissionForParty)
    hooksecurefunc("GarrisonMissionFrame_SetItemRewardDetails", StyleListItem)
    hooksecurefunc("GarrisonBuildingTab_Select", _hook_GarrisonBuildingListUpdate)
    hooksecurefunc("GarrisonBuildingList_SelectTab", _hook_GarrisonBuildingListUpdate)
    hooksecurefunc("GarrisonBuildingInfoBox_ShowFollowerPortrait", _hook_GarrisonBuildingInfoBoxFollowerPortrait)
    hooksecurefunc("GarrisonFollowerTooltipTemplate_SetGarrisonFollower", _hook_GarrisonFollowerTooltipTemplate_SetGarrisonFollower)
    hooksecurefunc("GarrisonMissionButton_SetRewards", _hook_GarrisonMissionButton_SetRewards)
    hooksecurefunc("GarrisonMissionFrame_CheckRewardButtons", _hook_GarrisonMissionFrame_CheckRewardButtons)


	if(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton) then
		GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:RemoveTextures(true)
		GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:SetStyle("Button")
	end

	SV.API:Set("ScrollFrame", GarrisonLandingPageReportListListScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", GarrisonMissionFrameMissionsListScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", GarrisonMissionFrameFollowersListScrollFrameScrollBar)
	SV.API:Set("CloseButton", GarrisonLandingPage.CloseButton)
	SV.API:Set("CloseButton", GarrisonMissionFrame.MissionTab.MissionPage.CloseButton)
	GarrisonLandingPage.CloseButton:SetFrameStrata("HIGH")

	for i = 1, GarrisonLandingPageReportListListScrollFrameScrollChild:GetNumChildren() do
		local child = select(i, GarrisonLandingPageReportListListScrollFrameScrollChild:GetChildren())
		for j = 1, child:GetNumChildren() do
			local childC = select(j, child:GetChildren())
			childC.Icon:SetTexCoord(0.1,0.9,0.1,0.9)
			childC.Icon:SetDesaturated(false)
		end
	end

	SV.API:Set("ScrollFrame", GarrisonLandingPageListScrollFrameScrollBar)

	SV.API:Set("Window", GarrisonRecruiterFrame, true)
	GarrisonRecruiterFrameInset:RemoveTextures()
	GarrisonRecruiterFrameInset:SetStyle("!_Frame", "Inset")
	SV.API:Set("DropDown", GarrisonRecruiterFramePickThreatDropDown)
	GarrisonRecruiterFrame.Pick.Radio1:SetStyle("!_Checkbox", false, -3, -3, true)
	GarrisonRecruiterFrame.Pick.Radio2:SetStyle("!_Checkbox", false, -3, -3, true)

	SV.API:Set("Window", GarrisonRecruitSelectFrame, true)
	GarrisonRecruitSelectFrame.FollowerSelection:RemoveTextures()

	GarrisonRecruitSelectFrame.FollowerList:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)

	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3:RemoveTextures()

	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1:SetStyle("Frame", 'Inset')
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2:SetStyle("Frame", 'Inset')
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3:SetStyle("Frame", 'Inset')

	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit1.PortraitFrame)
	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit2.PortraitFrame)
	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit3.PortraitFrame)

	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1.HireRecruits:SetStyle("Button")
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2.HireRecruits:SetStyle("Button")
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3.HireRecruits:SetStyle("Button")

	hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", _hook_GarrisonRecruitSelectFrame_UpdateRecruits)
	--print("Test Done")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_GarrisonUI", LoadGarrisonStyle)