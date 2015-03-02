--[[
##########################################################
S V U I  By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local find, format, len = string.find, string.format, string.len;
local sub, byte = string.sub, string.byte;
--[[ MATH METHODS ]]--
local floor, ceil, abs = math.floor, math.ceil, math.abs;
local twipe = table.wipe;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Inventory;
if(not MOD) then return end;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local nameKey = UnitName("player");
local realmKey = GetRealmName();
local DEBUG_BAGS = false;
local CreateFrame = _G.CreateFrame;
local hooksecurefunc = _G.hooksecurefunc;
local numBagFrame = NUM_BAG_FRAMES + 1;
local GEAR_CACHE, GEARSET_LISTING = {}, {};
local internalTimer;
local RefProfessionColors = {
	[0x0008] = {224/255,187/255,74/255},
	[0x0010] = {74/255,77/255,224/255},
	[0x0020] = {18/255,181/255,32/255},
	[0x0040] = {160/255,3/255,168/255},
	[0x0080] = {232/255,118/255,46/255},
	[0x0200] = {8/255,180/255,207/255},
	[0x0400] = {105/255,79/255,7/255},
	[0x10000] = {222/255,13/255,65/255},
	[0x100000] = {18/255,224/255,180/255}
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local goldFormat = "%s|TInterface\\MONEYFRAME\\UI-GoldIcon.blp:16:16|t"

local function FormatCurrency(amount)
	if not amount then return end 
	local gold = floor(abs(amount/10000))
	if gold ~= 0 then
		gold = BreakUpLargeNumbers(gold)
		return goldFormat:format(gold)
	end
end 

local function StyleBagToolButton(button, iconTex)
	if button.styled then return end

	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:WrapPoints(button, 4, 4)
	bg:SetTexture(SV.media.button.roundbg)
	bg:SetVertexColor(unpack(SV.media.color.default))

	local outer = button:CreateTexture(nil, "OVERLAY")
	outer:WrapPoints(button, 5, 5)
	outer:SetTexture(SV.media.button.round)
	outer:SetGradient(unpack(SV.media.gradient.container))

	button:SetNormalTexture(iconTex)
	iconTex = button:GetNormalTexture()
	iconTex:SetGradient(unpack(SV.media.gradient.medium))
	
	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:WrapPoints(button, 5, 5)
	SetPortraitToTexture(icon, iconTex)
	hooksecurefunc(icon, "SetTexture", SetPortraitToTexture)

	local hover = button:CreateTexture(nil, "HIGHLIGHT")
	hover:WrapPoints(button, 5, 5)
	hover:SetTexture(SV.media.button.round)
	hover:SetGradient(unpack(SV.media.gradient.yellow))

	if button.SetPushedTexture then 
		local pushed = button:CreateTexture(nil, "BORDER")
		pushed:WrapPoints(button, 5, 5)
		pushed:SetTexture(SV.media.button.round)
		pushed:SetGradient(unpack(SV.media.gradient.highlight))
		button:SetPushedTexture(pushed)
	end 

	if button.SetCheckedTexture then 
		local checked = button:CreateTexture(nil, "BORDER")
		checked:WrapPoints(button, 5, 5)
		checked:SetTexture(SV.media.button.round)
		checked:SetGradient(unpack(SV.media.gradient.green))
		button:SetCheckedTexture(checked)
	end 

	if button.SetDisabledTexture then 
		local disabled = button:CreateTexture(nil, "BORDER")
		disabled:WrapPoints(button, 5, 5)
		disabled:SetTexture(SV.media.button.round)
		disabled:SetGradient(unpack(SV.media.gradient.default))
		button:SetDisabledTexture(disabled)
	end 

	local cd = button:GetName() and _G[button:GetName().."Cooldown"]
	if cd then 
		cd:ClearAllPoints()
		cd:InsetPoints()
	end 
	button.styled = true
end 

local function encodeSub(i, j, k)
	local l = j;
	while k>0 and l <= #i do
		local m = byte(i, l)
		if m>240 then
			l = l + 4;
		elseif m>225 then
			l = l + 3;
		elseif m>192 then
			l = l + 2;
		else
			l = l + 1;
		end 
		k = k-1;
	end 
	return i:sub(j, (l-1))
end 

local function SetGearLabel(level, font, saveTo)
	if level == 1 then
		font:SetFormattedText("|cffffffaa%s|r", encodeSub(saveTo[1], 1, 4))
	elseif level == 2 then
		font:SetFormattedText("|cffffffaa%s %s|r", encodeSub(saveTo[1], 1, 4), encodeSub(saveTo[2], 1, 4))
	elseif level == 3 then
		font:SetFormattedText("|cffffffaa%s %s %s|r", encodeSub(saveTo[1], 1, 4), encodeSub(saveTo[2], 1, 4), encodeSub(saveTo[3], 1, 4))
	else
		font:SetText()
	end
end 

function MOD:BuildEquipmentMap()
	for key, gearData in pairs(GEARSET_LISTING) do
		twipe(gearData);
	end

	local set, player, bank, bags, slotIndex, bagIndex, loc, _;
	
	for i = 1, GetNumEquipmentSets() do
		set = GetEquipmentSetInfo(i);
		GEAR_CACHE = GetEquipmentSetLocations(set);
		if(GEAR_CACHE) then
			for key, location in pairs(GEAR_CACHE) do
				if(type(location) ~= "string") then
					player, bank, bags, _, slotIndex, bagIndex = EquipmentManager_UnpackLocation(location);
					if((bank or bags) and (slotIndex and bagIndex)) then
						loc = format("%d_%d", bagIndex, slotIndex);
						GEARSET_LISTING[loc] = (GEARSET_LISTING[loc] or {});
						tinsert(GEARSET_LISTING[loc], set);
					end
				end
			end
		end
	end
end
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
function MOD:INVENTORY_SEARCH_UPDATE()
	for _, frame in pairs(self.BagFrames) do 
		for id, bag in ipairs(frame.Bags) do 
			for i = 1, GetContainerNumSlots(id) do 
				local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(id, i)
				local item = bag[i]
				if(item and item:IsShown()) then 
					if isFiltered then 
						SetItemButtonDesaturated(item, 1)
						item:SetAlpha(0.4)
					else 
						SetItemButtonDesaturated(item)
						item:SetAlpha(1)
					end 
				end 
			end 
		end 
	end
	if(self.ReagentFrame) then
		for i = 1, self.ReagentFrame.numSlots do 
			local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(REAGENTBANK_CONTAINER, i)
			local item = frame.Bags[REAGENTBANK_CONTAINER][i]
			if(item and item:IsShown()) then 
				if isFiltered then 
					SetItemButtonDesaturated(item, 1)
					item:SetAlpha(0.4)
				else 
					SetItemButtonDesaturated(item)
					item:SetAlpha(1)
				end 
			end 
		end
	end
end

local SlotUpdate = function(self, slotID)
	if(not self[slotID]) then return end
	local bagID = self:GetID();
	local slot = self[slotID];
	local bagType = self.bagFamily;

	slot:Show()

	local texture, count, locked = GetContainerItemInfo(bagID, slotID);
	local start, duration, enable = GetContainerItemCooldown(bagID, slotID);
	local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);

	local itemID = GetContainerItemID(bagID, slotID);
	if(itemID and MOD.private.junk[itemID]) then
		slot.JunkIcon:Show()
	else
		slot.JunkIcon:Hide()
	end

	local r,g,b = 0,0,0
	slot.HasQuestItem = nil
	if(questId and (not isActiveQuest)) then
		r,g,b = 1,0.3,0.3
		slot.questIcon:Show();
		slot.HasQuestItem = true;
	elseif(questId or isQuestItem) then
		r,g,b = 1,0.3,0.3
		slot.questIcon:Hide();
		slot.HasQuestItem = true;
	elseif(bagType) then
		r,g,b = bagType[1],bagType[2],bagType[3]
		slot.questIcon:Hide();
	else
		slot.questIcon:Hide();
		local itemLink = GetContainerItemLink(bagID, slotID);
		if(itemLink) then
			local key = GetItemInfo(itemLink)
			if(key) then
				local journal = MOD.public[realmKey]["bags"][nameKey]
				local id = GetContainerItemID(bagID, slotID)
				if not journal[bagID] then
					journal[bagID] = {}
				end
				if id ~= 6948 then journal[bagID][key] = GetItemCount(id,true) end
			end
			local rarity = select(3, GetItemInfo(itemLink));
			if(rarity) then
				if(rarity > 1) then 
					r,g,b = GetItemQualityColor(rarity)
				elseif(rarity == 0) then
					slot.JunkIcon:Show()
				end
			end
		end
	end

	slot:SetBackdropColor(r,g,b,0.6)
	slot:SetBackdropBorderColor(r,g,b,1)

	CooldownFrame_SetTimer(slot.cooldown, start, duration, enable);

	if((duration > 0) and (enable == 0)) then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4)
	else 
		SetItemButtonTextureVertexColor(slot, 1, 1, 1)
	end

	if(C_NewItems.IsNewItem(bagID, slotID)) then
		C_NewItems.RemoveNewItem(bagID, slotID)
	end
	
	if(slot.NewItemTexture) then slot.NewItemTexture:Hide() end;
	if(slot.flashAnim) then slot.flashAnim:Stop() end;
    if(slot.newitemglowAnim) then slot.newitemglowAnim:Stop() end;

	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5)

	if(slot.GearInfo) then
		local loc = format("%d_%d", bagID, slotID)
		if(GEARSET_LISTING[loc]) then
			local level = #GEARSET_LISTING[loc] < 4 and #GEARSET_LISTING[loc] or 3;
			SetGearLabel(level, slot.GearInfo, GEARSET_LISTING[loc])
		else
			SetGearLabel(0, slot.GearInfo, nil)
		end
	end
