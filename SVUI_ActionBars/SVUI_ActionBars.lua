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
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, split = string.find, string.format, string.split;
local gsub = string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MODULE_NAME, MODULE_OBJ = ...;
local MOD = SV.ActionBars;
if(not MOD) then MOD = MODULE_OBJ end;
MOD.ButtonCache = {};
local LibStub = _G.LibStub;
if(not LibStub) then return end;
local LSM = LibStub("LibSharedMedia-3.0");
local LibAB = LibStub("LibActionButton-1.0");
local Masque = LibStub("Masque", true);
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local maxFlyoutCount = 0
local SetSpellFlyoutHook
local NewFrame = CreateFrame
local NewHook = hooksecurefunc
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS;
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function NewActionBar(barName)
	local bar = CreateFrame("Frame", barName, UIParent, "SecureHandlerStateTemplate")
	if Masque then
	    bar.MasqueGroup = Masque:Group(MODULE_NAME, barName)
	end
	bar.buttons = {}
	bar.conditions = ""
	bar.config = {
		outOfRangeColoring = "button",
		tooltip = "enable",
		showGrid = true,
		colors = {
			range = {0.8, 0.1, 0.1},
			mana = {0.5, 0.5, 1.0},
			hp = {0.5, 0.5, 1.0}
		},
		hideElements = {
			macro = false,
			hotkey = false,
			equipped = false
		},
		keyBoundTarget = false,
		clickOnDown = false
	}
	return bar
end

local function NewActionButton(parent, index, name)
	return LibAB:CreateButton(index, name, parent, nil)
end

local Bar_OnEnter = function(self)
	if(self._fade) then
		for i=1, self.maxButtons do
			self.buttons[i].cd:SetSwipeColor(0, 0, 0, 1)
			self.buttons[i].cd:SetDrawBling(true)
		end
		self:FadeIn(0.2, self:GetAlpha(), self._alpha)
	end
end 

local Bar_OnLeave = function(self)
	if(self._fade) then
		for i=1, self.maxButtons do
			self.buttons[i].cd:SetSwipeColor(0, 0, 0, 0)
			self.buttons[i].cd:SetDrawBling(false)
		end
		self:FadeOut(1, self:GetAlpha(), 0)
	end
end

function MOD:FixKeybindText(button)
	local hotkey = _G[button:GetName()..'HotKey']
	local hotkeyText = hotkey:GetText()
	if hotkeyText then
		hotkeyText = hotkeyText:gsub('SHIFT%-', "S")
		hotkeyText = hotkeyText:gsub('ALT%-',  "A")
		hotkeyText = hotkeyText:gsub('CTRL%-',  "C")
		hotkeyText = hotkeyText:gsub('BUTTON',  "B")
		hotkeyText = hotkeyText:gsub('MOUSEWHEELUP', "WU")
		hotkeyText = hotkeyText:gsub('MOUSEWHEELDOWN', "WD")
		hotkeyText = hotkeyText:gsub('NUMPAD',  "N")
		hotkeyText = hotkeyText:gsub('PAGEUP', "PgU")
		hotkeyText = hotkeyText:gsub('PAGEDOWN', "PgD")
		hotkeyText = hotkeyText:gsub('SPACE', "SP")
		hotkeyText = hotkeyText:gsub('INSERT', "INS")
		hotkeyText = hotkeyText:gsub('HOME', "HM")
		hotkeyText = hotkeyText:gsub('DELETE', "DEL")
		hotkeyText = hotkeyText:gsub('NMULTIPLY', "N*")
		hotkeyText = hotkeyText:gsub('NMINUS', "N-")
		hotkeyText = hotkeyText:gsub('NPLUS', "N+")
		hotkey:SetText(hotkeyText)
	end 
	hotkey:ClearAllPoints()
	hotkey:SetAllPoints()
end 

local function Pinpoint(parent)
    local centerX,centerY = parent:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local result;
    if not centerX or not centerY then 
        return "CENTER"
    end 
    local heightTop = screenHeight * 0.75;
    local heightBottom = screenHeight * 0.25;
    local widthLeft = screenWidth * 0.25;
    local widthRight = screenWidth * 0.75;
    if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then 
        result="TOP"
    elseif((centerX < widthLeft) and (centerY > heightTop)) then 
        result="TOPLEFT"
    elseif((centerX > widthRight) and (centerY > heightTop)) then 
        result="TOPRIGHT"
    elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then 
        result="BOTTOM"
    elseif((centerX < widthLeft) and (centerY < heightBottom)) then 
        result="BOTTOMLEFT"
    elseif((centerX > widthRight) and (centerY < heightBottom)) then 
        result="BOTTOMRIGHT"
    elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then 
        result="LEFT"
    elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then 
        result="RIGHT"
    else 
        result="CENTER"
    end 
    return result 
end 

local function SaveActionButton(button, noStyle)
	local name = button:GetName()
	local cooldown = _G[name.."Cooldown"]
	cooldown.SizeOverride = SV.db.ActionBars.cooldownSize
	-- cooldown:SetSwipeColor(0, 0, 0, 0)
	-- cooldown:SetDrawBling(false)
	if(not button.cd) then
		button.cd = cooldown;
	end
	MOD:FixKeybindText(button)
	MOD.ButtonCache[button] = true 
	if(not noStyle) then
		button:SetStyle("ActionSlot", true)
		button:SetCheckedTexture("")
	end
end 

