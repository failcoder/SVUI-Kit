--[[
##############################################################################
S V U I   By: Munglunch
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
PVP MODR
##########################################################
]]--
local _hook_PVPReadyDialogDisplay = function(self, _, _, _, queueType, _, queueRole)
	if(queueRole == "DAMAGER") then
		PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonDPS.background:GetTexCoord())
	elseif(queueRole == "TANK") then
		PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	elseif(queueRole == "HEALER") then
		PVPReadyDialogRoleIcon.texture:SetTexCoord(LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	end
	if(queueType == "ARENA") then
		self:SetHeight(100)
	end
end

local function PVPFrameStyle()
	if (SV.db.Skins and (SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.pvp ~= true)) then
		return 
	end

	local HonorFrame = _G.HonorFrame;
	local ConquestFrame = _G.ConquestFrame;
	local PVPUIFrame = _G.PVPUIFrame;
	local WarGamesFrame = _G.WarGamesFrame;
	local PVPReadyDialog = _G.PVPReadyDialog;
 	
	SV.API:Set("Window", PVPUIFrame, true)
	
	SV.API:Set("CloseButton", PVPUIFrameCloseButton)

	for g = 1, 2 do
		SV.API:Set("Tab", _G["PVPUIFrameTab"..g])
	end

	for i = 1, 4 do 
		local btn = _G["PVPQueueFrameCategoryButton"..i]
		if(btn) then
			btn.Background:Die()
			btn.Ring:Die()
			btn:SetStyle("Button")
			btn.Icon:ModSize(45)
			btn.Icon:SetTexCoord(.15, .85, .15, .85)
			btn.Icon:SetDrawLayer("OVERLAY", nil, 7)
			btn.Panel:WrapPoints(btn.Icon)
		end
	end

	SV.API:Set("DropDown", HonorFrameTypeDropDown)
	HonorFrame.Inset:RemoveTextures()
	HonorFrame.Inset:SetStyle("!_Frame", "Inset")
	SV.API:Set("ScrollFrame", HonorFrameSpecificFrameScrollBar)
	HonorFrameSoloQueueButton:RemoveTextures()
	HonorFrameGroupQueueButton:RemoveTextures()
	HonorFrameSoloQueueButton:SetStyle("Button")
	HonorFrameGroupQueueButton:SetStyle("Button")
	HonorFrame.BonusFrame:RemoveTextures()
	HonorFrame.BonusFrame.ShadowOverlay:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("!_Frame", "Button")
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("Button")
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:InsetPoints()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetTexture(1, 1, 0, 0.1)
		
	HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")
	HonorFrame.RoleInset:RemoveTextures()
	HonorFrame.RoleInset.DPSIcon.checkButton:SetStyle("Checkbox")
	HonorFrame.RoleInset.TankIcon.checkButton:SetStyle("Checkbox")
	HonorFrame.RoleInset.HealerIcon.checkButton:SetStyle("Checkbox")
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.TankIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.HealerIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.RoleInset.DPSIcon:DisableDrawLayer("BACKGROUND")
	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(n)
		if n.bg then
			n.bg:SetDesaturated(true)
		end
	end)
	
	local ConquestPointsBar = _G.ConquestPointsBar;
	
	ConquestFrame.Inset:RemoveTextures()
	ConquestPointsBarLeft:Die()
	ConquestPointsBarRight:Die()
	ConquestPointsBarMiddle:Die()
	ConquestPointsBarBG:Die()
	ConquestPointsBarShadow:Die()
	ConquestPointsBar.progress:SetTexture(SV.BaseTexture)
	ConquestPointsBar:SetStyle("!_Frame", 'Inset')
	ConquestPointsBar.Panel:WrapPoints(ConquestPointsBar, nil, -2)
	ConquestFrame:RemoveTextures()
	ConquestFrame.ShadowOverlay:RemoveTextures()
	ConquestJoinButton:RemoveTextures()
	ConquestJoinButton:SetStyle("Button")
	ConquestFrame.RatedBG:RemoveTextures()
	ConquestFrame.RatedBG:SetStyle("!_Frame", "Inset")
	ConquestFrame.RatedBG:SetStyle("Button")
	ConquestFrame.RatedBG.SelectedTexture:InsetPoints()
	ConquestFrame.RatedBG.SelectedTexture:SetTexture(1, 1, 0, 0.1)
	WarGamesFrame:RemoveTextures()
	WarGamesFrame.RightInset:RemoveTextures()
	WarGamesFrameInfoScrollFrame:RemoveTextures()
	WarGamesFrameInfoScrollFrameScrollBar:RemoveTextures()
	WarGameStartButton:RemoveTextures()
	WarGameStartButton:SetStyle("Button")
	SV.API:Set("ScrollFrame", WarGamesFrameScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", WarGamesFrameInfoScrollFrameScrollBar)
	WarGamesFrame.HorizontalBar:RemoveTextures()
	
	PVPReadyDialog:RemoveTextures()
	PVPReadyDialog:SetStyle("Frame", "Pattern")
	PVPReadyDialogEnterBattleButton:SetStyle("Button")
	PVPReadyDialogLeaveQueueButton:SetStyle("Button")
	SV.API:Set("CloseButton", PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIcon.texture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICONS-ROLEBACKGROUNDS")
	PVPReadyDialogRoleIcon.texture:SetAlpha(0.5)
	
	ConquestFrame.Inset:SetStyle("!_Frame", "Inset")
	WarGamesFrameScrollFrame:SetStyle("Frame", "Inset",false,2,2,6)

	hooksecurefunc("PVPReadyDialog_Display", _hook_PVPReadyDialogDisplay)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_PVPUI', PVPFrameStyle)

-- /script StaticPopupSpecial_Show(PVPReadyDialog)