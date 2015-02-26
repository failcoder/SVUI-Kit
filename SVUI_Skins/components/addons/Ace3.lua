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
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local RegisterAsWidget, RegisterAsContainer;

local ProxyLSMType = {
	["LSM30_Font"] = true, 
	["LSM30_Sound"] = true, 
	["LSM30_Border"] = true, 
	["LSM30_Background"] = true, 
	["LSM30_Statusbar"] = true
}

local ProxyType = {
	["InlineGroup"] = true, 
	["TreeGroup"] = true, 
	["TabGroup"] = true, 
	["SimpleGroup"] = true,
	["DropdownGroup"] = true
}

local function Widget_OnEnter(b)
	b:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Widget_OnLeave(b)
	b:SetBackdropBorderColor(0,0,0,1)
end

local function Widget_ScrollStyle(frame, arg)
	return SV.API:Set("ScrollFrame", frame) 
end 

local function Widget_ButtonStyle(frame, strip, bypass)
	if frame.Left then frame.Left:SetAlpha(0) end 
	if frame.Middle then frame.Middle:SetAlpha(0) end 
	if frame.Right then frame.Right:SetAlpha(0) end 
	if frame.SetNormalTexture then frame:SetNormalTexture("") end 
	if frame.SetHighlightTexture then frame:SetHighlightTexture(0,0,0,0) end 
	if frame.SetPushedTexture then frame:SetPushedTexture(0,0,0,0) end 
	if frame.SetDisabledTexture then frame:SetDisabledTexture("") end 
	if strip then frame:RemoveTextures() end 
	if not bypass then 
		frame:SetStyle("Button")
	end
end 

local function Widget_PaginationStyle(...)
	SV.API:Set("PageButton", ...)
end

local function SetAdjustedStyle(this, template, xTopleft, yTopleft, xBottomright, yBottomright)
	if(not this or (this and this.Panel)) then return end
	template = template or "Default"
	this:SetStyle("Frame", template)
	this.Panel:SetPoint("TOPLEFT", this, "TOPLEFT", xTopleft, yTopleft)
	this.Panel:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", xBottomright, yBottomright)
end

local NOOP = SV.fubar

local WidgetButton_OnClick = function(self)
	local obj = self.obj;
	if(obj and obj.pullout and obj.pullout.frame) then
		SV.API:Set("Frame", obj.pullout.frame, "Default", true)
	end
end

local WidgetDropButton_OnClick = function(self)
	local obj = self.obj;
	local widgetFrame = obj.dropdown
	if(widgetFrame) then
		SetAdjustedStyle(widgetFrame, "Default", 20, -2, -20, 2)
	end