local function SetFlyoutButton(button)
	if not button or not button.FlyoutArrow or not button.FlyoutArrow:IsShown() or not button.FlyoutBorder then return end 
	local LOCKDOWN = InCombatLockdown()
	button.FlyoutBorder:SetAlpha(0)
	button.FlyoutBorderShadow:SetAlpha(0)
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	for i = 1, GetNumFlyouts()do 
		local id = GetFlyoutID(i)
		local _, _, max, check = GetFlyoutInfo(id)
		if check then 
			maxFlyoutCount = max;
			break 
		end 
	end 
	local offset = 0;
	if SpellFlyout:IsShown() and SpellFlyout:GetParent() == button or GetMouseFocus() == button then offset = 5 else offset = 2 end 
	if button:GetParent() and button:GetParent():GetParent() and button:GetParent():GetParent():GetName() and button:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame" then return end 
	if button:GetParent() then 
		local point = Pinpoint(button:GetParent())
		if point:find("RIGHT") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("LEFT", button, "LEFT", -offset, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 270)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "LEFT")
			end 
		elseif point:find("LEFT") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("RIGHT", button, "RIGHT", offset, 0)
			SetClampedTextureRotation(button.FlyoutArrow, 90)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "RIGHT")
			end 
		elseif point:find("TOP") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("BOTTOM", button, "BOTTOM", 0, -offset)
			SetClampedTextureRotation(button.FlyoutArrow, 180)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "DOWN")
			end 
		elseif point == "CENTER" or point:find("BOTTOM") then 
			button.FlyoutArrow:ClearAllPoints()
			button.FlyoutArrow:SetPoint("TOP", button, "TOP", 0, offset)
			SetClampedTextureRotation(button.FlyoutArrow, 0)
			if not LOCKDOWN then 
				button:SetAttribute("flyoutDirection", "UP")
			end 
		end
	end 
end 

local function ModifyActionButton(button, noStyle)
	local name = button:GetName()
	if(not name) then return; end
	local icon = _G[name.."Icon"]
	local count = _G[name.."Count"]
	local flash = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local normal = _G[name.."NormalTexture"]
	local cooldown = _G[name.."Cooldown"]
	local buttonTex = button:GetNormalTexture()
	local shine = _G[name.."Shine"]
	local highlight = button:GetHighlightTexture()
	local pushed = button:GetPushedTexture()
	local checked = button:GetCheckedTexture()
	if cooldown then
		cooldown.SizeOverride = SV.db.ActionBars.cooldownSize
		--cooldown:SetAlpha(0)
	end 

	if(not noStyle) then
		if highlight then 
			highlight:SetTexture(1,1,1,.2)
		end 
		if pushed then 
			pushed:SetTexture(0,0,0,.4)
		end 
		if checked then 
			checked:SetTexture(1,1,1,.2)
		end 
		if flash then 
			flash:SetTexture("")
		end 
		if normal then 
			normal:SetTexture("")
			normal:Hide()
			normal:SetAlpha(0)
		end 
		if buttonTex then 
			buttonTex:SetTexture("")
			buttonTex:Hide()
			buttonTex:SetAlpha(0)
		end 
		if border then border:Die()end 
		if icon then 
			icon:SetTexCoord(.1,.9,.1,.9)
			icon:InsetPoints(name)
		end 
		if shine then shine:SetAllPoints()end
	end

	if count then
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT",1,1)
		count:SetShadowOffset(1,-1)
		SV:FontManager(count, "number")
	end 

	if SV.db.ActionBars.hotkeytext then 
		hotkey:ClearAllPoints()
		hotkey:SetAllPoints()
		hotkey:SetFontObject(SVUI_Font_Default)
		hotkey:SetJustifyH("RIGHT")
    	hotkey:SetJustifyV("TOP")
		hotkey:SetShadowOffset(1,-1)
	end 

	button.FlyoutUpdateFunc = SetFlyoutButton;
	MOD:FixKeybindText(button)
end 

