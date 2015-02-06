--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
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
local FAV_ICON = SV.Media.icon.star
local NORMAL_COLOR = {r = 1, g = 1, b = 1}
local SELECTED_COLOR = {r = 1, g = 1, b = 0}

local function PetJournal_UpdateMounts()
	for b = 1, #MountJournal.ListScrollFrame.buttons do 
		local d = _G["MountJournalListScrollFrameButton"..b]
		local e = _G["MountJournalListScrollFrameButton"..b.."Name"]
		if d.selectedTexture:IsShown() then
			if(e) then e:SetTextColor(1, 1, 0) end
			if d.Panel then
				d:SetBackdropBorderColor(1, 1, 0)
			end 
			if d.IconShadow then
				d.IconShadow:SetBackdropBorderColor(1, 1, 0)
			end 
		else
			if(e) then e:SetTextColor(1, 1, 1) end
			if d.Panel then
				d:SetBackdropBorderColor(0,0,0,1)
			end 
			if d.IconShadow then
				d.IconShadow:SetBackdropBorderColor(0,0,0,1)
			end 
		end 
	end 
end 

local function PetJournal_UpdatePets()
	local u = PetJournal.listScroll.buttons;
	local isWild = PetJournal.isWild;
	for b = 1, #u do 
		local v = u[b].index;
		if not v then
			break 
		end 
		local d = _G["PetJournalListScrollFrameButton"..b]
		local e = _G["PetJournalListScrollFrameButton"..b.."Name"]
		local w, x, y, z, level, favorite, A, B, C, D, E, F, G, H, I = C_PetJournal.GetPetInfoByIndex(v, isWild)
		if w ~= nil then 
			local J, K, L, M, N = C_PetJournal.GetPetStats(w)
			local color = NORMAL_COLOR
			if(N) then 
				color = ITEM_QUALITY_COLORS[N-1]
			end
			d:SetBackdropBorderColor(0,0,0,1)
			if(d.selectedTexture:IsShown() and d.Panel) then
				d:SetBackdropBorderColor(1,1,0,1)
				if d.IconShadow then
					d.IconShadow:SetBackdropBorderColor(1,1,0)
				end
			else
				if d.IconShadow then
					d.IconShadow:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end

			e:SetTextColor(color.r, color.g, color.b)
		end
	end 
