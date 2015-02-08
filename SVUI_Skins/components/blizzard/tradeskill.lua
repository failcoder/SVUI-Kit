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
	SV.API:Set("Window", TradeSkillFrame, true, true)
	SV.API:Set("Window", TradeSkillGuildFrame)

	TradeSkillGuildFrame:ModPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	TradeSkillGuildFrameContainer:RemoveTextures()
	TradeSkillGuildFrameContainer:SetStyle("Frame", "Inset")
	SV.API:Set("CloseButton", TradeSkillGuildFrameCloseButton)

	TradeSkillRankFrame:SetStyle("Frame", "Bar", true)
	TradeSkillRankFrame:SetStatusBarTexture(SV.Media.bar.default)

	TradeSkillListScrollFrame:ModSize(327, 290)
	TradeSkillListScrollFrame:SetStyle("Frame", "Inset")
	TradeSkillDetailScrollFrame:ModSize(327, 180)
	TradeSkillDetailScrollFrame:SetStyle("Frame", "Inset")

	TradeSkillCreateButton:SetStyle("Button")
	TradeSkillCancelButton:SetStyle("Button")
	TradeSkillFilterButton:SetStyle("Button")
	TradeSkillCreateAllButton:SetStyle("Button")
	TradeSkillViewGuildCraftersButton:SetStyle("Button")

	SV.API:Set("ScrollFrame", TradeSkillListScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", TradeSkillDetailScrollFrameScrollBar)

	TradeSkillLinkButton:ModSize(17, 14)
	TradeSkillLinkButton:ModPoint("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
	TradeSkillLinkButton:SetStyle("Button")
	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)

	TradeSkillFrameSearchBox:SetStyle("Editbox")
	TradeSkillInputBox:SetStyle("Editbox")

	SV.API:Set("PageButton", TradeSkillDecrementButton)
	SV.API:Set("PageButton", TradeSkillIncrementButton)

	TradeSkillIncrementButton:ModPoint("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)
	SV.API:Set("CloseButton", TradeSkillFrameCloseButton)

	TradeSkillSkillIcon:SetStyle("!_Frame", "Icon") 

	local internalTest = false;

	hooksecurefunc("TradeSkillFrame_SetSelection", function(_)
		TradeSkillSkillIcon:SetStyle("!_Frame", "Icon") 
		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		end 
		for i=1, MAX_TRADE_SKILL_REAGENTS do 
			local u = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local a1 = _G["TradeSkillReagent"..i.."Count"]
			icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			icon:SetDrawLayer("OVERLAY")
			if not icon.backdrop then 
				local a2 = CreateFrame("Frame", nil, u)
				if u:GetFrameLevel()-1 >= 0 then
					 a2:SetFrameLevel(u:GetFrameLevel()-1)
				else
					 a2:SetFrameLevel(0)
				end 
				a2:WrapPoints(icon)
				a2:SetStyle("!_Frame", "Icon")
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