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
HELPERS
##########################################################
]]--
local function MailFrame_OnUpdate()
	for b = 1, ATTACHMENTS_MAX_SEND do 
		local d = _G["SendMailAttachment"..b]
		if not d.styled then
			d:RemoveTextures()d:SetStylePanel("!_Frame", "Default")
			d:SetStylePanel("Button")
			d.styled = true 
		end 
		local e = d:GetNormalTexture()
		if e then
			e:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			e:InsetPoints()
		end 
	end 
end 
--[[ 
########################################################## 
MAILBOX MODR
##########################################################
]]--
local function MailBoxStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.mail ~= true then return end 

	MOD:ApplyWindowStyle(MailFrame)
	
	for b = 1, INBOXITEMS_TO_DISPLAY do 
		local i = _G["MailItem"..b]
		i:RemoveTextures()
		i:SetStylePanel("Frame", "Inset")
		i.Panel:ModPoint("TOPLEFT", 2, 1)
		i.Panel:ModPoint("BOTTOMRIGHT", -2, 2)
		local d = _G["MailItem"..b.."Button"]
		d:RemoveTextures()
		d:SetStylePanel("Button")
		local e = _G["MailItem"..b.."ButtonIcon"]
		e:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		e:InsetPoints()
	end 
	MOD:ApplyCloseButtonStyle(MailFrameCloseButton)
	MOD:ApplyPaginationStyle(InboxPrevPageButton)
	MOD:ApplyPaginationStyle(InboxNextPageButton)
	MailFrameTab1:RemoveTextures()
	MailFrameTab2:RemoveTextures()
	MOD:ApplyTabStyle(MailFrameTab1)
	MOD:ApplyTabStyle(MailFrameTab2)
	SendMailScrollFrame:RemoveTextures(true)
	SendMailScrollFrame:SetStylePanel("!_Frame", "Inset")
	MOD:ApplyScrollFrameStyle(SendMailScrollFrameScrollBar)
	SendMailNameEditBox:SetStylePanel("Editbox")
	SendMailSubjectEditBox:SetStylePanel("Editbox")
	SendMailMoneyGold:SetStylePanel("Editbox")
	SendMailMoneySilver:SetStylePanel("Editbox")
	SendMailMoneyCopper:SetStylePanel("Editbox")
	SendMailMoneyBg:Die()
	SendMailMoneyInset:RemoveTextures()

	_G["SendMailMoneySilver"]:SetStylePanel("Editbox")
	_G["SendMailMoneySilver"].Panel:ModPoint("TOPLEFT", -2, 1)
	_G["SendMailMoneySilver"].Panel:ModPoint("BOTTOMRIGHT", -12, -1)
	_G["SendMailMoneySilver"]:SetTextInsets(-1, -1, -2, -2)

	_G["SendMailMoneyCopper"]:SetStylePanel("Editbox")
	_G["SendMailMoneyCopper"].Panel:ModPoint("TOPLEFT", -2, 1)
	_G["SendMailMoneyCopper"].Panel:ModPoint("BOTTOMRIGHT", -12, -1)
	_G["SendMailMoneyCopper"]:SetTextInsets(-1, -1, -2, -2)

	SendMailNameEditBox.Panel:ModPoint("BOTTOMRIGHT", 2, 4)
	SendMailSubjectEditBox.Panel:ModPoint("BOTTOMRIGHT", 2, 0)
	SendMailFrame:RemoveTextures()
	
	hooksecurefunc("SendMailFrame_Update", MailFrame_OnUpdate)
	SendMailMailButton:SetStylePanel("Button")
	SendMailCancelButton:SetStylePanel("Button")
	OpenMailFrame:RemoveTextures(true)
	OpenMailFrame:SetStylePanel("!_Frame", "Transparent", true)
	OpenMailFrameInset:Die()
	MOD:ApplyCloseButtonStyle(OpenMailFrameCloseButton)
	OpenMailReportSpamButton:SetStylePanel("Button")
	OpenMailReplyButton:SetStylePanel("Button")
	OpenMailDeleteButton:SetStylePanel("Button")
	OpenMailCancelButton:SetStylePanel("Button")
	InboxFrame:RemoveTextures()
	MailFrameInset:Die()
	OpenMailScrollFrame:RemoveTextures(true)
	OpenMailScrollFrame:SetStylePanel("!_Frame", "Default")
	MOD:ApplyScrollFrameStyle(OpenMailScrollFrameScrollBar)
	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailArithmeticLine:Die()
	OpenMailLetterButton:RemoveTextures()
	OpenMailLetterButton:SetStylePanel("!_Frame", "Default")
	OpenMailLetterButton:SetStylePanel("Button")
	OpenMailLetterButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	OpenMailLetterButtonIconTexture:InsetPoints()
	OpenMailMoneyButton:RemoveTextures()
	OpenMailMoneyButton:SetStylePanel("!_Frame", "Default")
	OpenMailMoneyButton:SetStylePanel("Button")
	OpenMailMoneyButtonIconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	OpenMailMoneyButtonIconTexture:InsetPoints()
	for b = 1, ATTACHMENTS_MAX_SEND do 
		local d = _G["OpenMailAttachmentButton"..b]
		d:RemoveTextures()
		d:SetStylePanel("Button")
		local e = _G["OpenMailAttachmentButton"..b.."IconTexture"]
		if e then
			e:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			e:InsetPoints()
		end 
	end 
	OpenMailReplyButton:ModPoint("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)
	OpenMailDeleteButton:ModPoint("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)
	SendMailMailButton:ModPoint("RIGHT", SendMailCancelButton, "LEFT", -2, 0)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(MailBoxStyle)