end

local RefreshSlots = function(self)
	local bagID = self:GetID()
	if(not bagID) then return end
	local maxcount = GetContainerNumSlots(bagID)
	local journal = MOD.public[realmKey]["bags"][nameKey]
	for slotID = 1, maxcount do
		if journal[bagID] then
			twipe(journal[bagID])
		else
			journal[bagID] = {};
		end
		self:SlotUpdate(slotID) 
	end
	for id,items in pairs(journal) do
		for id,amt in pairs(items) do
			if not MOD.LootCache[id] then
				MOD.LootCache[id] = {}
			end
			MOD.LootCache[id][nameKey] = amt
		end
	end
end

local RefreshReagentSlots = function(self)
	local bagID = self:GetID()
	if(not bagID or (not self.SlotUpdate)) then return end
	local maxcount = self.numSlots
	local journal = MOD.public[realmKey]["bags"][nameKey]
	for slotID = 1, maxcount do
		if journal[bagID] then
			twipe(journal[bagID])
		else
			journal[bagID] = {};
		end
		self:SlotUpdate(slotID) 
	end
	for id,items in pairs(journal) do
		for id,amt in pairs(items) do
			MOD.LootCache[id] = MOD.LootCache[id] or {}
			MOD.LootCache[id][nameKey] = amt
		end
	end
end

local ContainerFrame_UpdateCooldowns = function(self)
	if self.isReagent then return end
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			for slotID = 1, GetContainerNumSlots(bagID)do 
				local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
				if(self.Bags[bagID][slotID]) then
					CooldownFrame_SetTimer(self.Bags[bagID][slotID].cooldown, start, duration, enable)
					if duration > 0 and enable == 0 then 
						SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 0.4, 0.4, 0.4)
					else 
						SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 1, 1, 1)
					end
				end
			end
		end 
	end 
end

local ContainerFrame_UpdateBags = function(self)
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			self.Bags[bagID]:RefreshSlots();
		end
	end
end

