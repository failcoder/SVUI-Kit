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
local SlotListener = CreateFrame("Frame")

local CharacterSlotNames = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"MainHandSlot",
	"SecondaryHandSlot"
};

local CharFrameList = {
	"CharacterFrame",
	"CharacterModelFrame",
	"CharacterFrameInset",
	"CharacterStatsPane",
	"CharacterFrameInsetRight",
	"PaperDollFrame",
	"PaperDollSidebarTabs",
	"PaperDollEquipmentManagerPane"
};

local function SetItemFrame(frame, point)
	point = point or frame
	local noscalemult = 2 * UIParent:GetScale()
	if point.bordertop then return end
	point.backdrop = frame:CreateTexture(nil, "BORDER")
	point.backdrop:SetDrawLayer("BORDER", -4)
	point.backdrop:SetAllPoints(point)
	point.backdrop:SetTexture(SV.Media.bar.default)
	point.backdrop:SetVertexColor(unpack(SV.Media.color.default))	
	point.bordertop = frame:CreateTexture(nil, "BORDER")
	point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.bordertop:SetHeight(noscalemult)
	point.bordertop:SetTexture(0,0,0)	
	point.bordertop:SetDrawLayer("BORDER", 1)
	point.borderbottom = frame:CreateTexture(nil, "BORDER")
	point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
	point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
	point.borderbottom:SetHeight(noscalemult)
	point.borderbottom:SetTexture(0,0,0)	
	point.borderbottom:SetDrawLayer("BORDER", 1)
	point.borderleft = frame:CreateTexture(nil, "BORDER")
	point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
	point.borderleft:SetWidth(noscalemult)
	point.borderleft:SetTexture(0,0,0)	
	point.borderleft:SetDrawLayer("BORDER", 1)
	point.borderright = frame:CreateTexture(nil, "BORDER")
	point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
	point.borderright:SetWidth(noscalemult)
	point.borderright:SetTexture(0,0,0)	
	point.borderright:SetDrawLayer("BORDER", 1)	
end

local function StyleCharacterSlots()
	for _,slotName in pairs(CharacterSlotNames) do
		local globalName = ("Character%s"):format(slotName)
		local charSlot = _G[globalName]
		if(charSlot) then
			if(not charSlot.Panel) then
				charSlot:RemoveTextures()
				charSlot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
				charSlot:SetStyle("!_ActionSlot", 1, 0, 0)

				local iconTex = _G[globalName.."IconTexture"]
				if(iconTex) then
					iconTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
					iconTex:InsetPoints(charSlot)
					--iconTex:SetParent(charSlot.Panel)
				end
			end

			local slotID = GetInventorySlotInfo(slotName)
			if(slotID) then
				local itemID = GetInventoryItemID("player", slotID)
				if(itemID) then 
					local info = select(3, GetItemInfo(itemID))
					if info and info > 1 then
						 charSlot:SetBackdropBorderColor(GetItemQualityColor(info))
					else
						 charSlot:SetBackdropBorderColor(0,0,0,1)
					end 
				else
					 charSlot:SetBackdropBorderColor(0,0,0,1)
				end
			end
		end 
	end

	for i = 1, #PAPERDOLL_SIDEBARS do 
		local tab = _G["PaperDollSidebarTab"..i]
		if(tab) then
			if(not tab.Panel) then
				tab.Highlight:SetTexture(1, 1, 1, 0.3)
				tab.Highlight:ModPoint("TOPLEFT", 3, -4)
				tab.Highlight:ModPoint("BOTTOMRIGHT", -1, 0)
				tab.Hider:SetTexture(0.4, 0.4, 0.4, 0.4)
				tab.Hider:ModPoint("TOPLEFT", 3, -4)
				tab.Hider:ModPoint("BOTTOMRIGHT", -1, 0)
				tab.TabBg:Die()
				if i == 1 then
					for x = 1, tab:GetNumRegions()do 
						local texture = select(x, tab:GetRegions())
						texture:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					end 
				end 
				tab:SetStyle("Frame", "Default", true, 2)
				tab.Panel:ModPoint("TOPLEFT", 2, -3)
				tab.Panel:ModPoint("BOTTOMRIGHT", 0, -2)
			end
			if(i == 1) then
				tab:ClearAllPoints()
				tab:SetPoint("BOTTOM", CharacterFrameInsetRight, "TOP", -30, 4)
			else
				tab:ClearAllPoints()
				tab:SetPoint("LEFT",  _G["PaperDollSidebarTab"..i-1], "RIGHT", 4, 0)
			end
		end 
	end
end 

