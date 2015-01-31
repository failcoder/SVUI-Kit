--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
local SV = _G['SVUI']
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;

local SVUILib = Librarian("Registry")
--[[ 
########################################################## 
Simple click2cast spell SpellBinder(sBinder by Fernir)
##########################################################
]]--
local ClickCastFrames
do
	_G.ClickCastFrames = _G.ClickCastFrames or {}
	ClickCastFrames = _G.ClickCastFrames
end

local UnitParseListing = {
	"PlayerFrame", "PetFrame",
	"TargetFrame", "TargetFrameToT", 
	"FocusFrame", "FocusFrameToT", 
	"Boss1TargetFrame", "Boss2TargetFrame", "Boss3TargetFrame", "Boss4TargetFrame", 
	"ArenaEnemyFrame1", "ArenaEnemyFrame2", "ArenaEnemyFrame3", "ArenaEnemyFrame4", "ArenaEnemyFrame5",
	"PartyMemberFrame1", "PartyMemberFrame2", "PartyMemberFrame3", "PartyMemberFrame4", "PartyMemberFrame5", 
	"PartyMemberFrame1PetFrame", "PartyMemberFrame2PetFrame", "PartyMemberFrame3PetFrame", "PartyMemberFrame4PetFrame", "PartyMemberFrame5PetFrame", 
	"CompactPartyFrameMemberSelf", "CompactPartyFrameMemberSelfBuff1", "CompactPartyFrameMemberSelfBuff2", "CompactPartyFrameMemberSelfBuff3", 
	"CompactPartyFrameMemberSelfDebuff1", "CompactPartyFrameMemberSelfDebuff2", "CompactPartyFrameMemberSelfDebuff3", 
	"CompactPartyFrameMember1Buff1", "CompactPartyFrameMember1Buff2", "CompactPartyFrameMember1Buff3", 
	"CompactPartyFrameMember1Debuff1", "CompactPartyFrameMember1Debuff2", "CompactPartyFrameMember1Debuff3", 
	"CompactPartyFrameMember2Buff1", "CompactPartyFrameMember2Buff2", "CompactPartyFrameMember2Buff3", 
	"CompactPartyFrameMember2Debuff1", "CompactPartyFrameMember2Debuff2", "CompactPartyFrameMember2Debuff3", 
	"CompactPartyFrameMember3Buff1", "CompactPartyFrameMember3Buff2", "CompactPartyFrameMember3Buff3", 
	"CompactPartyFrameMember3Debuff1", "CompactPartyFrameMember3Debuff2", "CompactPartyFrameMember3Debuff3", 
	"CompactPartyFrameMember4Buff1", "CompactPartyFrameMember4Buff2", "CompactPartyFrameMember4Buff3", 
	"CompactPartyFrameMember4Debuff1", "CompactPartyFrameMember4Debuff2", "CompactPartyFrameMember4Debuff3", 
	"CompactPartyFrameMember5Buff1", "CompactPartyFrameMember5Buff2", "CompactPartyFrameMember5Buff3", 
	"CompactPartyFrameMember5Debuff1", "CompactPartyFrameMember5Debuff2", "CompactPartyFrameMember5Debuff3"
}

for _, gName in pairs(UnitParseListing) do
	local frame = _G[gName]
	if(frame) then 
		ClickCastFrames[frame] = true 
	end
end

local SpellBinder = CreateFrame("Frame", "SVUI_SpellBinder", SpellBookFrame, "ButtonFrameTemplate")
SpellBinder:SetPoint("TOPLEFT", SpellBookFrame, "TOPRIGHT", 100, 0)
SpellBinder:SetSize(300, 400)
SpellBinder:Hide()

SpellBinder.title = SpellBinder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SpellBinder.title:SetPoint("TOP", SpellBinder, "TOP", 0, -5)
SpellBinder.title:SetText("Click-Cast Bindings")

