--[[
##############################################################################
M O D K I T   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local select  		= _G.select;
local unpack  		= _G.unpack;
local pairs   		= _G.pairs;
local ipairs  		= _G.ipairs;
local type    		= _G.type;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local print         = _G.print;
local string  		= _G.string;
local math    		= _G.math;
local table   		= _G.table;
local GetTime 		= _G.GetTime;
--[[ STRING METHODS ]]--
local format = string.format;
local lower, trim = string.lower, string.trim
--[[ MATH METHODS ]]--
local floor, modf = math.floor, math.modf;
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--BLIZZARD API
local ReloadUI              = _G.ReloadUI;
local EnableAddOn           = _G.EnableAddOn;
local DisableAddOn          = _G.DisableAddOn;
local GetAddOnInfo          = _G.GetAddOnInfo;
local GetAddOnMetadata      = _G.GetAddOnMetadata;
local PlaySoundFile   		= _G.PlaySoundFile;

local SV = select(2, ...)
local L = SV.L;
--[[ 
########################################################## 
LOCAL SLASH FUNCTIONS
##########################################################
]]--
SV.SlashRegistry = {};

local function SVUIMasterCommand(msg)
	if msg then
		msg = lower(trim(msg))
		if (msg == "install") then
			SV.Setup:Install()
		elseif (msg == "move") then
			SV.Layout:Toggle()
		elseif (msg == "reset" or msg == "resetui") then
			SV:ResetAllUI()
		elseif(SV.SlashRegistry[msg] and (type(SV.SlashRegistry[msg]) == 'function')) then
			SV.SlashRegistry[msg]()
		-- elseif (msg == "bg" or msg == "pvp") then
		-- 	local MOD = SV.Dock
		-- 	MOD.ForceHideBGStats = nil;
		-- 	MOD:UpdateAllReports()
		-- 	SV:AddonMessage(L['Battleground statistics will now show again if you are inside a battleground.'])
		else
			SV:ToggleConfig()
		end
	else
		SV:ToggleConfig()
	end
end

local function EnableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		EnableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end	
end

local function DisableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		DisableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end
end
--[[ 
########################################################## 
LOAD ALL SLASH FUNCTIONS
##########################################################
]]--
_G.SlashCmdList["SVUISV"] = SVUIMasterCommand;
_G.SLASH_SVUISV1="/sv"

_G.SlashCmdList["SVUIENABLE"] = EnableAddon;
_G.SLASH_SVUIENABLE1="/enable"

_G.SlashCmdList["SVUIDISABLE"] = DisableAddon;
_G.SLASH_SVUIDISABLE1="/disable"

_G.SlashCmdList["LOLWUT"] = function(msg)
	PlaySoundFile("Sound\\Character\\Human\\HumanVocalFemale\\HumanFemalePissed04.wav")
end
_G.SLASH_LOLWUT1 = "/lolwut";
--[[ 
########################################################## 
LEEEEEROY
##########################################################
]]--
local UnitName   			= _G.UnitName;
local IsInGroup             = _G.IsInGroup;
local CreateFrame           = _G.CreateFrame;
local IsInRaid         		= _G.IsInRaid;
local UnitIsGroupLeader     = _G.UnitIsGroupLeader;
local SendChatMessage   	= _G.SendChatMessage;
local IsEveryoneAssistant   = _G.IsEveryoneAssistant;
local UnitIsGroupAssistant  = _G.UnitIsGroupAssistant;
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME;
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE;

do
	local PullCountdown = CreateFrame("Frame", "PullCountdown")
	local PullCountdownHandler = CreateFrame("Frame")
	local firstdone, delay, target
	local interval = 1.5
	local lastupdate = 0

	local function reset()
		PullCountdownHandler:SetScript("OnUpdate", nil)
		firstdone, delay, target = nil, nil, nil
		lastupdate = 0
	end

	local function setmsg(warning)
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			return "INSTANCE_CHAT"
		elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
			if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
				return "RAID_WARNING"
			else
				return "RAID"
			end
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			return "PARTY"
		end
		return "SAY"
	end

	local function pull(self, elapsed)
		local tname = UnitName("target")
		if tname then
			target = tname
		else
			target = ""
		end
		if not firstdone then
			SendChatMessage((L["Pulling %s in %s.."]):format(target, tostring(delay)), setmsg(true))
			firstdone = true
			delay = delay - 1
		end
		lastupdate = lastupdate + elapsed
		if lastupdate >= interval then
			lastupdate = 0
			if delay > 0 then
				SendChatMessage(tostring(delay).."..", setmsg(true))
				delay = delay - 1
			else
				SendChatMessage(L["Leeeeeroy!"], setmsg(true))
				reset()
			end
		end
	end

	function PullCountdown.Pull(timer)
		delay = timer or 3
		if PullCountdownHandler:GetScript("OnUpdate") then
			reset()
			SendChatMessage(L["Pull ABORTED!"], setmsg(true))
		else
			PullCountdownHandler:SetScript("OnUpdate", pull)
		end
	end
	
	_G.SLASH_PULLCOUNTDOWN1 = "/jenkins"
	_G.SlashCmdList["PULLCOUNTDOWN"] = function(msg)
		if(tonumber(msg) ~= nil) then
			PullCountdown.Pull(msg)
		else
			PullCountdown.Pull()
		end
	end
end