--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################

STATS:Extend EXAMPLE USAGE: Reports:NewReportType(newStat,eventList,onEvents,update,click,focus,blur)

########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local type 		= _G.type;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local format, join = string.format, string.join;
--[[ MATH METHODS ]]--
local floor = math.floor;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local Reports = SV.Reports;
--[[ 
########################################################## 
TIME STATS (Credit: Elv)
##########################################################
]]--
local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }
local europeDisplayFormat = '';
local ukDisplayFormat = '';
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = join("", "", "%d", ":|r%02d", " %s|r")
local timerLongFormat = "%d:%02d:%02d"
local timerShortFormat = "%d:%02d"
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local lockoutFormatString = { "%dd %02dh %02dm", "%dd %dh %02dm", "%02dh %02dm", "%dh %02dm", "%dh %02dm", "%dm" }
local curHr, curMin, curAmPm
local enteredFrame = false;
local date = _G.date

local Update, lastPanel; -- UpValue
local localizedName, isActive, canQueue, startTime, canEnter, _
local name, instanceID, reset, difficultyId, locked, extended, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress

local function ValueColorUpdate(hex, r, g, b)
	europeDisplayFormat = join("", "%02d", hex, ":|r%02d")
	ukDisplayFormat = join("", "", "%d", hex, ":|r%02d", hex, " %s|r")
	
	if lastPanel ~= nil then
		Update(lastPanel, 20000)
	end
end

local function ConvertTime(h, m)
	local AmPm
	if SV.db.Reports.time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and SV.db.Reports.localtime) or (not tooltip and not SV.db.Reports.localtime) then
		return ConvertTime(GetGameTime())
	else
		local dateTable = date("*t")
		return ConvertTime(dateTable["hour"], dateTable["min"])
	end
end

local function Click()
	GameTimeFrame:Click();
end

local function OnLeave(self)
	Reports.ReportTooltip:Hide();
	enteredFrame = false;
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		RequestRaidInfo()
	end
end

local function OnEnter(self)
	Reports:SetDataTip(self)

	if(not enteredFrame) then
		enteredFrame = true;
		RequestRaidInfo()
	end

	Reports.ReportTooltip:AddLine(VOICE_CHAT_BATTLEGROUND);
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			Reports.ReportTooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)	
		end
	end	

	local oneraid, lockoutColor
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			if not oneraid then
				Reports.ReportTooltip:AddLine(" ")
				Reports.ReportTooltip:AddLine(L["Saved Raid(s)"])
				oneraid = true
			end
			if extended then 
				lockoutColor = lockoutColorExtended 
			else 
				lockoutColor = lockoutColorNormal 
			end
			
			local _, _, isHeroic, _ = GetDifficultyInfo(difficultyId)
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				Reports.ReportTooltip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, (isHeroic and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				Reports.ReportTooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, (isHeroic and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end			
		end
	end	
	
	local addedLine = false
	for i = 1, GetNumSavedWorldBosses() do
		name, instanceID, reset = GetSavedWorldBossInfo(i)
		if(reset) then
			if(not addedLine) then
				Reports.ReportTooltip:AddLine(' ')
				Reports.ReportTooltip:AddLine(RAID_INFO_WORLD_BOSS.."(s)")
				addedLine = true
			end
			Reports.ReportTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)		
		end
	end
	
	local timeText
	local Hr, Min, AmPm = CalculateTimeValues(true)

	Reports.ReportTooltip:AddLine(" ")
	if AmPm == -1 then
		Reports.ReportTooltip:AddDoubleLine(SV.db.Reports.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, 
			format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		Reports.ReportTooltip:AddDoubleLine(SV.db.Reports.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end	
	
	Reports.ReportTooltip:Show()
end

local int = 3
function Update(self, t)
	int = int - t
		
	if int > 0 then return end
	
	if GameTimeFrame.flashInvite then
		SV.Animate:Flash(self, 0.53)
	else
		SV.Animate:StopFlash(self)
	end	

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end
	
	curHr = Hr
	curMin = Min
	curAmPm = AmPm
		
	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
	lastPanel = self
	int = 5
end

local TimeColorUpdate = function()
	local hexColor = SV:HexColor("highlight")
	europeDisplayFormat = join("", "%02d|cff", hexColor, ":|r%02d")
	ukDisplayFormat = join("", "", "%d|cff", hexColor, ":|r%02d|cff", hexColor, " %s|r")
	if lastPanel ~= nil then 
		Update(lastPanel, 20000)
	end 
end 

SV.Events:On("SHARED_MEDIA_UPDATED", TimeColorUpdate, true)

Reports:NewReportType('Time', {"UPDATE_INSTANCE_INFO"}, OnEvent, Update, Click, OnEnter, OnLeave)