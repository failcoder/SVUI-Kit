--[[
##########################################################
M O D K I T   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local error 	= _G.error;
local pcall 	= _G.pcall;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper, find = string.lower, string.upper, string.find;
--[[ TABLE METHODS ]]--
local twipe = table.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local LSM = LibStub("LibSharedMedia-3.0")
local NewHook = hooksecurefunc;
--[[ 
########################################################## 
 /$$$$$$$$/$$$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$
| $$_____/ $$__  $$ /$$__  $$| $$$    /$$$| $$_____/
| $$     | $$  \ $$| $$  \ $$| $$$$  /$$$$| $$      
| $$$$$  | $$$$$$$/| $$$$$$$$| $$ $$/$$ $$| $$$$$   
| $$__/  | $$__  $$| $$__  $$| $$  $$$| $$| $$__/   
| $$     | $$  \ $$| $$  | $$| $$\  $ | $$| $$      
| $$     | $$  | $$| $$  | $$| $$ \/  | $$| $$$$$$$$
|__/     |__/  |__/|__/  |__/|__/     |__/|________/
##########################################################
]]--
local levelDiff = 2

local _hook_WindowLevel = function(self, level)
	local adjustment = level - levelDiff;
	if(adjustment < 0) then adjustment = 0 end
	self.Panel:SetFrameLevel(adjustment)
end

function MOD:ApplyFrameStyle(this, template, noStripping, fullStripping)
	if(not this or (this and this.Panel)) then return end  
	if not noStripping then this:RemoveTextures(fullStripping) end
	template = template or "Transparent"
	this:SetStylePanel("Frame", template)
end 

function MOD:ApplyAdjustedFrameStyle(this, template, xTopleft, yTopleft, xBottomright, yBottomright)
	if(not this or (this and this.Panel)) then return end
	template = template or "Transparent"
	this:SetStylePanel("Frame", template)
	this.Panel:SetPoint("TOPLEFT", this, "TOPLEFT", xTopleft, yTopleft)
	this.Panel:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", xBottomright, yBottomright)
end 

function MOD:ApplyFixedFrameStyle(this, template, noStripping, fullStripping)
	if(not this or (this and this.Panel)) then return end  
	if not noStripping then this:RemoveTextures(fullStripping) end
	template = template or "Transparent"
    this:SetStylePanel("!_Frame", template)
end

function MOD:ApplyWindowStyle(this, action, fullStrip)
	if(not this or (this and this.Panel)) then return end
	local template = action and "Composite2" or "Composite1"
	local baselevel = this:GetFrameLevel()
	if(baselevel < 1) then 
		this:SetFrameLevel(1)
	end
	
	this:RemoveTextures(fullStrip)
	this:SetStylePanel("Frame", template)
end

function MOD:ApplyAdjustedWindowStyle(this, action, fullStrip, padding, xOffset, yOffset)
	if(not this or (this and this.Panel)) then return end
	local template = action and "Composite2" or "Composite1"
	local baselevel = this:GetFrameLevel()
	if(baselevel < 1) then 
		this:SetFrameLevel(1)
	end
	
	this:RemoveTextures(fullStrip)
	this:SetStylePanel("Frame", template, false, padding, xOffset, yOffset)
end 

function MOD:ApplyWindowHolder(this, fullStrip)
	if(not this or (this and this.Panel)) then return end
	local baselevel = this:GetFrameLevel()
	if(baselevel < 1) then 
		this:SetFrameLevel(1)
	end
	
	this:RemoveTextures(fullStrip)
	this:SetStylePanel("Frame", "Blackout")
end
--[[ 
########################################################## 
 /$$$$$$$  /$$   /$$ /$$$$$$$$/$$$$$$$$/$$$$$$  /$$   /$$
| $$__  $$| $$  | $$|__  $$__/__  $$__/$$__  $$| $$$ | $$
| $$  \ $$| $$  | $$   | $$     | $$ | $$  \ $$| $$$$| $$
| $$$$$$$ | $$  | $$   | $$     | $$ | $$  | $$| $$ $$ $$
| $$__  $$| $$  | $$   | $$     | $$ | $$  | $$| $$  $$$$
| $$  \ $$| $$  | $$   | $$     | $$ | $$  | $$| $$\  $$$
| $$$$$$$/|  $$$$$$/   | $$     | $$ |  $$$$$$/| $$ \  $$
|_______/  \______/    |__/     |__/  \______/ |__/  \__/
##########################################################
]]--
local Button_OnEnter = function(self)
    self:SetBackdropColor(0.1, 0.8, 0.8)
end

local Button_OnLeave = function(self)
    self:SetBackdropColor(unpack(SV.Media.color.default))
end

function MOD:ApplyButtonStyle(this)
	if not this then return end 
    this:SetStylePanel("Button")
end

local ArrowButton_OnEnter = function(self)
    self:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local ArrowButton_OnLeave = function(self)
    self:SetBackdropBorderColor(0,0,0,1)
end

function MOD:ApplyArrowButtonStyle(this, direction, anchor)
	if not this then return end
	this:RemoveTextures()
	this:SetStylePanel("Button", nil, 1, -7, -7, nil, "green")
	this:SetFrameLevel(this:GetFrameLevel() + 4)
	local iconKey = "move_" .. direction:lower()
	this:SetNormalTexture(SV.Media.icon[iconKey])
    if not this.hookedColors then 
        this:HookScript("OnEnter", ArrowButton_OnEnter)
        this:HookScript("OnLeave", ArrowButton_OnLeave)
        this.hookedColors = true
    end 
    if anchor then 
    	this:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 2, 2) 
    end
end

--[[ CLOSE BUTTON ]]--
local CloseButton_OnEnter = function(self)
    self:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local CloseButton_OnLeave = function(self)
    self:SetBackdropBorderColor(0,0,0,1)
end

function MOD:ApplyCloseButtonStyle(this, anchor)
	if not this then return end
	this:RemoveTextures()
	this:SetStylePanel("Button", nil, 1, -7, -7, nil, "red")
	this:SetFrameLevel(this:GetFrameLevel() + 4)
	this:SetNormalTexture(SV.Media.icon.close)
    if not this.hookedColors then 
        this:HookScript("OnEnter", CloseButton_OnEnter)
        this:HookScript("OnLeave", CloseButton_OnLeave)
        this.hookedColors = true
    end 
    if anchor then 
    	this:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 2, 2) 
    end
