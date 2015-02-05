--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local format, split = string.format, string.split;
--[[ MATH METHODS ]]--
local min, floor = math.min, math.floor;
local parsefloat = math.parsefloat;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;

local UIPanels = {};
UIPanels["AchievementFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["AuctionFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ArchaeologyFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["BattlefieldMinimap"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["BarberShopFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["BlackMarketFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["CalendarFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["CharacterFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ClassTrainerFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["DressUpFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["DraenorZoneAbilityFrame"] 		= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["EncounterJournal"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["FriendsFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GMSurveyFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GossipFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildBankFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildRegistrarFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GarrisonLandingPage"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonMissionFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonBuildingFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonCapacitiveDisplayFrame"]  = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["HelpFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["InterfaceOptionsFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["ItemUpgradeFrame"]				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["KeyBindingFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["LFGDungeonReadyPopup"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["MacOptionsFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["MacroFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["MailFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["MerchantFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ObjectiveTrackerFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PlayerTalentFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PetJournalParent"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PetStableFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PVEFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PVPFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["QuestFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["QuestLogFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["RaidBrowserFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReadyCheckFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["ReforgingFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReportCheatingDialog"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReportPlayerNameDialog"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["RolePollPopup"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["SpellBookFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TabardFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TaxiFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TimeManagerFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TradeSkillFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TradeFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TransmogrifyFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TutorialFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["VideoOptionsFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["VoidStorageFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };

UIPanels["ScrollOfResurrectionSelectionFrame"] = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };

local Layout = SV:NewClass("Layout", L["UI Frame Layout"]);
Layout.Frames = {}

local Sticky = {};
Sticky.Frames = {};
Sticky.Frames[1] = SV.Screen;
Sticky.scripts = Sticky.scripts or {}
Sticky.rangeX = 15
Sticky.rangeY = 15
Sticky.StuckTo = Sticky.StuckTo or {}

local function SnapStickyFrame(frameA, frameB, left, top, right, bottom)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	local xA, yA = frameA:GetCenter()
	local xB, yB = frameB:GetCenter()
	local hA, hB = frameA:GetHeight()  /  2, ((frameB:GetHeight()  *  sB)  /  sA)  /  2
	local wA, wB = frameA:GetWidth()  /  2, ((frameB:GetWidth()  *  sB)  /  sA)  /  2
	local newX, newY = xA, yA
	if not left then left = 0 end
	if not top then top = 0 end
	if not right then right = 0 end
	if not bottom then bottom = 0 end
	if not xB or not yB or not sB or not sA or not sB then return end
	xB, yB = (xB * sB)  /  sA, (yB * sB)  /  sA
	local stickyAx, stickyAy = wA  *  0.75, hA  *  0.75
	local stickyBx, stickyBy = wB  *  0.75, hB  *  0.75
	local lA, tA, rA, bA = frameA:GetLeft(), frameA:GetTop(), frameA:GetRight(), frameA:GetBottom()
	local lB, tB, rB, bB = frameB:GetLeft(), frameB:GetTop(), frameB:GetRight(), frameB:GetBottom()
	local snap = nil
	lB, tB, rB, bB = (lB  *  sB)  /  sA, (tB  *  sB)  /  sA, (rB  *  sB)  /  sA, (bB  *  sB)  /  sA
	if (bA  <= tB and bB  <= tA) then
		if xA  <= (xB  +  Sticky.rangeX) and xA  >= (xB - Sticky.rangeX) then
			newX = xB
			snap = true
		end
		if lA  <= (lB  +  Sticky.rangeX) and lA  >= (lB - Sticky.rangeX) then
			newX = lB  +  wA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then 
				newX = newX  +  4
			end
			snap = true
		end
		if rA  <= (rB  +  Sticky.rangeX) and rA  >= (rB - Sticky.rangeX) then
			newX = rB - wA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then 
				newX = newX - 4
			end
			snap = true
		end
		if lA  <= (rB  +  Sticky.rangeX) and lA  >= (rB - Sticky.rangeX) then
			newX = rB  +  (wA - left)
			snap = true
		end
		if rA  <= (lB  +  Sticky.rangeX) and rA  >= (lB - Sticky.rangeX) then
			newX = lB - (wA - right)
			snap = true
		end
	end
	if (lA  <= rB and lB  <= rA) then
		if yA  <= (yB  +  Sticky.rangeY) and yA  >= (yB - Sticky.rangeY) then
			newY = yB
			snap = true
		end
		if tA  <= (tB  +  Sticky.rangeY) and tA  >= (tB - Sticky.rangeY) then
			newY = tB - hA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then 
				newY = newY - 4
			end
			snap = true
		end
		if bA  <= (bB  +  Sticky.rangeY) and bA  >= (bB - Sticky.rangeY) then
			newY = bB  +  hA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then 
				newY = newY  +  4
			end
			snap = true
		end
		if tA  <= (bB  +  Sticky.rangeY  +  bottom) and tA  >= (bB - Sticky.rangeY  +  bottom) then
			newY = bB - (hA - top)
			snap = true
		end
		if bA  <= (tB  +  Sticky.rangeY - top) and bA  >= (tB - Sticky.rangeY - top) then
			newY = tB  +  (hA - bottom)
			snap = true
		end
	end
	if snap then
		frameA:ClearAllPoints()
		frameA:SetPoint("CENTER", UIParent, "BOTTOMLEFT", newX, newY)
		return true
	end
end

local function GetStickyUpdate(frame, xoffset, yoffset, left, top, right, bottom)
	return function()
		local x, y = GetCursorPosition()
		local s = frame:GetEffectiveScale()
		x, y = x / s, y / s
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + xoffset, y + yoffset)
		Sticky.StuckTo[frame] = nil
		for i = 1, #Sticky.Frames do
			local v = Sticky.Frames[i]
			if(frame ~= v and frame ~= v:GetParent() and IsShiftKeyDown() and v:IsVisible()) then
				if SnapStickyFrame(frame, v, left, top, right, bottom) then
					Sticky.StuckTo[frame] = v
					break
				end
			end
		end
	end
end

local function StickyStartMoving(frame, left, top, right, bottom)
	local x, y = GetCursorPosition()
	local aX, aY = frame:GetCenter()
	local aS = frame:GetEffectiveScale()
	aX, aY = aX * aS, aY * aS
	local xoffset, yoffset = (aX - x), (aY - y)
	Sticky.scripts[frame] = frame:GetScript("OnUpdate")
	frame:SetScript("OnUpdate", GetStickyUpdate(frame, xoffset, yoffset, left, top, right, bottom))
end

local function StickyStopMoving(frame)
	frame:SetScript("OnUpdate", Sticky.scripts[frame])
	Sticky.scripts[frame] = nil
	if Sticky.StuckTo[frame] then
		local frame2 = Sticky.StuckTo[frame]
		Sticky.StuckTo[frame] = nil
		return true, frame2
	else
		return false, nil
	end
end
local CurrentFrameTarget, UpdateFrameTarget;
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function Pinpoint(parent)
    local centerX, centerY = parent:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local result;
    if not centerX or not centerY then 
        return "CENTER"
    end 
    local heightTop = screenHeight  *  0.75;
    local heightBottom = screenHeight  *  0.25;
    local widthLeft = screenWidth  *  0.25;
    local widthRight = screenWidth  *  0.75;
    if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then 
        result = "TOP"
    elseif((centerX < widthLeft) and (centerY > heightTop)) then 
        result = "TOPLEFT"
    elseif((centerX > widthRight) and (centerY > heightTop)) then 
        result = "TOPRIGHT"
    elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then 
        result = "BOTTOM"
    elseif((centerX < widthLeft) and (centerY < heightBottom)) then 
        result = "BOTTOMLEFT"
    elseif((centerX > widthRight) and (centerY < heightBottom)) then 
        result = "BOTTOMRIGHT"
    elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then 
        result = "LEFT"
    elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then 
        result = "RIGHT"
    else 
        result = "CENTER"
    end 
    return result 
end

local function CurrentPosition(frame)
	if not frame then return end

	local parentName
	local anchor1, parent, anchor2, x, y = frame:GetPoint()

	if((not anchor1) or (not anchor2) or (not x) or (not y)) then
		anchor1, anchor2, x, y = "TOPLEFT", "TOPLEFT", 160, -80
	end
	
	if(not parent or (parent and (not parent:GetName()))) then 
		parentName = "UIParent" 
	else
		parentName = parent:GetName()
	end
	return ("%s\031%s\031%s\031%d\031%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y))
end

local function GrabUsableRegions(frame)
	local parent = frame or SV.Screen
	local right = parent:GetRight()
	local top = parent:GetTop()
	local center = parent:GetCenter()
	return right, top, center
end

local function CalculateOffsets(frame)
	if(not CurrentFrameTarget) then return end
	local right, top, center = GrabUsableRegions()
	local xOffset, yOffset = CurrentFrameTarget:GetCenter()
	local screenLeft = (right * 0.33);
	local screenRight = (right * 0.66);
	local topMedian = (top * 0.5);
	local anchor, a1, a2;

	if(yOffset >= (top * 0.5)) then
		a1 = "TOP"
		yOffset = -(top - CurrentFrameTarget:GetTop())
	else
		a1 = "BOTTOM"
		yOffset = CurrentFrameTarget:GetBottom()
	end 

	if xOffset >= screenRight then
		a2 = "RIGHT"
		xOffset = (CurrentFrameTarget:GetRight() - right) 
	elseif xOffset <= screenLeft then
		a2 = "LEFT"
		xOffset = CurrentFrameTarget:GetLeft() 
	else
		a2 = ""
		xOffset = (xOffset - center) 
	end 

	xOffset = parsefloat(xOffset, 0)
	yOffset = parsefloat(yOffset, 0)
	anchor = ("%s%s"):format(a1,a2)

	return xOffset, yOffset, anchor
end

local function ResetAllAlphas()
	for entry,_ in pairs(Layout.Frames) do
		local frame = _G[entry]
		if(frame) then 
			frame:SetAlpha(0.4)
		end 
	end 
end
--[[ 
########################################################## 
HANDLERS
##########################################################
]]--
local TheHand = CreateFrame("Frame", "SVUI_HandOfLayout", UIParent)
TheHand:SetFrameStrata("DIALOG")
TheHand:SetFrameLevel(99)
TheHand:SetClampedToScreen(true)
TheHand:SetSize(128,128)
TheHand:SetPoint("CENTER")
TheHand.bg = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.bg:SetAllPoints(TheHand)
TheHand.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-OFF]])
TheHand.energy = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.energy:SetAllPoints(TheHand)
TheHand.energy:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-ENERGY]])
SV.Animate:Orbit(TheHand.energy, 10)
TheHand.flash = TheHand.energy.anim;
TheHand.energy:Hide()
TheHand.elapsedTime = 0;
TheHand.flash:Stop()
TheHand:Hide()
TheHand.UserHeld = false;

local TheHand_OnUpdate = function(self, elapsed)
	self.elapsedTime = self.elapsedTime  +  elapsed
	if self.elapsedTime > 0.1 then
		self.elapsedTime = 0
		local x, y = GetCursorPosition()
		local scale = SV.Screen:GetEffectiveScale()
		self:SetPoint("CENTER", SV.Screen, "BOTTOMLEFT", (x  /  scale)  +  50, (y  /  scale)  +  50)
	end 
end

function TheHand:Enable()
	self:Show()
	self.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-ON]])
	self.energy:Show()
	self.flash:Play()
	self:SetScript("OnUpdate", TheHand_OnUpdate) 
end

function TheHand:Disable()
	self.flash:Stop()
	self.energy:Hide()
	self.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-OFF]])
	self:SetScript("OnUpdate", nil)
	self.elapsedTime = 0
	self:Hide()
