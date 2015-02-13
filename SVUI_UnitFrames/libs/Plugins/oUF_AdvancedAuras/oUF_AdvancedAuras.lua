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
local math          = math;
local floor         = math.floor
local ceil         	= math.ceil
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
assert(oUF, 'oUF_Auras was unable to locate oUF install.')

local DAY, HOUR, MINUTE = 86400, 3600, 60;
local VISIBLE = 1;
local HIDDEN = 0;

local function FormatTime(seconds)
	if seconds < MINUTE then
		return ("%.1fs"):format(seconds)
	elseif seconds < HOUR then
		return ("%dm %ds"):format(seconds/60%60, seconds%60)
	elseif seconds < DAY then
		return ("%dh %dm"):format(seconds/(60*60), seconds/60%60)
	else
		return ("%dd %dh"):format(seconds/DAY, (seconds / HOUR) - (floor(seconds/DAY) * 24))
	end
end

local UpdateAuraTimer = function(self, elapsed)
	self.expiration = self.expiration - elapsed;

	if(self.nextUpdate > 0) then 
		self.nextUpdate = self.nextUpdate - elapsed;
		return;
	end

	if(self.expiration <= 0) then 
		self:SetScript("OnUpdate", nil)
		self.text:SetText('')
		return;
	end

	local expires = self.expiration;
	local calc, timeLeft = 0, 0;
	local timeFormat;
	if expires < 60 then 
		if expires >= 4 then
			timeLeft = floor(expires)
			timeFormat = "|cffffff00%d|r"
			self.nextUpdate = 0.51
		else
			timeLeft = expires
			timeFormat = "|cffff0000%.1f|r"
			self.nextUpdate = 0.051
		end 
	elseif expires < 3600 then
		timeFormat = "|cffffffff%d|r|cffCC8811m|r"
		timeLeft = ceil(expires / 60);
		calc = floor((expires / 60) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
	elseif expires < 86400 then
		timeFormat = "|cff66ffff%d|r|cffAA5511h|r"
		timeLeft = ceil(expires / 3600);
		calc = floor((expires / 3600) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
	else
		timeFormat = "|cff6666ff%d|r|cff991100d|r"
		timeLeft = ceil(expires / 86400);
		calc = floor((expires / 86400) + 0.5);
		self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 86400);
	end

	self.text:SetFormattedText(timeFormat, timeLeft)
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(self.parent.__owner.unit, self:GetID(), self.filter)
end

local OnLeave = function()
	GameTooltip:Hide()
end

local sort = function(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	if(compa and compb) then
		return compa > compb
	end
end

local genericFilter = function(self, frame, _, name, _, _, _, _, _, _, caster, _, shouldConsolidate)
	local isPlayer

	if(caster == 'player' or caster == 'vehicle') then
		isPlayer = true
	end

	if((self.onlyShowPlayer and isPlayer) or (not self.onlyShowPlayer and name)) then
		if(frame) then
			frame.isPlayer = isPlayer
			frame.owner = caster
		end
		if(not shouldConsolidate) then
			return true
		end
	end
end

local function SetBarAnchors(self)
	local bars = self.Bars

	for index = 1, #bars do
		local frame = bars[index]
		local anchor = frame.anchor
		frame:SetHeight(self.barHeight or 16)
		frame.iconHolder:SetWidth(frame:GetHeight())			
		frame:SetWidth(self:GetWidth())	
		frame:ClearAllPoints()
		if self.down == true then
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('TOPLEFT', anchor, 'TOPLEFT', 0, -1)
			else
				frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-self.spacing or 0))
			end
		else
			if self == anchor then -- Root frame so indent for icon
				frame:SetPoint('BOTTOMLEFT', anchor, 'BOTTOMLEFT', 0, 1)
			else
				frame:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', 0, (self.spacing or 0))
			end
		end
	end
end

--[[ BAR SPECIFIC ]]--

local Bars_OnUpdate = function(self)
	local timenow = GetTime()
	for index = 1, #self do
		local frame = self[index]
		local bar = frame.statusBar
		if not frame:IsVisible() then
			break
		end
		if frame.noTime then
			bar.spelltime:SetText()
			bar.spark:Hide()
		else
			local timeleft = frame.expirationTime - timenow
			bar:SetValue(timeleft)
			bar.spelltime:SetText(FormatTime(timeleft))
			if self.spark == true then
				bar.spark:Show()
			end
		end
	end
end