local function EquipmentFlyout_OnShow()
	EquipmentFlyoutFrameButtons:RemoveTextures()
	local counter = 1;
	local button = _G["EquipmentFlyoutFrameButton"..counter]
	while button do 
		local texture = _G["EquipmentFlyoutFrameButton"..counter.."IconTexture"]
		button:SetStyle("Button")
		texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		button:GetNormalTexture():SetTexture("")
		texture:InsetPoints()
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		if not button.Panel then
			button:SetStyle("Frame", "Default")
			button.Panel:SetAllPoints()
		end 
		counter = counter + 1;
		button = _G["EquipmentFlyoutFrameButton"..counter]
	end 
end

local function Reputation_OnShow()
	for i = 1, GetNumFactions()do 
		local bar = _G["ReputationBar"..i.."ReputationBar"]
		if bar then
			 bar:SetStatusBarTexture(SV.BaseTexture)
			if not bar.Panel then
				 bar:SetStyle("Frame", "Inset")
			end 
			_G["ReputationBar"..i.."Background"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture("")
			_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture("")
		end 
	end 
end

local function PaperDollTitlesPane_OnShow()
	for i,btn in pairs(PaperDollTitlesPane.buttons) do
		if(btn) then
			btn.BgTop:SetTexture("")
			btn.BgBottom:SetTexture("")
			btn.BgMiddle:SetTexture("")
		end
	end
	PaperDollTitlesPane_Update()
end

local function PaperDollEquipmentManagerPane_OnShow()
	for i,btn in pairs(PaperDollEquipmentManagerPane.buttons) do
		if(btn) then
			btn.BgTop:SetTexture("")
			btn.BgBottom:SetTexture("")
			btn.BgMiddle:SetTexture("")
			btn.icon:ModSize(36, 36)
			btn.Check:SetTexture("")
			btn.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			btn.icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
			if not btn.icon.bordertop then
				 SetItemFrame(btn, btn.icon)
			end 
		end
	end

	GearManagerDialogPopup:RemoveTextures()
	GearManagerDialogPopup:SetStyle("Frame", "Inset", true)
	GearManagerDialogPopup:ModPoint("LEFT", PaperDollFrame, "RIGHT", 4, 0)
	GearManagerDialogPopupScrollFrame:RemoveTextures()
	GearManagerDialogPopupEditBox:RemoveTextures()
	GearManagerDialogPopupEditBox:SetStyle("Frame", 'Inset')
	GearManagerDialogPopupOkay:SetStyle("Button")
	GearManagerDialogPopupCancel:SetStyle("Button")

	for i = 1, NUM_GEARSET_ICONS_SHOWN do 
		local btn = _G["GearManagerDialogPopupButton"..i]
		if(btn and (not btn.Panel)) then
			btn:RemoveTextures()
			btn:SetFrameLevel(btn:GetFrameLevel() + 2)
			btn:SetStyle("Button")
			if(btn.icon) then
				btn.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				btn.icon:SetTexture("")
				btn.icon:InsetPoints()
			end 
		end 
	end
end
--[[ 
########################################################## 
CHARACTERFRAME MODR
##########################################################
]]--
local function CharacterFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.character ~= true then
		 return 
	end

	SV.API:Set("Window", CharacterFrame, true, true, 1, 3, 3)

	SV.API:Set("CloseButton", CharacterFrameCloseButton)
	SV.API:Set("ScrollFrame", CharacterStatsPaneScrollBar)
	SV.API:Set("ScrollFrame", ReputationListScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", TokenFrameContainerScrollBar)
	SV.API:Set("ScrollFrame", GearManagerDialogPopupScrollFrameScrollBar)
	
	StyleCharacterSlots()

	SlotListener:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	SlotListener:SetScript("OnEvent", StyleCharacterSlots)
	CharacterFrame:HookScript("OnShow", StyleCharacterSlots)

	SV.API:Set("PageButton", CharacterFrameExpandButton)

	hooksecurefunc('CharacterFrame_Collapse', function()
		CharacterFrameExpandButton:RemoveTextures()
		SquareButton_SetIcon(CharacterFrameExpandButton, 'RIGHT')
	end)

	hooksecurefunc('CharacterFrame_Expand', function()
		CharacterFrameExpandButton:RemoveTextures()
		SquareButton_SetIcon(CharacterFrameExpandButton, 'LEFT')
	end)

	if GetCVar("characterFrameCollapsed") ~= "0" then
		 SquareButton_SetIcon(CharacterFrameExpandButton, 'RIGHT')
	else
		 SquareButton_SetIcon(CharacterFrameExpandButton, 'LEFT')
	end 

	SV.API:Set("CloseButton", ReputationDetailCloseButton)
	SV.API:Set("CloseButton", TokenFramePopupCloseButton)
	ReputationDetailAtWarCheckBox:SetStyle("Checkbox")
	ReputationDetailMainScreenCheckBox:SetStyle("Checkbox")
	ReputationDetailInactiveCheckBox:SetStyle("Checkbox")
	ReputationDetailLFGBonusReputationCheckBox:SetStyle("Checkbox")
	TokenFramePopupInactiveCheckBox:SetStyle("Checkbox")
	TokenFramePopupBackpackCheckBox:SetStyle("Checkbox")
	EquipmentFlyoutFrameHighlight:Die()
	EquipmentFlyoutFrame:HookScript("OnShow", EquipmentFlyout_OnShow)
	hooksecurefunc("EquipmentFlyout_Show", EquipmentFlyout_OnShow)
	CharacterFramePortrait:Die()
	SV.API:Set("ScrollFrame", _G["PaperDollTitlesPaneScrollBar"], 5)
	SV.API:Set("ScrollFrame", _G["PaperDollEquipmentManagerPaneScrollBar"], 5)

	for _,gName in pairs(CharFrameList) do
		if(_G[gName]) then _G[gName]:RemoveTextures(true) end
	end 

	CharacterFrameInsetRight:SetStyle("Frame", 'Inset')

	for i=1, 6 do
		local pane = _G["CharacterStatsPaneCategory"..i]
		if(pane) then
			pane:RemoveTextures()
		end
	end

	CharacterModelFrameBackgroundTopLeft:SetTexture("")
	CharacterModelFrameBackgroundTopRight:SetTexture("")
	CharacterModelFrameBackgroundBotLeft:SetTexture("")
	CharacterModelFrameBackgroundBotRight:SetTexture("")

	CharacterModelFrame:SetStyle("!_Frame", "Model")
	CharacterFrameExpandButton:SetFrameLevel(CharacterModelFrame:GetFrameLevel() + 5)

	PaperDollTitlesPane:RemoveTextures()
	PaperDollTitlesPaneScrollChild:RemoveTextures()
	PaperDollTitlesPane:SetStyle("Frame", 'Inset')
	PaperDollTitlesPane:HookScript("OnShow", PaperDollTitlesPane_OnShow)

	PaperDollEquipmentManagerPane:SetStyle("Frame", 'Inset')
	PaperDollEquipmentManagerPaneEquipSet:SetStyle("Button")
	PaperDollEquipmentManagerPaneSaveSet:SetStyle("Button")
	PaperDollEquipmentManagerPaneEquipSet:ModWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-8)
	PaperDollEquipmentManagerPaneSaveSet:ModWidth(PaperDollEquipmentManagerPaneSaveSet:GetWidth()-8)
	PaperDollEquipmentManagerPaneEquipSet:ModPoint("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
	PaperDollEquipmentManagerPaneSaveSet:ModPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
	PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture("")

	PaperDollEquipmentManagerPane:HookScript("OnShow", PaperDollEquipmentManagerPane_OnShow)

	for i = 1, 4 do
		 SV.API:Set("Tab", _G["CharacterFrameTab"..i])
	end


	ReputationFrame:RemoveTextures(true)
	ReputationListScrollFrame:RemoveTextures()
	ReputationListScrollFrame:SetStyle("Frame", "Inset")
	ReputationDetailFrame:RemoveTextures()
	ReputationDetailFrame:SetStyle("Frame", "Inset", true)
	ReputationDetailFrame:ModPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -28)
	ReputationFrame:HookScript("OnShow", Reputation_OnShow)
	hooksecurefunc("ExpandFactionHeader", Reputation_OnShow)
	hooksecurefunc("CollapseFactionHeader", Reputation_OnShow)
	TokenFrameContainer:SetStyle("Frame", 'Inset')

	TokenFrame:HookScript("OnShow", function()
		for i = 1, GetCurrencyListSize() do 
			local currency = _G["TokenFrameContainerButton"..i]
			if(currency) then
				currency.highlight:Die()
				currency.categoryMiddle:Die()
				currency.categoryLeft:Die()
				currency.categoryRight:Die()
				if currency.icon then
					 currency.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				end 
			end 
		end 
		TokenFramePopup:RemoveTextures()
		TokenFramePopup:SetStyle("Frame", "Inset", true)
		TokenFramePopup:ModPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 4, -28)
	end)

	PetModelFrame:SetStyle("Frame", "Premium", false, 1, -7, -7)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(.12, .63, .15, .55)
	PetPaperDollPetInfo:SetFrameLevel(PetPaperDollPetInfo:GetFrameLevel() + 10)
	PetPaperDollPetInfo:SetStyle("Frame", "Icon")
	PetPaperDollPetInfo.Panel:SetFrameLevel(0)
	PetPaperDollPetInfo:ModSize(24, 24)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(CharacterFrameStyle)