local ContainerFrame_UpdateLayout = function(self)
	local isBank = self.isBank
	local containerName = self:GetName()
	local buttonSpacing = 8;
	local containerWidth, numContainerColumns, buttonSize

	local precount = 0;
	for i, bagID in ipairs(self.BagIDs) do
		local numSlots = GetContainerNumSlots(bagID);
		precount = precount + (numSlots or 0);
	end

	if(SV.db.Inventory.alignToChat) then
		containerWidth = (isBank and SV.db.Dock.dockLeftWidth or SV.db.Dock.dockRightWidth)
		local avg = 0.08;
		if(precount > 287) then
			avg = 0.12
		elseif(precount > 167) then
			avg = 0.11
		elseif(precount > 127) then
			avg = 0.1
		elseif(precount > 97) then
			avg = 0.09
		end

		numContainerColumns = avg * 100;

		local unitSize = floor(containerWidth / numContainerColumns)
		buttonSize = unitSize - buttonSpacing;
	else
		containerWidth = (isBank and SV.db.Inventory.bankWidth) or SV.db.Inventory.bagWidth
		buttonSize = isBank and SV.db.Inventory.bankSize or SV.db.Inventory.bagSize;
		numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing));
	end

	local numContainerRows = ceil(precount / numContainerColumns)
	local containerHeight = (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + self.topOffset + self.bottomOffset
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local bottomPadding = (containerWidth - holderWidth) * 0.5;
	local lastButton, lastRowButton, globalName;
	local numContainerSlots, fullContainerSlots = GetNumBankSlots();
	local totalSlots = 0;

	self.ButtonSize = buttonSize;
	self.holderFrame:ModWidth(holderWidth);

	local menu = self.BagMenu
	local lastMenu;
	for i, bagID in ipairs(self.BagIDs) do
		if((not isBank and bagID <= 3) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots))) then

			menu:ModSize(((buttonSize + buttonSpacing) * (isBank and i - 1 or i)) + buttonSpacing, buttonSize + (buttonSpacing * 2))
			local bagSlot = menu[i];

			if(not bagSlot) then
				local globalName, bagTemplate;
				if isBank then
					globalName = "SVUI_BankBag" .. bagID - 4;
					bagTemplate = "BankItemButtonBagTemplate"
				else 
					globalName = "SVUI_MainBag" .. bagID .. "Slot";
					bagTemplate = "BagSlotButtonTemplate"
				end

				bagSlot = CreateFrame("CheckButton", globalName, menu, bagTemplate)
				bagSlot.parent = self;

				bagSlot:SetNormalTexture("")
				bagSlot:SetCheckedTexture("")
				bagSlot:SetPushedTexture("")
				bagSlot:SetScript("OnClick", nil)
				bagSlot:RemoveTextures()
				bagSlot:SetStyle("!_ActionSlot");

				if(not bagSlot.icon) then
					bagSlot.icon = bagSlot:CreateTexture(nil, "BORDER");
				end
				bagSlot.icon:InsetPoints()
				bagSlot.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

				if(not bagSlot.tooltipText) then
					bagSlot.tooltipText = ""
				end

				if(isBank) then
					bagSlot:SetID(bagID - 4)
					bagSlot.internalID = bagID;
				else
					MOD:NewFilterMenu(bagSlot)
					bagSlot.internalID = (bagID + 1);
				end

				menu[i] = bagSlot;
			end

			bagSlot:ModSize(buttonSize) 
			bagSlot:ClearAllPoints()

			if(isBank) then
				BankFrameItemButton_Update(bagSlot)
				BankFrameItemButton_UpdateLocked(bagSlot)

				if(i == 2) then 
					bagSlot:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", buttonSpacing, buttonSpacing)
				else 
					bagSlot:SetPoint("LEFT", lastMenu, "RIGHT", buttonSpacing, 0)
				end
			else
				if(i == 1) then 
					bagSlot:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", buttonSpacing, buttonSpacing)
				else 
					bagSlot:SetPoint("LEFT", lastMenu, "RIGHT", buttonSpacing, 0)
				end
			end
			lastMenu = bagSlot;	
		end

		local numSlots = GetContainerNumSlots(bagID);

		local bagName = ("%sBag%d"):format(containerName, bagID)
		local bag;

		if numSlots > 0 then
			if not self.Bags[bagID] then
				self.Bags[bagID] = CreateFrame("Frame", bagName, self); 
				self.Bags[bagID]:SetID(bagID);
				self.Bags[bagID].SlotUpdate = SlotUpdate;
				self.Bags[bagID].RefreshSlots = RefreshSlots;
			end

			self.Bags[bagID].numSlots = numSlots;
			self.Bags[bagID].bagFamily = false;

			local btype = select(2, GetContainerNumFreeSlots(bagID));
			if RefProfessionColors[btype] then
				local r, g, b = unpack(RefProfessionColors[btype]);
				self.Bags[bagID].bagFamily = {r, g, b};
			end

			for i = 1, MAX_CONTAINER_ITEMS do 
				if self.Bags[bagID][i] then 
					self.Bags[bagID][i]:Hide();
				end 
			end

			for slotID = 1, numSlots do
				totalSlots = totalSlots + 1;

				if not self.Bags[bagID][slotID] then
					local slotName = ("%sSlot%d"):format(bagName, slotID)
					local iconName = ("%sIconTexture"):format(slotName)
					local cdName = ("%sCooldown"):format(slotName)
					local questIcon = ("%sIconQuestTexture"):format(slotName)

					self.Bags[bagID][slotID] = CreateFrame("CheckButton", slotName, self.Bags[bagID], bagID == -1 and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate");
					self.Bags[bagID][slotID]:SetNormalTexture("");
					self.Bags[bagID][slotID]:SetCheckedTexture("");
					self.Bags[bagID][slotID]:RemoveTextures();
					self.Bags[bagID][slotID]:SetStyle("!_ActionSlot");

					-- if(self.Bags[bagID][slotID].flashAnim) then
					-- 	self.Bags[bagID][slotID].flashAnim.Play = SV.fubar
					-- end
					
					if(not self.Bags[bagID][slotID].NewItemTexture) then
						self.Bags[bagID][slotID].NewItemTexture = self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY", 1);
					end
					self.Bags[bagID][slotID].NewItemTexture:InsetPoints(self.Bags[bagID][slotID]);
					self.Bags[bagID][slotID].NewItemTexture:SetTexture("");
					self.Bags[bagID][slotID].NewItemTexture:Hide()

					if(not self.Bags[bagID][slotID].JunkIcon) then 
						self.Bags[bagID][slotID].JunkIcon = self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY");
						self.Bags[bagID][slotID].JunkIcon:ModSize(16,16);
					end
					self.Bags[bagID][slotID].JunkIcon:SetTexture([[Interface\BUTTONS\UI-GroupLoot-Coin-Up]]);
					self.Bags[bagID][slotID].JunkIcon:ModPoint("TOPLEFT", self.Bags[bagID][slotID], "TOPLEFT", -4, 4);

					if(not self.Bags[bagID][slotID].icon) then
						self.Bags[bagID][slotID].icon = self.Bags[bagID][slotID]:CreateTexture(nil, "BORDER");
					end
					self.Bags[bagID][slotID].icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));
					self.Bags[bagID][slotID].icon:InsetPoints(self.Bags[bagID][slotID]);

					self.Bags[bagID][slotID].questIcon = _G[questIcon] or self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
					self.Bags[bagID][slotID].questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
					self.Bags[bagID][slotID].questIcon:InsetPoints(self.Bags[bagID][slotID]);
					self.Bags[bagID][slotID].questIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));
					
					hooksecurefunc(self.Bags[bagID][slotID], "SetBackdropColor", function(self, r, g, b, a) if(self.HasQuestItem and (r ~= 1)) then self:SetBackdropColor(1,0.3,0.3,a) end end)
					hooksecurefunc(self.Bags[bagID][slotID], "SetBackdropBorderColor", function(self, r, g, b, a) if(self.HasQuestItem and (r ~= 1)) then self:SetBackdropBorderColor(1,0.3,0.3,a) end end)

					self.Bags[bagID][slotID].cooldown = _G[cdName];
				end

				if(not self.Bags[bagID][slotID].GearInfo) then 
					self.Bags[bagID][slotID].GearInfo = self.Bags[bagID][slotID]:CreateFontString(nil,"OVERLAY")
					self.Bags[bagID][slotID].GearInfo:SetFontObject(SVUI_Font_Default)
					self.Bags[bagID][slotID].GearInfo:SetAllPoints(self.Bags[bagID][slotID])
					self.Bags[bagID][slotID].GearInfo:SetWordWrap(true)
					self.Bags[bagID][slotID].GearInfo:SetJustifyH('LEFT')
					self.Bags[bagID][slotID].GearInfo:SetJustifyV('BOTTOM')
				end

				self.Bags[bagID][slotID]:SetID(slotID);
				self.Bags[bagID][slotID]:ModSize(buttonSize);

				if self.Bags[bagID][slotID]:GetPoint() then 
					self.Bags[bagID][slotID]:ClearAllPoints();
				end

				if lastButton then 
					if((totalSlots - 1) % numContainerColumns == 0) then 
						self.Bags[bagID][slotID]:ModPoint("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
						lastRowButton = self.Bags[bagID][slotID];
					else 
						self.Bags[bagID][slotID]:ModPoint("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
					end 
				else 
					self.Bags[bagID][slotID]:ModPoint("TOPLEFT", self.holderFrame, "TOPLEFT");
					lastRowButton = self.Bags[bagID][slotID];
				end

				lastButton = self.Bags[bagID][slotID];

				self.Bags[bagID]:SlotUpdate(slotID);
			end
		else
			if(self.Bags[bagID]) then
				self.Bags[bagID].numSlots = numSlots;
				
				for i = 1, MAX_CONTAINER_ITEMS do 
					if(self.Bags[bagID][i]) then 
						self.Bags[bagID][i]:Hide();
					end 
				end
			end 

			if(isBank) then
				if(menu[i]) then
					BankFrameItemButton_Update(menu[i])
					BankFrameItemButton_UpdateLocked(menu[i])
				end
			end
		end
	end
	
	self:ModSize(containerWidth, containerHeight);
end 

local ReagentFrame_UpdateLayout = function(self)
	if not _G.ReagentBankFrame then return; end

	local ReagentBankFrame = _G.ReagentBankFrame;

	local containerName = self:GetName()
	local buttonSpacing = 8;
	local preColumns = ReagentBankFrame.numColumn or 7
	local preSubColumns = ReagentBankFrame.numSubColumn or 2
	local numContainerColumns = preColumns * preSubColumns
	local numContainerRows = ReagentBankFrame.numRow or 7
	local buttonSize = SVUI_BankContainerFrame.ButtonSize
	local containerWidth = (buttonSize + buttonSpacing) * numContainerColumns + buttonSpacing
	local containerHeight = (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + self.topOffset + self.bottomOffset
	local maxCount = numContainerColumns * numContainerRows
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local lastButton, lastRowButton;
	local bagID = REAGENTBANK_CONTAINER;
	local totalSlots = 0;

	self.holderFrame:ModWidth(holderWidth);
	self.BagID = bagID

	local bag;
	local bagName = ("%sBag%d"):format(containerName, bagID)

	if not self.Bags[bagID] then
		bag = CreateFrame("Frame", bagName, self); 
		bag:SetID(bagID);
		bag.SlotUpdate = SlotUpdate;
		bag.RefreshSlots = RefreshReagentSlots;
		self.Bags[bagID] = bag
	else
		bag = self.Bags[bagID]
	end

	self.numSlots = maxCount;
	bag.numSlots = maxCount;
	bag.bagFamily = false;

	for slotID = 1, maxCount do
		local slot;
		totalSlots = totalSlots + 1;

		if not bag[slotID] then
			local slotName = ("%sSlot%d"):format(bagName, slotID)
			local iconName = ("%sIconTexture"):format(slotName)
			local questIcon = ("%sIconQuestTexture"):format(slotName)
			local cdName = ("%sCooldown"):format(slotName)

			slot = CreateFrame("CheckButton", slotName, bag, "ReagentBankItemButtonGenericTemplate");
			slot:SetNormalTexture(nil);
			slot:SetCheckedTexture(nil);
			slot:RemoveTextures()
			slot:SetStyle("!_ActionSlot");

			slot.NewItemTexture = slot:CreateTexture(nil, "OVERLAY", 1);
			slot.NewItemTexture:InsetPoints(slot);
			slot.NewItemTexture:SetTexture("");
			slot.NewItemTexture:Hide()

			slot.JunkIcon = slot:CreateTexture(nil, "OVERLAY");
			slot.JunkIcon:ModSize(16,16);
			slot.JunkIcon:SetTexture("");
			slot.JunkIcon:ModPoint("TOPLEFT", slot, "TOPLEFT", -4, 4);

			slot.icon = _G[iconName] or slot:CreateTexture(nil, "BORDER");
			slot.icon:InsetPoints(slot);
			slot.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

			slot.questIcon = _G[questIcon] or slot:CreateTexture(nil, "OVERLAY")
			slot.questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			slot.questIcon:InsetPoints(slot);
			slot.questIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

			slot.cooldown = _G[cdName];

			bag[slotID] = slot
		else
			slot = bag[slotID]
		end

		slot:SetID(slotID);
		slot:ModSize(buttonSize);

		if slot:GetPoint() then 
			slot:ClearAllPoints();
		end

		if lastButton then 
			if((totalSlots - 1) % numContainerColumns == 0) then 
				slot:ModPoint("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
				lastRowButton = slot;
			else 
				slot:ModPoint("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
			end 
		else 
			slot:ModPoint("TOPLEFT", self.holderFrame, "TOPLEFT");
			lastRowButton = slot;
		end

		lastButton = slot;

		if(slot.GetInventorySlot) then
			BankFrameItemButton_Update(slot)
			BankFrameItemButton_UpdateLocked(slot)
		end

		bag:SlotUpdate(slotID);
	end

	self:ModSize(containerWidth, containerHeight);
end 

function MOD:RefreshBagFrames(frame)
	if(frame and self[frame]) then
		self[frame]:UpdateLayout()
		return
	else
		if(self.BagFrame) then 
			self.BagFrame:UpdateLayout()
		end 
		if self.BankFrame then 
			self.BankFrame:UpdateLayout()
		end
		if self.ReagentFrame then 
			self.ReagentFrame:UpdateLayout()
		end
	end
end 

function MOD:UpdateGoldText()
	self.BagFrame.goldText:SetText(GetCoinTextureString(GetMoney(), 12))
end 

function MOD:VendorCheck(itemID, bagID, slot)
	if(itemID and MOD.private.junk[itemID]) then
		UseContainerItem(bagID, slot)
		PickupMerchantItem()
		return true
	end
end 

function MOD:ModifyBags()
	local docked = SV.db.Inventory.alignToChat
	local anchor, x, y
	if(docked) then
		if self.BagFrame then
			self.BagFrame:ClearAllPoints()
			self.BagFrame:ModPoint("BOTTOMRIGHT", SV.Dock.BottomRight, "BOTTOMRIGHT", 0, 0)
		end 
		if self.BankFrame then
			self.BankFrame:ClearAllPoints()
			self.BankFrame:ModPoint("BOTTOMLEFT", SV.Dock.BottomLeft, "BOTTOMLEFT", 0, 0)
		end
	else
		if self.BagFrame then
			local anchor, x, y = SV.db.Inventory.bags.point, SV.db.Inventory.bags.xOffset, SV.db.Inventory.bags.yOffset
			self.BagFrame:ClearAllPoints()
			self.BagFrame:ModPoint(anchor, SV.Screen, anchor, x, y)
		end 
		if self.BankFrame then
			local anchor, x, y = SV.db.Inventory.bank.point, SV.db.Inventory.bank.xOffset, SV.db.Inventory.bank.yOffset
			self.BankFrame:ClearAllPoints()
			self.BankFrame:ModPoint(anchor, SV.Screen, anchor, x, y)
		end
	end
end 

do
	local function Bags_OnEnter()
		if SV.db.Inventory.bagBar.mouseover ~= true then return end 
		SVUI_BagBar:FadeIn(0.2, SVUI_BagBar:GetAlpha(), 1)
	end

	local function Bags_OnLeave()
		if SV.db.Inventory.bagBar.mouseover ~= true then return end 
		SVUI_BagBar:FadeOut(0.2, SVUI_BagBar:GetAlpha(), 0)
	end

	local function AlterBagBar(bar)
		local icon = _G[bar:GetName().."IconTexture"]
		bar.oldTex = icon:GetTexture()
		bar:RemoveTextures()
		bar:SetStyle("!_Frame", "Default")
		bar:SetStyle("!_ActionSlot", 1, nil, nil, true)
		icon:SetTexture(bar.oldTex)
		icon:InsetPoints()
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9 )
	end

	local function LoadBagBar()
		if MOD.BagBarLoaded then return end

		local bar = CreateFrame("Frame", "SVUI_BagBar", SV.Screen)
		bar:SetPoint("TOPRIGHT", SV.Dock.BottomRight, "TOPLEFT", -4, 0)
		bar.buttons = {}
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", Bags_OnEnter)
		bar:SetScript("OnLeave", Bags_OnLeave)

		MainMenuBarBackpackButton:SetParent(bar)
		MainMenuBarBackpackButton.SetParent = SV.Hidden;
		MainMenuBarBackpackButton:ClearAllPoints()
		MainMenuBarBackpackButtonCount:SetFontObject(SVUI_Font_Default)
		MainMenuBarBackpackButtonCount:ClearAllPoints()
		MainMenuBarBackpackButtonCount:ModPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
		MainMenuBarBackpackButton:HookScript("OnEnter", Bags_OnEnter)
		MainMenuBarBackpackButton:HookScript("OnLeave", Bags_OnLeave)

		tinsert(bar.buttons, MainMenuBarBackpackButton)
		AlterBagBar(MainMenuBarBackpackButton)

		local count = #bar.buttons
		local frameCount = NUM_BAG_FRAMES - 1;

		for i = 0, frameCount do 
			local bagSlot = _G["CharacterBag"..i.."Slot"]
			bagSlot:SetParent(bar)
			bagSlot.SetParent = SV.Hidden;
			bagSlot:HookScript("OnEnter", Bags_OnEnter)
			bagSlot:HookScript("OnLeave", Bags_OnLeave)
			AlterBagBar(bagSlot)
			count = count + 1
			bar.buttons[count] = bagSlot
		end

		MOD.BagBarLoaded = true
	end

	function MOD:ModifyBagBar()
		if not SV.db.Inventory.bagBar.enable then return end

		if not self.BagBarLoaded then 
			LoadBagBar() 
		end 
		if SV.db.Inventory.bagBar.mouseover then 
			SVUI_BagBar:SetAlpha(0)
		else 
			SVUI_BagBar:SetAlpha(1)
		end 

		local showBy = SV.db.Inventory.bagBar.showBy
		local sortDir = SV.db.Inventory.bagBar.sortDirection
		local bagSize = SV.db.Inventory.bagBar.size
		local bagSpacing = SV.db.Inventory.bagBar.spacing

		for i = 1, #SVUI_BagBar.buttons do 
			local button = SVUI_BagBar.buttons[i]
			local lastButton = SVUI_BagBar.buttons[i - 1]

			button:ModSize(bagSize)
			button:ClearAllPoints()

			if(showBy == "HORIZONTAL" and sortDir == "ASCENDING") then 
				if i == 1 then 
					button:SetPoint("LEFT", SVUI_BagBar, "LEFT", bagSpacing, 0)
				elseif lastButton then 
					button:SetPoint("LEFT", lastButton, "RIGHT", bagSpacing, 0)
				end 
			elseif(showBy == "VERTICAL" and sortDir == "ASCENDING") then 
				if i == 1 then 
					button:SetPoint("TOP", SVUI_BagBar, "TOP", 0, -bagSpacing)
				elseif lastButton then 
					button:SetPoint("TOP", lastButton, "BOTTOM", 0, -bagSpacing)
				end 
			elseif(showBy == "HORIZONTAL" and sortDir == "DESCENDING") then 
				if i == 1 then 
					button:SetPoint("RIGHT", SVUI_BagBar, "RIGHT", -bagSpacing, 0)
				elseif lastButton then 
					button:SetPoint("RIGHT", lastButton, "LEFT", -bagSpacing, 0)
				end 
			else 
				if i == 1 then 
					button:SetPoint("BOTTOM", SVUI_BagBar, "BOTTOM", 0, bagSpacing)
				elseif lastButton then 
					button:SetPoint("BOTTOM", lastButton, "TOP", 0, bagSpacing)
				end 
			end 
		end 
		if showBy == "HORIZONTAL" then 
			SVUI_BagBar:ModWidth((bagSize * numBagFrame) + (bagSpacing * numBagFrame) + bagSpacing)
			SVUI_BagBar:ModHeight(bagSize + (bagSpacing * 2))
		else 
			SVUI_BagBar:ModHeight((bagSize * numBagFrame) + (bagSpacing * numBagFrame) + bagSpacing)
			SVUI_BagBar:ModWidth(bagSize + (bagSpacing * 2))
		end

	    if not SVUI_BagBar_MOVE then
	    	SVUI_BagBar:SetStyle("Frame", "Default")
	        SV:NewAnchor(SVUI_BagBar, L["Bags Bar"])
	    end

	    if SV.db.Inventory.bagBar.showBackdrop then 
			SVUI_BagBar.Panel:Show()
		else 
			SVUI_BagBar.Panel:Hide()
		end
	end
end
--[[ 
########################################################## 
BAG CONTAINER CREATION
##########################################################
]]--
do 
	local Search_OnKeyPressed = function(self)
		self:GetParent().detail:Show()
		self:ClearFocus()
		SetItemSearch('')
	end 

	local Search_OnInput = function(self)
		local i = 3;
		local j = self:GetText()
		if len(j) > i then 
			local k=true;
			for h=1,i,1 do 
				if sub(j,0-h,0-h) ~= sub(j,-1-h,-1-h) then 
					k=false;
					break 
				end 
			end 
			if k then 
				Search_OnKeyPressed(self)
				return 
			end 
		end 
		SetItemSearch(j)
	end 

	local Search_OnClick = function(self, button)
		local container = self:GetParent()
		if button == "RightButton"then 
			container.detail:Hide()
			container.editBox:Show()
			container.editBox:SetText(SEARCH)
			container.editBox:HighlightText()
		else 
			if container.editBox:IsShown()then 
				container.editBox:Hide()
				container.editBox:ClearFocus()
				container.detail:Show()
				SetItemSearch('')
			else 
				container.detail:Hide()
				container.editBox:Show()
				container.editBox:SetText(SEARCH)
				container.editBox:HighlightText()
			end 
		end 
	end 

	local Vendor_OnClick = function(self)
		if IsShiftKeyDown()then 
			SV.SystemAlert["DELETE_GRAYS"].Money = SV:VendorGrays(false,true,true)
			SV:StaticPopup_Show('DELETE_GRAYS')
		else 
			SV:VendorGrays()
		end 
	end 

	local Token_OnEnter = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetBackpackToken(self:GetID())
	end 

	local Token_OnLeave = function(self)
		GameTooltip:Hide() 
	end 

	local Token_OnClick = function(self)
		if IsModifiedClick("CHATLINK") then 
			HandleModifiedItemClick(GetCurrencyLink(self.currencyID))
		end 
	end 

	local Tooltip_Show = function(self)
		GameTooltip:SetOwner(self:GetParent(),"ANCHOR_TOP",0,4)
		GameTooltip:ClearLines()

		if(self.altText and IsShiftKeyDown()) then
			GameTooltip:AddLine(self.altText)
		else
			GameTooltip:AddLine(self.ttText)
		end

		if self.ttText2 then 
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(self.ttText2,self.ttText2desc,1,1,1)
		end

		self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.highlight))
		GameTooltip:Show()
	end 

	local Tooltip_Hide = function(self)
		self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.medium))
		GameTooltip:Hide()
	end 

	local Container_OnDragStart = function(self)
		if IsShiftKeyDown()then self:StartMoving()end
	end 
	local Container_OnDragStop = function(self)
		self:StopMovingOrSizing()
	end 
	local Container_OnClick = function(self)
		if IsControlKeyDown() then MOD:ModifyBags() end
	end 
	local Container_OnEnter = function(self)
		GameTooltip:SetOwner(self,"ANCHOR_TOPLEFT",0,4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L['Hold Shift + Drag:'],L['Temporary Move'],1,1,1)
		GameTooltip:AddDoubleLine(L['Hold Control + Right Click:'],L['Reset Position'],1,1,1)
		GameTooltip:Show()
	end

	function MOD:MakeBags()
		local bagName = "SVUI_ContainerFrame"
		local uisCount = #UISpecialFrames + 1;
		local bagsCount = #self.BagFrames + 1;
		local frame = CreateFrame("Button", "SVUI_ContainerFrame", UIParent)

		frame:SetStyle("Frame", "Container", true)
		frame:SetFrameStrata("HIGH")
		frame.UpdateLayout = ContainerFrame_UpdateLayout;
		frame.RefreshBags = ContainerFrame_UpdateBags;
		frame.RefreshCooldowns = ContainerFrame_UpdateCooldowns;

		frame:RegisterEvent("ITEM_LOCK_CHANGED")
		frame:RegisterEvent("ITEM_UNLOCKED")
		frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

		frame:SetMovable(true)

		frame:RegisterForDrag("LeftButton", "RightButton")
		frame:RegisterForClicks("AnyUp")

		frame:SetScript("OnDragStart", Container_OnDragStart)
		frame:SetScript("OnDragStop", Container_OnDragStop)
		frame:SetScript("OnClick", Container_OnClick)
		frame:SetScript("OnEnter", Container_OnEnter)
		frame:SetScript("OnLeave", Token_OnLeave)
		self:SetContainerEvents(frame)

		frame.isBank = false;
		frame.isReagent = false;
		frame:Hide()
		frame.bottomOffset = 32;
		frame.topOffset = 65;

		frame.BagIDs = {0, 1, 2, 3, 4}

		frame.Bags = {}
		frame.closeButton = CreateFrame("Button", "SVUI_ContainerFrameCloseButton", frame, "UIPanelCloseButton")
		frame.closeButton:ModPoint("TOPRIGHT", -4, -4)
		SV.API:Set("CloseButton", frame.closeButton);
		frame.closeButton:SetScript("PostClick", function() 
			if(not InCombatLockdown()) then CloseBag(0) end 
		end)

		frame.holderFrame = CreateFrame("Frame", nil, frame)
		frame.holderFrame:ModPoint("TOP", frame, "TOP", 0, -frame.topOffset)
		frame.holderFrame:ModPoint("BOTTOM", frame, "BOTTOM", 0, frame.bottomOffset)

		frame.Title = frame:CreateFontString()
		frame.Title:SetFontObject(SVUI_Font_Header)
		frame.Title:SetText(INVENTORY_TOOLTIP)
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		frame.Title:SetTextColor(1,0.8,0)

		frame.BagMenu = CreateFrame("Button", "SVUI_ContainerFrameBagMenu", frame)
		frame.BagMenu:ModPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
		frame.BagMenu:SetStyle("!_Frame", "Transparent")
		frame.BagMenu:Hide()

		frame.goldText = frame:CreateFontString(nil, "OVERLAY")
		frame.goldText:SetFontObject(SVUI_Font_Bag_Number)
		frame.goldText:ModPoint("BOTTOMRIGHT", frame.holderFrame, "TOPRIGHT", -2, 4)
		frame.goldText:SetJustifyH("RIGHT")

		frame.editBox = CreateFrame("EditBox", "SVUI_ContainerFrameEditBox", frame)
		frame.editBox:SetFrameLevel(frame.editBox:GetFrameLevel()+2)
		frame.editBox:SetStyle("Editbox")
		frame.editBox:ModHeight(15)
		frame.editBox:Hide()
		frame.editBox:ModPoint("BOTTOMLEFT", frame.holderFrame, "TOPLEFT", 2, 4)
		frame.editBox:ModPoint("RIGHT", frame.goldText, "LEFT", -5, 0)
		frame.editBox:SetAutoFocus(true)
		frame.editBox:SetScript("OnEscapePressed", Search_OnKeyPressed)
		frame.editBox:SetScript("OnEnterPressed", Search_OnKeyPressed)
		frame.editBox:SetScript("OnEditFocusLost", frame.editBox.Hide)
		frame.editBox:SetScript("OnEditFocusGained", frame.editBox.HighlightText)
		frame.editBox:SetScript("OnTextChanged", Search_OnInput)
		frame.editBox:SetScript("OnChar", Search_OnInput)
		frame.editBox.SearchReset = Search_OnKeyPressed
		frame.editBox:SetText(SEARCH)
		frame.editBox:SetFontObject(SVUI_Font_Bag)

		local searchButton = CreateFrame("Button", nil, frame)
		searchButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		searchButton:SetSize(60, 18)
		searchButton:SetPoint("BOTTOMLEFT", frame.editBox, "BOTTOMLEFT", -2, 0)
		searchButton:SetStyle("Button")
		searchButton:SetScript("OnClick", Search_OnClick)
		local searchText = searchButton:CreateFontString(nil, "OVERLAY")
		searchText:SetFontObject(SVUI_Font_Bag)
		searchText:SetAllPoints(searchButton)
		searchText:SetJustifyH("CENTER")
		searchText:SetText("|cff9999ff"..SEARCH.."|r")
		searchButton:SetFontString(searchText)
		frame.detail = searchButton

		frame.sortButton = CreateFrame("Button", nil, frame)
		frame.sortButton:ModPoint("TOP", frame, "TOP", 0, -10)
		frame.sortButton:ModSize(25, 25)
		StyleBagToolButton(frame.sortButton, MOD.media.cleanupIcon)
		frame.sortButton.ttText = L["Sort Bags"]
		frame.sortButton.altText = L["Filtered Cleanup"]
		frame.sortButton:SetScript("OnEnter", Tooltip_Show)
		frame.sortButton:SetScript("OnLeave", Tooltip_Hide)
		local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "bags", SortBags)
		frame.sortButton:SetScript("OnClick", Sort_OnClick)

		frame.stackButton = CreateFrame("Button", nil, frame)
		frame.stackButton:ModPoint("LEFT", frame.sortButton, "RIGHT", 10, 0)
		frame.stackButton:ModSize(25, 25)
		StyleBagToolButton(frame.stackButton, MOD.media.stackIcon)
		frame.stackButton.ttText = L["Stack Items"]
		frame.stackButton:SetScript("OnEnter", Tooltip_Show)
		frame.stackButton:SetScript("OnLeave", Tooltip_Hide)
		local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "bags")
		frame.stackButton:SetScript("OnClick", Stack_OnClick)

		frame.vendorButton = CreateFrame("Button", nil, frame)
		frame.vendorButton:ModPoint("RIGHT", frame.sortButton, "LEFT", -10, 0)
		frame.vendorButton:ModSize(25, 25)
		StyleBagToolButton(frame.vendorButton, MOD.media.vendorIcon)
		frame.vendorButton.ttText = L["Vendor Grays"]
		frame.vendorButton.ttText2 = L["Hold Shift:"]
		frame.vendorButton.ttText2desc = L["Delete Grays"]
		frame.vendorButton:SetScript("OnEnter", Tooltip_Show)
		frame.vendorButton:SetScript("OnLeave", Tooltip_Hide)
		frame.vendorButton:SetScript("OnClick", Vendor_OnClick)

		frame.bagsButton = CreateFrame("Button", nil, frame)
		frame.bagsButton:ModPoint("RIGHT", frame.vendorButton, "LEFT", -10, 0)
		frame.bagsButton:ModSize(25, 25)
		StyleBagToolButton(frame.bagsButton, MOD.media.bagIcon)
		frame.bagsButton.ttText = L["Toggle Bags"]
		frame.bagsButton:SetScript("OnEnter", Tooltip_Show)
		frame.bagsButton:SetScript("OnLeave", Tooltip_Hide)
		local BagBtn_OnClick = function()
			PlaySound("igMainMenuOption");
			if(SVUI_BagFilterMenu and SVUI_BagFilterMenu:IsShown()) then
				ToggleFrame(SVUI_BagFilterMenu)
			end
			ToggleFrame(frame.BagMenu)
		end
		frame.bagsButton:SetScript("OnClick", BagBtn_OnClick)

		frame.transferButton = CreateFrame("Button", nil, frame)
		frame.transferButton:ModPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
		frame.transferButton:ModSize(25, 25)
		StyleBagToolButton(frame.transferButton, MOD.media.transferIcon)
		frame.transferButton.ttText = L["Stack Bags to Bank"]
		frame.transferButton:SetScript("OnEnter", Tooltip_Show)
		frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
		local Transfer_OnClick = MOD:RunSortingProcess(MOD.Transfer, "bags bank")
		frame.transferButton:SetScript("OnClick", Transfer_OnClick)

		frame.currencyButton = CreateFrame("Frame", nil, frame)
		frame.currencyButton:ModPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 0)
		frame.currencyButton:ModPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
		frame.currencyButton:ModHeight(32)
		for h = 1, MAX_WATCHED_TOKENS do 
			frame.currencyButton[h] = CreateFrame("Button", nil, frame.currencyButton)
			frame.currencyButton[h]:ModSize(22)
			frame.currencyButton[h]:SetStyle("!_Frame", "Default")
			frame.currencyButton[h]:SetID(h)
			frame.currencyButton[h].icon = frame.currencyButton[h]:CreateTexture(nil, "OVERLAY")
			frame.currencyButton[h].icon:InsetPoints()
			frame.currencyButton[h].icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			frame.currencyButton[h].text = frame.currencyButton[h]:CreateFontString(nil, "OVERLAY")
			frame.currencyButton[h].text:ModPoint("LEFT", frame.currencyButton[h], "RIGHT", 2, 0)
			frame.currencyButton[h].text:SetFontObject(SVUI_Font_Bag_Number)
			frame.currencyButton[h]:SetScript("OnEnter", Token_OnEnter)
			frame.currencyButton[h]:SetScript("OnLeave", Token_OnLeave)
			frame.currencyButton[h]:SetScript("OnClick", Token_OnClick)
			frame.currencyButton[h]:Hide()
		end

		frame:SetScript("OnHide", CloseAllBags)

		tinsert(UISpecialFrames, bagName)
		tinsert(self.BagFrames, frame)

		self.BagFrame = frame
	end

	function MOD:MakeBankOrReagent(isReagent)
		-- Reagent Slots: 1 - 98
		-- /script print(ReagentBankFrameItem1:GetInventorySlot())
		local bagName = isReagent and "SVUI_ReagentContainerFrame" or "SVUI_BankContainerFrame"
		local uisCount = #UISpecialFrames + 1;
		local bagsCount = #self.BagFrames + 1;

		local frame = CreateFrame("Button", bagName, isReagent and self.BankFrame or SV.Screen)
		frame:SetStyle("Frame", "Container")
		frame:SetFrameStrata("HIGH")
		frame:SetFrameLevel(SVUI_ContainerFrame:GetFrameLevel() + 99)

		frame.UpdateLayout = isReagent and ReagentFrame_UpdateLayout or ContainerFrame_UpdateLayout;
		frame.RefreshBags = ContainerFrame_UpdateBags;
		frame.RefreshCooldowns = ContainerFrame_UpdateCooldowns;

		frame:RegisterEvent("ITEM_LOCK_CHANGED")
		frame:RegisterEvent("ITEM_UNLOCKED")
		frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton", "RightButton")
		frame:RegisterForClicks("AnyUp")
		frame:SetScript("OnDragStart", Container_OnDragStart)
		frame:SetScript("OnDragStop", Container_OnDragStop)
		frame:SetScript("OnClick", Container_OnClick)
		frame:SetScript("OnEnter", Container_OnEnter)
		frame:SetScript("OnLeave", Token_OnLeave)
		self:SetContainerEvents(frame)

		frame.isBank = true;
		frame.isReagent = isReagent;
		frame:Hide()
		frame.bottomOffset = 8;
		frame.topOffset = 60;

		if(isReagent) then
			frame.BagIDs = {REAGENTBANK_CONTAINER}
		else
			frame.BagIDs = {-1, 5, 6, 7, 8, 9, 10, 11}
		end

		frame.Bags = {}

		frame.closeButton = CreateFrame("Button", bagName.."CloseButton", frame, "UIPanelCloseButton")
		frame.closeButton:ModPoint("TOPRIGHT", -4, -4)
		SV.API:Set("CloseButton", frame.closeButton);
		frame.closeButton:SetScript("PostClick", function() 
			if(not InCombatLockdown()) then CloseBag(0) end 
		end)

		frame.holderFrame = CreateFrame("Frame", nil, frame)
		frame.holderFrame:ModPoint("TOP", frame, "TOP", 0, -frame.topOffset)
		frame.holderFrame:ModPoint("BOTTOM", frame, "BOTTOM", 0, frame.bottomOffset)

		frame.Title = frame:CreateFontString()
		frame.Title:SetFontObject(SVUI_Font_Header)
		frame.Title:SetText(isReagent and REAGENT_BANK or BANK or "Bank")
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		frame.Title:SetTextColor(1,0.8,0)

		frame.sortButton = CreateFrame("Button", nil, frame)
		frame.sortButton:ModPoint("TOPRIGHT", frame, "TOP", 0, -10)
		frame.sortButton:ModSize(25, 25)
		StyleBagToolButton(frame.sortButton, MOD.media.cleanupIcon)
		frame.sortButton.ttText = L["Sort Bank"]
		frame.sortButton.altText = L["Filtered Cleanup"]
		frame.sortButton:SetScript("OnEnter", Tooltip_Show)
		frame.sortButton:SetScript("OnLeave", Tooltip_Hide)

		frame.stackButton = CreateFrame("Button", nil, frame)
		frame.stackButton:ModPoint("LEFT", frame.sortButton, "RIGHT", 10, 0)
		frame.stackButton:ModSize(25, 25)
		StyleBagToolButton(frame.stackButton, MOD.media.stackIcon)
		frame.stackButton.ttText = L["Stack Items"]
		frame.stackButton:SetScript("OnEnter", Tooltip_Show)
		frame.stackButton:SetScript("OnLeave", Tooltip_Hide)

		if(not isReagent) then
			frame.BagMenu = CreateFrame("Button", bagName.."BagMenu", frame)
			frame.BagMenu:ModPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
			frame.BagMenu:SetStyle("!_Frame", "Transparent")
			frame.BagMenu:Hide()

			local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "bank", SortBankBags)
			frame.sortButton:SetScript("OnClick", Sort_OnClick)
			local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "bank")
			frame.stackButton:SetScript("OnClick", Stack_OnClick)

			frame.transferButton = CreateFrame("Button", nil, frame)
			frame.transferButton:ModPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
			frame.transferButton:ModSize(25, 25)
			StyleBagToolButton(frame.transferButton, MOD.media.transferIcon)
			frame.transferButton.ttText = L["Stack Bank to Bags"]
			frame.transferButton:SetScript("OnEnter", Tooltip_Show)
			frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
			local Transfer_OnClick = MOD:RunSortingProcess(MOD.Transfer, "bank bags")
			frame.transferButton:SetScript("OnClick", Transfer_OnClick)
			
			tinsert(UISpecialFrames, bagName)

			frame.bagsButton = CreateFrame("Button", nil, frame)
			frame.bagsButton:ModPoint("RIGHT", frame.sortButton, "LEFT", -10, 0)
			frame.bagsButton:ModSize(25, 25)
			StyleBagToolButton(frame.bagsButton, MOD.media.bagIcon)
			frame.bagsButton.ttText = L["Toggle Bags"]
			frame.bagsButton:SetScript("OnEnter", Tooltip_Show)
			frame.bagsButton:SetScript("OnLeave", Tooltip_Hide)
			local BagBtn_OnClick = function()
				PlaySound("igMainMenuOption");
				if(SVUI_BagFilterMenu and SVUI_BagFilterMenu:IsShown()) then
					ToggleFrame(SVUI_BagFilterMenu)
				end
				local numSlots, _ = GetNumBankSlots()
				if numSlots  >= 1 then 
					ToggleFrame(frame.BagMenu)
				else 
					SV:StaticPopup_Show("NO_BANK_BAGS")
				end 
			end
			frame.bagsButton:SetScript("OnClick", BagBtn_OnClick)

			frame.purchaseBagButton = CreateFrame("Button", nil, frame)
			frame.purchaseBagButton:ModSize(25, 25)
			frame.purchaseBagButton:ModPoint("RIGHT", frame.bagsButton, "LEFT", -10, 0)
			frame.purchaseBagButton:SetFrameLevel(frame.purchaseBagButton:GetFrameLevel()+2)
			StyleBagToolButton(frame.purchaseBagButton, MOD.media.purchaseIcon)
			frame.purchaseBagButton.ttText = L["Purchase"]
			frame.purchaseBagButton:SetScript("OnEnter", Tooltip_Show)
			frame.purchaseBagButton:SetScript("OnLeave", Tooltip_Hide)
			local PurchaseBtn_OnClick = function()
				PlaySound("igMainMenuOption");
				local _, full = GetNumBankSlots()
				if not full then 
					SV:StaticPopup_Show("BUY_BANK_SLOT")
				else 
					SV:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
				end 
			end
			frame.purchaseBagButton:SetScript("OnClick", PurchaseBtn_OnClick)

			local active_icon = IsReagentBankUnlocked() and MOD.media.reagentIcon or MOD.media.purchaseIcon
			frame.swapButton = CreateFrame("Button", nil, frame)
			frame.swapButton:ModPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -10)
			frame.swapButton:ModSize(25, 25)
			StyleBagToolButton(frame.swapButton, active_icon)
			frame.swapButton.ttText = L["Toggle Reagents Bank"]
			frame.swapButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self:GetParent(),"ANCHOR_TOP",0,4)
				GameTooltip:ClearLines()
				if(not IsReagentBankUnlocked()) then
					GameTooltip:AddDoubleLine("Purchase Reagents Bank", FormatCurrency(GetReagentBankCost()), 0.1,1,0.1, 1,1,1)
				else
					GameTooltip:AddLine(self.ttText)
				end
				self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.highlight))
				GameTooltip:Show()
			end)
			frame.swapButton:SetScript("OnLeave", Tooltip_Hide)
			frame.swapButton:SetScript("OnClick", function()
				if(not IsReagentBankUnlocked()) then 
					SV:StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB");
				else
					PlaySound("igMainMenuOption");
					if(_G["SVUI_ReagentContainerFrame"]:IsShown()) then
						_G["SVUI_ReagentContainerFrame"]:Hide()
					else
						_G["SVUI_ReagentContainerFrame"]:Show()
					end
				end
			end)
			frame:SetScript("OnHide", CloseBankFrame)
			self.BankFrame = frame
		else
			local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "reagent", SortBankBags)
			frame.sortButton:SetScript("OnClick", Sort_OnClick)
			local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "reagent")
			frame.stackButton:SetScript("OnClick", Stack_OnClick)

			frame.transferButton = CreateFrame("Button", nil, frame)
			frame.transferButton:ModPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
			frame.transferButton:ModSize(25, 25)
			StyleBagToolButton(frame.transferButton, MOD.media.depositIcon)
			frame.transferButton.ttText = L["Deposit All Reagents"]
			frame.transferButton:SetScript("OnEnter", Tooltip_Show)
			frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
			frame.transferButton:SetScript("OnClick", DepositReagentBank)

			frame:SetPoint("BOTTOMLEFT", self.BankFrame, "BOTTOMRIGHT", 2, 0)
			self.ReagentFrame = frame
		end

		tinsert(self.BagFrames, frame)
	end