end

function Layout:PostDragStart()
	TheHand:Enable()
	TheHand.UserHeld = true 
end

function Layout:PostDragStop()
	TheHand.UserHeld = false;
	TheHand:Disable()
end

function Layout:Movable_OnEnter()
	if TheHand.UserHeld then return end
	ResetAllAlphas()
	self:SetAlpha(1)
	self.text:SetTextColor(0, 1, 1)
	self:SetBackdropBorderColor(0, 0.7, 1)
	UpdateFrameTarget = self;
	SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-ON]])
	TheHand:SetPoint("CENTER", self, "TOP", 0, 0)
	TheHand:Show()
	if CurrentFrameTarget ~= self then 
		SVUI_LayoutPrecision:Hide()
		self:GetScript("OnMouseUp")(self)
	end
end

function Layout:Movable_OnLeave()
	if TheHand.UserHeld then return end
	self.text:SetTextColor(0.5, 0.5, 0.5)
	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
	SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-OFF]])
	TheHand:Hide()
	if(CurrentFrameTarget ~= self and not SVUI_LayoutPrecision:IsShown()) then
		self:SetAlpha(0.4)
	end
end

function Layout:Movable_OnMouseDown(button)
	if button == "RightButton" then
		TheHand.UserHeld = false;
		if(CurrentFrameTarget == self and not SVUI_LayoutPrecision:IsShown()) then
			Movable_OnUpdate()
			SVUI_LayoutPrecision:Show()
		else
			SVUI_LayoutPrecision:Hide()
		end
		if SV.db.general.stickyFrames then 
			StickyStopMoving(self)
		else 
			self:StopMovingOrSizing()
		end
	end