end

--[[ ITEM BUTTON ]]--

function MOD:ApplyItemButtonStyle(frame, adjust, shrink, noScript)
	if(not frame or (frame and frame.SkinsHooked)) then return end 

	local link = frame:GetName()

	frame:RemoveTextures()

	if(not frame.Panel) then
		if shrink then 
			frame:SetStylePanel("Frame", "Button", true, 1, -1, -1)
		else
			frame:SetStylePanel("!_Frame", "Button")
		end
	end

	if(link) then
		local nameObject = _G[("%sName"):format(link)]
		local subNameObject = _G[("%sSubName"):format(link)]
		local arrowObject = _G[("%sFlyoutArrow"):format(link)]
		local levelObject = _G[("%sLevel"):format(link)]
		local iconObject = _G[("%sIcon"):format(link)] or _G[("%sIconTexture"):format(link)]
		local countObject = _G[("%sCount"):format(link)]

		if(iconObject and not frame.IconShadow) then 
			iconObject:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			if adjust then 
				iconObject:InsetPoints(frame, 2, 2)
			end 

			frame.IconShadow = CreateFrame("Frame", nil, frame)
			frame.IconShadow:WrapPoints(iconObject)
			frame.IconShadow:SetStylePanel("Icon", 2, 0, 0)

			--iconObject:SetParent(frame.IconShadow)
		end

		if(not frame.Riser) then
			local fg = CreateFrame("Frame", nil, frame)
			fg:SetSize(120, 22)
			fg:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -11)
			fg:SetFrameLevel(frame:GetFrameLevel() + 1)
			frame.Riser = fg
		end

		if(countObject) then
			countObject:SetParent(frame.Riser)
			countObject:SetAllPoints(frame.Riser)
			countObject:SetFontObject(SVUI_Font_Number)
			countObject:SetDrawLayer("ARTWORK", 7)
		end

		if(nameObject) then nameObject:SetParent(frame.Riser) end
		if(subNameObject) then subNameObject:SetParent(frame.Riser) end
		if(arrowObject) then arrowObject:SetParent(frame.Riser) end

		if(levelObject) then 
			levelObject:SetParent(frame.Riser)
			levelObject:SetFontObject(SVUI_Font_Number)
			levelObject:SetDrawLayer("ARTWORK", 7)
		end

		if(not noScript) then
			frame:HookScript("OnEnter", Button_OnEnter)
    		frame:HookScript("OnLeave", Button_OnLeave)
    	end
	end 

	frame.SkinsHooked = true 