end 
--[[ 
########################################################## 
FRAME MODR
##########################################################
]]--
local function PetJournalStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.mounts ~= true then return end 

	MOD:ApplyWindowStyle(PetJournalParent)

	PetJournalParentPortrait:Hide()
	MOD:ApplyTabStyle(PetJournalParentTab1)
	MOD:ApplyTabStyle(PetJournalParentTab2)
	MOD:ApplyCloseButtonStyle(PetJournalParentCloseButton)

	MountJournal:RemoveTextures()
	MountJournal.LeftInset:RemoveTextures()
	MountJournal.RightInset:RemoveTextures()
	MountJournal.MountDisplay:RemoveTextures()
	MountJournal.MountDisplay.ShadowOverlay:RemoveTextures()
	MountJournal.MountCount:RemoveTextures()
	MountJournalListScrollFrame:RemoveTextures()
	MountJournalMountButton:RemoveTextures()
	MountJournalMountButton:SetStyle("Button")
	MountJournalSearchBox:SetStyle("Editbox")

	MOD:ApplyScrollFrameStyle(MountJournalListScrollFrameScrollBar)
	MountJournal.MountDisplay:SetStyle("!_Frame", "ModelBorder")

	local buttons = MountJournal.ListScrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		if(button) then
			MOD:ApplyItemButtonStyle(button, nil, true, true)
			local bar = _G["SVUI_MountSelectBar"..i]
			if(bar) then bar:SetParent(button.Panel) end
			if(button.favorite) then
				local fg = CreateFrame("Frame", nil, button)
				fg:SetAllPoints(favorite)
				fg:SetFrameLevel(button:GetFrameLevel() + 30)
				button.favorite:SetParent(fg)
				button.favorite:SetTexture(SV.Media.icon.star)
			end
		end
	end

	hooksecurefunc("MountJournal_UpdateMountList", PetJournal_UpdateMounts)
	MountJournalListScrollFrame:HookScript("OnVerticalScroll", PetJournal_UpdateMounts)
	MountJournalListScrollFrame:HookScript("OnMouseWheel", PetJournal_UpdateMounts)
	PetJournalSummonButton:RemoveTextures()
	PetJournalFindBattle:RemoveTextures()
	PetJournalSummonButton:SetStyle("Button")
	PetJournalFindBattle:SetStyle("Button")
	PetJournalRightInset:RemoveTextures()
	PetJournalLeftInset:RemoveTextures()

	for i = 1, 3 do 
		local button = _G["PetJournalLoadoutPet" .. i .. "HelpFrame"]
		button:RemoveTextures()
	end 

	PetJournalTutorialButton:Die()
	PetJournal.PetCount:RemoveTextures()
	PetJournalSearchBox:SetStyle("Editbox")
	PetJournalFilterButton:RemoveTextures(true)
	PetJournalFilterButton:SetStyle("Button")
	PetJournalListScrollFrame:RemoveTextures()
	MOD:ApplyScrollFrameStyle(PetJournalListScrollFrameScrollBar)

	for i = 1, #PetJournal.listScroll.buttons do 
		local button = _G["PetJournalListScrollFrameButton" .. i]
		local favorite = _G["PetJournalListScrollFrameButton" .. i .. "Favorite"]
		MOD:ApplyItemButtonStyle(button, false, true)
		if(favorite) then
			local fg = CreateFrame("Frame", nil, button)
			fg:SetAllPoints(favorite)
			fg:SetFrameLevel(button:GetFrameLevel() + 30)
			favorite:SetParent(fg)
			button.dragButton.favorite:SetParent(fg)
			favorite:SetTexture(SV.Media.icon.star)
			favorite:SetTexCoord(0,1,0,1)
		end
		
		button.dragButton.levelBG:SetAlpha(0)
		button.dragButton.level:SetParent(button)
		button.petTypeIcon:SetParent(button.Panel)
	end 

	hooksecurefunc('PetJournal_UpdatePetList', PetJournal_UpdatePets)
	PetJournalListScrollFrame:HookScript("OnVerticalScroll", PetJournal_UpdatePets)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", PetJournal_UpdatePets)
	PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')
	MOD:ApplyItemButtonStyle(PetJournalHealPetButton, true)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	PetJournalLoadoutBorder:RemoveTextures()

	for b = 1, 3 do
		local pjPet = _G['PetJournalLoadoutPet'..b]
		pjPet:RemoveTextures()
		pjPet.petTypeIcon:SetPoint('BOTTOMLEFT', 2, 2)
		pjPet.dragButton:WrapPoints(_G['PetJournalLoadoutPet'..b..'Icon'])
		pjPet.hover = true;
		pjPet.pushed = true;
		pjPet.checked = true;
		MOD:ApplyItemButtonStyle(pjPet, nil, nil, true)
		pjPet.setButton:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStyle("Frame", 'Default')
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStatusBarTexture(SV.Media.bar.default)
		_G['PetJournalLoadoutPet'..b..'XPBar']:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetStyle("Frame", 'Default')
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetStatusBarTexture(SV.BaseTexture)
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetFrameLevel(_G['PetJournalLoadoutPet'..b..'XPBar']:GetFrameLevel()+2)
		for v = 1, 3 do 
			local s = _G['PetJournalLoadoutPet'..b..'Spell'..v]
			MOD:ApplyItemButtonStyle(s)
			s.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
			_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:InsetPoints(s)
			s.Panel:SetFrameLevel(s:GetFrameLevel() + 1)
			_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:SetParent(s.Panel)
		end 
	end 

	PetJournalSpellSelect:RemoveTextures()

	for b = 1, 2 do 
		local Q = _G['PetJournalSpellSelectSpell'..b]
		MOD:ApplyItemButtonStyle(Q)
		_G['PetJournalSpellSelectSpell'..b..'Icon']:InsetPoints(Q)
		_G['PetJournalSpellSelectSpell'..b..'Icon']:SetDrawLayer('BORDER')
	end 

	PetJournalPetCard:RemoveTextures()
	MOD:ApplyItemButtonStyle(PetJournalPetCard, nil, nil, true)
	PetJournalPetCardInset:RemoveTextures()
	PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	MOD:ApplyItemButtonStyle(PetJournalPetCardPetInfo, nil, true, true)

	local fg = CreateFrame("Frame", nil, PetJournalPetCardPetInfo)
	fg:SetSize(40,40)
	fg:SetPoint("TOPLEFT", PetJournalPetCardPetInfo, "TOPLEFT", -1, 1)
	fg:SetFrameLevel(PetJournalPetCardPetInfo:GetFrameLevel() + 30)

	PetJournalPetCardPetInfo.favorite:SetParent(fg)
	PetJournalPetCardPetInfo.Panel:WrapPoints(PetJournalPetCardPetInfoIcon)
	PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.Panel)
	PetJournalPetCardPetInfo.level:SetParent(PetJournalPetCardPetInfo.Panel)

	local R = PetJournalPrimaryAbilityTooltip;R.Background:SetTexture(0,0,0,0)
	if R.Delimiter1 then
		R.Delimiter1:SetTexture(0,0,0,0)
		R.Delimiter2:SetTexture(0,0,0,0)
	end

	R.BorderTop:SetTexture(0,0,0,0)
	R.BorderTopLeft:SetTexture(0,0,0,0)
	R.BorderTopRight:SetTexture(0,0,0,0)
	R.BorderLeft:SetTexture(0,0,0,0)
	R.BorderRight:SetTexture(0,0,0,0)
	R.BorderBottom:SetTexture(0,0,0,0)
	R.BorderBottomRight:SetTexture(0,0,0,0)
	R.BorderBottomLeft:SetTexture(0,0,0,0)
	R:SetStyle("!_Frame", "Transparent", true)

	for b = 1, 6 do 
		local S = _G['PetJournalPetCardSpell'..b]
		S:SetFrameLevel(S:GetFrameLevel() + 2)
		S:DisableDrawLayer('BACKGROUND')
		S:SetStyle("Frame", 'Transparent')
		S.Panel:SetAllPoints()
		S.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		S.icon:InsetPoints(S.Panel)
	end

	PetJournalPetCardHealthFrame.healthBar:RemoveTextures()
	PetJournalPetCardHealthFrame.healthBar:SetStyle("Frame", 'Default')
	PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(SV.BaseTexture)
	PetJournalPetCardXPBar:RemoveTextures()
	PetJournalPetCardXPBar:SetStyle("Frame", 'Default')
	PetJournalPetCardXPBar:SetStatusBarTexture(SV.BaseTexture)

	MOD:ApplyTabStyle(PetJournalParentTab3)
	ToyBox:RemoveTextures()
	ToyBoxProgressBar:SetStyle("Frame", "Bar", true)
	ToyBoxSearchBox:SetStyle("Editbox")
	ToyBoxFilterButton:RemoveTextures()
	ToyBoxFilterButton:SetStyle("Button")
	ToyBoxIconsFrame:RemoveTextures()
	ToyBoxIconsFrame:SetStyle("!_Frame", 'ModelBorder')

	MountJournalFilterButton:RemoveTextures()
	MountJournalFilterButton:SetStyle("Button")

	MountJournal.SummonRandomFavoriteButton:RemoveTextures()
	MountJournal.SummonRandomFavoriteButton:SetStyle("ActionSlot")
	MountJournal.SummonRandomFavoriteButton.texture:SetTexture([[Interface\ICONS\ACHIEVEMENT_GUILDPERK_MOUNTUP]])
	MountJournal.SummonRandomFavoriteButton.texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	for i = 1, 18 do
		local gName = ("ToySpellButton%d"):format(i)
		local button = _G[gName]
		if(button) then
			button:SetStyle("Button")
		end
	end