local CreateAuraBar = function(self, parent, height)	
	local frame = CreateFrame("Button", nil, self)
	frame:SetHeight(height)
	frame:SetWidth(self:GetWidth())
	frame.parent = self

	frame:SetScript('OnEnter', OnEnter)
	frame:SetScript('OnLeave', OnLeave)
	frame.UpdateTooltip = UpdateTooltip

	local iconHolder = CreateFrame('Frame', nil, frame)
	iconHolder:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
	iconHolder:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, 0)
	iconHolder:SetWidth(frame:GetHeight())
	iconHolder:SetBackdrop({
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
    iconHolder:SetBackdropColor(0,0,0,0.5)
    iconHolder:SetBackdropBorderColor(0,0,0)
	frame.iconHolder = iconHolder

	frame.icon = frame.iconHolder:CreateTexture(nil, 'BORDER')
	frame.icon:SetTexCoord(.1, .9, .1, .9)
	frame.icon:SetPoint("TOPLEFT", frame.iconHolder, "TOPLEFT", 1, -1)
	frame.icon:SetPoint("BOTTOMRIGHT", frame.iconHolder, "BOTTOMRIGHT", -1, 1)

	frame.count = frame.iconHolder:CreateFontString(nil, "OVERLAY")
	frame.count:SetFontObject(NumberFontNormal)
	frame.count:SetPoint("BOTTOMRIGHT", frame.iconHolder, "BOTTOMRIGHT", -1, 0)

	local barHolder = CreateFrame('Frame', nil, frame)
	barHolder:SetPoint('BOTTOMLEFT', frame.iconHolder, 'BOTTOMRIGHT', self.gap, 0)
	barHolder:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
	barHolder:SetBackdrop({
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
    barHolder:SetBackdropColor(0,0,0,0.5)
    barHolder:SetBackdropBorderColor(0,0,0)
	frame.barHolder = barHolder
	
	-- the main bar
	frame.statusBar = CreateFrame("StatusBar", nil, frame.barHolder)
	frame.statusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	frame.statusBar:SetAlpha(self.fgalpha or 1)
	frame.statusBar:SetPoint("TOPLEFT", frame.barHolder, "TOPLEFT", 1, -1)
	frame.statusBar:SetPoint("BOTTOMRIGHT", frame.barHolder, "BOTTOMRIGHT", -1, 1)

	local spark = frame.statusBar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:SetWidth(12);
	spark:SetBlendMode("ADD");
	spark:SetPoint('CENTER', frame.statusBar:GetStatusBarTexture(), 'RIGHT')		
	frame.statusBar.spark = spark
	
	if self.down == true then
		if self == parent then -- Root frame so indent for icon
			frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, -1)
		else
			frame:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 0, (-self.spacing or 0))
		end
	else
		if self == parent then -- Root frame so indent for icon
			frame:SetPoint('BOTTOMLEFT', parent, 'BOTTOMLEFT', 0, 1)
		else
			frame:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, (self.spacing or 0))
		end
	end

	if self.PostCreateBar then
		self.PostCreateBar(frame)
	else
		frame.statusBar.spelltime = frame.statusBar:CreateFontString(nil, 'ARTWORK')
		frame.statusBar.spelltime:SetFont(self.timeFont or [[Fonts\FRIZQT__.TTF]], self.textSize or 10, self.textOutline or "NONE")
		frame.statusBar.spelltime:SetTextColor(1 ,1, 1)
		frame.statusBar.spelltime:SetShadowOffset(1, -1)
	  	frame.statusBar.spelltime:SetShadowColor(0, 0, 0)
		frame.statusBar.spelltime:SetJustifyH'RIGHT'
		frame.statusBar.spelltime:SetJustifyV'CENTER'
		frame.statusBar.spelltime:SetPoint'RIGHT'

		frame.statusBar.spellname = frame.statusBar:CreateFontString(nil, 'ARTWORK')
		frame.statusBar.spellname:SetFont(self.textFont or [[Fonts\FRIZQT__.TTF]], self.textSize or 10, self.textOutline or "NONE")
		frame.statusBar.spellname:SetTextColor(1, 1, 1)
		frame.statusBar.spellname:SetShadowOffset(1, -1)
	  	frame.statusBar.spellname:SetShadowColor(0, 0, 0)
		frame.statusBar.spellname:SetJustifyH'LEFT'
		frame.statusBar.spellname:SetJustifyV'CENTER'
		frame.statusBar.spellname:SetPoint'LEFT'
		frame.statusBar.spellname:SetPoint('RIGHT', frame.statusBar.spelltime, 'LEFT')
	end
	
	return frame
end

local UpdateAuraBar = function(self, auras, unit, index, offset, filter, isDebuff, visible)
	if not unit then return; end

	local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter);

	if self.forceShow then
		spellID = 47540
		name, rank, texture = GetSpellInfo(spellID)
		count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 60, 'player', nil, nil, nil, nil
	end

	if(name) then
		local n = visible + offset + 1
		local this = auras[n]
		if(not this) then
			this = (self.CreateAuraBar or CreateAuraBar) (self, n == 1 and self or auras[n - 1], self.barHeight)
			auras[n] = this
		end

		local show = true
		if not self.forceShow then
			show = (self.CustomFilter or genericFilter) (self, this, unit, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)
		end

		if(show) then
			this:SetID(index)
			this.icon:SetTexture(texture)
			this.spellID = spellID
			this.name = name
			this.count:SetText((count > 1 and count))
			this.duration = duration
			this.expirationTime = timeLeft
			this.owner = caster
			this.noTime = (duration == 0 and timeLeft == 0)
			this.filter = filter

			local bar = this.statusBar

			if this.noTime then
				bar:SetMinMaxValues(0, 1)
				bar:SetValue(1)
			else
				if self.scaleTime then
					local maxvalue = min(self.scaleTime, this.duration)
					bar:SetMinMaxValues(0, maxvalue)
					bar:SetWidth(
						( maxvalue / self.scaleTime ) *
						(	( self.auraBarWidth or self:GetWidth() ) -
							( bar:GetHeight() + (self.gap or 0) ) ) ) 
				else
					bar:SetMinMaxValues(0, this.duration)
				end
				bar:SetValue(this.expirationTime - GetTime())
			end

			bar.spellname:SetText(count > 1 and format("%s [%d]", this.name, count) or this.name)
			bar.spelltime:SetText(not this.noTime and FormatTime(this.expirationTime-GetTime()))

			this:Show()

			if self.PostBarUpdate then
				self:PostBarUpdate(filter, dtype, bar)
			else
				bar:SetStatusBarColor(.2, .6, 1)
			end

			return VISIBLE
		else
			return HIDDEN
		end
	end