end

local LayoutUpdateHandler = CreateFrame("Frame", nil)

local Movable_OnMouseUp = function(self)
	CurrentFrameTarget = self;
	local xOffset, yOffset, anchor = CalculateOffsets()

	SVUI_LayoutPrecisionSetX.CurrentValue = xOffset;
	SVUI_LayoutPrecisionSetX:SetText(xOffset)
	
	SVUI_LayoutPrecisionSetY.CurrentValue = yOffset;
	SVUI_LayoutPrecisionSetY:SetText(yOffset)

	SVUI_LayoutPrecision.Title:SetText(self.textString)
end

local Movable_OnUpdate = function(self)
	local frame = UpdateFrameTarget;
	if not frame then return end
	local rightPos, topPos, centerPos = GrabUsableRegions()
	local centerX, centerY = frame:GetCenter()
	local calc1 = rightPos * 0.33;
	local calc2 = rightPos * 0.66;
	local calc3 = topPos * 0.5;
	local anchor1, anchor2;
	if centerY >= calc3 then 
		anchor1 = "TOP"
		anchor2 = "BOTTOM"
	else 
		anchor1 = "BOTTOM"
		anchor2 = "TOP"
	end 
	if centerX >= calc2 then 
		anchor1 = "RIGHT"
		anchor2 = "LEFT"
	elseif centerX <= calc1 then 
		anchor1 = "LEFT"
		anchor2 = "RIGHT"
	end 
	SVUI_LayoutPrecision:ClearAllPoints()
	SVUI_LayoutPrecision:SetPoint(anchor1, frame, anchor2, 0, 0)
	SVUI_LayoutPrecision:SetFrameLevel(frame:GetFrameLevel() + 20)
	Movable_OnMouseUp(frame)