end

function MOD:RefreshTokens()
	local frame = MOD.BagFrame;
	local index = 0;

	for i=1,MAX_WATCHED_TOKENS do
		local name,count,icon,currencyID = GetBackpackCurrencyInfo(i)
		local set = frame.currencyButton[i]
		set:ClearAllPoints()
		if name then 
			set.icon:SetTexture(icon)
			if SV.db.Inventory.currencyFormat == 'ICON_TEXT' then 
				set.text:SetText(name..': '..count)
			elseif SV.db.Inventory.currencyFormat == 'ICON' then 
				set.text:SetText(count)
			end 
			set.currencyID = currencyID;
			set:Show()
			index = index + 1; 
		else 
			set:Hide()
		end 
	end

	if index == 0 then 
		frame.bottomOffset = 8;
		if frame.currencyButton:IsShown() then 
			frame.currencyButton:Hide()
			MOD.BagFrame:UpdateLayout()
		end 
		return 
	elseif not frame.currencyButton:IsShown() then 
		frame.bottomOffset = 28;
		frame.currencyButton:Show()
		MOD.BagFrame:UpdateLayout()
	end

	frame.bottomOffset = 28;
	local set = frame.currencyButton;
	if index == 1 then 
		set[1]:ModPoint("BOTTOM", set, "BOTTOM", -(set[1].text:GetWidth() / 2), 3)
	elseif index == 2 then 
		set[1]:ModPoint("BOTTOM", set, "BOTTOM", -set[1].text:GetWidth()-set[1]:GetWidth() / 2, 3)
		frame.currencyButton[2]:ModPoint("BOTTOMLEFT", set, "BOTTOM", set[2]:GetWidth() / 2, 3)
	else 
		set[1]:ModPoint("BOTTOMLEFT", set, "BOTTOMLEFT", 3, 3)
		set[2]:ModPoint("BOTTOM", set, "BOTTOM", -(set[2].text:GetWidth() / 3), 3)
		set[3]:ModPoint("BOTTOMRIGHT", set, "BOTTOMRIGHT", -set[3].text:GetWidth()-set[3]:GetWidth() / 2, 3)
	end 