end

local SetAuraBars = function(self, unit, filter, limit, isDebuff, offset, dontHide)
	if not unit then return; end

	if(not offset) then offset = 0 end
	local index = 1
	local visible = 0
	local auras = self.Bars

	while(visible < limit) do
		local result = UpdateAuraBar(self, auras, unit, index, offset, filter, isDebuff, visible)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		end

		index = index + 1
	end

	if(not dontHide) then
		for i = visible + offset + 1, #auras do
			auras[i]:Hide()
		end
	end

	if(visible == 0) then
		self:SetHeight(1)
	else
		--local height = (self.spacing + self.barHeight) * visible
		--self:SetHeight(height)
		local frame = auras[visible]
		if(self.down and (self:GetTop() and frame:GetBottom())) then
			self:SetHeight(self:GetTop() - frame:GetBottom())
		elseif(frame:GetTop() and self:GetBottom()) then
			self:SetHeight(frame:GetTop() - self:GetBottom())
		else
			self:SetHeight(20)
		end
	end

	if(self.PostUpdateBars) then self:PostUpdateBars(unit) end
end

--[[ ICON SPECIFIC ]]--

local createAuraIcon = function(icons, index)
	local button = CreateFrame("Button", nil, icons)
	button:EnableMouse(true)
	button:RegisterForClicks'RightButtonUp'

	button:SetWidth(icons.size or 16)
	button:SetHeight(icons.size or 16)

	local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cd:SetAllPoints(button)

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
	overlay:SetAllPoints(button)
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	button.overlay = overlay

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-Stealable]]
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode'ADD'
	button.stealable = stealable

	button.UpdateTooltip = UpdateTooltip
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)

	tinsert(icons, button)

	button.parent = icons
	button.icon = icon
	button.count = count
	button.cd = cd

	if(icons.PostCreateIcon) then icons:PostCreateIcon(button) end

	return button
end

