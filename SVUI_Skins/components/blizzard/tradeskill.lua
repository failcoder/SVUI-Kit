--[[
##############################################################################
M O D K I T   By: S.Jackson
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
TRADESKILL MODR
##########################################################
]]--
local function TradeSkillStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.tradeskill ~= true then
		 return 
	end

	TradeSkillListScrollFrame:RemoveTextures()
	TradeSkillDetailScrollFrame:RemoveTextures()
	TradeSkillFrameInset:RemoveTextures()
	TradeSkillExpandButtonFrame:RemoveTextures()
	TradeSkillDetailScrollChildFrame:RemoveTextures()
	TradeSkillRankFrame:RemoveTextures()
	TradeSkillCreateButton:RemoveTextures(true)
	TradeSkillCancelButton:RemoveTextures(true)
	TradeSkillFilterButton:RemoveTextures(true)
	TradeSkillCreateAllButton:RemoveTextures(true)
	TradeSkillViewGuildCraftersButton:RemoveTextures(true)

	for i = 9, 18 do
		local lastLine = "TradeSkillSkill" .. (i - 1);
		local newLine = CreateFrame("Button", "TradeSkillSkill" .. i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
		newLine:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 0)
	end
	_G.TRADE_SKILLS_DISPLAYED = 18;

	local curWidth,curHeight = TradeSkillFrame:GetSize()
	local enlargedHeight = curHeight + 170;
	TradeSkillFrame:ModSize(curWidth + 30, curHeight + 166)
	MOD:ApplyWindowStyle(TradeSkillFrame, true, true)
	MOD:ApplyWindowStyle(TradeSkillGuildFrame)

	TradeSkillGuildFrame:ModPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	TradeSkillGuildFrameContainer:RemoveTextures()
	TradeSkillGuildFrameContainer:SetStylePanel("Frame", "Inset")
	MOD:ApplyCloseButtonStyle(TradeSkillGuildFrameCloseButton)

	TradeSkillRankFrame:SetStylePanel("Frame", "Bar", true)
	TradeSkillRankFrame:SetStatusBarTexture(SV.Media.bar.default)

	TradeSkillListScrollFrame:ModSize(327, 290)
	TradeSkillListScrollFrame:SetStylePanel("Frame", "Inset")
	TradeSkillDetailScrollFrame:ModSize(327, 180)
	TradeSkillDetailScrollFrame:SetStylePanel("Frame", "Inset")

	TradeSkillCreateButton:SetStylePanel("Button")
	TradeSkillCancelButton:SetStylePanel("Button")
	TradeSkillFilterButton:SetStylePanel("Button")
	TradeSkillCreateAllButton:SetStylePanel("Button")
	TradeSkillViewGuildCraftersButton:SetStylePanel("Button")

	MOD:ApplyScrollFrameStyle(TradeSkillListScrollFrameScrollBar)
	MOD:ApplyScrollFrameStyle(TradeSkillDetailScrollFrameScrollBar)

	TradeSkillLinkButton:ModSize(17, 14)
	TradeSkillLinkButton:ModPoint("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
	TradeSkillLinkButton:SetStylePanel("Button", nil, nil, nil, nil, true)
	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)

	TradeSkillFrameSearchBox:SetStylePanel("Editbox")
	TradeSkillInputBox:SetStylePanel("Editbox")

	MOD:ApplyPaginationStyle(TradeSkillDecrementButton)
	MOD:ApplyPaginationStyle(TradeSkillIncrementButton)

	TradeSkillIncrementButton:ModPoint("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)
	MOD:ApplyCloseButtonStyle(TradeSkillFrameCloseButton)

	TradeSkillSkillIcon:SetStylePanel("!_Frame", "Slot") 

	local internalTest = false;

	hooksecurefunc("TradeSkillFrame_SetSelection", function(_)
		TradeSkillSkillIcon:SetStylePanel("!_Frame", "Slot") 
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end 
		for i=1, MAX_TRADE_SKILL_REAGENTS do 
			local u = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local a1 = _G["TradeSkillReagent"..i.."Count"]
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetDrawLayer("OVERLAY")
			if not icon.backdrop then 
				local a2 = CreateFrame("Frame", nil, u)
				if u:GetFrameLevel()-1 >= 0 then
					 a2:SetFrameLevel(u:GetFrameLevel()-1)
				else
					 a2:SetFrameLevel(0)
				end 
				a2:WrapPoints(icon)
				a2:SetStylePanel("!_Frame", "Slot")
				icon:SetParent(a2)
				icon.backdrop = a2 
			end 
			a1:SetParent(icon.backdrop)
			a1:SetDrawLayer("OVERLAY")
			if i > 2 and internalTest == false then 
				local d, a3, f, g, h = u:GetPoint()
				u:ClearAllPoints()
				u:ModPoint(d, a3, f, g, h-3)
				internalTest = true 
			end 
			_G["TradeSkillReagent"..i.."NameFrame"]:Die()
		end 
	end)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TradeSkillUI",TradeSkillStyle)