--[[ MODIFIED FOR SVUI BY SVUILUNCH ]]--

--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor;
local huge          = math.huge;
local min 			= math.min;
--TABLE
local table 		= _G.table;
local tsort 		= table.sort;
--BLIZZARD API
local GetTime       = _G.GetTime;
local CreateFrame   = _G.CreateFrame;
local UnitAura      = _G.UnitAura;
local UnitIsFriend  = _G.UnitIsFriend;
local GameTooltip  	= _G.GameTooltip;
local DebuffTypeColor  = _G.DebuffTypeColor;

local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, 'oUF_AuraBars was unable to locate oUF install.')

local function Round(number, decimalPlaces)
	if decimalPlaces and decimalPlaces > 0 then
		local mult = 10^decimalPlaces
		return floor((number * mult) + .5) / mult
	end
	return floor(number + .5)
end

local DAY, HOUR, MINUTE = 86400, 3600, 60
local function FormatTime(s)
	if s < MINUTE then
		return ("%.1fs"):format(s)
	elseif s < HOUR then
		return ("%dm %ds"):format(s/60%60, s%60)
	elseif s < DAY then
		return ("%dh %dm"):format(s/(60*60), s/60%60)
	else
		return ("%dd %dh"):format(s/DAY, (s / HOUR) - (floor(s/DAY) * 24))
	end
end

local function UpdateTooltip(self)
	GameTooltip:SetUnitAura(self.__unit, self:GetParent().aura.name, self:GetParent().aura.rank, self:GetParent().aura.filter)
end

local function OnEnter(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function OnLeave(self)
	GameTooltip:Hide()
end

local function SetAnchors(self)
	local bars = self.bars

	for index = 1, #bars do
		local frame = bars[index]
		local anchor = frame.anchor
		frame:SetHeight(self.auraBarHeight or 20)
		frame.statusBar.iconHolder:ModSize(frame:GetHeight())			
		frame:SetWidth((self.auraBarWidth or self:GetWidth()) - (frame:GetHeight() + (self.gap or 0)))	
		frame:ClearAllPoints()
		if self.down == true then
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', (frame:GetHeight() + (self.gap or 0) ), -1)
			else
				frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-self.spacing or 0))
			end
		else
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', (frame:GetHeight() + (self.gap or 0)), 1)
			else
				frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, (self.spacing or 0))
			end
		end
	end
end

local function SetBackground(frame)
	local btop = frame:CreateTexture(nil, "OVERLAY")
	btop:SetTexture(0, 0, 0)
	btop:SetPoint("TOPLEFT")
	btop:SetPoint("TOPRIGHT")
	btop:SetHeight(1)
	local bbottom = frame:CreateTexture(nil, "OVERLAY")
	bbottom:SetTexture(0, 0, 0)
	bbottom:SetPoint("BOTTOMLEFT")
	bbottom:SetPoint("BOTTOMRIGHT")
	bbottom:SetHeight(1)
	local bright = frame:CreateTexture(nil, "OVERLAY")
	bright:SetTexture(0, 0, 0)
	bright:SetPoint("TOPRIGHT")
	bright:SetPoint("BOTTOMRIGHT")
	bright:SetWidth(1)
	local bleft = frame:CreateTexture(nil, "OVERLAY")
	bleft:SetTexture(0, 0, 0)
	bleft:SetPoint("TOPLEFT")
	bleft:SetPoint("BOTTOMLEFT")
	bleft:SetWidth(1)
    frame:SetBackdrop({
        bgFile = [[Interface\BUTTONS\WHITE8X8]], 
        edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
        tile = false, 
        tileSize = 0, 
        edgeSize = 1, 
        insets = 
        {
            left = 0, 
            right = 0, 
            top = 0, 
            bottom = 0, 
        }, 
    })
    frame:SetBackdropColor(0,0,0,0.5)
    frame:SetBackdropBorderColor(0,0,0)
end