local UpdateAuraIcon = function(self, auras, unit, index, offset, filter, isDebuff, visible)
	local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter)
	
	if self.forceShow then
		spellID = 47540
		name, rank, texture = GetSpellInfo(spellID)
		count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 60, 'player', nil, nil, nil, nil
	end
	
	if(name) then
		local n = visible + offset + 1
		local this = auras[n]
		if(not this) then
			this = (self.CreateIcon or createAuraIcon) (self, n)
			auras[n] = this
		end
		
		local show = true
		if not self.forceShow then
			show = (self.CustomFilter or genericFilter) (self, this, unit, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff)
		end

		if(show) then
			this:SetID(index)
			this.icon:SetTexture(texture)
			this.spellID = spellID
			this.name = name
			this.count:SetText((count > 1 and count))
			this.duration = duration
			this.expirationTime = timeLeft
			this.owner = caster
			this.noTime = (duration == 0 and timeLeft == 0)
			this.filter = filter

			local cd = this.cd
			if(cd and not self.disableCooldown) then
				if(duration and duration > 0) then
					cd:SetCooldown(timeLeft - duration, duration)
					cd:Show()
				else
					cd:Hide()
				end
			end

			if((isDebuff and self.showDebuffType) or (not isDebuff and self.showBuffType) or self.showType) then
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none

				this.overlay:SetVertexColor(color.r, color.g, color.b)
				this.overlay:Show()
			else
				this.overlay:Hide()
			end

			if(this.stealable) then
				local stealable = not isDebuff and isStealable
				if(stealable and self.showStealableBuffs and not UnitIsUnit('player', unit)) then
					this.stealable:Show()
				else
					this.stealable:Hide()
				end
			end

			local isFriend = (UnitIsFriend('player', unit) == 1) and true or false;
			if(isDebuff) then
				if((not isFriend) and this.owner and (this.owner ~= "player") and (this.owner ~= "vehicle")) then
					this:SetBackdropBorderColor(0.9, 0.1, 0.1, 1)
					this.bg:SetBackdropColor(1, 0, 0, 1)
					this.icon:SetDesaturated((unit and not unit:find('arena%d')) and true or false)
				else
					local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
					this:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
					this.bg:SetBackdropColor(color.r, color.g, color.b, 1)
					this.icon:SetDesaturated(false)
				end
				this.bg:SetBackdropBorderColor(0, 0, 0, 1)
			else
				if((isStealable) and (not isFriend)) then
					this:SetBackdropBorderColor(0.92, 0.91, 0.55, 1)
					this.bg:SetBackdropColor(1, 1, 0.5, 1)
					this.bg:SetBackdropBorderColor(0, 0, 0, 1)
				else
					this:SetBackdropBorderColor(0, 0, 0, 1)
					this.bg:SetBackdropColor(0, 0, 0, 0)
					this.bg:SetBackdropBorderColor(0, 0, 0, 0)		
				end	
			end

			local size = self.size
			if(size) then
				this:SetSize(size, size)
			end
			
			if((not duration or duration == 0) or (not timeLeft or timeLeft == 0)) then
				this:SetScript('OnUpdate', nil)
				this.text:SetText('')
			elseif(timeLeft and duration ~= 0) then
				if(not this:GetScript('OnUpdate')) then
					this.expirationTime = timeLeft
					this.expiration = timeLeft - GetTime()
					this.nextUpdate = -1
					this:SetScript('OnUpdate', UpdateAuraTimer)
				elseif(this.expirationTime ~= timeLeft) then
					this.expirationTime = timeLeft
					this.expiration = timeLeft - GetTime()
					this.nextUpdate = -1
				end
			end

			this:Show()

			return VISIBLE
		else
			return HIDDEN
		end
	end
end

local SetAuraIcons = function(self, unit, filter, limit, isDebuff, offset, dontHide)
	if not unit then return; end

	if(not offset) then offset = 0 end
	local index = 1
	local visible = 0
	local auras = self.Icons

	while(visible < limit) do
		local result = UpdateAuraIcon(self, auras, unit, index, offset, filter, isDebuff, visible)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		end

		index = index + 1
	end

	if(not dontHide) then
		for i = visible + offset + 1, #auras do
			auras[i]:Hide()
		end
	end

	if(visible == 0) then
		self:SetHeight(1)
	else
		self:SetHeight(self.maxIconHeight)
		if(limit > 0) then
			local col = 0
			local row = 0
			local gap = self.gap
			local sizex = (self.size or 16) + (self['spacing-x'] or self.spacing or 0)
			local sizey = (self.size or 16) + (self['spacing-y'] or self.spacing or 0)
			local anchor = self.initialAnchor or "BOTTOMLEFT"
			local growthx = (self["growth-x"] == "LEFT" and -1) or 1
			local growthy = (self["growth-y"] == "DOWN" and -1) or 1
			local cols = floor(self:GetWidth() / sizex + .5)
			local rows = floor(self:GetHeight() / sizey + .5)

			for i = 1, #auras do
				local button = auras[i]
				if(button and button:IsShown()) then
					if(gap and button.debuff) then
						if(col > 0) then
							col = col + 1
						end

						gap = false
					end

					if(col >= cols) then
						col = 0
						row = row + 1
					end
					button:ClearAllPoints()
					button:SetPoint(anchor, self, anchor, col * sizex * growthx, row * sizey * growthy)

					col = col + 1
				elseif(not button) then
					break
				end
			end
		end
	end

	if(self.PostUpdate) then self:PostUpdate(unit) end