end 
--[[
########################################################## 
  /$$$$$$   /$$$$$$  /$$$$$$$   /$$$$$$  /$$       /$$      
 /$$__  $$ /$$__  $$| $$__  $$ /$$__  $$| $$      | $$      
| $$  \__/| $$  \__/| $$  \ $$| $$  \ $$| $$      | $$      
|  $$$$$$ | $$      | $$$$$$$/| $$  | $$| $$      | $$      
 \____  $$| $$      | $$__  $$| $$  | $$| $$      | $$      
 /$$  \ $$| $$    $$| $$  \ $$| $$  | $$| $$      | $$      
|  $$$$$$/|  $$$$$$/| $$  | $$|  $$$$$$/| $$$$$$$$| $$$$$$$$
 \______/  \______/ |__/  |__/ \______/ |________/|________/
##########################################################
--]]
function MOD:ApplyScrollFrameStyle(this, scale, yOffset)
	if(not this or (this and this.SkinsHooked)) then return end

	scale = scale or 5
	local scrollName = this:GetName()
	local bg, track, top, bottom, mid, upButton, downButton


	bg = _G[("%sBG"):format(scrollName)]
	if(bg) then bg:SetTexture(0,0,0,0) end 

	track = _G[("%sTrack"):format(scrollName)]
	if(track) then track:SetTexture(0,0,0,0) end 

	top = _G[("%sTop"):format(scrollName)]
	if(top) then top:SetTexture(0,0,0,0) end 

	bottom = _G[("%sBottom"):format(scrollName)]
	if(bottom) then bottom:SetTexture(0,0,0,0) end 

	mid = _G[("%sMiddle"):format(scrollName)]
	if(mid) then mid:SetTexture(0,0,0,0) end 

	upButton = _G[("%sScrollUpButton"):format(scrollName)]
	downButton = _G[("%sScrollDownButton"):format(scrollName)]

	if(upButton and downButton) then 
		upButton:RemoveTextures()
		if(not upButton.icon) then
			local upW, upH = upButton:GetSize()
			MOD:ApplyPaginationStyle(upButton)
			SquareButton_SetIcon(upButton, "UP")
			upButton:ModSize(upW + scale, upH + scale)
			if(yOffset) then
				local anchor, parent, relative, xBase, yBase = upButton:GetPoint()
				local yAdjust = (yOffset or 0) + yBase
				upButton:ClearAllPoints()
				upButton:SetPoint(anchor, parent, relative, xBase, yAdjust)
			end
		end 

		downButton:RemoveTextures()
		if(not downButton.icon) then
			local dnW, dnH = downButton:GetSize() 
			MOD:ApplyPaginationStyle(downButton)
			SquareButton_SetIcon(downButton, "DOWN")
			downButton:ModSize(dnW + scale, dnH + scale)
			if(yOffset) then
				local anchor, parent, relative, xBase, yBase = downButton:GetPoint()
				local yAdjust = ((yOffset or 0) * -1) + yBase
				downButton:ClearAllPoints()
				downButton:SetPoint(anchor, parent, relative, xBase, yAdjust)
			end
		end 

		if(not this.ScrollBG) then 
			this.ScrollBG = CreateFrame("Frame", nil, this)
			this.ScrollBG:SetPoint("TOPLEFT", upButton, "BOTTOMLEFT", 0, -1)
			this.ScrollBG:SetPoint("BOTTOMRIGHT", downButton, "TOPRIGHT", 0, 1)
			this.ScrollBG:SetStylePanel("!_Frame", "Transparent")
		end 

		if(this:GetThumbTexture()) then 
			this:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		end
	end

	this.SkinsHooked = true
end 

function MOD:ApplyScrollBarStyle(this)
	if(not this or (this and not this.GetOrientation)) then return end

	if(this:GetOrientation() == "VERTICAL") then 
		this:SetWidth(12)
	else 
		this:SetHeight(12)
		for i=1, this:GetNumRegions() do 
			local child = select(i, this:GetRegions())
			if(child and child:GetObjectType() == "FontString") then 
				local anchor, parent, relative, x, y = child:GetPoint()
				if relative:find("BOTTOM") then 
					child:SetPoint(anchor, parent, relative, x, y - 4)
				end 
			end 
		end 
	end

	this:RemoveTextures()
	this:SetBackdrop(nil)
	this:SetStylePanel("!_Frame", "Heavy")
    this:SetBackdropBorderColor(0.2,0.2,0.2)
	this:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")

	this.SkinsHooked = true