end


local function _openBags()
	GameTooltip:Hide()
	MOD.BagFrame:Show()
	MOD.BagFrame:RefreshBags()
	if(SV.Tooltip) then
		SV.Tooltip.GameTooltip_SetDefaultAnchor(GameTooltip)
	end
	MOD.BagFrame.editBox:SearchReset()
end

local function _closeBags()
	GameTooltip:Hide()
	MOD.BagFrame:Hide()
	if(MOD.BankFrame) then 
		MOD.BankFrame:Hide()
	end
	if(MOD.ReagentFrame) then 
		MOD.ReagentFrame:Hide()
	end
	if(SV.Dock.CloseBreakStuff) then
		SV.Dock:CloseBreakStuff()
	end
	if(SV.Tooltip) then
		SV.Tooltip.GameTooltip_SetDefaultAnchor(GameTooltip)
	end
	MOD.BagFrame.editBox:SearchReset()
end

local function _toggleBags(id)
	if(id and (GetContainerNumSlots(id) == 0)) then return end 
	if(MOD.BagFrame:IsShown()) then 
		_closeBags()
	else 
		_openBags()
	end 
end

local function _toggleBackpack()
	if IsOptionFrameOpen() then return end 
	if IsBagOpen(0) then 
		_openBags()
	else 
		_closeBags()
	end 
