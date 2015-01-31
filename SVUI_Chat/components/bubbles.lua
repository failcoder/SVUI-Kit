--[[
##########################################################
M O D K I T   By: S.Jackson
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
local math 		= _G.math;
local cos, deg, rad, sin = math.cos, math.deg, math.rad, math.sin;

local hooksecurefunc = _G.hooksecurefunc;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Chat;
local toonclass = select(2, UnitClass('player'))
--[[ 
########################################################## 
CHAT BUBBLES
##########################################################
]]--
-- local function LoadStyledChatBubbles()
-- 	if(SV.db.Chat.bubbles == true) then
-- 		local ChatBubbleHandler = CreateFrame("Frame", nil, UIParent)
-- 		local total = 0
-- 		local numKids = 0
-- 		local function styleBubble(frame)
-- 			local needsUpdate = true;
-- 			for i = 1, frame:GetNumRegions() do
-- 				local region = select(i, frame:GetRegions())
-- 				if region:GetObjectType() == "Texture" then
-- 					if(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]) then 
-- 						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-BG]])
-- 						needsUpdate = false 
-- 					elseif(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Backdrop]]) then
-- 						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-BACKDROP]])
-- 						needsUpdate = false 
-- 					elseif(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Tail]]) then
-- 						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-TAIL]])
-- 						needsUpdate = false 
-- 					else 
-- 						region:SetTexture(0,0,0,0)
-- 					end
-- 				elseif(region:GetObjectType() == "FontString" and not frame.text) then
-- 					frame.text = region 
-- 				end
-- 			end
-- 			if needsUpdate then 
-- 				frame:SetBackdrop(nil);
-- 				frame:SetClampedToScreen(false)
-- 				frame:SetFrameStrata("BACKGROUND")
-- 			end
-- 			if(frame.text) then
-- 				frame.text:SetFont(SV.Media.font.narrator, 10, "NONE")
-- 				frame.text:SetShadowColor(0,0,0,1)
-- 				frame.text:SetShadowOffset(1,-1)
-- 			end
-- 		end

-- 		ChatBubbleHandler:SetScript("OnUpdate", function(self, elapsed)
-- 			total = total + elapsed
-- 			if total > 0.1 then
-- 				total = 0
-- 				local newNumKids = WorldFrame:GetNumChildren()
-- 				if newNumKids ~= numKids then
-- 					for i = numKids + 1, newNumKids do
-- 						local frame = select(i, WorldFrame:GetChildren())
-- 						local b = frame:GetBackdrop()
-- 						if(b and b.bgFile == [[Interface\Tooltips\ChatBubble-Background]]) then
-- 							styleBubble(frame)
-- 						end
-- 					end
-- 					numKids = newNumKids
-- 				end
-- 			end
-- 		end)
-- 	end
-- end