end 
--[[
########################################################## 
 /$$$$$$$$/$$$$$$  /$$$$$$$   /$$$$$$                     
|__  $$__/$$__  $$| $$__  $$ /$$__  $$                    
   | $$ | $$  \ $$| $$  \ $$| $$  \__/                    
   | $$ | $$$$$$$$| $$$$$$$ |  $$$$$$                     
   | $$ | $$__  $$| $$__  $$ \____  $$                    
   | $$ | $$  | $$| $$  \ $$ /$$  \ $$                    
   | $$ | $$  | $$| $$$$$$$/|  $$$$$$/                    
   |__/ |__/  |__/|_______/  \______/                     
##########################################################
--]]
local Tab_OnEnter = function(self)
	self.backdrop:SetPanelColor("highlight")
	self.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local Tab_OnLeave = function(self)
	self.backdrop:SetPanelColor("dark")
	self.backdrop:SetBackdropBorderColor(0,0,0,1)
end 

function MOD:ApplyTabStyle(this, addBackground, xOffset, yOffset)
	if(not this or (this and this.SkinsHooked)) then return end 

	local tab = this:GetName();

	if _G[tab.."Left"] then _G[tab.."Left"]:SetTexture(0,0,0,0) end
	if _G[tab.."LeftDisabled"] then _G[tab.."LeftDisabled"]:SetTexture(0,0,0,0) end
	if _G[tab.."Right"] then _G[tab.."Right"]:SetTexture(0,0,0,0) end
	if _G[tab.."RightDisabled"] then _G[tab.."RightDisabled"]:SetTexture(0,0,0,0) end
	if _G[tab.."Middle"] then _G[tab.."Middle"]:SetTexture(0,0,0,0) end
	if _G[tab.."MiddleDisabled"] then _G[tab.."MiddleDisabled"]:SetTexture(0,0,0,0) end

	if(this.GetHighlightTexture and this:GetHighlightTexture()) then 
		this:GetHighlightTexture():SetTexture(0,0,0,0)
	end

	this:RemoveTextures()

	if(addBackground) then
		local nTex = this:GetNormalTexture()

		if(nTex) then
			nTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			nTex:InsetPoints()
		end

		xOffset = xOffset or 1
		yOffset = yOffset or 1

		this.pushed = true;
		this.backdrop = CreateFrame("Frame", nil, this)
		this.backdrop:WrapPoints(this, xOffset, yOffset)
		this.backdrop:SetFrameLevel(0)
		this.backdrop:SetBackdrop({
			bgFile = [[Interface\BUTTONS\WHITE8X8]], 
	        tile = false, 
	        tileSize = 0,
	        edgeFile = SV.Media.border.shadow,
	        edgeSize = 3,
	        insets = {
	            left = 0,
	            right = 0,
	            top = 0,
	            bottom = 0
	        }
	    });
	    this.backdrop:SetBackdropColor(0,0,0,1)
		this.backdrop:SetBackdropBorderColor(0,0,0,1)

		local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = this:GetPoint()
		this:ModPoint(initialAnchor, anchorParent, relativeAnchor, 1, yPosition)
	else
		xOffset = xOffset or 10
		yOffset = yOffset or 3
		this.backdrop = CreateFrame("Frame", nil, this)
		this.backdrop:InsetPoints(this, xOffset, yOffset)
		this.backdrop:SetStylePanel("!_Frame", "Heavy", true)
		this.backdrop:SetPanelColor("dark")

		if(this:GetFrameLevel() > 0) then
			this.backdrop:SetFrameLevel(this:GetFrameLevel() - 1)
		end
	end

	this:HookScript("OnEnter", Tab_OnEnter)
	this:HookScript("OnLeave", Tab_OnLeave)

    this.SkinsHooked = true
