--[[
##########################################################
S V U I   By: Munglunch
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry");
local L = SV.L;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local UIErrorsFrame = _G.UIErrorsFrame;
local ERR_FILTERS = {};
--[[ 
########################################################## 
EVENTS
##########################################################
]]--
function SV:UI_ERROR_MESSAGE(event, msg)
	if((not msg) or ERR_FILTERS[msg]) then return end
	UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0);
end

local ErrorFrameHandler = function(self, event)
	if(event == 'PLAYER_REGEN_DISABLED') then
		SV:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		SV:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function SV:CacheFilters()
	for k, v in pairs(SV.db.general.errorFilters) do
		ERR_FILTERS[k] = v
	end
	if(ERR_FILTERS[INTERRUPTED]) then
		ERR_FILTERS[SPELL_FAILED_INTERRUPTED] = true
		ERR_FILTERS[SPELL_FAILED_INTERRUPTED_COMBAT] = true
	end
end

function SV:UpdateErrorFilters()
	if(SV.db.general.filterErrors) then
		self:CacheFilters()
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
		self:RegisterEvent('UI_ERROR_MESSAGE')
		if(SV.db.general.hideErrorFrame) then
			self:RegisterEvent('PLAYER_REGEN_DISABLED', ErrorFrameHandler)
			self:RegisterEvent('PLAYER_REGEN_ENABLED', ErrorFrameHandler)
		end
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
		self:UnregisterEvent('UI_ERROR_MESSAGE')
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end
end
--[[ 
########################################################## 
LOAD
##########################################################
]]--
local function SetErrorFilters()
	if(SV.db.general.filterErrors) then
		SV:CacheFilters()
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
		SV:RegisterEvent('UI_ERROR_MESSAGE')
		if(SV.db.general.hideErrorFrame) then
			SV:RegisterEvent('PLAYER_REGEN_DISABLED', ErrorFrameHandler)
			SV:RegisterEvent('PLAYER_REGEN_ENABLED', ErrorFrameHandler)
		end
	end
end

SV:NewScript(SetErrorFilters)