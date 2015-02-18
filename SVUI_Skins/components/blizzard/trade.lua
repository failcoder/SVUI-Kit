--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
TRADEFRAME MODR
##########################################################
]]--
local function TradeFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.trade ~= true then
		 return 
	end 
	
	SV.API:Set("Window", TradeFrame, true)

	TradeFrameInset:Die()
	TradeFrameTradeButton:SetStyle("Button")
	TradeFrameCancelButton:SetStyle("Button")
	SV.API:Set("CloseButton", TradeFrameCloseButton, TradeFrame.Panel)
	TradePlayerInputMoneyFrameGold:SetStyle("Editbox")
	TradePlayerInputMoneyFrameSilver:SetStyle("Editbox")
	TradePlayerInputMoneyFrameCopper:SetStyle("Editbox")
	TradeRecipientItemsInset:Die()
	TradePlayerItemsInset:Die()
	TradePlayerInputMoneyInset:Die()
	TradePlayerEnchantInset:Die()
	TradeRecipientEnchantInset:Die()
	TradeRecipientMoneyInset:Die()
	TradeRecipientMoneyBg:Die()
	local inputs = {
		"TradePlayerInputMoneyFrameSilver",
		"TradePlayerInputMoneyFrameCopper"
	}
	for _,frame in pairs(inputs)do
		_G[frame]:SetStyle("Editbox")
		_G[frame].Panel:ModPoint("TOPLEFT", -2, 1)
		_G[frame].Panel:ModPoint("BOTTOMRIGHT", -12, -1)
		_G[frame]:SetTextInsets(-1, -1, -2, -2)
	end 
	for i = 1, 7 do 
		local W = _G["TradePlayerItem"..i]
		local X = _G["TradeRecipientItem"..i]
		local Y = _G["TradePlayerItem"..i.."ItemButton"]
		local Z = _G["TradeRecipientItem"..i.."ItemButton"]
		local b = _G["TradePlayerItem"..i.."ItemButtonIconTexture"]
		local z = _G["TradeRecipientItem"..i.."ItemButtonIconTexture"]
		if Y and Z then
			W:RemoveTextures()
			X:RemoveTextures()
			Y:RemoveTextures()
			Z:RemoveTextures()
			b:InsetPoints(Y)
			b:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			Y:SetStyle("!_Frame", "Button", true)
			Y:SetStyle("Button")
			Y.bg = CreateFrame("Frame", nil, Y)
			Y.bg:SetStyle("Frame", "Inset")
			Y.bg:SetPoint("TOPLEFT", Y, "TOPRIGHT", 4, 0)
			Y.bg:SetPoint("BOTTOMRIGHT", _G["TradePlayerItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
			Y.bg:SetFrameLevel(Y:GetFrameLevel()-3)
			Y:SetFrameLevel(Y:GetFrameLevel()-1)
			z:InsetPoints(Z)
			z:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			Z:SetStyle("!_Frame", "Button", true)
			Z:SetStyle("Button")
			Z.bg = CreateFrame("Frame", nil, Z)
			Z.bg:SetStyle("Frame", "Inset")
			Z.bg:SetPoint("TOPLEFT", Z, "TOPRIGHT", 4, 0)
			Z.bg:SetPoint("BOTTOMRIGHT", _G["TradeRecipientItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
			Z.bg:SetFrameLevel(Z:GetFrameLevel()-3)
			Z:SetFrameLevel(Z:GetFrameLevel()-1)
		end 
	end 
	TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayer:SetFrameStrata("HIGH")
	TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2)
	TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")
	TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipient:SetFrameStrata("HIGH")
	TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2)
	TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(TradeFrameStyle)