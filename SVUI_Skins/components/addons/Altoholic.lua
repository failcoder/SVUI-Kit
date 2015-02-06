--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
ALTOHOLIC
##########################################################
]]--
local function ColorAltoBorder(self)
	if self.border then
		local Backdrop = self.backdrop or self.Backdrop
		if not Backdrop then return end
		local r, g, b = self.border:GetVertexColor()
		Backdrop:SetBackdropBorderColor(r, g, b, 1)
	end
end

local function ApplyTextureStyle(self)
	if not self then return end
	self:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	local parent = self:GetParent()
	if(parent) then
		self:InsetPoints(parent, 1, 1)
	end
end

local function StyleAltoholic(event, addon)
	assert(AltoholicFrame, "AddOn Not Loaded")

	if event == "PLAYER_ENTERING_WORLD" then
		MOD:ApplyTooltipStyle(AltoTooltip)

		AltoholicFramePortrait:Die()

		MOD:ApplyFrameStyle(AltoholicFrame, "WindowAlternate", false, true)
		MOD:ApplyFrameStyle(AltoMsgBox)
		MOD:ApplyButtonStyle(AltoMsgBoxYesButton)
		MOD:ApplyButtonStyle(AltoMsgBoxNoButton)
		MOD:ApplyCloseButtonStyle(AltoholicFrameCloseButton)
		MOD:ApplyEditBoxStyle(AltoholicFrame_SearchEditBox, 175, 15)
		MOD:ApplyButtonStyle(AltoholicFrame_ResetButton)
		MOD:ApplyButtonStyle(AltoholicFrame_SearchButton)

		AltoholicFrameTab1:ModPoint("TOPLEFT", AltoholicFrame, "BOTTOMLEFT", -5, 2)
		AltoholicFrame_ResetButton:ModPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 25, -77)
		AltoholicFrame_SearchEditBox:ModPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 37, -56)
		AltoholicFrame_ResetButton:ModSize(85, 24)
		AltoholicFrame_SearchButton:ModSize(85, 24)
	end

	if addon == "Altoholic_Summary" then
		MOD:ApplyFrameStyle(AltoholicFrameSummary)
		MOD:ApplyFrameStyle(AltoholicFrameBagUsage)
		MOD:ApplyFrameStyle(AltoholicFrameSkills)
		MOD:ApplyFrameStyle(AltoholicFrameActivity)
		MOD:ApplyScrollBarStyle(AltoholicFrameSummaryScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicFrameBagUsageScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicFrameSkillsScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicFrameActivityScrollFrameScrollBar)
		MOD:ApplyDropdownStyle(AltoholicTabSummary_SelectLocation, 200)

		if(AltoholicFrameSummaryScrollFrame) then		
			AltoholicFrameSummaryScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameBagUsageScrollFrame) then
			AltoholicFrameBagUsageScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameSkillsScrollFrame) then
			AltoholicFrameSkillsScrollFrame:RemoveTextures(true)
		end

		if(AltoholicFrameActivityScrollFrame) then
			AltoholicFrameActivityScrollFrame:RemoveTextures(true)
		end

		MOD:ApplyButtonStyle(AltoholicTabSummary_RequestSharing)
		ApplyTextureStyle(AltoholicTabSummary_RequestSharingIconTexture)
		MOD:ApplyButtonStyle(AltoholicTabSummary_Options)
		ApplyTextureStyle(AltoholicTabSummary_OptionsIconTexture)
		MOD:ApplyButtonStyle(AltoholicTabSummary_OptionsDataStore)
		ApplyTextureStyle(AltoholicTabSummary_OptionsDataStoreIconTexture)

		for i = 1, 5 do
			MOD:ApplyButtonStyle(_G["AltoholicTabSummaryMenuItem"..i], true)
		end
		for i = 1, 8 do
			MOD:ApplyButtonStyle(_G["AltoholicTabSummary_Sort"..i], true)
		end
		for i = 1, 7 do
			MOD:ApplyTabStyle(_G["AltoholicFrameTab"..i], true)
		end
	end
	
	if IsAddOnLoaded("Altoholic_Characters") or addon == "Altoholic_Characters" then
		MOD:ApplyFrameStyle(AltoholicFrameContainers)
		MOD:ApplyFrameStyle(AltoholicFrameRecipes)
		MOD:ApplyFrameStyle(AltoholicFrameQuests)
		MOD:ApplyFrameStyle(AltoholicFrameGlyphs)
		MOD:ApplyFrameStyle(AltoholicFrameMail)
		MOD:ApplyFrameStyle(AltoholicFrameSpellbook)
		MOD:ApplyFrameStyle(AltoholicFramePets)
		MOD:ApplyFrameStyle(AltoholicFrameAuctions)
		MOD:ApplyScrollBarStyle(AltoholicFrameContainersScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicFrameQuestsScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicFrameRecipesScrollFrameScrollBar)
		MOD:ApplyDropdownStyle(AltoholicFrameTalents_SelectMember)
		MOD:ApplyDropdownStyle(AltoholicTabCharacters_SelectRealm)
		MOD:ApplyPaginationStyle(AltoholicFrameSpellbookPrevPage)
		MOD:ApplyPaginationStyle(AltoholicFrameSpellbookNextPage)
		MOD:ApplyPaginationStyle(AltoholicFramePetsNormalPrevPage)
		MOD:ApplyPaginationStyle(AltoholicFramePetsNormalNextPage)
		MOD:ApplyButtonStyle(AltoholicTabCharacters_Sort1)
		MOD:ApplyButtonStyle(AltoholicTabCharacters_Sort2)
		MOD:ApplyButtonStyle(AltoholicTabCharacters_Sort3)
		AltoholicFrameContainersScrollFrame:RemoveTextures(true)
		AltoholicFrameQuestsScrollFrame:RemoveTextures(true)
		AltoholicFrameRecipesScrollFrame:RemoveTextures(true)

		local Buttons = {
			'AltoholicTabCharacters_Characters',
			'AltoholicTabCharacters_CharactersIcon',
			'AltoholicTabCharacters_BagsIcon',
			'AltoholicTabCharacters_QuestsIcon',
			'AltoholicTabCharacters_TalentsIcon',
			'AltoholicTabCharacters_AuctionIcon',
			'AltoholicTabCharacters_MailIcon',
			'AltoholicTabCharacters_SpellbookIcon',
			'AltoholicTabCharacters_ProfessionsIcon',
		}

		for _, object in pairs(Buttons) do
			ApplyTextureStyle(_G[object..'IconTexture'])
			ApplyTextureStyle(_G[object])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				MOD:ApplyItemButtonStyle(_G["AltoholicFrameContainersEntry"..i.."Item"..j])
				_G["AltoholicFrameContainersEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Achievements") or addon == "Altoholic_Achievements" then
		MOD:ApplyFixedFrameStyle(AltoholicFrameAchievements)
		AltoholicFrameAchievementsScrollFrame:RemoveTextures(true)
		AltoholicAchievementsMenuScrollFrame:RemoveTextures(true)
		MOD:ApplyScrollBarStyle(AltoholicFrameAchievementsScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicAchievementsMenuScrollFrameScrollBar)
		MOD:ApplyDropdownStyle(AltoholicTabAchievements_SelectRealm)
		AltoholicTabAchievements_SelectRealm:ModPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 205, -57)

		for i = 1, 15 do
			MOD:ApplyButtonStyle(_G["AltoholicTabAchievementsMenuItem"..i], true)
		end

		for i = 1, 8 do
			for j = 1, 10 do
				MOD:ApplyFixedFrameStyle(_G["AltoholicFrameAchievementsEntry"..i.."Item"..j])
				local Backdrop = _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].backdrop or _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].Backdrop
				ApplyTextureStyle(_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background'])
				_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background']:SetInside(Backdrop)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Agenda") or addon == "Altoholic_Agenda" then
		MOD:ApplyFrameStyle(AltoholicFrameCalendarScrollFrame)
		MOD:ApplyFrameStyle(AltoholicTabAgendaMenuItem1)
		MOD:ApplyScrollBarStyle(AltoholicFrameCalendarScrollFrameScrollBar)
		MOD:ApplyPaginationStyle(AltoholicFrameCalendar_NextMonth)
		MOD:ApplyPaginationStyle(AltoholicFrameCalendar_PrevMonth)
		MOD:ApplyButtonStyle(AltoholicTabAgendaMenuItem1, true)

		for i = 1, 14 do
			MOD:ApplyFrameStyle(_G["AltoholicFrameCalendarEntry"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Grids") or addon == "Altoholic_Grids" then
		AltoholicFrameGridsScrollFrame:RemoveTextures(true)
		MOD:ApplyFixedFrameStyle(AltoholicFrameGrids)
		MOD:ApplyScrollBarStyle(AltoholicFrameGridsScrollFrameScrollBar)
		MOD:ApplyDropdownStyle(AltoholicTabGrids_SelectRealm)
		MOD:ApplyDropdownStyle(AltoholicTabGrids_SelectView)

		for i = 1, 8 do
			for j = 1, 10 do
				MOD:ApplyFixedFrameStyle(_G["AltoholicFrameGridsEntry"..i.."Item"..j], nil, nil, true)
				_G["AltoholicFrameGridsEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end

		AltoholicFrameGrids:HookScript('OnUpdate', function()
			for i = 1, 10 do
				for j = 1, 10 do
					if _G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"] then
						_G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"]:SetTexCoord(.08, .92, .08, .82)
					end
				end
			end
		end)

	end

	if IsAddOnLoaded("Altoholic_Guild") or addon == "Altoholic_Guild" then
		MOD:ApplyFrameStyle(AltoholicFrameGuildMembers)
		MOD:ApplyFrameStyle(AltoholicFrameGuildBank)
		MOD:ApplyScrollBarStyle(AltoholicFrameGuildMembersScrollFrameScrollBar)
		AltoholicFrameGuildMembersScrollFrame:RemoveTextures(true)

		for i = 1, 2 do
			MOD:ApplyButtonStyle(_G["AltoholicTabGuildMenuItem"..i])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				MOD:ApplyItemButtonStyle(_G["AltoholicFrameGuildBankEntry"..i.."Item"..j])
			end
		end

		for i = 1, 19 do
			MOD:ApplyItemButtonStyle(_G["AltoholicFrameGuildMembersItem"..i])
		end

		for i = 1, 5 do
			MOD:ApplyButtonStyle(_G["AltoholicTabGuild_Sort"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Search") or addon == "Altoholic_Search" then
		MOD:ApplyFixedFrameStyle(AltoholicFrameSearch, true)
		AltoholicFrameSearchScrollFrame:RemoveTextures(true)
		AltoholicSearchMenuScrollFrame:RemoveTextures(true)
		MOD:ApplyScrollBarStyle(AltoholicFrameSearchScrollFrameScrollBar)
		MOD:ApplyScrollBarStyle(AltoholicSearchMenuScrollFrameScrollBar)
		MOD:ApplyDropdownStyle(AltoholicTabSearch_SelectRarity)
		MOD:ApplyDropdownStyle(AltoholicTabSearch_SelectSlot)
		MOD:ApplyDropdownStyle(AltoholicTabSearch_SelectLocation)
		AltoholicTabSearch_SelectRarity:ModSize(125, 32)
		AltoholicTabSearch_SelectSlot:ModSize(125, 32)
		AltoholicTabSearch_SelectLocation:ModSize(175, 32)
		MOD:ApplyEditBoxStyle(_G["AltoholicTabSearch_MinLevel"])
		MOD:ApplyEditBoxStyle(_G["AltoholicTabSearch_MaxLevel"])

		for i = 1, 15 do
			MOD:ApplyButtonStyle(_G["AltoholicTabSearchMenuItem"..i])
		end

		for i = 1, 8 do
			MOD:ApplyButtonStyle(_G["AltoholicTabSearch_Sort"..i])
		end
	end
end

MOD:SaveAddonStyle("Altoholic", StyleAltoholic, nil, true)