end

local _hook_OnModifiedClick = function(self, button)
	if(MerchantFrame and MerchantFrame:IsShown()) then return end;
    if(IsAltKeyDown() and (button == "RightButton")) then
    	local slotID = self:GetID()
    	local bagID = self:GetParent():GetID()
    	local itemID = GetContainerItemID(bagID, slotID);
    	if(itemID) then
    		if(MOD.private.junk[itemID]) then
    			if(self.JunkIcon) then self.JunkIcon:Hide() end
    			MOD.private.junk[itemID] = nil
	    	else
	    		if(self.JunkIcon) then self.JunkIcon:Show() end
	    		MOD.private.junk[itemID] = true
	    	end
    	end
    end
end

function MOD:BANKFRAME_OPENED()
	if(not self.BankFrame) then 
		self:MakeBankOrReagent()
	end
	self.BankFrame:UpdateLayout()

	if(not self.ReagentFrame) then 
		self:MakeBankOrReagent(true)
	end
	
	if(self.ReagentFrame) then 
		self.ReagentFrame:UpdateLayout()
	end

	self:ModifyBags()
	
	self.BankFrame:Show()
	self.BankFrame:RefreshBags()
	self.BagFrame:Show()
	self.BagFrame:RefreshBags()
	self.RefreshTokens()