end

local Movable_OnSizeChanged = function(self)
	if InCombatLockdown()then return end 
	if self.dirtyWidth and self.dirtyHeight then 
		self.Grip:ModSize(self.dirtyWidth, self.dirtyHeight)
	else 
		self.Grip:ModSize(self:GetSize())
	end 
end

local Movable_OnDragStart = function(self)
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT)return end 
	if SV.db.general.stickyFrames then 
		StickyStartMoving(self, self.snapOffset, -2)
	else 
		self:StartMoving()
	end 
	UpdateFrameTarget = self;
	LayoutUpdateHandler:Show()
	LayoutUpdateHandler:SetScript("OnUpdate", Movable_OnUpdate)
	Layout:PostDragStart(self)
end

local Movable_OnDragStop = function(self)
	if InCombatLockdown()then SV:AddonMessage(ERR_NOT_IN_COMBAT)return end 
	if SV.db.general.stickyFrames then 
		StickyStopMoving(self)
	else 
		self:StopMovingOrSizing()
	end 
	local pR, pT, pC = GrabUsableRegions()
	local cX, cY = self:GetCenter()
	local newAnchor;
	if cY >= (pT * 0.5) then 
		newAnchor = "TOP"; 
		cY = (-(pT - self:GetTop()))
	else 
		newAnchor = "BOTTOM"
		cY = self:GetBottom()
	end 
	if cX >= (pR * 0.66) then 
		newAnchor = newAnchor.."RIGHT"
		cX = self:GetRight() - pR 
	elseif cX <= (pR * 0.33) then 
		newAnchor = newAnchor.."LEFT"
		cX = self:GetLeft()
	else 
		cX = cX - pC 
	end 
	if self.positionOverride then 
		self.parent:ClearAllPoints()
		self.parent:ModPoint(self.positionOverride, self, self.positionOverride)
	end

	self:ClearAllPoints()
	self:ModPoint(newAnchor, SV.Screen, newAnchor, cX, cY)

	Layout:SaveMovable(self.name)

	if SVUI_LayoutPrecision then 
		Movable_OnMouseUp(self)
	end

	UpdateFrameTarget = nil;

	LayoutUpdateHandler:SetScript("OnUpdate", nil)
	LayoutUpdateHandler:Hide()

	if(self.postdrag ~= nil and type(self.postdrag) == "function") then 
		self:postdrag(Pinpoint(self))
	end 
	self:SetUserPlaced(false)
	Layout:PostDragStop(self)
end

local Movable_OnShow = function(self)
	self:SetBackdropBorderColor(0.5, 0.5, 0.5)
