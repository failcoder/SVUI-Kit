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
FRAME MODR
##########################################################
]]--
local function MerchantStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.merchant ~= true then return end 
	MerchantFrame:RemoveTextures(true)
	MerchantFrame:SetStyle("Frame", "Composite1", false, nil, 2, 4)
	local level = MerchantFrame:GetFrameLevel()
	if(level > 0) then 
		MerchantFrame:SetFrameLevel(level - 1)
	else 
		MerchantFrame:SetFrameLevel(0)
	end
	MerchantBuyBackItem:RemoveTextures(true)
	MerchantBuyBackItem:SetStyle("Frame", "Inset", true, 2, 2, 3)
	MerchantBuyBackItem.Panel:SetFrameLevel(MerchantBuyBackItem.Panel:GetFrameLevel() + 1)
	MerchantBuyBackItemItemButton:RemoveTextures()
	MerchantBuyBackItemItemButton:SetStyle("Button")
	MerchantExtraCurrencyInset:RemoveTextures()
	MerchantExtraCurrencyBg:RemoveTextures()
	MerchantFrameInset:RemoveTextures()
	MerchantMoneyBg:RemoveTextures()
	MerchantMoneyInset:RemoveTextures()
	MerchantFrameInset:SetStyle("Frame", "Inset")
	MerchantFrameInset.Panel:SetFrameLevel(MerchantFrameInset.Panel:GetFrameLevel() + 1)
	MOD:ApplyDropdownStyle(MerchantFrameLootFilter)
	for b = 1, 2 do
		MOD:ApplyTabStyle(_G["MerchantFrameTab"..b])
	end 
	for b = 1, 12 do 
		local d = _G["MerchantItem"..b.."ItemButton"]
		local e = _G["MerchantItem"..b.."ItemButtonIconTexture"]
		local o = _G["MerchantItem"..b]o:RemoveTextures(true)
		o:SetStyle("!_Frame", "Inset")
		d:RemoveTextures()
		d:SetStyle("Button")
		d:ModPoint("TOPLEFT", o, "TOPLEFT", 4, -4)
		e:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		e:InsetPoints()
		_G["MerchantItem"..b.."MoneyFrame"]:ClearAllPoints()
		_G["MerchantItem"..b.."MoneyFrame"]:ModPoint("BOTTOMLEFT", d, "BOTTOMRIGHT", 3, 0)
	end 
	MerchantBuyBackItemItemButton:RemoveTextures()
	MerchantBuyBackItemItemButton:SetStyle("Button")
	MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	MerchantBuyBackItemItemButtonIconTexture:InsetPoints()
	MerchantRepairItemButton:SetStyle("Button")
	for b = 1, MerchantRepairItemButton:GetNumRegions()do 
		local p = select(b, MerchantRepairItemButton:GetRegions())
		if p:GetObjectType() == "Texture"then
			p:SetTexCoord(0.04, 0.24, 0.06, 0.5)
			p:InsetPoints()
		end 
	end MerchantGuildBankRepairButton:SetStyle("Button")
	MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
	MerchantGuildBankRepairButtonIcon:InsetPoints()
	MerchantRepairAllButton:SetStyle("Button")
	MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
	MerchantRepairAllIcon:InsetPoints()
	MerchantFrame:ModWidth(360)
	MOD:ApplyCloseButtonStyle(MerchantFrameCloseButton, MerchantFrame.Panel)
	MOD:ApplyPaginationStyle(MerchantNextPageButton)
	MOD:ApplyPaginationStyle(MerchantPrevPageButton)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(MerchantStyle)