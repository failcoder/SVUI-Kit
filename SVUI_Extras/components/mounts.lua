--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 		= _G.unpack;
local select 		= _G.select;
local pairs 		= _G.pairs;
local tonumber		= _G.tonumber;
local tinsert 		= _G.tinsert;
local table 		= _G.table;
local math 			= _G.math;
local bit 			= _G.bit;
local random 		= math.random; 
local twipe,band 	= table.wipe, bit.band;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Extras;
--[[ 
########################################################## 
LOCAL VARIABLES
##########################################################
]]--
local ttSummary = "";
local NewHook = hooksecurefunc;
local CountMounts, MountInfo, RandomMount, MountUp, UnMount;

local MountListener = CreateFrame("Frame");
MountListener.favorites = false
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
function CountMounts()
	return C_MountJournal.GetNumMounts()
end
function MountInfo(index)
	return true, C_MountJournal.GetMountInfo(index)
end
function RandomMount()
	if(MountListener.favorites) then
		return 0
	end
	local maxMounts = C_MountJournal.GetNumMounts()
	return random(1, maxMounts)
end
function MountUp(index)
	index = index or RandomMount()
	return C_MountJournal.Summon(index)
end
UnMount = C_MountJournal.Dismiss

local function UpdateMountCheckboxes(button, index)
	local _, creatureName = MountInfo(index);

	local n = button.MountBar
	local bar = _G[n]

	if(bar) then
		bar["GROUND"].index = index
		bar["GROUND"].name = creatureName
		bar["FLYING"].index = index
		bar["FLYING"].name = creatureName
		bar["SWIMMING"].index = index
		bar["SWIMMING"].name = creatureName
	    bar["SPECIAL"].index = index
	    bar["SPECIAL"].name = creatureName

		if(MOD.private.Mounts.names["GROUND"] == creatureName) then
			if(MOD.private.Mounts.types["GROUND"] ~= index) then
				MOD.private.Mounts.types["GROUND"] = index
			end
			bar["GROUND"]:SetChecked(true)
		else
			bar["GROUND"]:SetChecked(false)
		end

		if(MOD.private.Mounts.names["FLYING"] == creatureName) then
			if(MOD.private.Mounts.types["FLYING"] ~= index) then
				MOD.private.Mounts.types["FLYING"] = index
			end
			bar["FLYING"]:SetChecked(true)
		else
			bar["FLYING"]:SetChecked(false)
		end

		if(MOD.private.Mounts.names["SWIMMING"] == creatureName) then
			if(MOD.private.Mounts.types["SWIMMING"] ~= index) then
				MOD.private.Mounts.types["SWIMMING"] = index
			end
			bar["SWIMMING"]:SetChecked(true)
		else
			bar["SWIMMING"]:SetChecked(false)
		end

		if(MOD.private.Mounts.names["SPECIAL"] == creatureName) then
			if(MOD.private.Mounts.types["SPECIAL"] ~= index) then
				MOD.private.Mounts.types["SPECIAL"] = index
			end
			bar["SPECIAL"]:SetChecked(true)
		else
			bar["SPECIAL"]:SetChecked(false)
		end
	end
end

local function UpdateMountsCache()
	if(not MountJournal) then return end
	local num = CountMounts()
	MountListener.favorites = false

	for index = 1, num, 1 do
		local _, info, id, _, _, _, _, _, favorite = MountInfo(index)
		if(favorite == true) then
			MountListener.favorites = true
		end
		if(MOD.private.Mounts.names["GROUND"] == info) then
			if(MOD.private.Mounts.types["GROUND"] ~= index) then
				MOD.private.Mounts.types["GROUND"] = index
			end
		end
		if(MOD.private.Mounts.names["FLYING"] == info) then
			if(MOD.private.Mounts.types["FLYING"] ~= index) then
				MOD.private.Mounts.types["FLYING"] = index
			end
		end
		if(MOD.private.Mounts.names["SWIMMING"] == info) then
			if(MOD.private.Mounts.types["SWIMMING"] ~= index) then
				MOD.private.Mounts.types["SWIMMING"] = index
			end
		end
		if(MOD.private.Mounts.names["SPECIAL"] == info) then
			if(MOD.private.Mounts.types["SPECIAL"] ~= index) then
				MOD.private.Mounts.types["SPECIAL"] = index
			end
		end
	end
