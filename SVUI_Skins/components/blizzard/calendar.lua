--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
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
local CalendarButtons = {
	"CalendarViewEventAcceptButton",
	"CalendarViewEventTentativeButton",
	"CalendarViewEventRemoveButton",
	"CalendarViewEventDeclineButton"
};
--[[ 
########################################################## 
CALENDAR MODR
##########################################################
]]--
local function CalendarStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.calendar ~= true then
		 return 
	end

	SV.API:Set("Window", CalendarFrame)

	SV.API:Set("CloseButton", CalendarCloseButton)
	CalendarCloseButton:SetPoint("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)
	SV.API:Set("PageButton", CalendarPrevMonthButton)
	SV.API:Set("PageButton", CalendarNextMonthButton)

	do 
		local cfframe = _G["CalendarFilterFrame"];
		
		if(cfframe) then
			cfframe:RemoveTextures()
			cfframe:ModWidth(155)
			cfframe:SetStyle()

			local cfbutton = _G["CalendarFilterButton"];
			if(cfbutton) then
				cfbutton:ClearAllPoints()
				cfbutton:SetPoint("RIGHT", cfframe, "RIGHT", -10, 3)
				SV.API:Set("PageButton", cfbutton, true)
				cfframe.Panel:SetPoint("TOPLEFT", 20, 2)
				cfframe.Panel:SetPoint("BOTTOMRIGHT", cfbutton, "BOTTOMRIGHT", 2, -2)

				local cftext = _G["CalendarFilterFrameText"]
				if(cftext) then
					cftext:ClearAllPoints()
					cftext:SetPoint("RIGHT", cfbutton, "LEFT", -2, 0)
				end
			end
		end
	end

	local l = CreateFrame("Frame", "CalendarFrameBackdrop", CalendarFrame)
	l:SetStyle()
	l:SetPoint("TOPLEFT", 10, -72)
	l:SetPoint("BOTTOMRIGHT", -8, 3)
	CalendarContextMenu:SetStyle()
	hooksecurefunc(CalendarContextMenu, "SetBackdropColor", function(f, r, g, b, a)
		if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0.5 then
			 f:SetBackdropColor(0, 0, 0, 0.5)
		end 
	end)
	hooksecurefunc(CalendarContextMenu, "SetBackdropBorderColor", function(f, r, g, b)
		if r ~= 0 or g ~= 0 or b ~= 0 then
			 f:SetBackdropBorderColor(0, 0, 0)
		end 
	end)
	for u = 1, 42 do
		 _G["CalendarDayButton"..u]:SetFrameLevel(_G["CalendarDayButton"..u]:GetFrameLevel()+1)
	end 
	CalendarCreateEventFrame:RemoveTextures()
	CalendarCreateEventFrame:SetStyle("Transparent")
	CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:RemoveTextures()
	CalendarCreateEventCreateButton:SetStyle()
	CalendarCreateEventMassInviteButton:SetStyle()
	CalendarCreateEventInviteButton:SetStyle()
	CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:ModWidth(CalendarCreateEventInviteEdit:GetWidth()-2)
	CalendarCreateEventInviteList:RemoveTextures()
	CalendarCreateEventInviteList:SetStyle()
	CalendarCreateEventInviteEdit:SetStyle()
	CalendarCreateEventTitleEdit:SetStyle()
	SV.API:Set("DropDown", CalendarCreateEventTypeDropDown, 120)
	CalendarCreateEventDescriptionContainer:RemoveTextures()
	CalendarCreateEventDescriptionContainer:SetStyle()
	SV.API:Set("CloseButton", CalendarCreateEventCloseButton)
	CalendarCreateEventLockEventCheck:SetStyle()
	SV.API:Set("DropDown", CalendarCreateEventHourDropDown, 68)
	SV.API:Set("DropDown", CalendarCreateEventMinuteDropDown, 68)
	SV.API:Set("DropDown", CalendarCreateEventAMPMDropDown, 68)
	SV.API:Set("DropDown", CalendarCreateEventRepeatOptionDropDown, 120)
	CalendarCreateEventIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	hooksecurefunc(CalendarCreateEventIcon, "SetTexCoord", function(f, v, w, x, y)
		local z, A, B, C = 0.1, 0.9, 0.1, 0.9 
		if v ~= z or w ~= A or x ~= B or y ~= C then
			 f:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		end 
	end)
	CalendarCreateEventInviteListSection:RemoveTextures()
	CalendarClassButtonContainer:HookScript("OnShow", function()
		for u, D in ipairs(CLASS_SORT_ORDER)do 	
			local e = _G["CalendarClassButton"..u]e:RemoveTextures()
			e:SetStyle()
			local E = CLASS_ICON_TCOORDS[D]
			local F = e:GetNormalTexture()
			F:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			F:SetTexCoord(E[1]+0.015, E[2]-0.02, E[3]+0.018, E[4]-0.02)
		end 
		CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)
		CalendarClassTotalsButton:RemoveTextures()
		CalendarClassTotalsButton:SetStyle()
	end)
	CalendarTexturePickerFrame:RemoveTextures()
	CalendarTexturePickerTitleFrame:RemoveTextures()
	CalendarTexturePickerFrame:SetStyle("Transparent")
	SV.API:Set("ScrollFrame", CalendarTexturePickerScrollBar)
	CalendarTexturePickerAcceptButton:SetStyle()
	CalendarTexturePickerCancelButton:SetStyle()
	CalendarCreateEventInviteButton:SetStyle()
	CalendarCreateEventRaidInviteButton:SetStyle()
	CalendarMassInviteFrame:RemoveTextures()
	CalendarMassInviteFrame:SetStyle("Transparent")
	CalendarMassInviteTitleFrame:RemoveTextures()
	SV.API:Set("CloseButton", CalendarMassInviteCloseButton)
	CalendarMassInviteGuildAcceptButton:SetStyle()
	SV.API:Set("DropDown", CalendarMassInviteGuildRankMenu, 130)
	CalendarMassInviteGuildMinLevelEdit:SetStyle()
	CalendarMassInviteGuildMaxLevelEdit:SetStyle()
	CalendarViewRaidFrame:RemoveTextures()
	CalendarViewRaidFrame:SetStyle("Transparent")
	CalendarViewRaidFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewRaidTitleFrame:RemoveTextures()
	SV.API:Set("CloseButton", CalendarViewRaidCloseButton)
	CalendarViewHolidayFrame:RemoveTextures(true)
	CalendarViewHolidayFrame:SetStyle("Transparent")
	CalendarViewHolidayFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewHolidayTitleFrame:RemoveTextures()
	SV.API:Set("CloseButton", CalendarViewHolidayCloseButton)
	CalendarViewEventFrame:RemoveTextures()
	CalendarViewEventFrame:SetStyle("Transparent")
	CalendarViewEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewEventTitleFrame:RemoveTextures()
	CalendarViewEventDescriptionContainer:RemoveTextures()
	CalendarViewEventDescriptionContainer:SetStyle("Transparent")
	CalendarViewEventInviteList:RemoveTextures()
	CalendarViewEventInviteList:SetStyle("Transparent")
	CalendarViewEventInviteListSection:RemoveTextures()
	SV.API:Set("CloseButton", CalendarViewEventCloseButton)
	SV.API:Set("ScrollFrame", CalendarViewEventInviteListScrollFrameScrollBar)
	for _,btn in pairs(CalendarButtons)do
		 _G[btn]:SetStyle()
	end 
	CalendarEventPickerFrame:RemoveTextures()
	CalendarEventPickerTitleFrame:RemoveTextures()
	CalendarEventPickerFrame:SetStyle("Transparent")
	SV.API:Set("ScrollFrame", CalendarEventPickerScrollBar)
	CalendarEventPickerCloseButton:SetStyle()
	SV.API:Set("ScrollFrame", CalendarCreateEventDescriptionScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", CalendarCreateEventInviteListScrollFrameScrollBar)
	SV.API:Set("ScrollFrame", CalendarViewEventDescriptionScrollFrameScrollBar)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_Calendar",CalendarStyle)