end 
--[[
########################################################## 
 /$$$$$$$   /$$$$$$   /$$$$$$  /$$$$$$$$
| $$__  $$ /$$__  $$ /$$__  $$| $$_____/
| $$  \ $$| $$  \ $$| $$  \__/| $$      
| $$$$$$$/| $$$$$$$$| $$ /$$$$| $$$$$   
| $$____/ | $$__  $$| $$|_  $$| $$__/   
| $$      | $$  | $$| $$  \ $$| $$      
| $$      | $$  | $$|  $$$$$$/| $$$$$$$$
|__/      |__/  |__/ \______/ |________/
##########################################################
--]]
function MOD:ApplyPaginationStyle(button, isVertical)
	if(not button or (button and not button:GetName()) or (button and button.SkinsHooked)) then return end

	local bName = button:GetName()
	local testName = bName:lower()
	local leftDown = ((bName and testName:find('left')) or testName:find('prev') or testName:find('decrement')) or false

	button:RemoveTextures()
	button:SetNormalTexture("")
	button:SetPushedTexture(0,0,0,0)
	button:SetHighlightTexture(0,0,0,0)
	button:SetDisabledTexture("")

	button:SetStylePanel("!_Button", nil, 1, -7, -7)

	if not button.icon then 
		button.icon = button:CreateTexture(nil,'ARTWORK')
		button.icon:ModSize(13)
		button.icon:SetPoint('CENTER')
		button.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
		button.icon:SetTexCoord(0.02, 0.2, 0.02, 0.2)

		button:SetScript('OnMouseDown',function(self)
			if self:IsEnabled() then 
				self.icon:SetPoint("CENTER",-1,-1)
			end 
		end)

		button:SetScript('OnMouseUp',function(self)
			self.icon:SetPoint("CENTER",0,0)
		end)

		button:SetScript('OnDisable',function(self)
			SetDesaturation(self.icon, true)
			self.icon:SetAlpha(0.5)
		end)

		button:SetScript('OnEnable',function(self)
			SetDesaturation(self.icon, false)
			self.icon:SetAlpha(1.0)
		end)

		if not button:IsEnabled() then 
			button:GetScript('OnDisable')(button)
		end 
	end

	if isVertical then 
		if leftDown then SquareButton_SetIcon(button,'UP') else SquareButton_SetIcon(button,'DOWN')end 
	else 
		if leftDown then SquareButton_SetIcon(button,'LEFT') else SquareButton_SetIcon(button,'RIGHT')end 
	end

	button.SkinsHooked = true
end 
--[[
########################################################## 
 /$$$$$$$  /$$$$$$$   /$$$$$$  /$$$$$$$    
| $$__  $$| $$__  $$ /$$__  $$| $$__  $$   
| $$  \ $$| $$  \ $$| $$  \ $$| $$  \ $$   
| $$  | $$| $$$$$$$/| $$  | $$| $$$$$$$/   
| $$  | $$| $$__  $$| $$  | $$| $$____/    
| $$  | $$| $$  \ $$| $$  | $$| $$         
| $$$$$$$/| $$  | $$|  $$$$$$/| $$         
|_______/ |__/  |__/ \______/ |__/         
 /$$$$$$$   /$$$$$$  /$$      /$$ /$$   /$$
| $$__  $$ /$$__  $$| $$  /$ | $$| $$$ | $$
| $$  \ $$| $$  \ $$| $$ /$$$| $$| $$$$| $$
| $$  | $$| $$  | $$| $$/$$ $$ $$| $$ $$ $$
| $$  | $$| $$  | $$| $$$$_  $$$$| $$  $$$$
| $$  | $$| $$  | $$| $$$/ \  $$$| $$\  $$$
| $$$$$$$/|  $$$$$$/| $$/   \  $$| $$ \  $$
|_______/  \______/ |__/     \__/|__/  \__/
##########################################################
--]]
local _hook_DropDownButton_SetPoint = function(self, _, _, _, _, _, breaker)
	if not breaker then
		self:ModPoint("RIGHT", self.AnchorParent, "RIGHT", -10, 3, true)
	end
end