end

local function CollectionsJournalStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.mounts ~= true then return end 

	MOD:ApplyWindowStyle(CollectionsJournal)

	CollectionsJournalPortrait:Hide()
	MOD:ApplyTabStyle(CollectionsJournalTab1)
	MOD:ApplyTabStyle(CollectionsJournalTab2)
	MOD:ApplyCloseButtonStyle(CollectionsJournalCloseButton)

	MountJournal:RemoveTextures()
	MountJournal.LeftInset:RemoveTextures()
	MountJournal.RightInset:RemoveTextures()
	MountJournal.MountDisplay:RemoveTextures()
	MountJournal.MountDisplay.ShadowOverlay:RemoveTextures()
	MountJournal.MountCount:RemoveTextures()
	MountJournalListScrollFrame:RemoveTextures()
	MountJournalMountButton:RemoveTextures()
	MountJournalMountButton:SetStyle("Button")
	MountJournalSearchBox:SetStyle("Editbox")

	MOD:ApplyScrollFrameStyle(MountJournalListScrollFrameScrollBar)
	MountJournal.MountDisplay:SetStyle("!_Frame", "Model")

	local buttons = MountJournal.ListScrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		if(button) then
			MOD:ApplyItemButtonStyle(button, nil, true, true)
			local bar = _G["SVUI_MountSelectBar"..i]
			if(bar) then bar:SetParent(button.Panel) end
			if(button.favorite) then
				local fg = CreateFrame("Frame", nil, button)
				fg:SetAllPoints(favorite)
				fg:SetFrameLevel(button:GetFrameLevel() + 30)
				button.favorite:SetParent(fg)
				button.favorite:SetTexture(SV.Media.icon.star)
			end
		end
	end

	hooksecurefunc("MountJournal_UpdateMountList", PetJournal_UpdateMounts)
	MountJournalListScrollFrame:HookScript("OnVerticalScroll", PetJournal_UpdateMounts)
	MountJournalListScrollFrame:HookScript("OnMouseWheel", PetJournal_UpdateMounts)
	PetJournalSummonButton:RemoveTextures()
	PetJournalFindBattle:RemoveTextures()
	PetJournalSummonButton:SetStyle("Button")
	PetJournalFindBattle:SetStyle("Button")
	PetJournalRightInset:RemoveTextures()
	PetJournalLeftInset:RemoveTextures()

	for i = 1, 3 do 
		local button = _G["PetJournalLoadoutPet" .. i .. "HelpFrame"]
		button:RemoveTextures()
	end 

	PetJournalTutorialButton:Die()
	PetJournal.PetCount:RemoveTextures()
	PetJournalSearchBox:SetStyle("Editbox")
	PetJournalFilterButton:RemoveTextures(true)
	PetJournalFilterButton:SetStyle("Button")
	PetJournalListScrollFrame:RemoveTextures()
	MOD:ApplyScrollFrameStyle(PetJournalListScrollFrameScrollBar)

	for i = 1, #PetJournal.listScroll.buttons do 
		local button = _G["PetJournalListScrollFrameButton" .. i]
		local favorite = _G["PetJournalListScrollFrameButton" .. i .. "Favorite"]
		MOD:ApplyItemButtonStyle(button, false, true)
		if(favorite) then
			local fg = CreateFrame("Frame", nil, button)
			fg:SetAllPoints(favorite)
			fg:SetFrameLevel(button:GetFrameLevel() + 30)
			favorite:SetParent(fg)
			button.dragButton.favorite:SetParent(fg)
			favorite:SetTexture(SV.Media.icon.star)
			favorite:SetTexCoord(0,1,0,1)
		end
		
		button.dragButton.levelBG:SetAlpha(0)
		button.dragButton.level:SetParent(button)
		button.petTypeIcon:SetParent(button.Panel)
	end 

	hooksecurefunc('PetJournal_UpdatePetList', PetJournal_UpdatePets)
	PetJournalListScrollFrame:HookScript("OnVerticalScroll", PetJournal_UpdatePets)
	PetJournalListScrollFrame:HookScript("OnMouseWheel", PetJournal_UpdatePets)
	PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')
	MOD:ApplyItemButtonStyle(PetJournalHealPetButton, true)
	PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	PetJournalLoadoutBorder:RemoveTextures()

	for b = 1, 3 do
		local pjPet = _G['PetJournalLoadoutPet'..b]
		pjPet:RemoveTextures()
		pjPet.petTypeIcon:SetPoint('BOTTOMLEFT', 2, 2)
		pjPet.dragButton:WrapPoints(_G['PetJournalLoadoutPet'..b..'Icon'])
		pjPet.hover = true;
		pjPet.pushed = true;
		pjPet.checked = true;
		MOD:ApplyItemButtonStyle(pjPet, nil, nil, true)
		pjPet.setButton:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStyle("Frame", 'Default')
		_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStatusBarTexture(SV.Media.bar.default)
		_G['PetJournalLoadoutPet'..b..'XPBar']:RemoveTextures()
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetStyle("Frame", 'Default')
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetStatusBarTexture(SV.BaseTexture)
		_G['PetJournalLoadoutPet'..b..'XPBar']:SetFrameLevel(_G['PetJournalLoadoutPet'..b..'XPBar']:GetFrameLevel()+2)
		for v = 1, 3 do 
			local s = _G['PetJournalLoadoutPet'..b..'Spell'..v]
			MOD:ApplyItemButtonStyle(s)
			s.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
			_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:InsetPoints(s)
			s.Panel:SetFrameLevel(s:GetFrameLevel() + 1)
			_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:SetParent(s.Panel)
		end 
	end 

	PetJournalSpellSelect:RemoveTextures()

	for b = 1, 2 do 
		local Q = _G['PetJournalSpellSelectSpell'..b]
		MOD:ApplyItemButtonStyle(Q)
		_G['PetJournalSpellSelectSpell'..b..'Icon']:InsetPoints(Q)
		_G['PetJournalSpellSelectSpell'..b..'Icon']:SetDrawLayer('BORDER')
	end 

	PetJournalPetCard:RemoveTextures()
	MOD:ApplyItemButtonStyle(PetJournalPetCard, nil, nil, true)
	PetJournalPetCardInset:RemoveTextures()
	PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	MOD:ApplyItemButtonStyle(PetJournalPetCardPetInfo, nil, true, true)

	local fg = CreateFrame("Frame", nil, PetJournalPetCardPetInfo)
	fg:SetSize(40,40)
	fg:SetPoint("TOPLEFT", PetJournalPetCardPetInfo, "TOPLEFT", -1, 1)
	fg:SetFrameLevel(PetJournalPetCardPetInfo:GetFrameLevel() + 30)

	PetJournalPetCardPetInfo.favorite:SetParent(fg)
	PetJournalPetCardPetInfo.Panel:WrapPoints(PetJournalPetCardPetInfoIcon)
	PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.Panel)
	PetJournalPetCardPetInfo.level:SetParent(PetJournalPetCardPetInfo.Panel)

	local R = PetJournalPrimaryAbilityTooltip;R.Background:SetTexture(0,0,0,0)
	if R.Delimiter1 then
		R.Delimiter1:SetTexture(0,0,0,0)
		R.Delimiter2:SetTexture(0,0,0,0)
	end

	R.BorderTop:SetTexture(0,0,0,0)
	R.BorderTopLeft:SetTexture(0,0,0,0)
	R.BorderTopRight:SetTexture(0,0,0,0)
	R.BorderLeft:SetTexture(0,0,0,0)
	R.BorderRight:SetTexture(0,0,0,0)
	R.BorderBottom:SetTexture(0,0,0,0)
	R.BorderBottomRight:SetTexture(0,0,0,0)
	R.BorderBottomLeft:SetTexture(0,0,0,0)
	R:SetStyle("!_Frame", "Transparent", true)

	for b = 1, 6 do 
		local S = _G['PetJournalPetCardSpell'..b]
		S:SetFrameLevel(S:GetFrameLevel() + 2)
		S:DisableDrawLayer('BACKGROUND')
		S:SetStyle("Frame", 'Transparent')
		S.Panel:SetAllPoints()
		S.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		S.icon:InsetPoints(S.Panel)
	end

	PetJournalPetCardHealthFrame.healthBar:RemoveTextures()
	PetJournalPetCardHealthFrame.healthBar:SetStyle("Frame", 'Default')
	PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(SV.BaseTexture)
	PetJournalPetCardXPBar:RemoveTextures()
	PetJournalPetCardXPBar:SetStyle("Frame", 'Default')
	PetJournalPetCardXPBar:SetStatusBarTexture(SV.BaseTexture)

	MOD:ApplyTabStyle(CollectionsJournalTab3)
	ToyBox:RemoveTextures()
	ToyBoxProgressBar:SetStyle("Frame", "Bar", true)
	ToyBoxSearchBox:SetStyle("Editbox")
	ToyBoxFilterButton:RemoveTextures()
	ToyBoxFilterButton:SetStyle("Button")
	ToyBoxIconsFrame:RemoveTextures()
	ToyBoxIconsFrame:SetStyle("!_Frame", 'Model')

	MountJournalFilterButton:RemoveTextures()
	MountJournalFilterButton:SetStyle("Button")

	MountJournal.SummonRandomFavoriteButton:RemoveTextures()
	MountJournal.SummonRandomFavoriteButton:SetStyle("ActionSlot")
	MountJournal.SummonRandomFavoriteButton.texture:SetTexture([[Interface\ICONS\ACHIEVEMENT_GUILDPERK_MOUNTUP]])
	MountJournal.SummonRandomFavoriteButton.texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	for i = 1, 18 do
		local gName = ("ToySpellButton%d"):format(i)
		local button = _G[gName]
		if(button) then
			button:SetStyle("Button")
		end
	end
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_PetJournal", PetJournalStyle)
MOD:SaveBlizzardStyle("Blizzard_Collections", CollectionsJournalStyle)