end
--[[ 
########################################################## 
CONSTRUCTS
##########################################################
]]--
function Layout:New(frame, moveName, title, snap, dragStopFunc, callbackOnEnter)
	if(not frame or (self.Frames[moveName] ~= nil)) then return end

	self.Frames[moveName] = {
		text = title,
		postdrag = dragStopFunc,
		point = CurrentPosition(frame)
	} 

	local movable = CreateFrame("Button", moveName, SV.Screen)
	movable:SetFrameLevel(frame:GetFrameLevel() + 1)
	movable:SetClampedToScreen(true)
	movable:SetWidth(frame:GetWidth())
	movable:SetHeight(frame:GetHeight())
	movable:SetFrameStrata("DIALOG")

	movable.parent = frame;
	movable.name = moveName;
	movable.textString = title;
	movable.postdrag = dragStopFunc;
	movable.snapOffset = snap or -2; 

	local anchor1, anchorParent, anchor2, xPos, yPos
	if(self.Anchors and self.Anchors[moveName] and (type(self.Anchors[moveName]) == "string")) then 
		anchor1, anchorParent, anchor2, xPos, yPos = split("\031", self.Anchors[moveName])
	else
		anchor1, anchorParent, anchor2, xPos, yPos = split("\031", CurrentPosition(frame))
	end 

	movable:SetPoint(anchor1, anchorParent, anchor2, xPos, yPos)
	movable:SetStyle("!_Frame", "Transparent")
	movable:SetAlpha(0.4)

	frame:SetScript("OnSizeChanged", Movable_OnSizeChanged)
	frame.Grip = movable;
	frame:ClearAllPoints()
	frame:SetPoint(anchor1, movable, anchor1, 0, 0)

	local mtext = movable:CreateFontString(nil, "OVERLAY")
	mtext:SetFontObject(SVUI_Font_Default)
	mtext:SetJustifyH("CENTER")
	mtext:SetPoint("CENTER")
	mtext:SetText(title or moveName)
	mtext:SetTextColor(0.5, 0.5, 0.5)

	movable:SetFontString(mtext)
	movable.text = mtext;

	movable:RegisterForDrag("LeftButton", "RightButton")
	movable:SetScript("OnMouseUp", Movable_OnMouseUp)
	movable:SetScript("OnDragStart", Movable_OnDragStart)
	movable:SetScript("OnDragStop", Movable_OnDragStop)
	movable:SetScript("OnShow", Movable_OnShow)

	movable:SetScript("OnEnter", Layout.Movable_OnEnter)
	movable:SetScript("OnMouseDown", Layout.Movable_OnMouseDown)
	movable:SetScript("OnLeave", Layout.Movable_OnLeave)

	movable:SetMovable(true)
	movable:Hide()

	if(dragStopFunc and (type(dragStopFunc) == "function") and callbackOnEnter) then 
		movable:RegisterEvent("PLAYER_ENTERING_WORLD")
		movable:SetScript("OnEvent", function(this, event)
			local point = Pinpoint(this)
			dragStopFunc(this, point)
			this:UnregisterAllEvents()
		end)
	end 

	Sticky.Frames[#Sticky.Frames + 1] = movable;
end

function Layout:HasMoved(frameName)
	if(self.Anchors and self.Anchors[frameName]) then 
		return true 
	else 
		return false 
	end 
end 

function Layout:SaveMovable(frameName)
	if((not _G[frameName]) or (not self.Anchors)) then return end 
	self.Anchors[frameName] = CurrentPosition(_G[frameName])
end

function Layout:ChangeSnapOffset(frameName, snapOffset)
	if(not _G[frameName]) then return end 
	_G[frameName].snapOffset = snapOffset or -2;
end 

function Layout:Add(frame, title, snapOffset, dragStopFunc, overrideName, callbackOnEnter)
	if(not frame or (not overrideName and not frame:GetName())) then return end
	local frameName = overrideName or frame:GetName()
	local moveName = ("%s_MOVE"):format(frameName) 
	self:New(frame, moveName, title, snapOffset, dragStopFunc, callbackOnEnter)
end

function Layout:Reset(request, bypass)
	if(request == "" or request == nil) then 
		for frameName, frameData in pairs(self.Frames) do 
			local frame = _G[frameName];
			if(frameData.point) then
				local u, v, w, x, y = split("\031", frameData.point)
				frame:ClearAllPoints()
				frame:SetPoint(u, v, w, x, y)
				if(not bypass) then
					if(frameData.postdrag and (type(frameData.postdrag) == "function")) then 
						frameData.postdrag(frame, Pinpoint(frame))
					end
				end
			end
			if(self.Anchors and self.Anchors[frameName]) then 
				self.Anchors[frameName] = nil 
			end 
		end
	else 
		for frameName, frameData in pairs(self.Frames) do
			if(frameData.point and (request == frameData.text)) then
				local frame = _G[frameName]
				local u, v, w, x, y = split("\031", frameData.point)
				frame:ClearAllPoints()
				frame:SetPoint(u, v, w, x, y) 
				if(not bypass) then
					if(frameData.postdrag and (type(frameData.postdrag) == "function")) then 
						frameData.postdrag(frame, Pinpoint(frame))
					end
				end
				if(self.Anchors and self.Anchors[frameName]) then 
					self.Anchors[frameName] = nil 
				end
				break
			end
		end 
	end 
end 

function Layout:SetPositions()
	for frameName, frameData in pairs(self.Frames) do 
		local frame = _G[frameName];
		local anchor1, parent, anchor2, x, y;
		if frame then
			if (self.Anchors and self.Anchors[frameName] and (type(self.Anchors[frameName]) == "string")) then 
				anchor1, parent, anchor2, x, y = split("\031", self.Anchors[frameName])
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, parent, anchor2, x, y)
			elseif(frameData.point) then 
				anchor1, parent, anchor2, x, y = split("\031", frameData.point)
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, parent, anchor2, x, y)
			end
		end
	end
end  

function Layout:Toggle(isConfigMode)
	if(InCombatLockdown()) then return end 
	local enabled = false;
	if(isConfigMode  ~= nil and isConfigMode  ~= "") then 
		self.ConfigurationMode = isConfigMode 
	end 

	if(not self.ConfigurationMode) then
		if(SV.OptionsLoaded) then 
			LibStub("AceConfigDialog-3.0"):Close(SV.NameID)
			GameTooltip:Hide()
			self.ConfigurationMode = true 
		else 
			self.ConfigurationMode = false 
		end 
	else
		self.ConfigurationMode = false
	end

	if(SVUI_Layout:IsShown()) then
		SVUI_Layout:Hide()
	else
		SVUI_Layout:Show()
		enabled = true
	end

	for frameName, _ in pairs(self.Frames)do 
		if(_G[frameName]) then 
			local movable = _G[frameName] 
			if(not enabled) then 
				movable:Hide() 
			else 
				movable:Show() 
			end 
		end 
	end