do
	local SpellFlyoutButton_OnEnter = function(self)
		local parent = self:GetParent()
		local anchor = select(2, parent:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then
			local alpha = anchorParent._alpha
			local actual = anchorParent:GetAlpha()
			anchorParent:FadeIn(0.2, actual, alpha)
		end
	end

	local SpellFlyoutButton_OnLeave = function(self)
		local parent = self:GetParent()
		local anchor = select(2, parent:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then
			local actual = anchorParent:GetAlpha()
			anchorParent:FadeOut(1, actual, 0)
		end
	end

	local SpellFlyout_OnEnter = function(self)
		local anchor = select(2,self:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent = anchor:GetParent()
		if anchorParent._fade then 
			Bar_OnEnter(anchorParent)	
		end
	end

	local SpellFlyout_OnLeave = function(self)
		local anchor = select(2, self:GetPoint())
		if not MOD.ButtonCache[anchor] then return end 
		local anchorParent=anchor:GetParent()
		if anchorParent._fade then 
			Bar_OnLeave(anchorParent)
		end
	end

	local SpellFlyout_OnShow = function()
		for i=1,maxFlyoutCount do
			local name = ("SpellFlyoutButton%s"):format(i)
			local button = _G[name]
			if(button) then 
				ModifyActionButton(button)
				SaveActionButton(button)

				button:HookScript('OnEnter', SpellFlyoutButton_OnEnter)
				
				button:HookScript('OnLeave', SpellFlyoutButton_OnLeave)
			end 
		end 
		SpellFlyout:HookScript('OnEnter', SpellFlyout_OnEnter)
		SpellFlyout:HookScript('OnLeave', SpellFlyout_OnLeave)
	end

	local QualifyFlyouts = function()
		if InCombatLockdown() then return end 
		for button,_ in pairs(MOD.ButtonCache)do 
			if(button and button.FlyoutArrow) then
				SetFlyoutButton(button)
			end 
		end 
	end 

	function SetSpellFlyoutHook()
		SpellFlyout:HookScript("OnShow",SpellFlyout_OnShow);
		SV.Timers:ExecuteTimer(QualifyFlyouts, 5)
	end
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateBarBindings(pet, stance)
	if stance == true then
		local bar = _G["SVUI_StanceBar"]
		local bindText = bar.binding

	  	for i=1,NUM_STANCE_SLOTS do
	  		local name = ("SVUI_StanceBarButton%s"):format(i)
	  		local hkname = ("SVUI_StanceBarButton%sHotKey"):format(i)
			local hotkey = _G[hkname]
		    if SV.db.ActionBars.hotkeytext then
		    	local key = bindText:format(i);
		    	local binding = GetBindingKey(key)
		      	hotkey:Show()
		      	hotkey:SetText(binding)
		      	MOD:FixKeybindText(_G[name])
		    else 
		      	hotkey:Hide()
		    end 
	  	end
  	end
  	if pet == true then
  		local bar = _G["SVUI_PetActionBar"]
		local bindText = bar.binding

	  	for i=1,NUM_PET_ACTION_SLOTS do
	  		local name = ("PetActionButton%s"):format(i)
	  		local hkname = ("PetActionButton%sHotKey"):format(i)
			local hotkey = _G[hkname]
		    if SV.db.ActionBars.hotkeytext then 
		      	local key = bindText:format(i);
		    	local binding = GetBindingKey(key)
		      	hotkey:Show()
		      	hotkey:SetText(binding)
		      	MOD:FixKeybindText(_G[name])
		    else
	    		hotkey:Hide()
	    	end 
	  	end
	end
end 

function MOD:UpdateAllBindings(event)
	if event == "UPDATE_BINDINGS" then 
		MOD:UpdateBarBindings(true,true)
	end 
	MOD:UnregisterEvent("PLAYER_REGEN_DISABLED")
	if InCombatLockdown() then return end 
	for i = 1, 6 do
		local barName = ("SVUI_ActionBar%d"):format(i)
		local bar = _G[barName]
		if(bar and bar.buttons) then
			local thisBinding = bar.binding

			ClearOverrideBindings(bar)

			for k = 1,#bar.buttons do 
				local binding = thisBinding:format(k);
				local btn = ("%sButton%d"):format(barName, k);
				for x = 1,select('#',GetBindingKey(binding)) do 
					local key = select(x, GetBindingKey(binding))
					if (key and key ~= "") then 
						SetOverrideBindingClick(bar, false, key, btn)
					end 
				end 
			end
		end
	end 
end 

function MOD:SetBarConfigData(bar)
	local db = SV.db.ActionBars
	local thisBinding = bar.binding;
	local buttonList = bar.buttons;
	local config = bar.config
	config.hideElements.macro = (not db.macrotext);
	config.hideElements.hotkey = (not db.hotkeytext);
	config.showGrid = db.showGrid;
	config.clickOnDown = db.keyDown;
	config.colors.range = db.unc
	config.colors.mana = db.unpc
	config.colors.hp = db.unpc
	SetModifiedClick("PICKUPACTION", db.unlock)
	for i,button in pairs(buttonList)do
		if thisBinding then
			config.keyBoundTarget = thisBinding:format(i)
		end
		button.keyBoundTarget = config.keyBoundTarget;
		button.postKeybind = self.FixKeybindText;
		button:SetAttribute("buttonlock",true)
		button:SetAttribute("checkselfcast",true)
		button:SetAttribute("checkfocuscast",true)
		button:UpdateConfig(config)
	end
end 

function MOD:UpdateBarPagingDefaults()
	local parse, custom;
	if SV.db.ActionBars.Bar6.enable then
		parse = "[vehicleui,mod:alt,mod:ctrl] %d; [possessbar] %d; [overridebar] %d; [form,noform] 0; [shapeshift] 13; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; %s";
	else
		parse = "[vehicleui,mod:alt,mod:ctrl] %d; [possessbar] %d; [overridebar] %d; [form,noform] 0; [shapeshift] 13; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; %s";
	end
	
	local mainbar = _G["SVUI_ActionBar1"]
	if(mainbar) then
		if SV.db.ActionBars.Bar1.useCustomPaging then
			custom = SV.db.ActionBars.Bar1.customPaging[SV.class];
		else
			custom = ""
		end

		mainbar.conditions = parse:format(GetVehicleBarIndex(), GetVehicleBarIndex(), GetOverrideBarIndex(), custom);
	end

	for i=2, 6 do
		local id = ("Bar%d"):format(i)
		local bar = _G["SVUI_Action" .. id]
		if(bar and SV.db.ActionBars[id].useCustomPaging) then
			bar.conditions = SV.db.ActionBars[id].customPaging[SV.class];
		end
	end 

	if((not SV.db.ActionBars.enable or InCombatLockdown()) or not self.isInitialized) then return end 
	local Bar2Option = InterfaceOptionsActionBarsPanelBottomRight
	local Bar3Option = InterfaceOptionsActionBarsPanelBottomLeft
	local Bar4Option = InterfaceOptionsActionBarsPanelRightTwo
	local Bar5Option = InterfaceOptionsActionBarsPanelRight

	if (SV.db.ActionBars.Bar2.enable and not Bar2Option:GetChecked()) or (not SV.db.ActionBars.Bar2.enable and Bar2Option:GetChecked())  then
		Bar2Option:Click()
	end
	
	if (SV.db.ActionBars.Bar3.enable and not Bar3Option:GetChecked()) or (not SV.db.ActionBars.Bar3.enable and Bar3Option:GetChecked())  then
		Bar3Option:Click()
	end
	
	if not SV.db.ActionBars.Bar5.enable and not SV.db.ActionBars.Bar4.enable then
		if Bar4Option:GetChecked() then
			Bar4Option:Click()
		end				
		
		if Bar5Option:GetChecked() then
			Bar5Option:Click()
		end
	elseif not SV.db.ActionBars.Bar5.enable then
		if not Bar5Option:GetChecked() then
			Bar5Option:Click()
		end
		
		if not Bar4Option:GetChecked() then
			Bar4Option:Click()
		end
	elseif (SV.db.ActionBars.Bar4.enable and not Bar4Option:GetChecked()) or (not SV.db.ActionBars.Bar4.enable and Bar4Option:GetChecked()) then
		Bar4Option:Click()
	elseif (SV.db.ActionBars.Bar5.enable and not Bar5Option:GetChecked()) or (not SV.db.ActionBars.Bar5.enable and Bar5Option:GetChecked()) then
		Bar5Option:Click()
	end
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
do
	local Button_OnEnter = function(self)
		local parent = self:GetParent()
		if parent and parent._fade then
			Bar_OnEnter(parent)
		end
	end 

	local Button_OnLeave = function(self)
		GameTooltip:Hide()
		local parent = self:GetParent()
		if parent and parent._fade then
			Bar_OnLeave(parent)
		end
	end 

	local function _refreshButtons(bar, id, max, space, cols, totalButtons, size, point, selfcast)
		if InCombatLockdown() then return end 
		if not bar then return end 
		local hideByScale = id == "Pet" and true or false;
		local isStance = id == "Stance" and true or false;
		local button,lastButton,lastRow;

		for i=1, max do 
			button = bar.buttons[i]
			lastButton = bar.buttons[i - 1]
			lastRow = bar.buttons[i - cols]
			button:SetParent(bar)
			button:ClearAllPoints()
			button:ModSize(size)
			button:SetAttribute("showgrid",1)

			if(selfcast) then
				button:SetAttribute("unit2", "player")
			end

			if(not button._hookFade) then
				button:HookScript('OnEnter', Button_OnEnter)
				button:HookScript('OnLeave', Button_OnLeave)
				button._hookFade = true;
			end 

			local x,y,anchor1,anchor2;

			if(i == 1) then
				x, y = 0, 0
				if(point:find("BOTTOM")) then
					y = space
				elseif(point:find("TOP")) then
					y = -space
				end
				if(point:find("RIGHT")) then
					x = -space
				elseif(point:find("LEFT")) then
					x = space
				end
				button:ModPoint(point,bar,point,x,y)
			elseif((i - 1) % cols == 0) then 
				x, y = 0, -space
				anchor1, anchor2 = "TOP", "BOTTOM"
		      	if(point:find("BOTTOM")) then 
		        	y = space;
		        	anchor1 = "BOTTOM"
		        	anchor2 = "TOP"
		      	end
				button:ModPoint(anchor1,lastRow,anchor2,x,y)
			else 
				x, y = space, 0
		      	anchor1, anchor2 = "LEFT", "RIGHT";
		      	if(point:find("RIGHT")) then 
		        	x = -space;
		        	anchor1 = "RIGHT"
		        	anchor2 = "LEFT"
		      	end
				button:ModPoint(anchor1,lastButton,anchor2,x,y)
			end 

			if(i > totalButtons) then
				if hideByScale then
					button:SetScale(0.000001)
	      			button:SetAlpha(0)
				else 
					button:Hide()
				end
				if button.cd then
					button.cd:SetSwipeColor(0, 0, 0, 0)
					button.cd:SetDrawBling(false)
				end
			else 
				if hideByScale then
					button:SetScale(1)
	      			button:SetAlpha(1)
				else 
					button:Show()
				end
				if button.cd then
					button.cd:SetSwipeColor(0, 0, 0, 1)
					button.cd:SetDrawBling(true)
				end
			end
			local hasMasque = false;
			if bar.MasqueGroup then
			    bar.MasqueGroup:AddButton(button)
			    hasMasque = true
			end
			if (not isStance or (isStance and not button.FlyoutUpdateFunc)) then 
	      		ModifyActionButton(button, hasMasque);
	      		SaveActionButton(button, hasMasque);
	    	end
		end

		if(bar._fade) then Bar_OnLeave(bar) end
	end 

	local function _getPage(bar, defaultPage, condition)
		local page = SV.db.ActionBars[bar].customPaging[SV.class]
		if not condition then condition = '' end
		if not page then page = '' end
		if page then
			condition = condition.." "..page
		end
		condition = condition.." "..defaultPage
		return condition
	end

	function MOD:RefreshBar(id)
		if(InCombatLockdown()) then return end

		local bar 
		local isPet, isStance = false, false
		local db = SV.db.ActionBars[id]

		if(id == "Pet") then
			bar = _G["SVUI_PetActionBar"]
			isPet = true
		elseif(id == "Stance") then
			bar = _G["SVUI_StanceBar"]
			isStance = true
		else
			bar = _G[("SVUI_Action%s"):format(id)]
		end

		if(not bar or not db) then return end

		local selfcast = db.rightClickSelf
		local space = db.buttonspacing;
		local cols = db.buttonsPerRow;
		local size = db.buttonsize;
		local point = db.point;
		local barVisibility = db.customVisibility;
		local totalButtons = db.buttons;
		local max = (isStance and GetNumShapeshiftForms()) or (isPet and 10) or NUM_ACTIONBAR_BUTTONS;
		local rows = ceil(totalButtons  /  cols);

		if max < cols then cols = max end 
		if rows < 1 then rows = 1 end
		bar.maxButtons = max;
		bar:ModWidth(space  +  (size  *  cols)  +  ((space  *  (cols - 1))  +  space));
		bar:ModHeight((space  +  (size  *  rows))  +  ((space  *  (rows - 1))  +  space));
		bar.backdrop:ClearAllPoints()
	  	bar.backdrop:SetAllPoints()
		bar._fade = db.mouseover;
		bar._alpha = db.alpha;

		if db.backdrop == true then 
			bar.backdrop:Show()
		else 
			bar.backdrop:Hide()
		end 

		bar:SetScript('OnEnter', Bar_OnEnter)
		bar:SetScript('OnLeave', Bar_OnLeave)

		if(db.mouseover == true) then 
			bar:SetAlpha(0)
			bar._fade = true
		else 
			bar:SetAlpha(db.alpha)
			bar._fade = false 
		end 
		
		_refreshButtons(bar, id, max, space, cols, totalButtons, size, point, selfcast);

		if(isPet or isStance) then
			if db.enable then 
				bar:SetScale(1)
				bar:SetAlpha(db.alpha)
				if(db.mouseover == true) then 
					bar:SetAlpha(0)
				else 
					bar:SetAlpha(db.alpha)
				end
				RegisterStateDriver(bar, "visibility", barVisibility)
			else 
				bar:SetScale(0.000001)
				bar:SetAlpha(0)
				UnregisterStateDriver(bar, "visibility")
			end
			--RegisterStateDriver(bar, "show", barVisibility)
		else
			local p,c = bar.page, bar.conditions
		  	local page = _getPage(id, p, c)
			if c:find("[form, noform]") then
				bar:SetAttribute("hasTempBar", true)
				local newCondition = c:gsub(" %[form, noform%] 0; ", "");
				bar:SetAttribute("newCondition", newCondition)
			else
				bar:SetAttribute("hasTempBar", false)
			end

			RegisterStateDriver(bar, "page", page)
			if not bar.ready then
				bar.ready = true;
				self:RefreshBar(id) 
				return
			end
			
			if db.enable == true then
				bar:Show()
				RegisterStateDriver(bar, "visibility", barVisibility)
			else
				bar:Hide()
				UnregisterStateDriver(bar, "visibility")
			end
			
			local moverName = ("SVUI_Action%d_MOVE"):format(id);
			if(_G[moverName]) then
				_G[moverName].snapOffset = (space * 0.5)
			end
		end
	end 
end 

function MOD:RefreshActionBars()
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
	self:UpdateBarPagingDefaults()
	for button, _ in pairs(self.ButtonCache)do 
		if button then 
			ModifyActionButton(button)
			SaveActionButton(button)
			if(button.FlyoutArrow) then
				SetFlyoutButton(button)
			end
		else 
			self.ButtonCache[button] = nil 
		end 
	end

	local id, bar
	for i = 1, 6 do
		id = ("Bar%d"):format(i)
		bar = _G[("SVUI_Action%s"):format(id)]
		self:RefreshBar(id)
		self:SetBarConfigData(bar)
	end

	self:RefreshBar("Pet")
	self:RefreshBar("Stance")
	self:UpdateBarBindings(true, true)

	collectgarbage("collect");
end 

local Vehicle_Updater = function()
	local bar = _G["SVUI_ActionBar1"]
	local space = SV.db.ActionBars["Bar1"].buttonspacing
	local total = SV.db.ActionBars["Bar1"].buttons;
	local rows = SV.db.ActionBars["Bar1"].buttonsPerRow;
	local size = SV.db.ActionBars["Bar1"].buttonsize
	local point = SV.db.ActionBars["Bar1"].point;
	local columns = ceil(total / rows)
	if (HasOverrideActionBar() or HasVehicleActionBar()) and total == 12 then 
		bar.backdrop:ClearAllPoints()
		bar.backdrop:ModPoint(SV.db.ActionBars["Bar1"].point, bar, SV.db.ActionBars["Bar1"].point)
		bar.backdrop:ModWidth(space + ((size * rows) + (space * (rows - 1)) + space))
		bar.backdrop:ModHeight(space + ((size * columns) + (space * (columns - 1)) + space))
		bar.backdrop:SetFrameLevel(0);
	else 
		bar.backdrop:SetAllPoints()
		bar.backdrop:SetFrameLevel(0);
	end
	MOD:RefreshBar("Bar1")
end 
--[[ 
########################################################## 
HOOKED / REGISTERED FUNCTIONS
##########################################################
]]--
local SVUIOptionsPanel_OnEvent = function()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetText((L['Remove Bar %d Action Page']):format(2))
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetText((L['Remove Bar %d Action Page']):format(3))
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetText((L['Remove Bar %d Action Page']):format(4))
	InterfaceOptionsActionBarsPanelRight.Text:SetText((L['Remove Bar %d Action Page']):format(5))
	InterfaceOptionsActionBarsPanelBottomRight:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript('OnEnter',nil)
	InterfaceOptionsActionBarsPanelRight:SetScript('OnEnter',nil)
end 

local SVUIButton_ShowOverlayGlow = function(self)
	if not self.overlay then return end  
	local size = self:GetWidth() / 3;
	self.overlay:WrapPoints(self, size)
end 

local ResetAllBindings = function(self)
	if InCombatLockdown() then return end

	local bar
	for i = 1, 6 do
		bar = _G[("SVUI_ActionBar%d"):format(i)]
		if(bar) then
			ClearOverrideBindings(bar)
		end
	end

	ClearOverrideBindings(_G["SVUI_PetActionBar"])
	ClearOverrideBindings(_G["SVUI_StanceBar"])

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAllBindings")
end 
--[[ 
########################################################## 
BAR CREATION
##########################################################
]]--
local CreateActionBars, CreateStanceBar, CreatePetBar;
local barBindingIndex = {
	"ACTIONBUTTON%d",
	"MULTIACTIONBAR2BUTTON%d",
	"MULTIACTIONBAR1BUTTON%d",
	"MULTIACTIONBAR4BUTTON%d",
	"MULTIACTIONBAR3BUTTON%d",
	"SVUIACTIONBAR6BUTTON%d",
	"SVUIACTIONBAR7BUTTON%d",
	"SVUIACTIONBAR8BUTTON%d",
	"SVUIACTIONBAR9BUTTON%d",
	"SVUIACTIONBAR10BUTTON%d"
}
local barPageIndex = {1, 5, 6, 4, 3, 2, 7, 8, 9, 10}

CreateActionBars = function(self)
	local count = SV.db.ActionBars.barCount or 6
	local lastExtendedBar;
	for i = 1, count do 
		local barID = ("Bar%d"):format(i)
		local barName = ("SVUI_Action%s"):format(barID)
		local buttonMax = NUM_ACTIONBAR_BUTTONS

		local space = SV.db.ActionBars["Bar"..i].buttonspacing

		local thisBar = NewActionBar(barName)
		thisBar.binding = barBindingIndex[i]
		thisBar.page = barPageIndex[i]

		if(i == 1) then
			thisBar:ModPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 28)
		elseif(i == 2) then
			thisBar:ModPoint("BOTTOM", _G["SVUI_ActionBar1"], "TOP", 0, -space)
		elseif(i == 3) then
			thisBar:ModPoint("BOTTOMLEFT", _G["SVUI_ActionBar1"], "BOTTOMRIGHT", space, 0)
		elseif(i == 4) then
			thisBar:ModPoint("RIGHT", SV.Screen, "RIGHT", -space, 0)
		elseif(i == 5) then
			thisBar:ModPoint("BOTTOMRIGHT", _G["SVUI_ActionBar1"], "BOTTOMLEFT", -space, 0)
		elseif(not lastExtendedBar) then
			thisBar:ModPoint("BOTTOM", _G["SVUI_ActionBar2"], "TOP", 0, space)
			lastExtendedBar = thisBar
		else
			thisBar:ModPoint("BOTTOM", lastExtendedBar, "TOP", 0, space)
			lastExtendedBar = thisBar
		end
			
		local bg = CreateFrame("Frame", nil, thisBar)
		bg:SetAllPoints()
		bg:SetFrameLevel(0)
		thisBar:SetFrameLevel(5)
		bg:SetStyle("Frame", "Transparent")
		bg:SetPanelColor("dark")
		thisBar.backdrop = bg

		for k = 1, buttonMax do
			local buttonName = ("%sButton%d"):format(barName, k)
			thisBar.buttons[k] = NewActionButton(thisBar, k, buttonName)
			thisBar.buttons[k]:SetState(0, "action", k)
			for x = 1, 14 do 
				local calc = (x - 1)  *  buttonMax  +  k;
				thisBar.buttons[k]:SetState(x, "action", calc)
			end 
			if k == 12 then 
				thisBar.buttons[k]:SetState(12, "custom", {
					func = function(...) 
						if UnitExists("vehicle") then 
							VehicleExit() 
						else 
							PetDismiss() 
						end 
					end, 
					texture = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down", 
					tooltip = LEAVE_VEHICLE
				});
			end 
		end

		self:SetBarConfigData(thisBar)

		if i == 1 then 
			thisBar:SetAttribute("hasTempBar", true)
		else 
			thisBar:SetAttribute("hasTempBar", false)
		end

		thisBar:SetAttribute("_onstate-page", [[
			if HasTempShapeshiftActionBar() and self:GetAttribute("hasTempBar") then
				newstate = GetTempShapeshiftBarIndex() or newstate
			end

			if newstate ~= 0 then
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			else
				local newCondition = self:GetAttribute("newCondition")
				if newCondition then
					newstate = SecureCmdOptionParse(newCondition)
					self:SetAttribute("state", newstate)
					control:ChildUpdate("state", newstate)
				end
			end
		]])

		self:RefreshBar(barID)
		SV:NewAnchor(thisBar, L[barID])
	end 
end

do
	local function SetStanceBarButtons()
		local maxForms = GetNumShapeshiftForms();
		local currentForm = GetShapeshiftForm();
		local maxButtons = NUM_STANCE_SLOTS;
		local texture, name, isActive, isCastable, _;
		for i = 1, maxButtons do
			local button = _G["SVUI_StanceBarButton"..i]
			local icon = _G["SVUI_StanceBarButton"..i.."Icon"]
			if i <= maxForms then 
				texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
				if texture == "Interface\\Icons\\Spell_Nature_WispSplode" and SV.db.ActionBars.Stance.style == "darkenInactive" then 
					_, _, texture = GetSpellInfo(name)
				end

				icon:SetTexture(texture)

				if(button.cd) then
					if texture then 
						button.cd:SetAlpha(1)
						button.cd:SetSwipeColor(0, 0, 0, 1)
						button.cd:SetDrawBling(true)
					else 
						button.cd:SetAlpha(0)
						button.cd:SetSwipeColor(0, 0, 0, 0)
						button.cd:SetDrawBling(false)
					end
				end

				if isActive then 
					StanceBarFrame.lastSelected = button:GetID()

					if maxForms > 1 then 
						if button.checked then button.checked:SetTexture(0, 0.5, 0, 0.2) end
						button:SetBackdropBorderColor(0.4, 0.8, 0)
					end
					icon:SetVertexColor(1, 1, 1)
					button:SetChecked(true) 
				else 
					if maxForms > 1 and currentForm > 0 then 
						button:SetBackdropBorderColor(0, 0, 0)
						if button.checked then 
							button.checked:SetAlpha(1)
						end
						if SV.db.ActionBars.Stance.style == "darkenInactive" then 
							icon:SetVertexColor(0.25, 0.25, 0.25)
						else 
							icon:SetVertexColor(1, 1, 1)
						end
					end

					button:SetChecked(false) 
				end 
				if isCastable then 
					icon:SetDesaturated(false)
					button:SetAlpha(1)
				else 
					icon:SetDesaturated(true)
					button:SetAlpha(0.4)
				end
			end 
		end 
	end 

	local function UpdateShapeshiftForms(self, event)
	  if InCombatLockdown() or not _G["SVUI_StanceBar"] then return end 

	  local stanceBar = _G["SVUI_StanceBar"];

	  for i = 1, #stanceBar.buttons do 
		stanceBar.buttons[i]:Hide()
	  end 

	  local ready = false;
	  local maxForms = GetNumShapeshiftForms()

	  for i = 1, NUM_STANCE_SLOTS do 
		if(not stanceBar.buttons[i]) then 
		  stanceBar.buttons[i] = CreateFrame("CheckButton", format("SVUI_StanceBarButton%d", i), stanceBar, "StanceButtonTemplate")
		  stanceBar.buttons[i]:SetID(i)
		  ready = true 
		end 
		if(i <= maxForms) then 
		  stanceBar.buttons[i]:Show()
		else 
		  stanceBar.buttons[i]:Hide()
		end 
	  end 

	  MOD:RefreshBar("Stance")

	  SetStanceBarButtons() 
	  if not C_PetBattles.IsInBattle() or ready then 
		if maxForms == 0 then 
		  UnregisterStateDriver(stanceBar, "show")
		  stanceBar:Hide()
		else 
		  stanceBar:Show()
		  RegisterStateDriver(stanceBar, "show", "[petbattle] hide;show")
		end 
	  end 
	end 

	local function UpdateShapeshiftCD()
	  local maxForms = GetNumShapeshiftForms()
	  for i = 1, NUM_STANCE_SLOTS do 
		if i  <= maxForms then 
		  local cooldown = _G["SVUI_StanceBarButton"..i.."Cooldown"]
		  local start, duration, enable = GetShapeshiftFormCooldown(i)
		  CooldownFrame_SetTimer(cooldown, start, duration, enable)
		end 
	  end
	end 

	CreateStanceBar = function(self)
	  local barID = "Stance";
	  local parent = _G["SVUI_ActionBar1"]
	  local maxForms = GetNumShapeshiftForms();
	  if SV.db.ActionBars["Bar2"].enable then 
		parent = _G["SVUI_ActionBar2"]
	  end

	  local stanceBar = NewActionBar("SVUI_StanceBar")
	  stanceBar.binding = "CLICK SVUI_StanceBarButton%d:LeftButton"

	  stanceBar:ModPoint("BOTTOMRIGHT",parent,"TOPRIGHT",0,2);
	  stanceBar:SetFrameLevel(5);

	  local bg = CreateFrame("Frame", nil, stanceBar)
	  bg:SetAllPoints();
	  bg:SetFrameLevel(0);
	  bg:SetStyle("Frame", "Transparent")
	  bg:SetPanelColor("dark")
	  stanceBar.backdrop = bg;

	  for i = 1, NUM_STANCE_SLOTS do
		stanceBar.buttons[i] = _G["SVUI_StanceBarButton"..i]
	  end

	  stanceBar:SetAttribute("_onstate-show", [[    
		if newstate == "hide" then
		  self:Hide();
		else
		  self:Show();
		end 
	  ]]);

	  self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", UpdateShapeshiftForms)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", UpdateShapeshiftCD)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", SetStanceBarButtons)
	  self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", SetStanceBarButtons)
	  self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", SetStanceBarButtons)
	  UpdateShapeshiftForms()
	  stanceBar.snapOffset = -3
	  SV:NewAnchor(stanceBar, L["Stance Bar"])
	  self:RefreshBar("Stance")
	  SetStanceBarButtons()
	  self:UpdateBarBindings(false, true)
	end 
end

do
	local RefreshPet = function(self, event, arg)
		if event == "UNIT_AURA" and arg  ~= "pet" then return end 
		for i = 1, NUM_PET_ACTION_SLOTS, 1 do 
			local name = "PetActionButton"..i;
			local button = _G[name]
			local icon = _G[name.."Icon"]
			local auto = _G[name.."AutoCastable"]
			local shine = _G[name.."Shine"]
			local checked = button:GetCheckedTexture()
			local actionName, subtext, actionIcon, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
			button:SetChecked(false)
			button:SetBackdropBorderColor(0, 0, 0)
			checked:SetAlpha(0)
			if(not isToken) then 
				icon:SetTexture(actionIcon)
				button.tooltipName = actionName 
			else 
				icon:SetTexture(_G[actionIcon])
				button.tooltipName = _G[actionName]
			end 
			button.isToken = isToken;
			button.tooltipSubtext = subtext;
			if arg and actionName ~= "PET_ACTION_FOLLOW" then
				if(IsPetAttackAction(i)) then PetActionButton_StartFlash(button) end
			else
				if(IsPetAttackAction(i)) then PetActionButton_StopFlash(button) end
			end 
			if autoCastAllowed then 
				auto:Show()
			else 
				auto:Hide()
			end 
			if (isActive and actionName ~= "PET_ACTION_FOLLOW") then
				button:SetChecked(true)
				checked:SetAlpha(1)
				button:SetBackdropBorderColor(0.4, 0.8, 0)
			else
				button:SetChecked(false)
				checked:SetAlpha(0)
				button:SetBackdropBorderColor(0, 0, 0)
			end 
			if(autoCastEnabled) then 
				AutoCastShine_AutoCastStart(shine)
			else
				AutoCastShine_AutoCastStop(shine)
			end
			button:SetAlpha(1)
			if actionIcon then 
				icon:Show()
				if GetPetActionSlotUsable(i)then 
					SetDesaturation(icon, nil)
				else 
					SetDesaturation(icon, 1)
				end
				if(button.cd) then
					button.cd:SetAlpha(1)
					button.cd:SetSwipeColor(0, 0, 0, 1)
					button.cd:SetDrawBling(true)
				end
			else 
				icon:Hide()
				if(button.cd) then
					button.cd:SetAlpha(0)
					button.cd:SetSwipeColor(0, 0, 0, 0)
					button.cd:SetDrawBling(false)
				end
			end
			
			if(not PetHasActionBar() and actionIcon and actionName  ~= "PET_ACTION_FOLLOW") then 
				PetActionButton_StopFlash(button)
				SetDesaturation(icon, 1)
				button:SetChecked(false)
			end 
		end
	end 

	CreatePetBar = function(self)
		local barID = "Pet";
		local parent = _G["SVUI_ActionBar1"]
		if SV.db.ActionBars["Bar2"].enable then 
			parent = _G["SVUI_ActionBar2"]
		end

		local petBar = NewActionBar("SVUI_PetActionBar")
		petBar.binding = "BONUSACTIONBUTTON%d"

		petBar:ModPoint("BOTTOMLEFT",parent,"TOPLEFT",0,2);
		petBar:SetFrameLevel(5);
		local bg = CreateFrame("Frame", nil, petBar)
		bg:SetAllPoints();
		bg:SetFrameLevel(0);
		bg:SetStyle("Frame", "Transparent")
		bg:SetPanelColor("dark")
		petBar.backdrop = bg;
		for i = 1, NUM_PET_ACTION_SLOTS do 
			petBar.buttons[i] = _G["PetActionButton"..i]
		end
		petBar:SetAttribute("_onstate-show", [[    
			if newstate == "hide" then
			  self:Hide();
			else
			  self:Show();
			end 
		]]);

		PetActionBarFrame.showgrid = 1;
		PetActionBar_ShowGrid();

		self:RefreshBar("Pet")
		self:UpdateBarBindings(true, false)

		self:RegisterEvent("PLAYER_CONTROL_GAINED", RefreshPet)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", RefreshPet)
		self:RegisterEvent("PLAYER_CONTROL_LOST", RefreshPet)
		self:RegisterEvent("PET_BAR_UPDATE", RefreshPet)
		self:RegisterEvent("UNIT_PET", RefreshPet)
		self:RegisterEvent("UNIT_FLAGS", RefreshPet)
		self:RegisterEvent("UNIT_AURA", RefreshPet)
		self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", RefreshPet)
		self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", PetActionBar_UpdateCooldowns)

		SV:NewAnchor(petBar, L["Pet Bar"])
	end 
end

local CreateExtraBar = function(self)
	local specialBar = CreateFrame("Frame", "SVUI_SpecialAbility", SV.Screen)
	specialBar:ModPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 360)
	specialBar:ModSize(ExtraActionBarFrame:GetSize())
	ExtraActionBarFrame:SetParent(specialBar)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", specialBar, "CENTER")
	ExtraActionBarFrame.ignoreFramePositionManager = true;
	local max = ExtraActionBarFrame:GetNumChildren()
	for i = 1, max do 
		local name = ("ExtraActionButton%d"):format(i)
		local icon = ("%sIcon"):format(name)
		local cool = ("%sCooldown"):format(name)
		local button = _G[name]
		if(button) then 
			button.noResize = true;
			button.pushed = true;
			button.checked = true;
			ModifyActionButton(button)
			_G[icon]:SetDrawLayer("ARTWORK")
			_G[cool]:InsetPoints()
			local checkedTexture = button:CreateTexture(nil, "OVERLAY")
			checkedTexture:SetTexture(0.9, 0.8, 0.1, 0.3)
			checkedTexture:InsetPoints()
			button:SetCheckedTexture(checkedTexture)
		end 
	end
	if HasExtraActionBar()then 
		ExtraActionBarFrame:Show()
	end
	SV:NewAnchor(specialBar, L["Extra Action Button"])