local function CreateAuraBar(oUF, anchor)
	local auraBarParent = oUF.AuraBars
	
	local frame = CreateFrame("Frame", nil, auraBarParent)
	frame:SetHeight(auraBarParent.auraBarHeight or 20)
	frame:SetWidth((auraBarParent.auraBarWidth or auraBarParent:GetWidth()) - (frame:GetHeight() + (auraBarParent.gap or 0)))
	frame.anchor = anchor
	SetBackground(frame)
	
	-- the main bar
	local statusBar = CreateFrame("StatusBar", nil, frame)
	statusBar:SetStatusBarTexture(auraBarParent.barTexture or [[Interface\TargetingFrame\UI-StatusBar]])
	statusBar:SetAlpha(auraBarParent.fgalpha or 1)
	statusBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
	statusBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
	frame.statusBar = statusBar
	
	if auraBarParent.down == true then
		if auraBarParent == anchor then -- Root frame so indent for icon
			frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', (frame:GetHeight() + (auraBarParent.gap or 0) ), -1)
		else
			frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-auraBarParent.spacing or 0))
		end
	else
		if auraBarParent == anchor then -- Root frame so indent for icon
			frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', (frame:GetHeight() + (auraBarParent.gap or 0)), 1)
		else
			frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, (auraBarParent.spacing or 0))
		end
	end
	
	local spark = statusBar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:SetWidth(12);
	spark:SetBlendMode("ADD");
	spark:SetPoint('CENTER', statusBar:GetStatusBarTexture(), 'RIGHT')		
	statusBar.spark = spark
	
	local holder = CreateFrame('Button', nil, statusBar)
	holder:SetHeight(frame:GetHeight())
	holder:SetWidth(frame:GetHeight())
	holder:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -auraBarParent.gap, 0)
	SetBackground(holder)
	holder.__unit = oUF.unit
	holder:SetScript('OnEnter', OnEnter)
	holder:SetScript('OnLeave', OnLeave)
	holder.UpdateTooltip = UpdateTooltip
	statusBar.iconHolder = holder

	statusBar.icon = statusBar.iconHolder:CreateTexture(nil, 'OVERLAY')
	statusBar.icon:SetTexCoord(.1, .9, .1, .9)
	statusBar.icon:SetPoint("TOPLEFT", statusBar.iconHolder, "TOPLEFT", 1, -1)
	statusBar.icon:SetPoint("BOTTOMRIGHT", statusBar.iconHolder, "BOTTOMRIGHT", -1, 1)

	if auraBarParent.PostCreateBar then
		auraBarParent.PostCreateBar(statusBar)
	else
		statusBar.spelltime = statusBar:CreateFontString(nil, 'ARTWORK')
		statusBar.spelltime:SetFont(auraBarParent.timeFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.textSize or 10, auraBarParent.textOutline or "NONE")
		statusBar.spelltime:SetTextColor(1 ,1, 1)
		statusBar.spelltime:SetShadowOffset(1, -1)
	  	statusBar.spelltime:SetShadowColor(0, 0, 0)
		statusBar.spelltime:SetJustifyH'RIGHT'
		statusBar.spelltime:SetJustifyV'CENTER'
		statusBar.spelltime:SetPoint'RIGHT'

		statusBar.spellname = statusBar:CreateFontString(nil, 'ARTWORK')
		statusBar.spellname:SetFont(auraBarParent.textFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.textSize or 10, auraBarParent.textOutline or "NONE")
		statusBar.spellname:SetTextColor(1, 1, 1)
		statusBar.spellname:SetShadowOffset(1, -1)
	  	statusBar.spellname:SetShadowColor(0, 0, 0)
		statusBar.spellname:SetJustifyH'LEFT'
		statusBar.spellname:SetJustifyV'CENTER'
		statusBar.spellname:SetPoint'LEFT'
		statusBar.spellname:SetPoint('RIGHT', statusBar.spelltime, 'LEFT')
	end
	
	return frame
end

local function UpdateBars(auraBars)
	local bars = auraBars.bars
	local timenow = GetTime()

	for index = 1, #bars do
		local frame = bars[index]
		local bar = frame.statusBar
		if not frame:IsVisible() then
			break
		end
		if bar.aura.noTime then
			bar.spelltime:SetText()
			bar.spark:Hide()
		else
			local timeleft = bar.aura.expirationTime - timenow
			bar:SetValue(timeleft)
			bar.spelltime:SetText(FormatTime(timeleft))
			if auraBars.spark == true then
				bar.spark:Show()
			end
		end
	end
end

local function DefaultFilter(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate)
	if unitCaster == 'player' and not shouldConsolidate then
		return true
	end
end