end
--[[ 
########################################################## 
ALIGNMENT GRAPH
##########################################################
]]--
local Graph = {}

function Graph:Toggle(enabled)
	if((not self.Grid) or (self.CellSize ~= SV.db.general.graphSize)) then
		self:UpdateAllReports()
	end
	if(not enabled) then
        self.Grid:Hide()
	else
		self.Grid:Show()
	end
end

function Graph:UpdateAllReports()
	local cellSize = SV.db.general.graphSize
	self.CellSize = cellSize

	self.Grid = CreateFrame('Frame', nil, UIParent)
	self.Grid:SetAllPoints(SV.Screen) 

	local size = 1 
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / cellSize
	local hStep = height / cellSize

	for i = 0, cellSize do 
		local tx = self.Grid:CreateTexture(nil, 'BACKGROUND') 
		if(i == cellSize / 2) then 
			tx:SetTexture(0, 1, 0, 0.8) 
		else 
			tx:SetTexture(0, 0, 0, 0.8) 
		end 
		tx:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", i*wStep - (size/2), 0) 
		tx:SetPoint('BOTTOMRIGHT', self.Grid, 'BOTTOMLEFT', i*wStep + (size/2), 0) 
	end

	height = GetScreenHeight()
	
	do
		local tx = self.Grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 1, 0, 0.8)
		tx:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", 0, -(height/2) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', self.Grid, 'TOPRIGHT', 0, -(height/2 + size/2))
	end
	
	for i = 1, floor((height/2)/hStep) do
		local tx = self.Grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0, 0.8)
		
		tx:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', self.Grid, 'TOPRIGHT', 0, -(height/2+i*hStep + size/2))
		
		tx = self.Grid:CreateTexture(nil, 'BACKGROUND') 
		tx:SetTexture(0, 0, 0, 0.8)
		
		tx:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
		tx:SetPoint('BOTTOMRIGHT', self.Grid, 'TOPRIGHT', 0, -(height/2-i*hStep + size/2))
	end

	self.Grid:Hide()
end

function Graph:Initialize()
	self:UpdateAllReports()
end
--[[ 
########################################################## 
SCRIPT AND EVENT HANDLERS
##########################################################
]]--
local XML_Layout_OnEvent = function(self)
	if self:IsShown() then 
		self:Hide()
		Layout:Toggle(true)
	end
end 

local XML_LayoutGridButton_OnClick = function(self)
	local enabled = true
	if(Graph.Grid and Graph.Grid:IsShown()) then
		enabled = false
	end

	Graph:Toggle(enabled)
end

local XML_LayoutLockButton_OnClick = function(self)
	Graph:Toggle()
	Layout:Toggle(true)
	if(SV.OptionsLoaded) then 
		LibStub("AceConfigDialog-3.0"):Open(SV.NameID)
	end 
end

local SVUI_LayoutPrecisionResetButton_OnClick = function(self)
	if(not CurrentFrameTarget) then return end
	local name = CurrentFrameTarget.name
	Layout:Reset(name)
end 

local XML_LayoutPrecisionInputX_EnterPressed = function(self)
	local current = tonumber(self:GetText())
	if(current) then 
		if(CurrentFrameTarget) then
			local xOffset, yOffset, anchor = CalculateOffsets()
			yOffset = tonumber(SVUI_LayoutPrecisionSetY.CurrentValue)
			CurrentFrameTarget:ClearAllPoints()
			CurrentFrameTarget:ModPoint(anchor, SVUIParent, anchor, current, yOffset)
			Layout:SaveMovable(CurrentFrameTarget.name)
		end
		self.CurrentValue = current
	end
	self:SetText(floor((self.CurrentValue or 0) + 0.5))
	EditBox_ClearFocus(self)
end

local XML_LayoutPrecisionInputY_EnterPressed = function(self)
	local current = tonumber(self:GetText())
	if(current) then 
		if(CurrentFrameTarget) then
			local xOffset, yOffset, anchor = CalculateOffsets()
			xOffset = tonumber(SVUI_LayoutPrecisionSetX.CurrentValue)
			CurrentFrameTarget:ClearAllPoints()
			CurrentFrameTarget:ModPoint(anchor, SVUIParent, anchor, xOffset, current)
			Layout:SaveMovable(CurrentFrameTarget.name)
		end
		self.CurrentValue = current
	end
	self:SetText(floor((self.CurrentValue or 0) + 0.5))
	EditBox_ClearFocus(self)
end
--[[ 
########################################################## 
DRAGGABLES
##########################################################
]]--
local Dragger = CreateFrame("Frame", nil);
Dragger.Frames = {};

local function SetDraggablePoint(frame, data)
	if((not frame) or (not data)) then return; end
	local frameName = frame:GetName()
	local point = Dragger.Frames[frameName];
	if(point and (type(point) == "string") and (point ~= 'TBD')) then
		local anchor1, parent, anchor2, x, y = split("\031", point);
		data.cansetpoint = true;
		data.snapped = false;
		frame:ClearAllPoints();
		frame:SetPoint(anchor1, parent, anchor2, x, y);
	end
