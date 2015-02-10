--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
local len          	= string.len;
local sub          	= string.sub;
--MATH
local math          = _G.math;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--BLIZZARD API
local time 					= _G.time;
local difftime 				= _G.difftime;
local BetterDate 			= _G.BetterDate;
local ReloadUI              = _G.ReloadUI;
local UnitName   			= _G.UnitName;
local IsInGroup             = _G.IsInGroup;
local CreateFrame           = _G.CreateFrame;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = LibStub("LibSharedMedia-3.0")
local MOD = SV.Chat;
if(not MOD) then return end;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local SetAllChatHooks, SetParseHandlers;
local internalTest = false
local locale = GetLocale()
local NewHook = hooksecurefunc;
--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, Chat has to continuously 
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
local CHAT_WIDTH = 350;
local CHAT_HEIGHT = 180;
local CHAT_THROTTLE = 45;
local CHAT_ALLOW_URL = true;
local CHAT_HOVER_URL = true;
local CHAT_STICKY = true;
local TAB_WIDTH = 75;
local TAB_HEIGHT = 20;
local TAB_SKINS = true;
local CHAT_FADING = false;
local TIME_STAMP_MASK = "NONE";
local THROTTLE_CACHE = {};
local COPY_LINES = {};
local ACTIVE_HYPER_LINK;
local TABS_DIRTY = false;
--[[ 
########################################################## 
INIT SETTINGS
##########################################################
]]--
local CHAT_FRAMES = _G.CHAT_FRAMES
local CHAT_GUILD_GET = "|Hchannel:GUILD|hG|h %s ";
local CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s ";
local CHAT_RAID_GET = "|Hchannel:RAID|hR|h %s ";
local CHAT_RAID_WARNING_GET = "RW %s ";
local CHAT_RAID_LEADER_GET = "|Hchannel:RAID|hRL|h %s ";
local CHAT_PARTY_GET = "|Hchannel:PARTY|hP|h %s ";
local CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|hPL|h %s ";
local CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|hPG|h %s ";
local CHAT_INSTANCE_CHAT_GET = "|Hchannel:Battleground|hI.|h %s: ";
local CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: ";
local CHAT_WHISPER_INFORM_GET = "to %s ";
local CHAT_WHISPER_GET = "from %s ";
local CHAT_BN_WHISPER_INFORM_GET = "to %s ";
local CHAT_BN_WHISPER_GET = "from %s ";
local CHAT_SAY_GET = "%s ";
local CHAT_YELL_GET = "%s ";
local CHAT_FLAG_AFK = "[AFK] ";
local CHAT_FLAG_DND = "[DND] ";
local CHAT_FLAG_GM = "[GM] ";
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local ScrollIndicator = CreateFrame("Frame", nil)
local HighLight_OnUpdate = function(self)
	if(self:IsMouseOver(50, -2, 0, 50)) then
		self.texture:SetGradientAlpha("HORIZONTAL",0,1,0,0.8,0,0.3,0,0)
	else
		self.texture:SetGradientAlpha("HORIZONTAL",0,1,1,0.8,0,0.3,0.3,0)
	end