SpellBinder.sbOpen = false
SpellBinder.spellbuttons = {}

SpellBinder.list = CreateFrame("ScrollFrame", "SVUI_SpellBinderSpellList", _G["SVUI_SpellBinderInset"], "UIPanelScrollFrameTemplate")
SpellBinder.list.child = CreateFrame("Frame", nil, SpellBinder.list)
SpellBinder.list:SetPoint("TOPLEFT", _G["SVUI_SpellBinderInset"], "TOPLEFT", 0, -5)
SpellBinder.list:SetPoint("BOTTOMRIGHT", _G["SVUI_SpellBinderInset"], "BOTTOMRIGHT", -30, 5)
SpellBinder.list:SetScrollChild(SpellBinder.list.child)
--[[ 
########################################################## 
SCRIPT HANDLERS
##########################################################
]]--
local BoundSpell_OnEnter = function(self) 
	self.delete:GetNormalTexture():SetVertexColor(1, 0, 0)
	self:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
	self:SetBackdropColor(0.2, 0.2, 0.2, 0.7)
end

local BoundSpell_OnLeave = function(self) 
	self.delete:GetNormalTexture():SetVertexColor(0.8, 0, 0)
	self:SetBackdrop(nil)
end

local Temp_OnUpdate = function(self)
	self:UpdateAll()
	if self.updated then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local SpellBindTab_OnEnter = function(self) 
	GameTooltip:ClearLines() 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT") 
	GameTooltip:AddLine("Click-Cast Binding") 
	GameTooltip:Show() 
end

local SpellBindTab_OnLeave = function(self) 
	GameTooltip:Hide() 
end

local SpellBindTab_OnShow = function(self)
	if SpellBinder:IsVisible() then self:SetChecked(true) end
	local num = GetNumSpellTabs()
	local lastTab = _G["SpellBookSkillLineTab"..num]

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", lastTab, "BOTTOMLEFT", 0, -17)

	self:SetScript("OnEnter", SpellBindTab_OnEnter)
	self:SetScript("OnLeave", SpellBindTab_OnLeave)
end

local SpellBindTab_OnClick = function(self)
	if InCombatLockdown() then SpellBinder:Hide() return end
	if SpellBinder:IsVisible() then
		SpellBinder:Hide()
		SpellBinder.sbOpen = false
	else
		SpellBinder:Show()
		SpellBinder.sbOpen = true
	end
	SpellBinder:ToggleButtons()
end

local SpellBindClose_OnClick = function(self)
	SpellBinder:Hide()
	SpellBinder.sbOpen = false
	SpellBinder:ToggleButtons()
end

local SpellBindMask_OnClick = function(self, button)
	if SpellBinder.sbOpen then
		local slot = SpellBook_GetSpellBookSlot(self:GetParent())
		local spellname, subtype = GetSpellBookItemName(slot, SpellBookFrame.bookType)
		local texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType)

		if spellname ~= 0 and ((SpellBookFrame.bookType == BOOKTYPE_PET) or (SpellBookFrame.selectedSkillLine > 1)) then
			local originalbutton = button
			local modifier = ""

			if IsShiftKeyDown() then modifier = "Shift-"..modifier end
			if IsControlKeyDown() then modifier = "Ctrl-"..modifier end
			if IsAltKeyDown() then modifier = "Alt-"..modifier end

			if IsHarmfulSpell(slot, SpellBookFrame.bookType) then
				button = ("%s%d"):format("harmbutton", SecureButton_GetButtonSuffix(button))
				originalbutton = "|cffff2222(harm)|r "..originalbutton
			else
				button = SecureButton_GetButtonSuffix(button)
			end

			for i, v in pairs(SV.private.SpellBinder.spells) do if v.spell == spellname then return end end

			tinsert(SV.private.SpellBinder.spells, {["id"] = slot, ["modifier"] = modifier, ["button"] = button, ["spell"] = spellname, ["rank"] = "", ["texture"] = texture, ["origbutton"] = originalbutton,})
			SpellBinder:BuildSpells(false)
		end
	end