local sort = function(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa > compb
end


local function Update(self, event, unit)
	if self.unit ~= unit then return end
	local auraBars = self.AuraBars
	local helpOrHarm
	local isFriend = UnitIsFriend('player', unit)
	
	if auraBars.friendlyAuraType and auraBars.enemyAuraType then
		if isFriend then
			helpOrHarm = auraBars.friendlyAuraType
		else
			helpOrHarm = auraBars.enemyAuraType
		end
	else
		helpOrHarm = isFriend and 'HELPFUL' or 'HARMFUL'
	end

	-- Create a table of auras to display
	local auras = {}
	local lastAuraIndex = 0
	for index = 1, 40 do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, helpOrHarm);

		if auraBars.forceShow then
			spellID = 47540
			name, rank, icon = GetSpellInfo(spellID)
			count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 60, 'player', nil, nil, nil, nil
		end

		if not name then break end

		local show = true
		if not auraBars.forceShow then
			show = (auraBars.filter or DefaultFilter)(self, unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID)
		else
			show = lastAuraIndex < 5;
		end
		
		if (show) then
			lastAuraIndex = lastAuraIndex + 1
			auras[lastAuraIndex] = {}
			auras[lastAuraIndex].spellID = spellID
			auras[lastAuraIndex].name = name
			auras[lastAuraIndex].rank = rank
			auras[lastAuraIndex].icon = icon
			auras[lastAuraIndex].count = count
			auras[lastAuraIndex].debuffType = debuffType
			auras[lastAuraIndex].duration = duration
			auras[lastAuraIndex].expirationTime = expirationTime
			auras[lastAuraIndex].unitCaster = unitCaster
			auras[lastAuraIndex].isStealable = isStealable
			auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
			auras[lastAuraIndex].filter = helpOrHarm
			auras[lastAuraIndex].shouldConsolidate = shouldConsolidate
		end
	end

	if auraBars.sort then
		tsort(auras, type(auraBars.sort) == 'function' and auraBars.sort or sort)
	end

	-- Show and configure bars for buffs/debuffs.
	local bars = auraBars.bars
	if lastAuraIndex == 0 then
		auraBars:SetHeight(1)
	end
	
	for index = 1 , lastAuraIndex do
		if auraBars:GetWidth() == 0 then break; end
		local aura = auras[index]
		local frame = bars[index]
		
		if not frame then
			frame = (auraBars.CreateAuraBar or CreateAuraBar) (self, index == 1 and auraBars or bars[index - 1])
			bars[index] = frame
		end

		if index == lastAuraIndex then
			if(auraBars.down and (auraBars:GetTop() and frame:GetBottom())) then
				auraBars:SetHeight(auraBars:GetTop() - frame:GetBottom())
			elseif(frame:GetTop() and auraBars:GetBottom()) then
				auraBars:SetHeight(frame:GetTop() - auraBars:GetBottom())
			else
				auraBars:ModHeight(20)
			end
		end
		
		local bar = frame.statusBar
		frame.index = index
		
		-- Backup the details of the aura onto the bar, so the OnUpdate function can use it
		bar.aura = aura

		-- Configure
		if bar.aura.noTime then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		else
			if auraBars.scaleTime then
				local maxvalue = min(auraBars.scaleTime, bar.aura.duration)
				bar:SetMinMaxValues(0, maxvalue)
				bar:SetWidth(
					( maxvalue / auraBars.scaleTime ) *
					(	( auraBars.auraBarWidth or auraBars:GetWidth() ) -
						( bar:GetHeight() + (auraBars.gap or 0) ) ) ) 				-- icon size + gap
			else
				bar:SetMinMaxValues(0, bar.aura.duration)
			end
			bar:SetValue(bar.aura.expirationTime - GetTime())
		end

		bar.icon:SetTexture(bar.aura.icon)

		bar.spellname:SetText(bar.aura.count > 1 and format("%s [%d]", bar.aura.name, bar.aura.count) or bar.aura.name)
		bar.spelltime:SetText(not bar.noTime and FormatTime(bar.aura.expirationTime-GetTime()))

		-- Colour bars
		local r, g, b = .2, .6, 1 -- Colour for buffs
		if auraBars.buffColor then
			r, g, b = unpack(auraBars.buffColor)
		end		
		
		if helpOrHarm == 'HARMFUL' then
			local debuffType = bar.aura.debuffType and bar.aura.debuffType or 'none'
			
			r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
			if auraBars.debuffColor then
				r, g, b = unpack(auraBars.debuffColor)
			else
				if debuffType == 'none' and auraBars.defaultDebuffColor then
					r, g, b = unpack(auraBars.defaultDebuffColor)
				end
			end			
		end
		bar:SetStatusBarColor(r, g, b)
		frame:Show()
	end

	-- Hide unused bars.
	for index = lastAuraIndex + 1, #bars do
		bars[index]:Hide()
	end
	
	if auraBars.PostUpdate then
		auraBars:PostUpdate(event, unit)
	end
end

local function Enable(self)
	if self.AuraBars then
		self:RegisterEvent('UNIT_AURA', Update)
		self.AuraBars:SetHeight(1)
		self.AuraBars.bars = self.AuraBars.bars or {}
		self.AuraBars.SetAnchors = SetAnchors
		self.AuraBars:SetScript('OnUpdate', UpdateBars)
		return true
	end
end

local function Disable(self)
	local auraFrame = self.AuraBars
	if auraFrame then
		self:UnregisterEvent('UNIT_AURA', Update)
		auraFrame:SetScript('OnUpdate', nil)
	end
end

oUF:AddElement('AuraBars', Update, Enable, Disable)