end
--[[ 
########################################################## 
DEFAULT REMOVAL
##########################################################
]]--
local function RemoveDefaults()
	if(InCombatLockdown()) then
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED")
		return 
	end
	local removalManager = CreateFrame("Frame")
	removalManager:Hide()
	MultiBarBottomLeft:SetParent(removalManager)
	MultiBarBottomRight:SetParent(removalManager)
	MultiBarLeft:SetParent(removalManager)
	MultiBarRight:SetParent(removalManager)

	for i = 1, 12 do
		local ab = _G[("ActionButton%d"):format(i)]
		ab:Hide()
		ab:UnregisterAllEvents()
		ab:SetAttribute("statehidden", true)
		local mbl = _G[("MultiBarLeftButton%d"):format(i)]
		mbl:Hide()
		mbl:UnregisterAllEvents()
		mbl:SetAttribute("statehidden", true)
		local mbr = _G[("MultiBarRightButton%d"):format(i)]
		mbr:Hide()
		mbr:UnregisterAllEvents()
		mbr:SetAttribute("statehidden", true)
		local mbbl = _G[("MultiBarBottomLeftButton%d"):format(i)]
		mbbl:Hide()
		mbbl:UnregisterAllEvents()
		mbbl:SetAttribute("statehidden", true)
		local mbbr = _G[("MultiBarBottomRightButton%d"):format(i)]
		mbbr:Hide()
		mbbr:UnregisterAllEvents()
		mbbr:SetAttribute("statehidden", true)
		local mca = _G[("MultiCastActionButton%d"):format(i)]
		mca:Hide()
		mca:UnregisterAllEvents()
		mca:SetAttribute("statehidden", true)
		local vb = _G[("VehicleMenuBarActionButton%d"):format(i)]
		if(vb) then 
			vb:Hide()
			vb:UnregisterAllEvents()
			vb:SetAttribute("statehidden", true)
		end
		local ob = _G[("OverrideActionBarButton%d"):format(i)]
		if(ob) then 
			ob:Hide()
			ob:UnregisterAllEvents()
			ob:SetAttribute("statehidden", true)
		end 
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(removalManager)
	local maxChildren = MainMenuBar:GetNumChildren();
	for i = 1, maxChildren do
		local child = select(i, MainMenuBar:GetChildren())
		if child then 
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(removalManager)
		end 
	end 
	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(removalManager)
	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(removalManager)
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(removalManager)
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(removalManager)
	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(removalManager)
	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(removalManager)
	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(removalManager)
	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(removalManager)
	
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetScale(0.0001)
	InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
	InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.00001)
	InterfaceOptionsStatusTextPanelXP:SetAlpha(0)
	InterfaceOptionsStatusTextPanelXP:SetScale(0.00001)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	MOD.DefaultsRemoved = true
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	if(not MOD.DefaultsRemoved) then
		RemoveDefaults()
	end
	self:RefreshActionBars()