end

local SpellBindDelete_OnClick = function(self)
	local spell = self.spell
	for j, k in ipairs(SV.private.SpellBinder.spells) do
		if k ~= spell.spell then
			k.checked = false
			_G[j.."_cbs"]:SetBackdropColor(0, 0, 0, 0)
		end
	end
	spell.checked = not spell.checked
	SpellBinder:DeleteSpell()
end
--[[ 
########################################################## 
EVENT HANDLERS
##########################################################
]]--
local SpellBind_OnEvent = function(self)
	self:UpdateAll()
end
--[[ 
########################################################## 
METHODS
##########################################################
]]--
function SpellBinder:BuildSpells(delete)
	if(not SV.private.SpellBinder) then return end

	if(not SV.private.SpellBinder.spells) then
		SV.private.SpellBinder.spells = {}
		SV.private.SpellBinder.frames = {}
		SV.private.SpellBinder.keys = {}
	end
	
	local oldb, spellName
	local scroll = self.list.child
	scroll:SetPoint("TOPLEFT")
	scroll:SetSize(270, 300)

	if delete then
		local i = 1
		while _G[i.."_cbs"] do
			_G[i.."_fs"]:SetText("")
			_G[i.."_texture"]:SetTexture(0,0,0,0)
			_G[i.."_cbs"].checked = false
			_G[i.."_cbs"]:ClearAllPoints()
			_G[i.."_cbs"]:Hide()
			i = i + 1
		end
	end

	for i, spell in ipairs(SV.private.SpellBinder.spells) do
		spellName = spell.spell
		if spellName then
			local bf = _G[i.."_cbs"] or CreateFrame("Button", i.."_cbs", scroll)
			spell.checked = spell.checked or false

			if i == 1 then
				bf:SetPoint("TOPLEFT", scroll, "TOPLEFT", 10, -10)
				bf:SetPoint("BOTTOMRIGHT", scroll, "TOPRIGHT", -10, -34)
			else
				bf:SetPoint("TOPLEFT", oldb, "BOTTOMLEFT", 0, -2)
				bf:SetPoint("BOTTOMRIGHT", oldb, "BOTTOMRIGHT", 0, -26)
			end

			bf:EnableMouse(true)

			bf.tex = bf.tex or bf:CreateTexture(i.."_texture", "OVERLAY")
			bf.tex:SetSize(22, 22)
			bf.tex:SetPoint("LEFT")
			bf.tex:SetTexture(spell.texture)
			bf.tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			bf.delete = bf.delete or CreateFrame("Button", i.."_delete", bf)
			bf.delete:SetSize(16, 16)
			bf.delete:SetPoint("RIGHT")
			bf.delete:SetNormalTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
			bf.delete:GetNormalTexture():SetVertexColor(0.8, 0, 0)
			bf.delete:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
			bf.delete:SetHighlightTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
			bf.delete.spell = spell
			bf.delete:SetScript("OnClick", SpellBindDelete_OnClick)

			bf:SetScript("OnEnter", BoundSpell_OnEnter)
			bf:SetScript("OnLeave", BoundSpell_OnLeave)

			bf.fs = bf.fs or bf:CreateFontString(i.."_fs", "OVERLAY", "GameFontNormal")
			bf.fs:SetText(spell.modifier..spell.origbutton)
			bf.fs:SetPoint("RIGHT", bf.delete, "LEFT", -4, 0)

			for frame,_ in pairs(ClickCastFrames) do
				if frame and SV.private.SpellBinder.frames[frame] then
					if frame:CanChangeAttribute() or frame:CanChangeProtectedState() then
						if frame:GetAttribute(spell.modifier.."type"..spell.button) ~= "menu" then
							--frame:RegisterForClicks("AnyDown")
							if spell.button:find("harmbutton") then
								frame:SetAttribute(spell.modifier..spell.button, spell.spell)
								frame:SetAttribute(spell.modifier.."type-"..spell.spell, "spell")
								frame:SetAttribute(spell.modifier.."spell-"..spell.spell, spell.spell)

								SV.private.SpellBinder.keys[spell.modifier..spell.button] = spell.spell
								SV.private.SpellBinder.keys[spell.modifier.."type-"..spell.spell] = "spell"
								SV.private.SpellBinder.keys[spell.modifier.."spell-"..spell.spell] = spell.spell
							else
								frame:SetAttribute(spell.modifier.."type"..spell.button, "spell")
								frame:SetAttribute(spell.modifier.."spell"..spell.button, spell.spell)

								SV.private.SpellBinder.keys[spell.modifier.."type"..spell.button] = "spell"
								SV.private.SpellBinder.keys[spell.modifier.."spell"..spell.button] = spell.spell
							end
						end
					end
				end
			end

			bf:Show()
			oldb = bf
		end
	end