end

local function SaveCurrentPosition(frame)
	if not frame then return end 
	local frameName = frame:GetName()
	local anchor1, parent, anchor2, x, y = frame:GetPoint()
	if((not anchor1) or (not anchor2) or (not x) or (not y)) then
		Dragger.Frames[frameName] = "TBD";
	else
		local parentName
		if(not parent or (parent and (not parent:GetName()))) then 
			parentName = "UIParent" 
		else
			parentName = parent:GetName()
		end
		Dragger.Frames[frameName] = ("%s\031%s\031%s\031%d\031%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y))
	end
end

--[[SCRIPT AND EVENT HANDLERS]]--

local DraggerFrame_OnDragStart = function(self)
	if(not self:IsMovable()) then return; end 
	self:StartMoving();
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = true;
		data.snapped = false;
		data.canupdate = false;
	end
end

local DraggerFrame_OnDragStop = function(self)
	if(not self:IsMovable()) then return; end
	self:StopMovingOrSizing();
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = false;
		data.snapped = false;
		data.canupdate = true;
		SaveCurrentPosition(self);
	end
end

local _hook_DraggerFrame_OnShow = function(self)
	if(InCombatLockdown() or (not self:IsMovable())) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.snapped)) then
		SetDraggablePoint(self, data)
	end
end

local _hook_DraggerFrame_OnHide = function(self)
	if(InCombatLockdown() or (not self:IsMovable())) then return; end
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = false;
		data.snapped = false;
		data.canupdate = true;
	end
end

local _hook_DraggerFrame_OnUpdate = function(self)
	if(InCombatLockdown()) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.moving) and (not data.snapped)) then
		SetDraggablePoint(self, data)
	end
end

local _hook_DraggerFrame_OnSetPoint = function(self)
	if(not self:IsMovable()) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.moving)) then
		if(not data.cansetpoint) then
			data.snapped = true;
			data.canupdate = false;
		end
	end
end

local _hook_UIParent_ManageFramePositions = function()
	for frameName, point in pairs(Dragger.Frames) do
		local data = UIPanels[frameName]
		if(data and (not data.snapped)) then
			SetDraggablePoint(_G[frameName], data)
		end
	end
end

local DraggerEventHandler = function(self, event, ...)
	if(InCombatLockdown()) then return end

	local noMoreChanges = true;
	local allCentered = SV.db.screen.multiMonitor

	for frameName, data in pairs(UIPanels) do
		if(not self.Frames[frameName] or (self.Frames[frameName] and type(self.Frames[frameName]) ~= 'string')) then
			self.Frames[frameName] = 'TBD'
			noMoreChanges = false; 
		end
		if(not data.initialized) then 
			local frame = _G[frameName]
			if(frame) then
				frame:EnableMouse(true)

				if(frameName == "LFGDungeonReadyPopup") then 
					LFGDungeonReadyDialog:EnableMouse(false)
				end

				frame:SetMovable(true)
				frame:RegisterForDrag("LeftButton")
				frame:SetClampedToScreen(true)

				if(allCentered) then
					frame:ClearAllPoints()
					frame:SetPoint('TOP', SV.Screen, 'TOP', 0, -180)
					data.centered = true
				end

				if(self.Frames[frameName] == 'TBD') then
					SaveCurrentPosition(frame);
				end

				data.canupdate = true

				frame:SetScript("OnDragStart", DraggerFrame_OnDragStart)
				frame:SetScript("OnDragStop", DraggerFrame_OnDragStop)

				frame:HookScript("OnUpdate", _hook_DraggerFrame_OnUpdate)
				hooksecurefunc(frame, "SetPoint", _hook_DraggerFrame_OnSetPoint)

				if(SV.db.general.saveDraggable) then
					frame:HookScript("OnShow", _hook_DraggerFrame_OnShow)
					frame:HookScript("OnHide", _hook_DraggerFrame_OnHide)
				end

				data.initialized = true
			end
			noMoreChanges = false;
		end
	end

	if(noMoreChanges) then
		self.EventsActive = false;
		self:UnregisterEvent("ADDON_LOADED")
		self:UnregisterEvent("LFG_UPDATE")
		self:UnregisterEvent("ROLE_POLL_BEGIN")
		self:UnregisterEvent("READY_CHECK")
		self:UnregisterEvent("UPDATE_WORLD_STATES")
		self:UnregisterEvent("WORLD_STATE_TIMER_START")
		self:UnregisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
		self:SetScript("OnEvent", nil)
	end
end

--[[METHODS]]--

function Dragger:New(frameName)
	if(not UIPanels[frameName]) then 
		UIPanels[frameName] = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
		if(not self.EventsActive) then
			self:RegisterEvent("ADDON_LOADED")
			self:RegisterEvent("LFG_UPDATE")
			self:RegisterEvent("ROLE_POLL_BEGIN")
			self:RegisterEvent("READY_CHECK")
			self:RegisterEvent("UPDATE_WORLD_STATES")
			self:RegisterEvent("WORLD_STATE_TIMER_START")
			self:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
			self:SetScript("OnEvent", DraggerEventHandler)
			self.EventsActive = true;
		end
	end
