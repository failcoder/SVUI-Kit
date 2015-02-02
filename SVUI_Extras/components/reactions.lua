--[[
##########################################################
S V U I   By: S.Jackson
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
--[[ STRING METHODS ]]--
local format, gsub = string.format, string.gsub;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Extras;
--[[ 
########################################################## 
LOCALS (from ShestakUI  by:Shestak)
##########################################################
]]--
local toon = UnitName("player");

local Reactions = {
	Woot = {
		[29166] = true, [20484] = true, [61999] = true, 
		[20707] = true, [50769] = true, [2006] = true, 
		[7328] = true, [2008] = true, [115178] = true, 
		[110478] = true, [110479] = true, [110482] = true, 
		[110483] = true, [110484] = true, [110485] = true, 
		[110486] = true, [110488] = true, [110490] = true, 
		[110491] = true
	},
	LookWhatICanDo = {
		34477, 19801, 57934, 633, 20484, 113269, 61999, 
		20707, 2908, 120668, 16190, 64901, 108968
	},
	Toys = {
		[61031] = true, [49844] = true
	},
	Bots = {
		[22700] = true, [44389] = true, [54711] = true, 
		[67826] = true, [126459] = true
	},
	Portals = {
		[10059] = true, [11416] = true, [11419] = true, 
		[32266] = true, [49360] = true, [33691] = true, 
		[88345] = true, [132620] = true, [11417] = true, 
		[11420] = true, [11418] = true, [32267] = true, 
		[49361] = true, [35717] = true, [88346] = true, 
		[132626] = true, [53142] = true
	},
	StupidHat = {
		[1] = {88710, 33820, 19972, 46349, 92738}, 
		[2] = {32757}, 
		[8] = {50287, 19969}, 
		[15] = {65360, 65274}, 
		[16] = {44050, 19970, 84660, 84661, 45992, 86559, 45991}, 
		[17] = {86558}
	}
}

local MsgTest = function(warning)
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
--[[ 
########################################################## 
WEARING NON COMBAT GEAR
##########################################################
]]--
local StupidHatHandler = CreateFrame("Frame")
local StupidHatHandler_OnEvent = function(self, event)
	if(not IsInInstance()) then return end
	local item = {}
	for i = 1, 17 do
		if Reactions.StupidHat[i] ~= nil then
			item[i] = GetInventoryItemID("player", i) or 0
			for j, baditem in pairs(Reactions.StupidHat[i]) do
				if item[i] == baditem then
					PlaySound("RaidWarning", "master")
					RaidNotice_AddMessage(RaidWarningFrame, format("%s %s", CURRENTLY_EQUIPPED, GetItemInfo(item[i]).."!!!"), ChatTypeInfo["RAID_WARNING"])
					print(format("|cffff3300%s %s", CURRENTLY_EQUIPPED, GetItemInfo(item[i]).."!!!|r"))
				end
			end
		end
	end
end
--[[ 
########################################################## 
VARIOUS COMBAT REACTIONS
##########################################################
]]--
local random = math.random
local function rng()
	return random(1,6)
end

local REACTION_INTERRUPT, REACTION_WOOT, REACTION_LOOKY, REACTION_SHARE, REACTION_EMOTE, REACTION_CHAT = false, false, false, false, false, false;

local SAPPED_MESSAGE = {
	"Oh Hell No ... {rt8}SAPPED{rt8}", 
	"{rt8}SAPPED{rt8} ...Someone's about to get slapped!", 
	"Mother Fu... {rt8}SAPPED{rt8}", 
	"{rt8}SAPPED{rt8} ...How cute", 
	"{rt8}SAPPED{rt8} ...Ain't Nobody Got Time For That!", 
	"Uh-Oh... {rt8}SAPPED{rt8}"
}

local ReactionEmotes = {
	"SALUTE",
	"THANK",
	"DRINK"
}

local function Thanks_Emote(sourceName)
	if not REACTION_EMOTE then return end
	local index = random(1,#ReactionEmotes)
	DoEmote(ReactionEmotes[index], sourceName)
end

local ChatLogHandler = CreateFrame("Frame")
local ChatLogHandler_OnEvent = function(self, event, ...)
	local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, _, _, otherSpellID = ...

	if not sourceName then return end

	if(REACTION_INTERRUPT) then
		if ((spellID == 6770) and (destName == toon) and (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH")) then
			local msg = SAPPED_MESSAGE[rng()]
			SendChatMessage(msg, "SAY")
			SV:AddonMessage("Sapped by: "..sourceName)
			DoEmote("CRACK", sourceName)
		elseif(subEvent == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") and IsInGroup()) then
			SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(otherSpellID), MsgTest())
		end
	end

	if(REACTION_WOOT) then
		for key, value in pairs(Reactions.Woot) do
			if spellID == key and value == true and destName == toon and sourceName ~= toon and (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_SUCCESS") then
				Thanks_Emote(sourceName)
				--SendChatMessage(L["Thanks for "]..GetSpellLink(spellID)..", "..sourceName, "WHISPER", nil, sourceName)
				print(GetSpellLink(spellID)..L[" received from "]..sourceName)
			end
		end
	end

	if(REACTION_LOOKY) then
		local outbound;
		local spells = Reactions.LookWhatICanDo
		local _, _, difficultyID = GetInstanceInfo()

		if(difficultyID ~= 0 and subEvent == "SPELL_CAST_SUCCESS") then
			if(not (sourceGUID == UnitGUID("player") and sourceName == toon)) then
				for i, spells in pairs(spells) do
					if(spellID == spells) then
						if(destName == nil) then
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
						else
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID).." -> "..destName)
						end
						if(REACTION_CHAT) then
							SendChatMessage(outbound, MsgTest())
						else
							print(outbound)
						end
					end
				end
			else
				if(not (sourceGUID == UnitGUID("player") and sourceName == toon)) then return end
				for i, spells in pairs(spells) do
					if(spellID == spells) then
						if(destName == nil) then
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
						else
							outbound = GetSpellLink(spellID).." -> "..destName
						end
						if(REACTION_CHAT) then
							SendChatMessage(outbound, MsgTest())
						else
							print(outbound)
						end
					end
				end
			end
		end
	end

	if(REACTION_SHARE) then
		if not IsInGroup() or InCombatLockdown() or not subEvent or not spellID then return end
		if not UnitInRaid(sourceName) and not UnitInParty(sourceName) then return end

		local sourceName = format(sourceName:gsub("%-[^|]+", ""))
		if(not sourceName) then return end
		local thanks = false
		local outbound
		if subEvent == "SPELL_CAST_SUCCESS" then
			-- Feasts
			if (spellID == 126492 or spellID == 126494) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT1_NAME)
			elseif (spellID == 126495 or spellID == 126496) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT2_NAME)
			elseif (spellID == 126501 or spellID == 126502) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT3_NAME)
			elseif (spellID == 126497 or spellID == 126498) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT4_NAME)
			elseif (spellID == 126499 or spellID == 126500) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT5_NAME)
			elseif (spellID == 104958 or spellID == 105193 or spellID == 126503 or spellID == 126504 or spellID == 145166 or spellID == 145169 or spellID == 145196) then
				outbound = (L["%s has prepared a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Refreshment Table
			elseif spellID == 43987 then
				outbound = (L["%s has prepared a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Ritual of Summoning
			elseif spellID == 698 then
				outbound = (L["%s is casting %s. Click!"]):format(sourceName, GetSpellLink(spellID))
			-- Piccolo of the Flaming Fire
			elseif spellID == 18400 then
				outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
			end
			if(outbound) then thanks = true end
		elseif subEvent == "SPELL_SUMMON" then
			-- Repair Bots
			if Reactions.Bots[spellID] then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
				thanks = true
			end
		elseif subEvent == "SPELL_CREATE" then
			-- Ritual of Souls and MOLL-E
			if (spellID == 29893 or spellID == 54710) then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
				thanks = true
			-- Toys
			elseif Reactions.Toys[spellID] then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Portals
			elseif Reactions.Portals[spellID] then
				outbound = (L["%s is casting %s."]):format(sourceName, GetSpellLink(spellID))
			end
		elseif subEvent == "SPELL_AURA_APPLIED" then
			-- Turkey Feathers and Party G.R.E.N.A.D.E.
			if (spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == toon)) then
				outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
			end
		end

		if(outbound) then
			if(REACTION_CHAT) then
				SendChatMessage(outbound, MsgTest(true))
			else
				print(outbound)
			end
			if(thanks and sourceName) then
				Thanks_Emote(sourceName)
			end
		end
	end
end
--[[ 
########################################################## 
CONFIG TOGGLE
##########################################################
]]--
function MOD:ToggleReactions()
	local settings = SV.db.Extras

	REACTION_INTERRUPT = settings.pvpinterrupt
	REACTION_WOOT = settings.woot
	REACTION_LOOKY = settings.lookwhaticando
	REACTION_SHARE = settings.sharingiscaring
	REACTION_EMOTE = settings.reactionEmote
	REACTION_CHAT = settings.reactionChat

	if(settings.stupidhat) then
		StupidHatHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		StupidHatHandler:SetScript("OnEvent", StupidHatHandler_OnEvent)
	else
		StupidHatHandler:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		StupidHatHandler:SetScript("OnEvent", nil)
	end

	if(not REACTION_SHARE) and (not REACTION_INTERRUPT) and (not REACTION_WOOT) and (not REACTION_LOOKY) then
		ChatLogHandler:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		ChatLogHandler:SetScript("OnEvent", nil)
	else
		ChatLogHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		ChatLogHandler:SetScript("OnEvent", ChatLogHandler_OnEvent)
	end
end