end

function SpellBinder:BuildList()
	if(SV.private.SpellBinder and SV.private.SpellBinder.frames) then
		for frame,_ in pairs(ClickCastFrames) do
			SV.private.SpellBinder.frames[frame] = SV.private.SpellBinder.frames[frame] or true
		end
	end
end

function SpellBinder:ToggleButtons()
	for i = 1, SPELLS_PER_PAGE do
		if(self.spellbuttons[i]) then
			self.spellbuttons[i]:Hide()
			if self.sbOpen and SpellBookFrame.bookType ~= BOOKTYPE_PROFESSION then
				local slot = SpellBook_GetSpellBookSlot(self.spellbuttons[i]:GetParent())
				if slot then
					local spellname, subtype = GetSpellBookItemName(slot, SpellBookFrame.bookType)
					if spellname then
						self.spellbuttons[i]:Show()
					end
				end
			end
		end
	end
	self:BuildList()
	self:BuildSpells(true)
	if self:IsVisible() then self.tab:SetChecked(true) else self.tab:SetChecked(false) end
end

function SpellBinder:DeleteSpell()
	local count = table.getn(SV.private.SpellBinder.spells)
	for i, spell in ipairs(SV.private.SpellBinder.spells) do
		if spell.checked then
			for frame,_ in pairs(ClickCastFrames) do
				local f
				if frame and type(frame) == "table" then f = frame:GetName() end
				if f then
					if frame:CanChangeAttribute() or frame:CanChangeProtectedState() then
						if frame:GetAttribute(spell.modifier.."type"..spell.button) ~= "menu" then
							if spell.button:find("harmbutton") then
								frame:SetAttribute(spell.modifier..spell.button, nil)
								frame:SetAttribute(spell.modifier.."type-"..spell.spell, nil)
								frame:SetAttribute(spell.modifier.."spell-"..spell.spell, nil)
							else
								frame:SetAttribute(spell.modifier.."type"..spell.button, nil)
								frame:SetAttribute(spell.modifier.."spell"..spell.button, nil)
							end
						end
					end
				end
			end
			tremove(SV.private.SpellBinder.spells, i)
		end
	end
	self:BuildSpells(true)
end

function SpellBinder:UpdateAll()
	if InCombatLockdown() then
		self:SheduleUpdate()
		return
	end
	self:BuildList()
	self:BuildSpells(true)
end

function SpellBinder:SheduleUpdate()
	self.updated = false
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:SetScript("OnEvent", Temp_OnUpdate)
	else
		self:UpdateAll()
	end
end
--[[ 
########################################################## 
SET HOOKS
##########################################################
]]--
local _hook_CreateFrame = function(self, name, parent, template)
	if template and template:find("SecureUnitButtonTemplate") then ClickCastFrames[_G[name]] = true end
end