end

function Dragger:SetPositions()
	for frameName, point in pairs(Dragger.Frames) do
		local data = UIPanels[frameName]
		if(data and (not data.snapped)) then
			SetDraggablePoint(_G[frameName], point, data)
		end
	end
end

function Dragger:Reset()
	if(SV.db.general.saveDraggable) then
		for frameName, data in pairs(UIPanels) do
			if(SV.private.Draggables[frameName]) then
				SV.private.Draggables[frameName] = nil
			end
			data.initialized = nil
		end
		self.Frames = SV.private.Draggables
	else
		for frameName, data in pairs(UIPanels) do
			if(self.Frames[frameName]) then
				self.Frames[frameName] = nil
			end
			data.initialized = nil
		end
	end

	if(not self.EventsActive) then
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("LFG_UPDATE")
		self:RegisterEvent("ROLE_POLL_BEGIN")
		self:RegisterEvent("READY_CHECK")
		self:RegisterEvent("UPDATE_WORLD_STATES")
		self:RegisterEvent("WORLD_STATE_TIMER_START")
		self:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
		self:SetScript("OnEvent", DraggerEventHandler)
		self.EventsActive = true;
	end

	ReloadUI() 
end

local function InitializeMovables()
	Layout.Anchors = SV.db.LAYOUT or {}
	
	SVUI_Layout:SetStyle("!_Frame")
	SVUI_Layout:SetPanelColor("yellow")
	SVUI_Layout:RegisterForDrag("LeftButton")
	SVUI_Layout:RegisterEvent("PLAYER_REGEN_DISABLED")
	SVUI_Layout:SetScript("OnEvent", XML_Layout_OnEvent)

	SVUI_LayoutGridButton:SetScript("OnClick", XML_LayoutGridButton_OnClick)
	SVUI_LayoutLockButton:SetScript("OnClick", XML_LayoutLockButton_OnClick)

	SVUI_LayoutPrecision:SetStyle("Frame", "Transparent")
	SVUI_LayoutPrecision:EnableMouse(true)

	SVUI_LayoutPrecisionSetX:SetStyle("Editbox")
	SVUI_LayoutPrecisionSetX.CurrentValue = 0;
	SVUI_LayoutPrecisionSetX:SetScript("OnEnterPressed", XML_LayoutPrecisionInputX_EnterPressed)

	SVUI_LayoutPrecisionSetY:SetStyle("Editbox")
	SVUI_LayoutPrecisionSetY.CurrentValue = 0;
	SVUI_LayoutPrecisionSetY:SetScript("OnEnterPressed", XML_LayoutPrecisionInputY_EnterPressed)

	SVUI_LayoutPrecisionUpButton:SetStyle("Button")
	SVUI_LayoutPrecisionDownButton:SetStyle("Button")
	SVUI_LayoutPrecisionLeftButton:SetStyle("Button")
	SVUI_LayoutPrecisionRightButton:SetStyle("Button")
	
	Layout:SetPositions()

	if(SV.db.general.saveDraggable) then
		SV.private.Draggables = SV.private.Draggables or {}
		Dragger.Frames = SV.private.Draggables
	else
		SV.private.Draggables = {}
		Dragger.Frames = {}
	end

	Dragger.EventsActive = true

	Dragger:RegisterEvent("ADDON_LOADED")
	Dragger:RegisterEvent("LFG_UPDATE")
	Dragger:RegisterEvent("ROLE_POLL_BEGIN")
	Dragger:RegisterEvent("READY_CHECK")
	Dragger:RegisterEvent("UPDATE_WORLD_STATES")
	Dragger:RegisterEvent("WORLD_STATE_TIMER_START")
	Dragger:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")

	DraggerEventHandler(Dragger)
	Dragger:SetScript("OnEvent", DraggerEventHandler)

	if(SV.db.general.saveDraggable) then
		hooksecurefunc("UIParent_ManageFramePositions", _hook_UIParent_ManageFramePositions)
	end
end

SVUI_Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-OFF]]);

SV.Events:On("LOAD_ALL_WIDGETS", "InitializeMovables", InitializeMovables);

SV.SystemAlert["RESETBLIZZARD_CHECK"] = {
	text = L["Are you sure you want to all draggable Blizzard frames to their original positions? This will reload your UI."], 
	button1 = ACCEPT, 
	button2 = CANCEL, 
	OnAccept = function(a)Dragger:Reset()end, 
	timeout = 0, 
	whileDead = 1
};

SV.SystemAlert["RESETLAYOUT_CHECK"] = {
	text = L["Are you sure you want to all movable frames to their original positions?"], 
	button1 = ACCEPT, 
	button2 = CANCEL, 
	OnAccept = function(a) Layout:Reset() end, 
	timeout = 0, 
	whileDead = 1
};