end

local function Update_MountCheckButtons()
	if(not MountJournal or (MountJournal and not MountJournal.cachedMounts)) then return end
	local count = #MountJournal.cachedMounts
	if(type(count) ~= "number") then return end 
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
	for i=1, #buttons do
        local button = buttons[i];
        local displayIndex = i + offset;
        if ( displayIndex <= count ) then
			local index = MountJournal.cachedMounts[displayIndex];
			UpdateMountCheckboxes(button, index)
		end
	end
end

local ProxyUpdate_Mounts = function(self, event, ...)
	if(event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED") then
		UpdateMountsCache()
	end
	Update_MountCheckButtons()
end

local function UpdateCurrentMountSelection()
	ttSummary = ""
	local creatureName

	if(MOD.private.Mounts.types["FLYING"]) then
		creatureName = MOD.private.Mounts.names["FLYING"]
		if(creatureName) then
			ttSummary = ttSummary .. "\nFlying: " .. creatureName
		end
	end

	if(MOD.private.Mounts.types["SWIMMING"]) then
		creatureName = MOD.private.Mounts.names["SWIMMING"]
		if(creatureName) then
			ttSummary = ttSummary .. "\nSwimming: " .. creatureName
		end
	end

	if(MOD.private.Mounts.types["GROUND"]) then
		creatureName = MOD.private.Mounts.names["GROUND"]
		if(creatureName) then
			ttSummary = ttSummary .. "\nGround: " .. creatureName
		end
	end

	if(MOD.private.Mounts.types["SPECIAL"]) then
		creatureName = MOD.private.Mounts.names["SPECIAL"]
		if(creatureName) then
			ttSummary = ttSummary .. "\nSpecial: " .. creatureName
		end
	end
end

local CheckButton_OnClick = function(self)
	local index = self.index
	local name = self.name
	local key = self.key

	if(index) then
		if(self:GetChecked() == true) then
			MOD.private.Mounts.types[key] = index
			MOD.private.Mounts.names[key] = name
		else
			MOD.private.Mounts.types[key] = false
			MOD.private.Mounts.names[key] = ""
		end
		Update_MountCheckButtons()
		UpdateCurrentMountSelection()
	end
	GameTooltip:Hide()
end

local CheckButton_OnEnter = function(self)
	local index = self.name
	local key = self.key
	local r,g,b = self:GetBackdropColor()
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 20)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(key,r,g,b)
	GameTooltip:AddLine("",1,1,0)
	GameTooltip:AddLine("Check this box to enable/disable \nthis mount for \nthe 'Lets Ride' key-binding",1,1,1)
	if(key == "SPECIAL") then
		GameTooltip:AddLine("",1,1,0)
		GameTooltip:AddLine("Hold |cff00FF00[SHIFT]|r or |cff00FF00[CTRL]|r while \nclicking to force this mount \nover all others.",1,1,1)
	end
	GameTooltip:AddLine(ttSummary,1,1,1)
	
	GameTooltip:Show()
end

local CheckButton_OnLeave = function(self)
	GameTooltip:Hide()
end

local _hook_SetChecked = function(self, checked)
    local r,g,b = 0,0,0
    if(checked) then
        r,g,b = self:GetCheckedTexture():GetVertexColor()
    end
    self:SetBackdropBorderColor(r,g,b) 
end