end
--[[ 
########################################################## 
AceGUI MOD
##########################################################
]]--
local function StyleAceGUI(event, addon)
	local AceGUI = LibStub("AceGUI-3.0", true)

	assert(AceGUI and (AceGUI.RegisterAsContainer ~= RegisterAsContainer or AceGUI.RegisterAsWidget ~= RegisterAsWidget), "Addon Not Loaded")

	local regWidget = AceGUI.RegisterAsWidget;
	local regContainer = AceGUI.RegisterAsContainer;

	RegisterAsWidget = function(self, widget)

		local widgetType = widget.type;
		-- print("RegisterAsWidget: " .. widgetType);
		if(widgetType == "MultiLineEditBox") then 
			local widgetFrame = widget.frame;
			SV.API:Set("!_Frame", widgetFrame, "Default", true)
			SV.API:Set("Frame", widget.scrollBG, "Transparent", true) 
			Widget_ButtonStyle(widget.button)
			SV.API:Set("ScrollFrame", widget.scrollBar) 
			widget.scrollBar:SetPoint("RIGHT", widgetFrame, "RIGHT", -4)
			widget.scrollBG:SetPoint("TOPRIGHT", widget.scrollBar, "TOPLEFT", -2, 19)
			widget.scrollBG:SetPoint("BOTTOMLEFT", widget.button, "TOPLEFT")
			widget.scrollFrame:SetPoint("BOTTOMRIGHT", widget.scrollBG, "BOTTOMRIGHT", -4, 8)

		elseif(widgetType == "CheckBox") then 
			widget.checkbg:Die()
			widget.highlight:Die()
			if not widget.styledCheckBG then 
				widget.styledCheckBG = CreateFrame("Frame", nil, widget.frame)
				widget.styledCheckBG:InsetPoints(widget.check)
				SV.API:Set("!_Frame", widget.styledCheckBG, "Checkbox")
			end 
			widget.check:SetParent(widget.styledCheckBG)

		elseif(widgetType == "Dropdown") then 
			local widgetDropdown = widget.dropdown;
			local widgetButton = widget.button;

			widgetDropdown:RemoveTextures()
			widgetButton:ClearAllPoints()
			widgetButton:ModPoint("RIGHT", widgetDropdown, "RIGHT", -20, 0)
			widgetButton:SetFrameLevel(widgetButton:GetFrameLevel() + 1)
			Widget_PaginationStyle(widgetButton, true)

			SetAdjustedStyle(widgetDropdown, "Default", 20, -2, -20, 2)

			widgetButton:SetParent(widgetDropdown.Panel)
			widget.text:SetParent(widgetDropdown.Panel)
			widgetButton:HookScript("OnClick", WidgetButton_OnClick)

		elseif(widgetType == "EditBox") then 
			local widgetEditbox = widget.editbox;
			SV.API:Set("EditBox", widgetEditbox, nil, 15, 2, -2)

		elseif(widgetType == "Button") then 
			local widgetFrame = widget.frame;
			Widget_ButtonStyle(widgetFrame, true)
			widget.text:SetParent(widgetFrame.Panel)

		elseif(widgetType == "Slider") then 
			local widgetSlider = widget.slider;
			local widgetEditbox = widget.editbox;

			SV.API:Set("!_Frame", widgetSlider, "Bar")

			widgetSlider:ModHeight(20)
			widgetSlider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
			widgetSlider:GetThumbTexture():SetVertexColor(0.8, 0.8, 0.8)

			widgetEditbox:ModHeight(15)
			widgetEditbox:SetPoint("TOP", widgetSlider, "BOTTOM", 0, -1)

			widget.lowtext:SetPoint("TOPLEFT", widgetSlider, "BOTTOMLEFT", 2, -2)
			widget.hightext:SetPoint("TOPRIGHT", widgetSlider, "BOTTOMRIGHT", -2, -2)

		elseif(ProxyLSMType[widgetType]) then 
			local widgetFrame = widget.frame;
			local dropButton = widgetFrame.dropButton;

			widgetFrame:RemoveTextures()
			Widget_PaginationStyle(dropButton, true)
			widgetFrame.text:ClearAllPoints()
			widgetFrame.text:ModPoint("RIGHT", dropButton, "LEFT", -2, 0)
			dropButton:ClearAllPoints()
			dropButton:ModPoint("RIGHT", widgetFrame, "RIGHT", -10, -6)
			if(not widgetFrame.Panel) then 
				if(widgetType == "LSM30_Font") then 
					SetAdjustedStyle(widgetFrame, "Transparent", 20, -17, 2, -2)
				elseif(widgetType == "LSM30_Sound") then 
					SetAdjustedStyle(widgetFrame, "Transparent", 20, -17, 2, -2)
					widget.soundbutton:SetParent(widgetFrame.Panel)
					widget.soundbutton:ClearAllPoints()
					widget.soundbutton:ModPoint("LEFT", widgetFrame.Panel, "LEFT", 2, 0)
				elseif(widgetType == "LSM30_Statusbar") then 
					SetAdjustedStyle(widgetFrame, "Transparent", 20, -17, 2, -2)
					widget.bar:SetParent(widgetFrame.Panel)
					widget.bar:InsetPoints()
				elseif(widgetType == "LSM30_Border" or widgetType == "LSM30_Background") then 
					SetAdjustedStyle(widgetFrame, "Transparent", 42, -16, 2, -2)
				end 
				widgetFrame.Panel:ModPoint("BOTTOMRIGHT", dropButton, "BOTTOMRIGHT", 2, -2)
				SetAdjustedStyle(widgetFrame, "Transparent", 20, -2, 2, -2)
			end 
			dropButton:SetParent(widgetFrame.Panel)
			widgetFrame.text:SetParent(widgetFrame.Panel)
			dropButton:HookScript("OnClick", WidgetDropButton_OnClick)
		end
		return regWidget(self, widget)
	end

	AceGUI.RegisterAsWidget = RegisterAsWidget

	RegisterAsContainer = function(self, widget)
		local widgetType = widget.type;
		-- print("RegisterAsContainer: " .. widgetType);
		local widgetParent = widget.content:GetParent()
		if widgetType == "ScrollFrame" then 
			SV.API:Set("ScrollFrame", widget.scrollBar) 
		elseif widgetType == "Frame" then
			for i = 1, widgetParent:GetNumChildren()do 
				local childFrame = select(i, widgetParent:GetChildren())
				if childFrame:GetObjectType() == "Button" and childFrame:GetText() then 
					Widget_ButtonStyle(childFrame)
				else 
					childFrame:RemoveTextures()
				end 
			end
			SV.API:Set("Window", widgetParent)
		elseif(ProxyType[widgetType]) then

			if widget.treeframe then 
				SV.API:Set("Frame", widget.treeframe, "Transparent")
				widgetParent:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
				local oldFunc = widget.CreateButton;
				widget.CreateButton = function(self)
					local newButton = oldFunc(self)
					newButton.toggle:RemoveTextures()
					newButton.toggle.SetNormalTexture = NOOP;
					newButton.toggle.SetPushedTexture = NOOP;
					newButton.toggle:SetStyle("Button")
					newButton.toggleText = newButton.toggle:CreateFontString(nil, "OVERLAY")
					newButton.toggleText:SetFont([[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]], 19)
					newButton.toggleText:SetPoint("CENTER")
					newButton.toggleText:SetText("*")
					return newButton 
				end
			elseif(not widgetParent.Panel) then
				SV.API:Set("Frame", widgetParent, "Transparent")
			end

			if(widgetType == "TabGroup") then
				local oldFunc = widget.CreateTab;
				widget.CreateTab = function(self, arg)
					local newTab = oldFunc(self, arg)
					newTab:RemoveTextures()
					return newTab 
				end 
			end

			if widget.scrollbar then 
				SV.API:Set("ScrollFrame", widget.scrollBar) 
			end 
		end
		return regContainer(self, widget)
	end 

	AceGUI.RegisterAsContainer = RegisterAsContainer
end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
--MOD:SaveAddonStyle("SVUI_ConfigOMatic", StyleAceGUI, nil, true)
MOD:SaveAddonStyle("AceGUI", StyleAceGUI, nil, true)