end
do
	local EmoteCount = 39;
	local EmotePatterns = {
		{
			"%:%-%@","%:%@","%:%-%)","%:%)","%:D","%:%-D","%;%-D","%;D","%=D",
			"xD","XD","%:%-%(","%:%(","%:o","%:%-o","%:%-O","%:O","%:%-0",
			"%:P","%:%-P","%:p","%:%-p","%=P","%=p","%;%-p","%;p","%;P","%;%-P",
			"%;%-%)","%;%)","%:S","%:%-S","%:%,%(","%:%,%-%(","%:%'%(",
			"%:%'%-%(","%:%F","<3","</3"
		},
		{
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\angry.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\angry.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\happy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\happy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\sad.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\sad.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\winky.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\winky.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\hmm.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\hmm.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\middle_finger.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\heart.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\broken_heart.blp]]
		}
	}

	local function GetEmoticon(pattern)
		for i=1, EmoteCount do
			local emote,icon = EmotePatterns[1][i], EmotePatterns[2][i];
			pattern = gsub(pattern, emote, "|T" .. icon .. ":16|t");
		end
		return pattern;
	end

	local function SetEmoticon(text)
		if not text then return end 
		if (not SV.db.Chat.smileys or text:find(" / run") or text:find(" / dump") or text:find(" / script")) then 
			return text 
		end 
		local result = "";
		local maxLen = len(text);
		local count = 1;
		local temp, pattern;
		while count  <= maxLen do 
			temp = maxLen;
			local section = find(text, "|H", count, true)
			if section ~= nil then temp = section end 
			pattern = sub(text, count, temp);
			result = result .. GetEmoticon(pattern)
			count = temp  +  1;
			if section ~= nil then 
				temp = find(text, "|h]|r", count, -1) or find(text, "|h", count, -1)
				temp = temp or maxLen;
				if count < temp then 
					result = result..sub(text, count, temp)
					count = temp  +  1;
				end 
			end 
		end 
		return result 
	end

	local SVUI_ParseMessage = function(self, event, text, ...)
		if ((event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER") and MOD.media.whisperSound) then 
			if text:sub(1, 3) == "OQ, " then 
				return false, text, ...
			end 
			PlaySoundFile(MOD.media.whisperSound, "Master")
		end 
		if(not CHAT_ALLOW_URL) then
			text = SetEmoticon(text)
			return false, text, ...
		end 
		local result, ct = text:gsub("(%a+)://(%S+)%s?", "%1://%2")
		if ct > 0 then 
			return false, SetEmoticon(result), ...
		end 
		result, ct = text:gsub("www%.([_A-Za-z0-9-]+)%.(%S+)%s?", "www.%1.%2")
		if ct > 0 then 
			return false, SetEmoticon(result), ...
		end 
		result, ct = text:gsub("([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", "%1@%2%3%4")
		if ct > 0 then 
			return false, SetEmoticon(result), ...
		end 
		text = SetEmoticon(text)
		return false, text, ...
	end

	local function _concatTimeStamp(msg)
		if (TIME_STAMP_MASK and TIME_STAMP_MASK ~= 'NONE' ) then
			local timeStamp = BetterDate(TIME_STAMP_MASK, time());
			timeStamp = timeStamp:gsub(' ', '')
			timeStamp = timeStamp:gsub('AM', ' AM')
			timeStamp = timeStamp:gsub('PM', ' PM')
			msg = '|cffB3B3B3['..timeStamp..'] |r'..msg
		end
		return msg
	end

	local function _getlink(this, prefix, text, color)
	    text = tostring(text)
	    local colorstring = ("|cff%s%s|r"):format(color or "ffffff", tostring(this))
	    return format("|H%s:%s|h%s|h", prefix, text, colorstring)
	end

	local function _parse(arg1, arg2, arg3)
		internalTest = true;
		local prefix = (" [%s]"):format(arg2)
		local slink = _getlink(prefix, "url", arg2, "0099FF")
		return ("%s "):format(slink)
	end

	local AddModifiedMessage = function(self, text, ...)
		internalTest = false;
		if text:find("%pTInterface%p+") or text:find("%pTINTERFACE%p+") then 
			internalTest = true 
		end 
		if not internalTest then text = text:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", _parse) end 
		if not internalTest then text = text:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", _parse) end 
		if not internalTest then text = text:gsub("(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", _parse) end 
		if not internalTest then text = text:gsub("(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", _parse) end 
		if not internalTest then text = text:gsub("(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", _parse) end 
		if not internalTest then text = text:gsub("(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", _parse) end
		if(self.___isFaded) then
			for i=1, 8 do
				text = text:gsub("|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "")
			end
		end
		self.TempAddMessage(self, _concatTimeStamp(text), ...)
	end

	local ChatEventFilter = function(self, event, message, author, ...)
		local filter = nil
		if locale == 'enUS' or locale == 'enGB' then
			if message:find('[\227-\237]') then
				filter = true
			end
		end
		if filter then
			return true;
		end
		local blockFlag = false
		local msg = author:upper() .. message;
		if(author ~= UnitName("player") and msg ~= nil and (event == "CHAT_MSG_YELL")) then
			if THROTTLE_CACHE[msg] and CHAT_THROTTLE ~= 0 then
				if difftime(time(), THROTTLE_CACHE[msg]) <= CHAT_THROTTLE then
					blockFlag = true
				end
			end
			if blockFlag then
				return true;
			else
				if CHAT_THROTTLE ~= 0 then
					THROTTLE_CACHE[msg] = time()
				end
			end
		end
		return SVUI_ParseMessage(self, event, message, author, ...)
	end

	function SetParseHandlers()
		for _,chatName in pairs(CHAT_FRAMES)do 
			local chat = _G[chatName]
			if chat:GetID() ~= 2 then
				chat.TempAddMessage = chat.AddMessage;
				chat.AddMessage = AddModifiedMessage
			end
		end 
		--ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", ChatEventFilter);
	end
end 
--[[ 
########################################################## 
CORE FUNCTIONS
##########################################################
]]--
local TabsList = {};

local function AnchorInsertHighlight()
	local lastTab = TabsList[1];
	for chatID,frame in pairs(TabsList) do
		if(frame and frame.isDocked) then
			lastTab = frame
		end
	end
	MOD.Dock.Highlight:ClearAllPoints();
	if(not lastTab) then
		MOD.Dock.Highlight:SetPoint("LEFT", MOD.Dock.Bar, "LEFT", 2, 0);
	else
		MOD.Dock.Highlight:SetPoint("LEFT", lastTab, "RIGHT", 6, 0);
	end
end

do
	local TabSafety = {};
	local refreshLocked = false;
	local doskey = false;



	local SVUI_OnHyperlinkShow = function(self, link, ...)
		if(link:sub(1, 3) == "url") then
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
			local currentLink = (link):sub(5)
			if (not ChatFrameEditBox:IsShown()) then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end
			ChatFrameEditBox:Insert(currentLink)
			ChatFrameEditBox:HighlightText()
			return;
		end
		local test, text = link:match("(%a+):(.+)");
		if(test == "url") then 
			local editBox = LAST_ACTIVE_CHAT_EDIT_BOX or _G[("%sEditBox"):format(self:GetName())]
			if editBox then 
				editBox:SetText(text)
				editBox:SetFocus()
				editBox:HighlightText()
			end 
		else 
			ChatFrame_OnHyperlinkShow(self, link, ...)
		end
	end

	local _hook_TabTextColor = function(self, r, g, b, a)
		local r2, g2, b2 = 1, 1, 1;
		if r ~= r2 or g ~= g2 or b ~= b2 then 
			self:SetTextColor(r2, g2, b2)
			self:SetShadowColor(0, 0, 0)
			self:SetShadowOffset(2, -2)
		end 
	end

	local Tab_OnEnter = function(self)
		SV.Dock:EnterFade()
		local chatFrame = _G[("ChatFrame%d"):format(self:GetID())];
		local tabText = self.text:GetText() or "Chat "..chatID;
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
		GameTooltip:ClearLines();
		GameTooltip:AddLine(tabText,1,1,1);
	    if ( chatFrame.isTemporary and chatFrame.chatType == "BN_CONVERSATION" ) then
	        BNConversation_DisplayConversationTooltip(tonumber(chatFrame.chatTarget));
	    else
	        GameTooltip_AddNewbieTip(self, CHAT_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_CHATOPTIONS, 1);
	    end
		if not self.IsOpen then
			self:SetPanelColor("highlight")
		end
		GameTooltip:Show()
	end

	local Tab_OnLeave = function(self)
		SV.Dock:ExitFade()
		if not self.IsOpen then
			self:SetPanelColor("default")
		end
		GameTooltip:Hide()
	end

	local Tab_OnClick = function(self,button)
		FCF_Tab_OnClick(self,button);
		local chatFrame = _G[("ChatFrame%d"):format(self:GetID())]; 
		if(chatFrame:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not chatFrame:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
		for chatID,frame in pairs(TabsList) do
			frame.link.IsOpen = false
			frame.link:SetPanelColor("default")
			frame.link.icon:SetGradient(unpack(SV.media.gradient.icon))
		end
		if(chatFrame.isDocked) then
	        self.IsOpen = true
	        self.icon:SetGradient(unpack(SV.media.gradient.green))
	    end
	end

	local Tab_OnDragStart = function(self)
		MOD.Dock.Highlight:Show()
		MOD.Dock.Highlight:SetScript("OnUpdate", HighLight_OnUpdate)
	end

	local Tab_OnDragStop = function(self)
		MOD.Dock.Highlight:Hide()
		MOD.Dock.Highlight:SetScript("OnUpdate", nil)
	end

	local EditBox_OnKeyUp = function(self, button)
		if(not button) then return end
		if(doskey) then
			if(button == KEY_LEFT) then 
				self:SetCursorPosition(0)
			elseif(button == KEY_RIGHT) then
				self:SetCursorPosition(self:GetNumLetters())
			end
			doskey = false
		elseif((button == KEY_UP) or (button == KEY_DOWN)) then
			doskey = true
		end
	end

	local EditBox_OnEditFocusGained = function(self)
		self:Show()
		if not MOD.Dock.Parent:IsShown()then 
			MOD.Dock.editboxforced = true;
			MOD.Dock.Parent.Bar.Button:GetScript("OnEnter")(MOD.Dock.Parent.Bar.Button)
		end
		MOD.Dock.Parent.Alert:Activate(self)
	end

	local EditBox_OnEditFocusLost = function(self)
		if MOD.Dock.editboxforced then 
			MOD.Dock.editboxforced = nil;
			if MOD.Dock.Parent:IsShown()then 
				MOD.Dock.Parent.Bar.Button:GetScript("OnLeave")(MOD.Dock.Parent.Bar.Button)
			end 
		end 
		self:Hide()
		MOD.Dock.Parent.Alert:Deactivate()
		doskey = false
	end

	local EditBox_OnTextChanged = function(self)
		local text = self:GetText()
		if(InCombatLockdown()) then 
			local max = 5;
			if(len(text) > max) then 
				local testText = true;
				for i = 1, max, 1 do 
					if(sub(text, 0 - i, 0 - i) ~= sub(text, -1 - i, -1 - i)) then 
						testText = false;
						break 
					end 
				end 
				if(testText) then 
					self:Hide()
					return 
				end 
			end 
		end

		if(text:len() < 5) then 
			if(text:sub(1, 4) == "/tt ") then 
				local name, realm = UnitName("target")
				if(name) then 
					name = gsub(name, " ", "")
					if(name and (not UnitIsSameServer("player", "target"))) then 
						name = name.."-"..gsub(realm, " ", "")
					end
				else
					name = L["Invalid Target"]
				end  
				ChatFrame_SendTell(name, ChatFrame1)
			end 
			if(text:sub(1, 4) == "/gr ") then 
				self:SetText(MOD:GetGroupDistribution()..text:sub(5))
				ChatEdit_ParseText(self, 0)
				doskey = false
			end 
		end

		local result, ct = text:gsub("|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if(ct > 0) then 
			result = result:gsub("|", "")
			self:SetText(result)
			doskey = false
		end 
	end

	local function _repositionDockedTabs()
		if(not MOD.Dock or not TABS_DIRTY) then return end;
		local lastTab = TabsList[1];
		if(lastTab) then
			lastTab:ClearAllPoints()
			lastTab:ModPoint("LEFT", MOD.Dock.Bar, "LEFT", 2, 0);
		end
		local offset = 1;
		for chatID,frame in pairs(TabsList) do
			if(frame and chatID ~= 1 and frame.isDocked) then
				frame:ClearAllPoints()
				if(not lastTab) then
					frame:SetPoint("LEFT", MOD.Dock.Bar, "LEFT", 2, 0);
				else
					frame:SetPoint("LEFT", lastTab, "RIGHT", 6, 0);
				end
				lastTab = frame
			end
		end
		local newWidth = ((MOD.Dock.Bar:GetHeight() * 1.75) + 6) * offset;
		MOD.Dock.Bar:SetWidth(newWidth);
		AnchorInsertHighlight();
		TABS_DIRTY = false;
	end  

	local function _removeTab(frame,chat)
		if(not frame) then return end 
		local name = frame:GetName();
		--if(not TabSafety[name]) then return end 
		TabSafety[name] = false;
		if(frame.chatID) then
			local chatID = frame.chatID;
			if(TabsList[chatID]) then
				TabsList[chatID] = nil;
			end
		end
		frame:SetParent(chat)
		frame:ClearAllPoints()
		frame:ModPoint("TOPLEFT", chat, "BOTTOMLEFT", -3, -6)
		TABS_DIRTY = true
		_repositionDockedTabs()
	end

	local function _addTab(frame,chatID)
		local name = frame:GetName();
		if(TabSafety[name]) then return end 
		TabSafety[name] = true;
		TabsList[chatID] = frame
	    frame.chatID = chatID;
	    frame:SetParent(MOD.Dock.Bar)
	    TABS_DIRTY = true
	    _repositionDockedTabs()
	end

	NewHook("FCFDock_UpdateTabs", _repositionDockedTabs)

	local function _customTab(tab, chatID, enabled)
		if(tab.IsStyled) then return end 
		local tabName = tab:GetName();
		local tabSize = MOD.Dock.Bar:GetHeight();

		local holder = CreateFrame("Frame", ("SVUI_ChatTab%s"):format(chatID), MOD.Dock.Bar)
		holder:SetWidth(tabSize * 1.75)
		holder:SetHeight(tabSize)
		tab.chatID = chatID;
		tab:SetParent(holder)
		tab:ClearAllPoints()
		tab:SetAllPoints(holder)
		SV.Dock:SetButtonTheme(tab, tabSize)
		tab.icon = tab:CreateTexture(nil,"BACKGROUND",nil,3)
		tab.icon:InsetPoints(tab, 6, 3)
		tab.icon:SetTexture(MOD.media.dockIcon)
		if(tab.conversationIcon) then
			tab:SetPanelColor("VERTICAL", 0.1, 0.53, 0.65, 0.6, 0.2, 1)
			tab.icon:SetGradient("VERTICAL", 0.1, 0.53, 0.65, 0.3, 0.7, 1)
		else
			tab:SetPanelColor("default")
			tab.icon:SetGradient(unpack(SV.media.gradient.icon))
		end
		if(chatID == 1) then
			tab.IsOpen = true
	        tab.icon:SetGradient(unpack(SV.media.gradient.green))
		end
		tab.icon:SetAlpha(0.5)
		tab:SetAlpha(1);

		tab.SetAlpha = SV.fubar
		tab.SetHeight = SV.fubar
		tab.SetSize = SV.fubar
		tab.SetParent = SV.fubar
		tab.ClearAllPoints = SV.fubar
		tab.SetAllPoints = SV.fubar
		tab.SetPoint = SV.fubar

		tab:SetScript("OnEnter", Tab_OnEnter);
		tab:SetScript("OnLeave", Tab_OnLeave);
		tab:SetScript("OnClick", Tab_OnClick);
		tab:HookScript("OnDragStart", Tab_OnDragStart);
		tab:HookScript("OnDragStop", Tab_OnDragStop);
		tab.Holder = holder
		tab.Holder.link = tab
		tab.IsStyled = true;
	end

	local function _modifyChat(chat)
		if(not chat) then return; end
		local chatName = chat:GetName()
		local chatID = chat:GetID();
		local tabName = chatName.."Tab";
		local tabText = _G[chatName.."TabText"]
		SV:FontManager(chat, "chatdialog", "LEFT")
		SV:FontManager(tabText, "chattab")
		if(not chat.Panel) then
			chat:SetStyle("Frame", "Transparent", true, 1, 3, 6)
			chat.Panel:Hide()
		end
		if(SV.media.internal.font.chatdialog.outline ~= 'NONE' )then
			chat:SetShadowColor(0, 0, 0, 0)
			chat:SetShadowOffset(0, 0)
		else
			chat:SetShadowColor(0, 0, 0, 1)
			chat:SetShadowOffset(1, -1)
		end
		if(not chat.InitConfig) then
			local tab = _G[tabName]
			local editBoxName = chatName.."EditBox";
			local editBox = _G[editBoxName]
			-------------------------------------------
			chat:SetFrameLevel(4)
			chat:SetClampRectInsets(0, 0, 0, 0)
			chat:SetClampedToScreen(false)
			chat:RemoveTextures(true)
			chat:SetBackdropColor(0,0,0,0)
			_G[chatName.."ButtonFrame"]:Die()
			-------------------------------------------
			_G[tabName .."Left"]:SetTexture("")
			_G[tabName .."Middle"]:SetTexture("")
			_G[tabName .."Right"]:SetTexture("")
			_G[tabName .."SelectedLeft"]:SetTexture("")
			_G[tabName .."SelectedMiddle"]:SetTexture("")
			_G[tabName .."SelectedRight"]:SetTexture("")
			_G[tabName .."HighlightLeft"]:SetTexture("")
			_G[tabName .."HighlightMiddle"]:SetTexture("")
			_G[tabName .."HighlightRight"]:SetTexture("")

			tab.text = _G[chatName.."TabText"]
			tab.text:SetShadowColor(0, 0, 0)
			tab.text:SetShadowOffset(2, -2)
			tab.text:InsetPoints(tab)
			tab.text:SetJustifyH("CENTER")
			tab.text:SetJustifyV("MIDDLE")
			NewHook(tab.text, "SetTextColor", _hook_TabTextColor)
			if tab.conversationIcon then
				tab.conversationIcon:SetAlpha(0)
				tab.conversationIcon:ClearAllPoints()
				tab.conversationIcon:ModPoint("TOPLEFT", tab, "TOPLEFT", 0, 0)
			end 
			if(TAB_SKINS and not tab.IsStyled) then
				local arg3 = (chat.inUse or chat.isDocked or chat.isTemporary)
				_customTab(tab, chatID, arg3)
			else
				tab:SetHeight(TAB_HEIGHT)
				tab:SetWidth(TAB_WIDTH)
				tab.SetWidth = SV.fubar;
			end
			-------------------------------------------
			local ebPoint1, ebPoint2, ebPoint3 = select(6, editBox:GetRegions())
			ebPoint1:Die()
			ebPoint2:Die()
			ebPoint3:Die()
			_G[editBoxName.."FocusLeft"]:Die()
			_G[editBoxName.."FocusMid"]:Die()
			_G[editBoxName.."FocusRight"]:Die()
			editBox:SetStyle("Frame", "Lite", true, 2, -2, -3)
			editBox:SetAltArrowKeyMode(false)
			editBox:SetAllPoints(MOD.Dock.Parent.Alert)
			editBox:HookScript("OnEditFocusGained", EditBox_OnEditFocusGained)
			editBox:HookScript("OnEditFocusLost", EditBox_OnEditFocusLost)
			editBox:HookScript("OnTextChanged", EditBox_OnTextChanged)
			editBox:HookScript("OnKeyUp", EditBox_OnKeyUp)
			-------------------------------------------
			chat:SetTimeVisible(100)	
			chat:SetFading(CHAT_FADING)
			chat:SetScript("OnHyperlinkClick", SVUI_OnHyperlinkShow)

			local alertSize = MOD.Dock.Bar:GetHeight();
			local alertOffset = alertSize * 0.25
			local alert = CreateFrame("Frame", nil, tab)
			alert:SetSize(alertSize, alertSize)
			alert:SetFrameStrata("DIALOG")
			alert:SetPoint("TOPRIGHT", tab, "TOPRIGHT", alertOffset, alertOffset)
			local alticon = alert:CreateTexture(nil, "OVERLAY")
			alticon:SetAllPoints(alert)
			alticon:SetTexture(MOD.media.whisperIcon)
			alert:Hide()
			chat.WhisperAlert = alert

			--copy chat button
			chat.button = CreateFrame('Frame', format("SVUI_CopyChatButton%d", id), chat)
			chat.button:SetAlpha(0.35)
			chat.button:ModSize(38, 18)
			chat.button:SetPoint('TOPRIGHT', chat, 'TOPRIGHT', 0, 0)
			chat.button:SetStyle("Frame", "Lite")
			
			chat.button.Title = chat.button:CreateFontString()
			chat.button.Title:SetFontObject(SVUI_Font_ChatTab)
			chat.button.Title:SetText("copy")
			chat.button.Title:InsetPoints(chat.button)
			chat.button.Title:SetTextColor(1,0.8,0)
			
			chat.button:SetScript("OnMouseUp", function(self, btn)
				if btn == "RightButton" and id == 1 then
					ToggleFrame(ChatMenu)
				else
					MOD:CopyChat(chat)
				end
			end)
			
			chat.button:SetScript("OnEnter", function(self) self:FadeIn() end)
			chat.button:SetScript("OnLeave", function(self) self:FadeOut() end)
			chat.button:FadeOut()

			chat.InitConfig = true
		end
	end 

	local function _modifyTab(tab, floating)	
		if(not floating) then
			_G[tab:GetName().."Text"]:Show()
			if tab.owner and tab.owner.button and GetMouseFocus() ~= tab.owner.button then
				tab.owner.button:SetAlpha(1)
			end
			if tab.conversationIcon then
				tab.conversationIcon:Show()
			end
		elseif GetMouseFocus() ~= tab then
			_G[tab:GetName().."Text"]:Hide()
			if tab.owner and tab.owner.button and GetMouseFocus() ~= tab.owner.button then
				tab.owner.button:SetAlpha(1)
			end
			if tab.conversationIcon then 
				tab.conversationIcon:Hide()
			end
		end
	end

	function MOD:RefreshChatFrames(forced)
		if ((not forced) and (refreshLocked and (IsMouseButtonDown("LeftButton") or InCombatLockdown()))) then return; end

		CHAT_WIDTH, CHAT_HEIGHT = MOD.Dock:GetSize();	

		for i,name in pairs(CHAT_FRAMES) do 
			local chat = _G[name]
			local id = chat:GetID() 
			local tab = _G[name.."Tab"]
			local tabText = _G[name.."TabText"]
			_modifyChat(chat, tabText)
			tab.owner = chat;
			chat:SetBackdropColor(0,0,0,0);
			if not chat.isDocked and chat:IsShown() then
				--print("setting size "..id .. " = " ..CHAT_WIDTH)
				chat:SetSize(CHAT_WIDTH, CHAT_HEIGHT)
				chat.Panel:Show()
				tab.owner = chat;
				if(not TAB_SKINS) then
					tab.isDocked = chat.isDocked;
					tab:SetParent(chat)
					_modifyTab(tab, true)
				else
					tab.isDocked = false;
					if(tab.Holder) then
						tab.Holder.isDocked = false;
						_removeTab(tab.Holder, chat)
					end
				end
				if chat:IsMovable() then
					chat:SetUserPlaced(true)
				end 
			else
				--print("Setting: " .. name)
				chat:ClearAllPoints();
				chat:SetPoint("CENTER", MOD.Dock, "CENTER", 0, 0);
				chat:SetSize(CHAT_WIDTH - 4, CHAT_HEIGHT - 4);
				chat.Panel:Hide();

				FCF_SavePositionAndDimensions(chat)
				tab.owner = chat;
				if(not TAB_SKINS) then
					tab.isDocked = chat.isDocked;
					tab:SetParent(MOD.Dock.Bar)
					_modifyTab(tab, false)
				else
					tab.isDocked = true;
					local arg3 = (chat.inUse or chat.isDocked or chat.isTemporary)
					if(tab.Holder and arg3) then
						tab.Holder.isDocked = true;
						_addTab(tab.Holder, id)
					end
				end
			end 
		end 
		refreshLocked = true 
	end
end
--[[ 
########################################################## 
CHAT HISTORY FUNCTIONS
##########################################################
]]--
local function MessageTimeStamp()
	local timestamp, current;
	local actual = time();
	local estimate = GetTime()
	if(not estimate) then
		current = random(1, 999)
	else
		current = select(2, ("."):split(estimate, 2)) or 0
	end
	timestamp = ("%d.%d"):format(actual, current)
	return timestamp;
end

function MOD:SAVE_CHAT_HISTORY(event, ...)
	local temp_cache = {}
	for i = 1, select('#', ...) do	
		temp_cache[i] = select(i, ...) or false
	end
	if(#temp_cache > 0) then
	  	temp_cache[20] = event
	  	local timestamp = MessageTimeStamp()
		local lineNum, lineID = 0

		self.ChatHistory[timestamp] = temp_cache

		for id, data in pairs(self.ChatHistory) do
			lineNum = lineNum + 1
			if((not lineID) or lineID > id) then
				lineID = id
			end
		end

		if(lineNum > 128) then
			self.ChatHistory[lineID] = nil
		end
	end
	temp_cache = nil
end  

function MOD:EnableChatHistory()
	self:RegisterEvent("CHAT_MSG_CHANNEL", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_EMOTE", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID_WARNING", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_SAY", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_YELL", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_GUILD", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_OFFICER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_PARTY", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_BN_CONVERSATION", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", "SAVE_CHAT_HISTORY")
	
	local temp_cache, data_cache = {}
	for id, _ in pairs(self.ChatHistory) do
		tinsert(temp_cache, tonumber(id))
	end
	tsort(temp_cache, function(a, b)
		return a < b
	end)
	for i = 1, #temp_cache do
		local lineID = tostring(temp_cache[i])
		data_cache = self.ChatHistory[lineID]
		if(data_cache) then
			local GUID = data_cache[12]
			if((type(data_cache) == "table") and data_cache[20] ~= nil and (GUID and type(GUID) == "string")) then
				if(not GUID:find("Player-")) then
					self.ChatHistory[lineID] = nil
				else
					ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, data_cache[20], unpack(data_cache))
				end
			end
		end
	end
	
	temp_cache = nil
	data_cache = nil
	wipe(self.ChatHistory)
end

function MOD:DisableChatHistory()
	self:UnregisterEvent("CHAT_MSG_CHANNEL")
	self:UnregisterEvent("CHAT_MSG_EMOTE")
	self:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
	self:UnregisterEvent("CHAT_MSG_RAID_WARNING")
	self:UnregisterEvent("CHAT_MSG_SAY")
	self:UnregisterEvent("CHAT_MSG_YELL")
	self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM")
	self:UnregisterEvent("CHAT_MSG_GUILD")
	self:UnregisterEvent("CHAT_MSG_OFFICER")
	self:UnregisterEvent("CHAT_MSG_PARTY")
	self:UnregisterEvent("CHAT_MSG_PARTY_LEADER")
	self:UnregisterEvent("CHAT_MSG_RAID")
	self:UnregisterEvent("CHAT_MSG_RAID_LEADER")
	self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT")
	self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
	self:UnregisterEvent("CHAT_MSG_BN_CONVERSATION")
	self:UnregisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
end
--[[ 
########################################################## 
EVENTS
##########################################################
]]--
function MOD:CHAT_MSG_WHISPER(event, ...)
	if(self.db.general.saveChats) then
		self:SAVE_CHAT_HISTORY(event, ...)
	end
end

function MOD:CHAT_MSG_BN_WHISPER(event, ...)
	if(self.db.general.saveChats) then
		self:SAVE_CHAT_HISTORY(event, ...)
	end
end

function MOD:PET_BATTLE_CLOSE()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame and _G[frameName.."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
			FCF_Close(frame)
		end
	end
end
--[[ 
########################################################## 
HOOKS
##########################################################
]]--
local function _hook_SetTabPosition(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"];
	local frame = chatTab.Holder
	if(frame) then
		if(not chatFrame.isLocked) then
			frame.isDocked = false;
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", -3, -6);
			TABS_DIRTY = true;
			AnchorInsertHighlight();
		end
	end
end

local function _hook_TabStopDragging(chatFrame)
	if(MOD.Dock.Highlight:IsMouseOver(50, -2, 0, 50)) then
		TABS_DIRTY = true;
		FCF_DockFrame(chatFrame, chatFrame:GetID(), true);
	end
end

do
	local _linkTokens = {
		['item'] = true,
		['spell'] = true,
		['unit'] = true,
		['quest'] = true,
		['enchant'] = true,
		['achievement'] = true,
		['instancelock'] = true,
		['talent'] = true,
		['glyph'] = true,
	}

	local _hook_OnMouseWheel = function(self, delta)
		if(IsShiftKeyDown()) then
			if(delta and delta > 0) then
				self:ScrollToTop()
			else
				self:ScrollToBottom()
			end
		end
		if(self:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not self:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
	end

	local _hook_ChatEditOnEnterKey = function(self, input)
		local ctype = self:GetAttribute("chatType");
		local attr = (not CHAT_STICKY) and "SAY" or ctype;
		local chat = self:GetParent();
		if not chat.isTemporary and ChatTypeInfo[ctype].sticky == 1 then
			self:SetAttribute("chatType", attr);
		end
	end

	local _hook_ChatFontUpdate = function(self, chat, size)
		if ( not chat ) then
			chat = FCF_GetCurrentChatFrame();
		end
		if ( not size ) then
			size = self.value or SV.media.font.chatdialog.size;
		end
		SV.media.font.chatdialog.size = size;
		SV.Events:Trigger("FONT_GROUP_UPDATED", "chatdialog");
		if(SV.media.font.chatdialog.outline ~= 'NONE' )then
			chat:SetShadowColor(0, 0, 0, 0)
			chat:SetShadowOffset(0, 0)
		else
			chat:SetShadowColor(0, 0, 0, 1)
			chat:SetShadowOffset(1, -1)
		end
	end

	local _hook_GDMFrameSetPoint = function(self)
		self:SetAllPoints(MOD.Dock.Bar)
		--print("_hook_GDMScrollSetPoint")
	end

	local _hook_GDMScrollSetPoint = function(self, point, anchor, attachTo, x, y)
		if(anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0) then
			--print("_hook_GDMScrollSetPoint " .. point .. " " .. attachTo)
			self:SetPoint(point, anchor, attachTo, -2, -6)
		end
	end

	local _hook_OnHyperlinkEnter = function(self, refString)
		if(not CHAT_HOVER_URL or InCombatLockdown()) then return; end
		local token = refString:match("^([^:]+)")
		if _linkTokens[token] then
			ShowUIPanel(GameTooltip)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(refString)
			ACTIVE_HYPER_LINK = self;
			GameTooltip:Show()
		end
	end

	local _hook_OnHyperlinkLeave = function(self, refString)
		if(not CHAT_HOVER_URL) then return; end
		local token = refString:match("^([^:]+)")
		if _linkTokens[token] then
			HideUIPanel(GameTooltip)
			ACTIVE_HYPER_LINK = nil;
		end
	end

	local _hook_OnMessageScrollChanged = function(self)
		if(not CHAT_HOVER_URL) then return; end
		if(ACTIVE_HYPER_LINK == self) then
			HideUIPanel(GameTooltip)
			ACTIVE_HYPER_LINK = false;
		end
		if(self:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not self:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			ScrollIndicator.parent = self
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
	end

	local _hook_TabOnEnter = function(self)
		--_G[self:GetName().."Text"]:Show()
		if self.conversationIcon then
			self.conversationIcon:Show()
		end
	end

	local _hook_TabOnLeave = function(self)
		--_G[self:GetName().."Text"]:Hide()
		if self.conversationIcon then
			self.conversationIcon:Hide()
		end
	end

	local _hook_OnUpdateHeader = function(editBox)
		local attrib = editBox:GetAttribute("chatType")
		if attrib == "CHANNEL" then 
			local channel = GetChannelName(editBox:GetAttribute("channelTarget"))
			if channel == 0 then 
				editBox:SetBackdropBorderColor(0,0,0)
			else 
				editBox:SetBackdropBorderColor(ChatTypeInfo[attrib..channel].r, ChatTypeInfo[attrib..channel].g, ChatTypeInfo[attrib..channel].b)
			end 
		elseif attrib then 
			editBox:SetBackdropBorderColor(ChatTypeInfo[attrib].r, ChatTypeInfo[attrib].g, ChatTypeInfo[attrib].b)
		end 
	end

	local _hook_FCFStartAlertFlash = function(self)
		if(not self.WhisperAlert) then return end
		self.WhisperAlert:Show()
		SV.Animate:Flash(self.WhisperAlert,1,true)
	end

	local _hook_FCFStopAlertFlash = function(self)
		if(not self.WhisperAlert) then return end
		SV.Animate:StopFlash(self.WhisperAlert)
		self.WhisperAlert:Hide()
	end

	function SetAllChatHooks()
		NewHook('FCF_StartAlertFlash', _hook_FCFStartAlertFlash)
		NewHook('FCF_StopAlertFlash', _hook_FCFStopAlertFlash)
		NewHook('FCF_OpenNewWindow', MOD.RefreshChatFrames)
		NewHook('FCF_UnDockFrame', MOD.RefreshChatFrames)
		NewHook('FCF_DockFrame', MOD.RefreshChatFrames)
		NewHook('FCF_OpenTemporaryWindow', MOD.RefreshChatFrames)
		NewHook("FCF_SetTabPosition", _hook_SetTabPosition)
		NewHook("FCF_StopDragging", _hook_TabStopDragging)
		NewHook('ChatEdit_OnEnterPressed', _hook_ChatEditOnEnterKey)
		NewHook('FCF_SetChatWindowFontSize', _hook_ChatFontUpdate)
		NewHook(GeneralDockManager, 'SetPoint', _hook_GDMFrameSetPoint)
		NewHook(GeneralDockManagerScrollFrame, 'SetPoint', _hook_GDMScrollSetPoint)
		for _, name in pairs(CHAT_FRAMES) do
			local chat = _G[name]
			local tab = _G[name .. "Tab"]
			if(not chat.hookedHyperLinks) then
				chat:HookScript('OnHyperlinkEnter', _hook_OnHyperlinkEnter)
				chat:HookScript('OnHyperlinkLeave', _hook_OnHyperlinkLeave)
				chat:HookScript('OnMessageScrollChanged', _hook_OnMessageScrollChanged)
				chat:HookScript('OnMouseWheel', _hook_OnMouseWheel)
				tab:HookScript('OnEnter', _hook_TabOnEnter)
				tab:HookScript('OnLeave', _hook_TabOnLeave)
				chat.hookedHyperLinks = true
			end
		end
		NewHook("ChatEdit_UpdateHeader", _hook_OnUpdateHeader)
	end
end

local ScrollFullButton = function(self)
	if(not self.parent) then return end
	self.parent:ScrollToBottom()
	self:Hide()
end

local function removeIconFromLine(text)
	for i=1, 8 do
		text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "")
	end
	text = gsub(text, "(|TInterface(.*)|t)", "")
	return text
end

function MOD:FadeLines(frame)
	for i = select("#", frame:GetRegions()), 1, -1 do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			local newtext = removeIconFromLine(line)
			region:SetText(newtext)
			region:SetAlpha(0)
		end
	end
	frame.___isFaded = true;
end

function MOD:ShowLines(frame)
	for i = select("#", frame:GetRegions()), 1, -1 do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "FontString" then
			region:SetAlpha(1)
		end
	end
	frame.___isFaded = nil;
end

function MOD:GetLines(...)
	local index = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			COPY_LINES[index] = removeIconFromLine(line)
			index = index + 1
		end
	end
	return index - 1
end

function MOD:CopyChat(frame)
	if not SVUI_CopyChatFrame:IsShown() then
		SVUI_CopyChatFrame:Show()
		local lineCt = self:GetLines(frame:GetRegions())
		local text = tconcat(COPY_LINES, "\n", 1, lineCt)
		SVUI_CopyChatFrameEditBox:SetText(text)
	else
		SVUI_CopyChatFrame:Hide()
	end
end

local function DockFadeInChat()
	local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)
	MOD:ShowLines(activeChatFrame)
	activeChatFrame:FadeIn(0.2, activeChatFrame:GetAlpha(), 1)
end

local function DockFadeOutChat()
	local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK)
	MOD:FadeLines(activeChatFrame)
	activeChatFrame:FadeOut(2, activeChatFrame:GetAlpha(), 0, true)
end

function MOD:UpdateLocals()
	CHAT_WIDTH = (SV.db.Dock.dockLeftWidth or 350) - 10;
	CHAT_HEIGHT = (SV.db.Dock.dockLeftHeight or 180) - 15;
	CHAT_THROTTLE = SV.db.Chat.throttleInterval;
	CHAT_ALLOW_URL = SV.db.Chat.url;
	CHAT_HOVER_URL = SV.db.Chat.hyperlinkHover;
	CHAT_STICKY = SV.db.Chat.sticky;
	TAB_WIDTH = SV.db.Chat.tabWidth;
	TAB_HEIGHT = SV.db.Chat.tabHeight;
	TAB_SKINS = SV.db.Chat.tabStyled;
	CHAT_FADING = SV.db.Chat.fade;
	MOD.media.whisperSound = LSM:Fetch("sound", SV.db.Chat.psst);
	TIME_STAMP_MASK = SV.db.Chat.timeStampFormat;
	if(CHAT_THROTTLE and CHAT_THROTTLE == 0) then
		twipe(THROTTLE_CACHE)
	end
end

function MOD:ReLoad()
	self:RefreshChatFrames(true) 
end

function MOD:Load()
	self.private.history = self.private.history or {};
	self.ChatHistory = self.private.history;

	self.Dock = SV.Dock:NewAdvancedDocklet("BottomLeft", "SVUI_ChatFrameDock")

	local hlSize = self.Dock.Bar:GetHeight()
	local insertHL = CreateFrame("Frame", nil, self.Dock.Bar)
	insertHL:SetPoint("LEFT", self.Dock.Bar, "LEFT", 0, 0)
	insertHL:SetSize(hlSize, hlSize)
	local insTex = insertHL:CreateTexture(nil, "OVERLAY")
	insTex:SetAllPoints()
	insTex:SetTexture(SV.media.bar.default);
	insTex:SetGradientAlpha("HORIZONTAL",0,1,1,0.8,0,0.3,0.3,0)
	insertHL.texture = insTex
	insertHL:Hide()

	self.Dock.Highlight = insertHL

	ScrollIndicator:SetParent(self.Dock)
	ScrollIndicator:SetSize(20,20)
	ScrollIndicator:SetPoint("BOTTOMRIGHT", self.Dock, "BOTTOMRIGHT", 6, 0)
	ScrollIndicator:SetFrameStrata("HIGH")
	ScrollIndicator:EnableMouse(true)
	ScrollIndicator.icon = ScrollIndicator:CreateTexture(nil, "BACKGROUND")
	ScrollIndicator.icon:SetAllPoints()
	ScrollIndicator.icon:SetTexture(MOD.media.scrollIcon)
	ScrollIndicator.icon:SetBlendMode("ADD")
	ScrollIndicator:Hide()
	ScrollIndicator:SetScript("OnMouseDown", ScrollFullButton)

	NewHook(ChatFrame2, "SetPoint", function(self, a1, p, a2, x, y)
		if((a1 ~= 'CENTER') or (a2 ~= 'CENTER') or (x ~= 0) or (y ~= 0)) then
			self:ClearAllPoints()
			self:SetPoint('CENTER', p, 'CENTER', 0, 0)
		end  
	end)

	self:RegisterEvent('UPDATE_CHAT_WINDOWS', 'RefreshChatFrames')
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'RefreshChatFrames')
	self:RegisterEvent('PET_BATTLE_CLOSE')

	SetParseHandlers()

	self:UpdateLocals()
	self:RefreshChatFrames(true)

	_G.GeneralDockManagerOverflowButton:ClearAllPoints()
	_G.GeneralDockManagerOverflowButton:SetPoint('BOTTOMRIGHT', self.Dock.Bar, 'BOTTOMRIGHT', -2, 2)
	_G.GeneralDockManagerOverflowButtonList:SetStyle("!_Frame", 'Transparent')
	_G.GeneralDockManager:SetAllPoints(self.Dock.Bar)

	SetAllChatHooks()

	FriendsMicroButton:Die()
	ChatFrameMenuButton:Die()

	_G.InterfaceOptionsSocialPanelTimestampsButton:SetAlpha(0)
	_G.InterfaceOptionsSocialPanelTimestampsButton:SetScale(0.000001)
	_G.InterfaceOptionsSocialPanelTimestamps:SetAlpha(0)
	_G.InterfaceOptionsSocialPanelTimestamps:SetScale(0.000001)
	_G.InterfaceOptionsSocialPanelChatStyle:EnableMouse(false)
	_G.InterfaceOptionsSocialPanelChatStyleButton:Hide()
	_G.InterfaceOptionsSocialPanelChatStyle:SetAlpha(0)

	local frame = CreateFrame("Frame", "SVUI_CopyChatFrame", self.Dock)
	frame:SetPoint('BOTTOMLEFT', self.Dock, 'TOPLEFT', 0, 0)
	frame:SetPoint('BOTTOMRIGHT', self.Dock, 'TOPRIGHT', 0, 0)
	frame:SetHeight(self.Dock:GetHeight())
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	SV.Dock.SetThemeDockStyle(frame)

	frame.Title = frame:CreateFontString()
	frame.Title:SetFontObject(SVUI_Font_Header)
	frame.Title:SetJustifyH('LEFT')
	frame.Title:SetText("Copy Chat")
	frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 4)
	frame.Title:SetTextColor(1,0.8,0)

	local scrollArea = CreateFrame("ScrollFrame", "SVUI_CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	local editBox = CreateFrame("EditBox", "SVUI_CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(SVUI_Font_Chat)
	editBox:SetJustifyH('LEFT')
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(200)
	editBox:SetScript("OnEscapePressed", function() SVUI_CopyChatFrame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	editBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then return end
		local _, max = SVUI_CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for i=1, max do
			ScrollFrameTemplate_OnMouseWheel(SVUI_CopyChatScrollFrame, -1)
		end
	end)		

	local close = CreateFrame("Button", "SVUI_CopyChatFrameCloseButton", frame, "UIPanelCloseButton");
	close:SetPoint("TOPRIGHT");
	close:SetFrameLevel(close:GetFrameLevel() + 1);
	close:EnableMouse(true);
	SV.API:Set("CloseButton", close);
	tinsert(UISpecialFrames, "SVUI_CopyChatFrame")

	if(SV.db.Chat.saveChats) then
		self:EnableChatHistory()
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	end

	self:LoadChatBubbles()

	SV.Events:On("DOCK_LEFT_FADE_IN", DockFadeInChat, "DockFadeInChat");
	SV.Events:On("DOCK_LEFT_FADE_OUT", DockFadeOutChat, "DockFadeOutChat");
end