local function CreateMountCheckBox(name, parent)
	local frame = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    frame:SetStyle("Frame", "Icon", true, 1)

    if(frame.Left) then frame.Left:SetAlpha(0) end 
    if(frame.Middle) then frame.Middle:SetAlpha(0) end 
    if(frame.Right) then frame.Right:SetAlpha(0) end 
    if(frame.SetNormalTexture) then frame:SetNormalTexture("") end 
    if(frame.SetDisabledTexture) then frame:SetDisabledTexture("") end
    if(frame.SetCheckedTexture) then frame:SetCheckedTexture("") end
    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover) 
    end
    if(frame.SetPushedTexture) then
        if(not frame.pushed) then 
            local pushed = frame:CreateTexture(nil, "OVERLAY")
            pushed:InsetPoints(frame.Panel)
            frame.pushed = pushed;
        end
        frame.pushed:SetTexture(0.1, 0.8, 0.1, 0.3)
        frame:SetPushedTexture(frame.pushed)
    end 
    if(frame.SetCheckedTexture) then
        if(not frame.checked) then
            local checked = frame:CreateTexture(nil, "OVERLAY")
            checked:InsetPoints(frame.Panel)
            frame.checked = checked
        end

        frame.checked:SetTexture(SV.Media.bar.gloss)
        frame.checked:SetVertexColor(0, 1, 0, 1)
        
        frame:SetCheckedTexture(frame.checked)
    end

    hooksecurefunc(frame, "SetChecked", _hook_SetChecked)

    return frame
end;
--[[ 
########################################################## 
SLASH FUNCTION
##########################################################
]]--
_G.SVUILetsRide = function()
	local maxMounts = CountMounts()

	if(not maxMounts or IsMounted()) then
		UnMount()
		return
	end

	if(CanExitVehicle()) then
		VehicleExit()
		return
	end

	MOD.private.Mounts = MOD.private.Mounts or {}
	if not MOD.private.Mounts.types then 
		MOD.private.Mounts.types = {
			["GROUND"] = false, 
			["FLYING"] = false, 
			["SWIMMING"] = false, 
			["SPECIAL"] = false
		}
	end

	local continent = GetCurrentMapContinent()
	local checkList = MOD.private.Mounts.types
	local letsFly = (IsFlyableArea() and (continent ~= 962 and continent ~= 7))
	local letsSwim = IsSwimming()

	if(IsModifierKeyDown() and checkList["SPECIAL"]) then
		MountUp(checkList["SPECIAL"])
	else
		if(letsSwim) then
			if(checkList["SWIMMING"]) then
				MountUp(checkList["SWIMMING"])
			elseif(letsFly) then
				MountUp(checkList["FLYING"])
			else
				MountUp(checkList["GROUND"])
			end
		elseif(letsFly) then
			if(checkList["FLYING"]) then
				MountUp(checkList["FLYING"])
			else
				MountUp(checkList["GROUND"])
			end
		else
			MountUp(checkList["GROUND"])
		end
	end