end

--[[ SETUP AND ENABLE/DISABLE ]]--

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end

	local buffs = self.Buffs
	if(buffs) then
		local numBuffs = buffs.num or 32
		if(not buffs.UseBars) then
			if(buffs.Bars:IsShown()) then
				buffs.Bars:Hide()
			end
			if(not buffs.Icons:IsShown()) then
				buffs.Icons:Show()
			end
			buffs:SetAuraIcons(unit, buffs.filter or 'HELPFUL', numBuffs)
			if buffs.sort then
				tsort(buffs.Icons, type(buffs.sort) == 'function' and buffs.sort or sort)
			end
		else
			if(buffs.Icons:IsShown()) then
				buffs.Icons:Hide()
			end
			if(not buffs.Bars:IsShown()) then
				buffs.Bars:Show()
			end
			buffs:SetAuraBars(unit, buffs.filter or 'HELPFUL', numBuffs)
			if buffs.sort then
				tsort(buffs.Bars, type(buffs.sort) == 'function' and buffs.sort or sort)
			end
		end
	end

	local debuffs = self.Debuffs
	if(debuffs) then
		local numDebuffs = debuffs.num or 40
		if(not debuffs.UseBars) then
			if(debuffs.Bars:IsShown()) then
				debuffs.Bars:Hide()
			end
			if(not debuffs.Icons:IsShown()) then
				debuffs.Icons:Show()
			end
			debuffs:SetAuraIcons(unit, debuffs.filter or 'HARMFUL', numDebuffs, true)
			if debuffs.sort then
				tsort(debuffs.Icons, type(debuffs.sort) == 'function' and debuffs.sort or sort)
			end
		else
			if(debuffs.Icons:IsShown()) then
				debuffs.Icons:Hide()
			end
			if(not debuffs.Bars:IsShown()) then
				debuffs.Bars:Show()
			end
			debuffs:SetAuraBars(unit, debuffs.filter or 'HARMFUL', numDebuffs, true)
			if debuffs.sort then
				tsort(debuffs.Bars, type(debuffs.sort) == 'function' and debuffs.sort or sort)
			end
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	if(self.Buffs or self.Debuffs) then
		self:RegisterEvent('UNIT_AURA', Update)

		local buffs = self.Buffs
		if(buffs) then
			buffs.__owner = self
			buffs.Icons = buffs.Icons or CreateFrame("Frame", nil, buffs)
			buffs.Bars = buffs.Bars or CreateFrame("Frame", nil, buffs)
			buffs.ForceUpdate = ForceUpdate
			buffs.SetAuraIcons = SetAuraIcons
			buffs.SetAuraBars = SetAuraBars
			buffs.Bars:SetScript('OnUpdate', Bars_OnUpdate)

			buffs:SetHeight(1)
			buffs.maxIconHeight = buffs.maxIconHeight or 20
			buffs.barHeight = buffs.barHeight or 16
			buffs.SetBarAnchors = SetBarAnchors
		end

		local debuffs = self.Debuffs
		if(debuffs) then
			debuffs.__owner = self
			debuffs.Icons = debuffs.Icons or CreateFrame("Frame", nil, debuffs)
			debuffs.Bars = debuffs.Bars or CreateFrame("Frame", nil, debuffs)
			debuffs.ForceUpdate = ForceUpdate
			debuffs.SetAuraIcons = SetAuraIcons
			debuffs.SetAuraBars = SetAuraBars
			debuffs.Bars:SetScript('OnUpdate', Bars_OnUpdate)

			debuffs:SetHeight(1)
			debuffs.maxIconHeight = debuffs.maxIconHeight or 20
			debuffs.barHeight = debuffs.barHeight or 16
			debuffs.SetBarAnchors = SetBarAnchors
		end

		return true
	end
end

local Disable = function(self)
	if(self.Buffs or self.Debuffs) then
		self:UnregisterEvent('UNIT_AURA', Update)

		local buffs = self.Buffs
		if(buffs and buffs.Bars) then
			buffs:SetScript('OnUpdate', nil)
		end

		local debuffs = self.Debuffs
		if(debuffs and debuffs.Bars) then
			debuffs.Bars:SetScript('OnUpdate', nil)
		end
	end
end

oUF:AddElement('Auras', Update, Enable, Disable)