end

local function UpdateActionBarOptions()
	if InCombatLockdown() or not SV.db.ActionBars.IsLoaded then return end 
	if (SV.db.ActionBars.Bar2.enable ~= InterfaceOptionsActionBarsPanelBottomRight:GetChecked()) then 
		InterfaceOptionsActionBarsPanelBottomRight:Click()
	end 
	if (SV.db.ActionBars.Bar3.enable ~= InterfaceOptionsActionBarsPanelRightTwo:GetChecked()) then 
		InterfaceOptionsActionBarsPanelRightTwo:Click()
	end 
	if (SV.db.ActionBars.Bar4.enable ~= InterfaceOptionsActionBarsPanelRight:GetChecked()) then 
		InterfaceOptionsActionBarsPanelRight:Click()
	end 
	if (SV.db.ActionBars.Bar5.enable ~= InterfaceOptionsActionBarsPanelBottomLeft:GetChecked()) then 
		InterfaceOptionsActionBarsPanelBottomLeft:Click()
	end 
  	MOD:RefreshBar("Bar1")
	MOD:RefreshBar("Bar6")
end
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:ReLoad()
	self:RefreshActionBars();
end 

function MOD:Load()
	RemoveDefaults();
	
	self:UpdateBarPagingDefaults()

	CreateActionBars(self)
	CreateStanceBar(self)
	CreatePetBar(self)
	CreateExtraBar(self)
	self:InitializeMicroBar()
	self:InitializeZoneButton()
	self:InitializeTotemBar()
	
	self:LoadKeyBinder()

	self:RegisterEvent("UPDATE_BINDINGS", "UpdateAllBindings")
	self:RegisterEvent("PET_BATTLE_CLOSE", "UpdateAllBindings")
	self:RegisterEvent("PET_BATTLE_OPENING_DONE", ResetAllBindings)
	self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", Vehicle_Updater)
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", Vehicle_Updater)
	if C_PetBattles.IsInBattle()then 
		ResetAllBindings(self)
	else 
		self:UpdateAllBindings()
	end 
	NewHook("BlizzardOptionsPanel_OnEvent", SVUIOptionsPanel_OnEvent)
	NewHook("ActionButton_ShowOverlayGlow", SVUIButton_ShowOverlayGlow)
	if not GetCVarBool("lockActionBars") then SetCVar("lockActionBars", 1) end 
	SetSpellFlyoutHook()

	self.IsLoaded = true

	SV.SystemAlert["BAR6_CONFIRMATION"] = {
		text = L["Enabling / Disabling Bar #6 will toggle a paging option from your main actionbar to prevent duplicating bars, are you sure you want to do this?"], 
		button1 = YES, 
		button2 = NO, 
		OnAccept = function(a)
			if SV.db.ActionBars["BAR6"].enable ~= true then 
				SV.db.ActionBars.Bar6.enable = true;
				UpdateActionBarOptions()
			else 
				SV.db.ActionBars.Bar6.enable = false;
				UpdateActionBarOptions()
			end 
		end, 
		OnCancel = SV.fubar, 
		timeout = 0, 
		whileDead = 1, 
		state1 = 1
	};
end