function MOD:ApplyDropdownStyle(this, width)
	if(not this or (this and this.SkinsHooked)) then return end 

	local ddName = this:GetName();
	local ddText = _G[("%sText"):format(ddName)]
	local ddButton = _G[("%sButton"):format(ddName)]

	if not width then width = 155 end 

	this:RemoveTextures()
	this:ModWidth(width)

	if(ddButton) then
		if(ddText) then
			ddText:SetPoint("RIGHT", ddButton, "LEFT", 2, 0)
		end

		ddButton:ClearAllPoints()
		ddButton:ModPoint("RIGHT", this, "RIGHT", -10, 3)
		ddButton.AnchorParent = this

		NewHook(ddButton, "SetPoint", _hook_DropDownButton_SetPoint)

		self:ApplyPaginationStyle(ddButton, true)

		local currentLevel = this:GetFrameLevel()
		if(currentLevel == 0) then
			currentLevel = 1
		end

		local bg = CreateFrame("Frame", nil, this)
		bg:ModPoint("TOPLEFT", this, "TOPLEFT", 18, -2)
		bg:ModPoint("BOTTOMRIGHT", ddButton, "BOTTOMRIGHT", 2, -2)
		bg:SetStylePanel("Frame", "Blackout")
		bg:SetBackdropBorderColor(0,0,0)
		this.Panel = bg
	end

	this.SkinsHooked = true 
end 
--[[
########################################################## 
 /$$$$$$$$/$$$$$$   /$$$$$$  /$$    /$$$$$$$$/$$$$$$ /$$$$$$$ 
|__  $$__/$$__  $$ /$$__  $$| $$   |__  $$__/_  $$_/| $$__  $$
   | $$ | $$  \ $$| $$  \ $$| $$      | $$    | $$  | $$  \ $$
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$$$$$$/
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$____/ 
   | $$ | $$  | $$| $$  | $$| $$      | $$    | $$  | $$      
   | $$ |  $$$$$$/|  $$$$$$/| $$$$$$$$| $$   /$$$$$$| $$      
   |__/  \______/  \______/ |________/|__/  |______/|__/      
##########################################################
--]]
local Tooltip_OnShow = function(self)
	self:SetBackdrop({
		bgFile = SV.BaseTexture,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		edgeSize=1
	})
	self:SetBackdropColor(0,0,0,0.8)
	self:SetBackdropBorderColor(0,0,0)
end

function MOD:ApplyTooltipStyle(frame)
	if(not frame or (frame and frame.SkinsHooked)) then return end
	frame:HookScript('OnShow', Tooltip_OnShow)
	frame.SkinsHooked = true
end 
--[[
########################################################## 
  /$$$$$$  /$$       /$$$$$$$$ /$$$$$$$  /$$$$$$$$
 /$$__  $$| $$      | $$_____/| $$__  $$|__  $$__/
| $$  \ $$| $$      | $$      | $$  \ $$   | $$   
| $$$$$$$$| $$      | $$$$$   | $$$$$$$/   | $$   
| $$__  $$| $$      | $$__/   | $$__  $$   | $$   
| $$  | $$| $$      | $$      | $$  \ $$   | $$   
| $$  | $$| $$$$$$$$| $$$$$$$$| $$  | $$   | $$   
|__/  |__/|________/|________/|__/  |__/   |__/   
##########################################################
--]]
local SetAlertColor = function(self, r, g, b)
	self.AlertPanel:SetBackdropColor(r,g,b)
	self.AlertPanel.left:SetVertexColor(r,g,b)
	self.AlertPanel.right:SetVertexColor(r,g,b)
	self.AlertPanel.top:SetVertexColor(r,g,b)
	self.AlertPanel.bottom:SetVertexColor(r,g,b)
end

