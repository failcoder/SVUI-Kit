--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local function cleanT(a,b)
	for c=1,a:GetNumRegions()do 
		local d=select(c,a:GetRegions())
		if d and d:GetObjectType()=="Texture"then 
			local n=d:GetName();
			if n=='TabardFrameEmblemTopRight' or n=='TabardFrameEmblemTopLeft' or n=='TabardFrameEmblemBottomRight' or n=='TabardFrameEmblemBottomLeft' then return end 
			if b and type(b)=='boolean'then 
				d:Die()
			elseif d:GetDrawLayer()==b then 
				d:SetTexture("")
			elseif b and type(b)=='string'and d:GetTexture()~=b then 
				d:SetTexture("")
			else 
				d:SetTexture("")
			end 
		end 
	end 
end
--[[ 
########################################################## 
TABARDFRAME MODR
##########################################################
]]--
local function TabardFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.tabard ~= true then
		 return 
	end 
	cleanT(TabardFrame, true)
	TabardFrame:SetStyle("Frame", "Window2", false)
	TabardModel:SetStyle("!_Frame", "Transparent")
	TabardFrameCancelButton:SetStyle("Button")
	TabardFrameAcceptButton:SetStyle("Button")
	SV.API:Set("CloseButton", TabardFrameCloseButton)
	TabardFrameCostFrame:RemoveTextures()
	TabardFrameCustomizationFrame:RemoveTextures()
	TabardFrameInset:Die()
	TabardFrameMoneyInset:Die()
	TabardFrameMoneyBg:RemoveTextures()
	for b = 1, 5 do 
		local c = "TabardFrameCustomization"..b;_G[c]:RemoveTextures()
		SV.API:Set("PageButton", _G[c.."LeftButton"])
		SV.API:Set("PageButton", _G[c.."RightButton"])
		if b > 1 then
			 _G[c]:ClearAllPoints()
			_G[c]:ModPoint("TOP", _G["TabardFrameCustomization"..b-1], "BOTTOM", 0, -6)
		else
			local d, e, f, g, h = _G[c]:GetPoint()
			_G[c]:ModPoint(d, e, f, g, h + 4)
		end 
	end 
	TabardCharacterModelRotateLeftButton:SetPoint("BOTTOMLEFT", 4, 4)
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
	hooksecurefunc(TabardCharacterModelRotateLeftButton, "SetPoint", function(self, d, j, k, l, m)
		if d ~= "BOTTOMLEFT" or l ~= 4 or m ~= 4 then
			 self:SetPoint("BOTTOMLEFT", 4, 4)
		end 
	end)
	hooksecurefunc(TabardCharacterModelRotateRightButton, "SetPoint", function(self, d, j, k, l, m)
		if d ~= "TOPLEFT" or l ~= 4 or m ~= 0 then
			 self:SetPoint("TOPLEFT", _G.TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
		end 
	end)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(TabardFrameStyle)