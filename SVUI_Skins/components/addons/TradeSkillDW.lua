--[[
##########################################################
S V U I   By: Munglunch
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
TSDW
##########################################################
]]--
local function StyleTradeSkillDW()
	assert(TradeSkillDW_QueueFrame, "AddOn Not Loaded")

	TradeSkillFrame:SetStyle("{0}Window2")
	TradeSkillListScrollFrame:RemoveTextures(true)
	TradeSkillDetailScrollFrame:RemoveTextures(true)
	TradeSkillFrameInset:RemoveTextures(true)
	TradeSkillExpandButtonFrame:RemoveTextures(true)
	TradeSkillDetailScrollChildFrame:RemoveTextures(true)
	TradeSkillListScrollFrame:RemoveTextures(true)
	SV.API:Set("Frame", TradeSkillGuildFrame,"Transparent")
	SV.API:Set("Frame", TradeSkillGuildFrameContainer,"Transparent")
	TradeSkillGuildFrame:ModPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	SV.API:Set("CloseButton", TradeSkillGuildFrameCloseButton)

	TradeSkillFrame:HookScript("OnShow", function() 
		SV.API:Set("Frame", TradeSkillFrame) 
		TradeSkillListScrollFrame:RemoveTextures() 
		if not TradeSkillDWExpandButton then return end 
		if not TradeSkillDWExpandButton.styled then 
			SV.API:Set("PageButton", TradeSkillDWExpandButton) 
			TradeSkillDWExpandButton.styled = true 
		end
	end)
	
	TradeSkillFrame:ModHeight(TradeSkillFrame:GetHeight() + 12)
	TradeSkillRankFrame:SetStyle("Transparent")
	TradeSkillRankFrame:SetStatusBarTexture(SV.media.statusbar.default)
	TradeSkillCreateButton:SetStyle()
	TradeSkillCancelButton:SetStyle()
	TradeSkillFilterButton:SetStyle()
	TradeSkillCreateAllButton:SetStyle()
	TradeSkillViewGuildCraftersButton:SetStyle()
	TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
	TradeSkillLinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
	TradeSkillLinkButton:GetHighlightTexture():Die()
	SV.API:Set("Frame", TradeSkillLinkButton,"Transparent")
	TradeSkillLinkButton:ModSize(17, 14)
	TradeSkillLinkButton:ModPoint("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
	TradeSkillFrameSearchBox:SetStyle()
	TradeSkillInputBox:SetStyle()
	TradeSkillIncrementButton:ModPoint("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)
	SV.API:Set("CloseButton", TradeSkillFrameCloseButton)
	SV.API:Set("ScrollFrame", TradeSkillDetailScrollFrameScrollBar)
	local once = false
	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		TradeSkillSkillIcon:SetStyle()

		if TradeSkillSkillIcon:GetNormalTexture() then
			TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)
			TradeSkillSkillIcon:GetNormalTexture():ClearAllPoints()
			TradeSkillSkillIcon:GetNormalTexture():ModPoint("TOPLEFT", 2, -2)
			TradeSkillSkillIcon:GetNormalTexture():ModPoint("BOTTOMRIGHT", -2, 2)
		end

		for i = 1, MAX_TRADE_SKILL_REAGENTS do
			local button = _G["TradeSkillReagent"..i]
			local icon = _G["TradeSkillReagent"..i.."IconTexture"]
			local count = _G["TradeSkillReagent"..i.."Count"]
			icon:SetTexCoord(0.1,0.9,0.1,0.9)
			icon:SetDrawLayer("OVERLAY")
			if not icon.backdrop then
				icon.backdrop = CreateFrame("Frame", nil, button)
				icon.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
				SV.API:Set("Frame", icon.backdrop,"Transparent")
				icon.backdrop:ModPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
				icon.backdrop:ModPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
			end
			icon:SetParent(icon.backdrop)
			count:SetParent(icon.backdrop)
			count:SetDrawLayer("OVERLAY")
			if i > 2 and once == false then
				local point, anchoredto, point2, x, y = button:GetPoint()
				button:ClearAllPoints()
				button:ModPoint(point, anchoredto, point2, x, y - 3)
				once = true
			end
			_G["TradeSkillReagent"..i.."NameFrame"]:Die()
		end
	end)

	TradeSkillDW_QueueFrame:HookScript("OnShow", function() SV.API:Set("Frame", TradeSkillDW_QueueFrame,"Transparent") end)

	SV.API:Set("CloseButton", TradeSkillDW_QueueFrameCloseButton)

	TradeSkillDW_QueueFrameInset:RemoveTextures()
	TradeSkillDW_QueueFrameClear:SetStyle()
	TradeSkillDW_QueueFrameDown:SetStyle()
	TradeSkillDW_QueueFrameUp:SetStyle()
	TradeSkillDW_QueueFrameDo:SetStyle()
	TradeSkillDW_QueueFrameDetailScrollFrame:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrame:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent1:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent2:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent3:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent4:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent5:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent6:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent7:RemoveTextures()
	TradeSkillDW_QueueFrameDetailScrollFrameChildFrameReagent8:RemoveTextures()
	SV.API:Set("ScrollFrame", TradeSkillDW_QueueFrameDetailScrollFrameScrollBar)
	TradeSkillListScrollFrame:RemoveTextures()
end
MOD:SaveAddonStyle("TradeSkillDW", StyleTradeSkillDW)