local _hook_CompactUnitFrame_SetUpFrame = function(self, ...)
	ClickCastFrames[self] = true
end

local _hook_SpellBookFrame_OnUpdate = function(self)
	if SpellBinder.sbOpen then SpellBinder:ToggleButtons() end
end

local _hook_SpellBookFrame_OnHide = function(self)
	if not SpellBinder then return end
	SpellBinder:Hide()
	SpellBinder.sbOpen = false
	SpellBinder:ToggleButtons()
end

hooksecurefunc("CreateFrame", _hook_CreateFrame)
hooksecurefunc("CompactUnitFrame_SetUpFrame", _hook_CompactUnitFrame_SetUpFrame)
hooksecurefunc("SpellBookFrame_Update", _hook_SpellBookFrame_OnUpdate)
hooksecurefunc(SpellBookFrame, "Hide", _hook_SpellBookFrame_OnHide)
--[[ 
########################################################## 
LOADER
##########################################################
]]--
SVUI_SpellBinderCloseButton:SetScript("OnClick", SpellBindClose_OnClick)

SpellBinder.tab = CreateFrame("CheckButton", nil, _G["SpellBookSkillLineTab1"], "SpellBookSkillLineTabTemplate")
SpellBinder.tab:SetScript("OnShow", SpellBindTab_OnShow)
SpellBinder.tab:SetScript("OnClick", SpellBindTab_OnClick)
SpellBinder.tab:Show()

SpellBinder:RegisterEvent("GROUP_ROSTER_UPDATE")
SpellBinder:RegisterEvent("PLAYER_ENTERING_WORLD")
SpellBinder:RegisterEvent("PLAYER_LOGIN")
SpellBinder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
SpellBinder:RegisterEvent("ZONE_CHANGED")

local function LoadSpellBinder()
	SV.private.SpellBinder = SV.private.SpellBinder or {}
	SV.private.SpellBinder.spells = SV.private.SpellBinder.spells or {}
	SV.private.SpellBinder.frames = SV.private.SpellBinder.frames or {}
	SV.private.SpellBinder.keys = SV.private.SpellBinder.keys or {}

	SpellBinder:RemoveTextures()

	SVUI_SpellBinderInset:RemoveTextures()

	SpellBinder:SetStylePanel("Frame", "Composite2")
	SpellBinder.Panel:SetPoint("TOPLEFT", -18, 0)
	SpellBinder.Panel:SetPoint("BOTTOMRIGHT", 0, 0)

	SpellBinder.list:RemoveTextures()
	SpellBinder.list:SetStylePanel("Frame", "Inset")

	SpellBinder.tab:RemoveTextures()
	SpellBinder.tab:SetStylePanel("Button")
	SpellBinder.tab:SetNormalTexture("Interface\\ICONS\\Achievement_Guild_Doctorisin")
	SpellBinder.tab:GetNormalTexture():ClearAllPoints()
	SpellBinder.tab:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
	SpellBinder.tab:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
	SpellBinder.tab:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

	SpellBinder:BuildList()
	SpellBinder:BuildSpells(true)

	for i = 1, SPELLS_PER_PAGE do
		local parent = _G["SpellButton"..i]
		local button = CreateFrame("Button", "SpellButtonMask"..i, parent)
		button:SetID(parent:GetID())
		button:RegisterForClicks("AnyDown")
		button:SetAllPoints(parent)
		button:SetScript("OnClick", SpellBindMask_OnClick)
		if(not button.shine) then
			button.shine = SpellBook_GetAutoCastShine()
			button.shine:Show()
			button.shine:SetParent(button)
			button.shine:SetAllPoints()
		end
		AutoCastShine_AutoCastStart(button.shine)

		button:Hide()
		SpellBinder.spellbuttons[i] = button
	end

	SpellBinder:SetScript("OnEvent", SpellBind_OnEvent)
end

SV:NewScript(LoadSpellBinder)