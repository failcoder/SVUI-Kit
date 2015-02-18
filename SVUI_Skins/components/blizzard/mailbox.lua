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
HELPERS
##########################################################
]]--
local function MailFrame_OnUpdate()
	for b = 1, ATTACHMENTS_MAX_SEND do 
		local d = _G["SendMailAttachment"..b]
		if not d.styled then
			d:RemoveTextures()d:SetStyle("!_Frame", "Default")
			d:SetStyle("Button")
			d.styled = true 
		end 
		local e = d:GetNormalTexture()
		if e then
			e:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
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

	SV.API:Set("Window", MailFrame)
	
	for b = 1, INBOXITEMS_TO_DISPLAY do 
		local i = _G["MailItem"..b]
		i:RemoveTextures()
		i:SetStyle("Frame", "Inset")
		i.Panel:ModPoint("TOPLEFT", 2, 1)
		i.Panel:ModPoint("BOTTOMRIGHT", -2, 2)
		local d = _G["MailItem"..b.."Button"]
		d:RemoveTextures()
		d:SetStyle("Button")
		local e = _G["MailItem"..b.."ButtonIcon"]
		e:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		e:InsetPoints()
	end 
	SV.API:Set("CloseButton", MailFrameCloseButton)
	SV.API:Set("PageButton", InboxPrevPageButton)
	SV.API:Set("PageButton", InboxNextPageButton)
	MailFrameTab1:RemoveTextures()
	MailFrameTab2:RemoveTextures()
	SV.API:Set("Tab", MailFrameTab1)
	SV.API:Set("Tab", MailFrameTab2)
	SendMailScrollFrame:RemoveTextures(true)
	SendMailScrollFrame:SetStyle("!_Frame", "Inset")
	SV.API:Set("ScrollFrame", SendMailScrollFrameScrollBar)
	SendMailNameEditBox:SetStyle("Editbox")
	SendMailSubjectEditBox:SetStyle("Editbox")
	SendMailMoneyGold:SetStyle("Editbox")
	SendMailMoneySilver:SetStyle("Editbox")
	SendMailMoneyCopper:SetStyle("Editbox")
	SendMailMoneyBg:Die()
	SendMailMoneyInset:RemoveTextures()

	_G["SendMailMoneySilver"]:SetStyle("Editbox")
	_G["SendMailMoneySilver"].Panel:ModPoint("TOPLEFT", -2, 1)
	_G["SendMailMoneySilver"].Panel:ModPoint("BOTTOMRIGHT", -12, -1)
	_G["SendMailMoneySilver"]:SetTextInsets(-1, -1, -2, -2)

	_G["SendMailMoneyCopper"]:SetStyle("Editbox")
	_G["SendMailMoneyCopper"].Panel:ModPoint("TOPLEFT", -2, 1)
	_G["SendMailMoneyCopper"].Panel:ModPoint("BOTTOMRIGHT", -12, -1)
	_G["SendMailMoneyCopper"]:SetTextInsets(-1, -1, -2, -2)

	SendMailNameEditBox.Panel:ModPoint("BOTTOMRIGHT", 2, 4)
	SendMailSubjectEditBox.Panel:ModPoint("BOTTOMRIGHT", 2, 0)
	SendMailFrame:RemoveTextures()
	
	hooksecurefunc("SendMailFrame_Update", MailFrame_OnUpdate)
	SendMailMailButton:SetStyle("Button")
	SendMailCancelButton:SetStyle("Button")
	OpenMailFrame:RemoveTextures(true)
	OpenMailFrame:SetStyle("!_Frame", "Transparent", true)
	OpenMailFrameInset:Die()
	SV.API:Set("CloseButton", OpenMailFrameCloseButton)
	OpenMailReportSpamButton:SetStyle("Button")
	OpenMailReplyButton:SetStyle("Button")
	OpenMailDeleteButton:SetStyle("Button")
	OpenMailCancelButton:SetStyle("Button")
	InboxFrame:RemoveTextures()
	MailFrameInset:Die()
	OpenMailScrollFrame:RemoveTextures(true)
	OpenMailScrollFrame:SetStyle("!_Frame", "Default")
	SV.API:Set("ScrollFrame", OpenMailScrollFrameScrollBar)
	SendMailBodyEditBox:SetTextColor(1, 1, 1)
	OpenMailBodyText:SetTextColor(1, 1, 1)
	InvoiceTextFontNormal:SetTextColor(1, 1, 1)
	OpenMailArithmeticLine:Die()
	OpenMailLetterButton:RemoveTextures()
	OpenMailLetterButton:SetStyle("!_Frame", "Default")
	OpenMailLetterButton:SetStyle("Button")
	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	OpenMailLetterButtonIconTexture:InsetPoints()
	OpenMailMoneyButton:RemoveTextures()
	OpenMailMoneyButton:SetStyle("!_Frame", "Default")
	OpenMailMoneyButton:SetStyle("Button")
	OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	OpenMailMoneyButtonIconTexture:InsetPoints()
	for b = 1, ATTACHMENTS_MAX_SEND do 
		local d = _G["OpenMailAttachmentButton"..b]
		d:RemoveTextures()
		d:SetStyle("Button")
		local e = _G["OpenMailAttachmentButton"..b.."IconTexture"]
		if e then
			e:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
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