function MOD:ApplyAlertStyle(frame, typeIndex)
	if(not frame or (frame and frame.AlertPanel)) then return end

	local alertType = (typeIndex and typeIndex == 2) and "typeB" or "typeA";

	local TEMPLATE = SV.Media.alert[alertType];
	local r,g,b = unpack(TEMPLATE.COLOR);
	local size = frame:GetHeight();
	local half = size * 0.5;
	local offset = size * 0.1;
	local lvl = frame:GetFrameLevel();

	if lvl < 1 then lvl = 1 end

    local alertpanel = CreateFrame("Frame", nil, frame)
    alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", offset, 0)
    alertpanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -offset, 0)
    alertpanel:SetFrameLevel(lvl - 1)
    alertpanel:SetBackdrop({
        bgFile = TEMPLATE.BG
    })
    alertpanel:SetBackdropColor(r,g,b)

    --[[ LEFT ]]--
    alertpanel.left = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.left:SetTexture(TEMPLATE.LEFT)
    alertpanel.left:SetVertexColor(r,g,b)
    alertpanel.left:SetPoint("TOPRIGHT", alertpanel, "TOPLEFT", 0, 0)
    alertpanel.left:SetPoint("BOTTOMRIGHT", alertpanel, "BOTTOMLEFT", 0, 0)
    alertpanel.left:SetWidth(size)

    --[[ RIGHT ]]--
    alertpanel.right = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.right:SetTexture(TEMPLATE.RIGHT)
    alertpanel.right:SetVertexColor(r,g,b)
    alertpanel.right:SetPoint("TOPLEFT", alertpanel, "TOPRIGHT", 0, 0)
    alertpanel.right:SetPoint("BOTTOMLEFT", alertpanel, "BOTTOMRIGHT", 0, 0)
    alertpanel.right:SetWidth(size * 2)

    --[[ TOP ]]--
    alertpanel.top = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.top:SetTexture(TEMPLATE.TOP)
    alertpanel.top:SetPoint("BOTTOMLEFT", alertpanel, "TOPLEFT", 0, 0)
    alertpanel.top:SetPoint("BOTTOMRIGHT", alertpanel, "TOPRIGHT", 0, 0)
    alertpanel.top:SetHeight(half)

    --[[ BOTTOM ]]--
    alertpanel.bottom = alertpanel:CreateTexture(nil, "BORDER")
    alertpanel.bottom:SetTexture(TEMPLATE.BOTTOM)
    alertpanel.bottom:SetPoint("TOPLEFT", alertpanel, "BOTTOMLEFT", 0, 0)
    alertpanel.bottom:SetPoint("TOPRIGHT", alertpanel, "BOTTOMRIGHT", 0, 0)
    alertpanel.bottom:SetWidth(half)

    frame.AlertPanel = alertpanel
    frame.AlertColor = SetAlertColor
end

local SetIconAlertColor = function(self, r, g, b)
	--self.AlertPanel.bg:SetGradient('VERTICAL', (r*0.5), (g*0.5), (b*0.5), r, g, b)
	self.AlertPanel.icon:SetGradient('VERTICAL', (r*0.5), (g*0.5), (b*0.5), r, g, b)
end

function MOD:ApplyItemAlertStyle(frame, noicon)
	if(not frame or (frame and frame.AlertPanel)) then return end

	local size = frame:GetWidth() * 0.5;
	local lvl = frame:GetFrameLevel();

	if lvl < 1 then lvl = 1 end

    local alertpanel = CreateFrame("Frame", nil, frame)
    alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", -25, 10)
    alertpanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10)
    alertpanel:SetHeight(size)
    alertpanel:SetFrameLevel(lvl - 1)

    --[[ FRAME BG ]]--
    alertpanel.bg = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -5)
    alertpanel.bg:SetAllPoints()
    alertpanel.bg:SetTexture(SV.Media.alert.full)
    alertpanel.bg:SetGradient('VERTICAL', 0, 0, 0, .37, .32, .29)

    if(not noicon) then
	    --[[ ICON BG ]]--
	    alertpanel.icon = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -2)
	    alertpanel.icon:SetTexture(SV.Media.alert.icon)
	    alertpanel.icon:SetGradient('VERTICAL', 1, 0.35, 0, 1, 1, 0)
	    alertpanel.icon:SetPoint("LEFT", alertpanel, "LEFT", -45, 20)
	    alertpanel.icon:SetSize(size, size)
	    frame.AlertColor = SetIconAlertColor
	end

    frame.AlertPanel = alertpanel
end
--[[
########################################################## 
 /$$      /$$ /$$$$$$  /$$$$$$   /$$$$$$ 
| $$$    /$$$|_  $$_/ /$$__  $$ /$$__  $$
| $$$$  /$$$$  | $$  | $$  \__/| $$  \__/
| $$ $$/$$ $$  | $$  |  $$$$$$ | $$      
| $$  $$$| $$  | $$   \____  $$| $$      
| $$\  $ | $$  | $$   /$$  \ $$| $$    $$
| $$ \/  | $$ /$$$$$$|  $$$$$$/|  $$$$$$/
|__/     |__/|______/ \______/  \______/ 
##########################################################
--]]
function MOD:ApplyEditBoxStyle(this, width, height, x, y)
	if not this then return end
	this:RemoveTextures(true)
    this:SetStylePanel("Editbox", x, y)
    if width then this:ModWidth(width) end
	if height then this:ModHeight(height) end
end