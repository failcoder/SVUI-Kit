--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local tinsert = _G.tinsert;
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
local HelpFrameList = {
	"HelpFrameLeftInset",
	"HelpFrameMainInset",
	"HelpFrameKnowledgebase",
	"HelpFrameHeader",
	"HelpFrameKnowledgebaseErrorFrame"
}

local HelpFrameButtonList = {
	"HelpFrameOpenTicketHelpItemRestoration",
	"HelpFrameAccountSecurityOpenTicket",
	"HelpFrameOpenTicketHelpTopIssues",
	"HelpFrameOpenTicketHelpOpenTicket",
	"HelpFrameKnowledgebaseSearchButton",
	"HelpFrameKnowledgebaseNavBarHomeButton",
	"HelpFrameCharacterStuckStuck",
	"GMChatOpenLog",
	"HelpFrameTicketSubmit",
	"HelpFrameTicketCancel"
}

local function NavBarHelper(button)
	for i = 1, #button.navList do 
		local this = button.navList[i]
		local last = button.navList[i - 1]
		if this and last then
			local level = last:GetFrameLevel()
			if(level >= 2) then
				level = level - 2
			else
				level = 0
			end
			this:SetFrameLevel(level)
		end 
	end 
end 
--[[ 
########################################################## 
HELPFRAME MODR
##########################################################
]]--
local function HelpFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.help ~= true then
		return 
	end 
	tinsert(HelpFrameButtonList, "HelpFrameButton16")
	tinsert(HelpFrameButtonList, "HelpFrameSubmitSuggestionSubmit")
	tinsert(HelpFrameButtonList, "HelpFrameReportBugSubmit")
	for d = 1, #HelpFrameList do
		_G[HelpFrameList[d]]:RemoveTextures(true)
		_G[HelpFrameList[d]]:SetStyle("Frame", "Default")
	end 
	HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel()+2)
	HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(HelpFrameKnowledgebaseErrorFrame:GetFrameLevel()+2)
	HelpFrameReportBugScrollFrame:RemoveTextures()
	HelpFrameReportBugScrollFrame:SetStyle("Frame", "Default")
	HelpFrameReportBugScrollFrame.Panel:ModPoint("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrame.Panel:ModPoint("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameReportBug:GetNumChildren()do 
		local e = select(d, HelpFrameReportBug:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	MOD:ApplyScrollFrameStyle(HelpFrameReportBugScrollFrameScrollBar)
	HelpFrameSubmitSuggestionScrollFrame:RemoveTextures()
	HelpFrameSubmitSuggestionScrollFrame:SetStyle("Frame", "Default")
	HelpFrameSubmitSuggestionScrollFrame.Panel:ModPoint("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrame.Panel:ModPoint("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameSubmitSuggestion:GetNumChildren()do 
		local e = select(d, HelpFrameSubmitSuggestion:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	MOD:ApplyScrollFrameStyle(HelpFrameSubmitSuggestionScrollFrameScrollBar)
	HelpFrameTicketScrollFrame:RemoveTextures()
	HelpFrameTicketScrollFrame:SetStyle("Frame", "Default")
	HelpFrameTicketScrollFrame.Panel:ModPoint("TOPLEFT", -4, 4)
	HelpFrameTicketScrollFrame.Panel:ModPoint("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameTicket:GetNumChildren()do 
		local e = select(d, HelpFrameTicket:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	MOD:ApplyScrollFrameStyle(HelpFrameKnowledgebaseScrollFrame2ScrollBar)
	for d = 1, #HelpFrameButtonList do
		_G[HelpFrameButtonList[d]]:RemoveTextures(true)
		_G[HelpFrameButtonList[d]]:SetStyle("Button")
		if _G[HelpFrameButtonList[d]].text then
			_G[HelpFrameButtonList[d]].text:ClearAllPoints()
			_G[HelpFrameButtonList[d]].text:SetPoint("CENTER")
			_G[HelpFrameButtonList[d]].text:SetJustifyH("CENTER")
		end 
	end 
	for d = 1, 6 do 
		local f = _G["HelpFrameButton"..d]
		f:SetStyle("Button")
		f.text:ClearAllPoints()
		f.text:SetPoint("CENTER")
		f.text:SetJustifyH("CENTER")
	end 
	for d = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren()do 
		local f = _G["HelpFrameKnowledgebaseScrollFrameButton"..d]
		f:RemoveTextures(true)
		f:SetStyle("Button")
	end 
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:ModPoint("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)
	HelpFrameKnowledgebaseNavBarOverlay:Die()
	HelpFrameKnowledgebaseNavBar:RemoveTextures()
	HelpFrame:RemoveTextures(true)
	HelpFrame:SetStyle("Frame", "Window")
	HelpFrameKnowledgebaseSearchBox:SetStyle("Editbox")
	MOD:ApplyScrollFrameStyle(HelpFrameKnowledgebaseScrollFrameScrollBar, 5)
	MOD:ApplyScrollFrameStyle(HelpFrameTicketScrollFrameScrollBar, 4)
	MOD:ApplyCloseButtonStyle(HelpFrameCloseButton, HelpFrame.Panel)
	MOD:ApplyCloseButtonStyle(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.Panel)
	HelpFrameCharacterStuckHearthstone:SetStyle("Button")
	HelpFrameCharacterStuckHearthstone:SetStyle("!_Frame", "Default")
	HelpFrameCharacterStuckHearthstone.IconTexture:InsetPoints()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	hooksecurefunc("NavBar_AddButton", function(h, k)
		local i = h.navList[#h.navList]
		if not i.styled then
			i:SetStyle("Button")
			i.styled = true;
			i:HookScript("OnClick", function()
				NavBarHelper(h)
			end)
		end 
		NavBarHelper(h)
	end)
	HelpFrameGM_ResponseNeedMoreHelp:SetStyle("Button")
	HelpFrameGM_ResponseCancel:SetStyle("Button")
	for d = 1, HelpFrameGM_Response:GetNumChildren()do 
		local e = select(d, HelpFrameGM_Response:GetChildren())
		if e and e:GetObjectType()
		 == "Frame"and not e:GetName()
		then
			e:SetStyle("!_Frame", "Default")
		end 
	end 
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(HelpFrameStyle)