end

function MOD:BANKFRAME_CLOSED()
	if(self.BankFrame and self.BankFrame:IsShown()) then 
		self.BankFrame:Hide()
	end
	if(self.ReagentFrame and self.ReagentFrame:IsShown()) then 
		self.ReagentFrame:Hide()
	end
end

function MOD:PLAYERBANKBAGSLOTS_CHANGED()
	if(self.BankFrame) then 
		self.BankFrame:UpdateLayout()
	end
	if(self.ReagentFrame) then 
		self.ReagentFrame:UpdateLayout()
	end
end 

function MOD:PLAYER_ENTERING_WORLD()
	self:UpdateGoldText()
	self.BagFrame:RefreshBags()
end 
--[[ 
########################################################## 
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:ReLoad()
	self:RefreshBagFrames()
	self:ModifyBags();
	self:ModifyBagBar();
end 

function MOD:Load()
	self:InitializeJournal()

	self:ModifyBagBar()
	self.BagFrames = {}
	self:MakeBags()
	self:ModifyBags()
	self.BagFrame:UpdateLayout()

	self:InitializeMenus()

	BankFrame:UnregisterAllEvents()
	for i = 1, NUM_CONTAINER_FRAMES do
		local frame = _G["ContainerFrame"..i]
		if(frame) then frame:Die() end
	end

	hooksecurefunc("OpenAllBags", _openBags)
	hooksecurefunc("CloseAllBags", _closeBags)
	hooksecurefunc("ToggleBag", _toggleBags)
	hooksecurefunc("ToggleAllBags", _toggleBackpack)
	hooksecurefunc("ToggleBackpack", _toggleBackpack)
	hooksecurefunc("BackpackTokenFrame_Update", self.RefreshTokens)
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", _hook_OnModifiedClick)

	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
	self:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")

	StackSplitFrame:SetFrameStrata("DIALOG")

	SV.SystemAlert["BUY_BANK_SLOT"] = {
		text = CONFIRM_BUY_BANK_SLOT, 
		button1 = YES, 
		button2 = NO, 
		OnAccept = function(self) PurchaseSlot() end, 
		OnShow = function(self) MoneyFrame_Update(self.moneyFrame, GetBankSlotCost()) end, 
		hasMoneyFrame = 1, 
		timeout = 0, 
		hideOnEscape = 1
	};
	SV.SystemAlert["CONFIRM_BUY_REAGENTBANK_TAB"] = {
		text = L["Purchase Reagents Bank?"], 
		button1 = YES, 
		button2 = NO, 
		OnAccept = function(self) BuyReagentBank() end, 
		OnShow = function(self)
			MoneyFrame_Update(self.moneyFrame, GetReagentBankCost());
			if(MOD.ReagentFrame) then
				MOD.ReagentFrame:UpdateLayout()
				MOD.ReagentFrame:Show()
				if(MOD.ReagentFrame.swapButton) then
					MOD.ReagentFrame.swapButton:SetNormalTexture(MOD.media.reagentIcon)
				end
			end
		end, 
		hasMoneyFrame = 1, 
		timeout = 0, 
		hideOnEscape = 1
	};
	SV.SystemAlert["CANNOT_BUY_BANK_SLOT"] = {
		text = L["Can't buy anymore slots!"], 
		button1 = ACCEPT, 
		timeout = 0, 
		whileDead = 1
	};
	SV.SystemAlert["NO_BANK_BAGS"] = {
		text = L["You must purchase a bank slot first!"], 
		button1 = ACCEPT, 
		timeout = 0, 
		whileDead = 1
	};
end 