end
--[[ 
########################################################## 
ADDING CHECKBOXES TO JOURNAL
##########################################################
]]--
function MOD:SetMountCheckButtons()
	if(SV.GameVersion > 60000) then
		LoadAddOn("Blizzard_Collections")
	else
		LoadAddOn("Blizzard_PetJournal")
	end
	MOD.private.Mounts = MOD.private.Mounts or {}

	if not MOD.private.Mounts.types then 
		MOD.private.Mounts.types = {
			["GROUND"] = false, 
			["FLYING"] = false, 
			["SWIMMING"] = false, 
			["SPECIAL"] = false
		}
	end
	if not MOD.private.Mounts.names then 
		MOD.private.Mounts.names = {
			["GROUND"] = "", 
			["FLYING"] = "", 
			["SWIMMING"] = "", 
			["SPECIAL"] = ""	
		} 
	end

	UpdateMountsCache()

	local scrollFrame = MountJournal.ListScrollFrame;
	local scrollBar = _G["MountJournalListScrollFrameScrollBar"]
    local buttons = scrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i]
		local barWidth = button:GetWidth()
		local width = (barWidth - 18) * 0.25
		local height = 7
		local barName = ("SVUI_MountSelectBar%d"):format(i)

		local buttonBar = CreateFrame("Frame", barName, button)
		buttonBar:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
		buttonBar:SetSize(barWidth, height + 8)

		--[[ CREATE CHECKBOXES ]]--
		buttonBar["GROUND"] = CreateMountCheckBox(("%s_GROUND"):format(barName), buttonBar)
		buttonBar["GROUND"]:SetSize(width,height)
		buttonBar["GROUND"]:SetPoint("BOTTOMLEFT", buttonBar, "BOTTOMLEFT", 6, 4)
		buttonBar["GROUND"]:RemoveTextures()
	    buttonBar["GROUND"]:SetPanelColor(0.2, 0.7, 0.1, 0.15)
	    buttonBar["GROUND"]:GetCheckedTexture():SetVertexColor(0.2, 0.7, 0.1, 1)
	    buttonBar["GROUND"].key = "GROUND"
		buttonBar["GROUND"]:SetChecked(false)
		buttonBar["GROUND"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["GROUND"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["GROUND"]:SetScript("OnLeave", CheckButton_OnLeave)

	    buttonBar["FLYING"] = CreateMountCheckBox(("%s_FLYING"):format(barName), buttonBar)
		buttonBar["FLYING"]:SetSize(width,height)
		buttonBar["FLYING"]:SetPoint("BOTTOMLEFT", buttonBar["GROUND"], "BOTTOMRIGHT", 2, 0)
		buttonBar["FLYING"]:RemoveTextures()
	    buttonBar["FLYING"]:SetPanelColor(1, 1, 0.2, 0.15)
	    buttonBar["FLYING"]:GetCheckedTexture():SetVertexColor(1, 1, 0.2, 1)
	    buttonBar["FLYING"].key = "FLYING"
		buttonBar["FLYING"]:SetChecked(false)
		buttonBar["FLYING"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["FLYING"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["FLYING"]:SetScript("OnLeave", CheckButton_OnLeave)

	    buttonBar["SWIMMING"] = CreateMountCheckBox(("%s_SWIMMING"):format(barName), buttonBar)
		buttonBar["SWIMMING"]:SetSize(width,height)
		buttonBar["SWIMMING"]:SetPoint("BOTTOMLEFT", buttonBar["FLYING"], "BOTTOMRIGHT", 2, 0)
		buttonBar["SWIMMING"]:RemoveTextures()
	    buttonBar["SWIMMING"]:SetPanelColor(0.2, 0.42, 0.76, 0.15)
	    buttonBar["SWIMMING"]:GetCheckedTexture():SetVertexColor(0.2, 0.42, 0.76, 1)
	    buttonBar["SWIMMING"].key = "SWIMMING"
		buttonBar["SWIMMING"]:SetChecked(false)
		buttonBar["SWIMMING"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["SWIMMING"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["SWIMMING"]:SetScript("OnLeave", CheckButton_OnLeave)

		buttonBar["SPECIAL"] = CreateMountCheckBox(("%s_SPECIAL"):format(barName), buttonBar)
		buttonBar["SPECIAL"]:SetSize(width,height)
		buttonBar["SPECIAL"]:SetPoint("BOTTOMLEFT", buttonBar["SWIMMING"], "BOTTOMRIGHT", 2, 0)
		buttonBar["SPECIAL"]:RemoveTextures()
	    buttonBar["SPECIAL"]:SetPanelColor(0.7, 0.1, 0.1, 0.15)
	    buttonBar["SPECIAL"]:GetCheckedTexture():SetVertexColor(0.7, 0.1, 0.1, 1)
	    buttonBar["SPECIAL"].key = "SPECIAL"	
		buttonBar["SPECIAL"]:SetChecked(false)
		buttonBar["SPECIAL"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["SPECIAL"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["SPECIAL"]:SetScript("OnLeave", CheckButton_OnLeave)

		button.MountBar = barName

		UpdateMountCheckboxes(button, i)
	end

	UpdateCurrentMountSelection()

	MountListener:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
	
	MountListener:RegisterEvent("COMPANION_LEARNED")
	MountListener:RegisterEvent("COMPANION_UNLEARNED")
	MountListener:RegisterEvent("COMPANION_UPDATE")
	MountListener:SetScript("OnEvent", ProxyUpdate_Mounts)

	scrollFrame:HookScript("OnMouseWheel", Update_MountCheckButtons)
	scrollBar:HookScript("OnValueChanged", Update_MountCheckButtons)
	NewHook("MountJournal_UpdateMountList", Update_MountCheckButtons)
end