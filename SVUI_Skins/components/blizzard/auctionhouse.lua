--[[
##############################################################################
S V U I   By: S.Jackson
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
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
local AuctionSortLinks = {
	"BrowseQualitySort", 
	"BrowseLevelSort", 
	"BrowseDurationSort", 
	"BrowseHighBidderSort", 
	"BrowseCurrentBidSort", 
	"BidQualitySort", 
	"BidLevelSort", 
	"BidDurationSort", 
	"BidBuyoutSort", 
	"BidStatusSort", 
	"BidBidSort", 
	"AuctionsQualitySort", 
	"AuctionsDurationSort", 
	"AuctionsHighBidderSort", 
	"AuctionsBidSort"
}
local AuctionBidButtons = {
	"BrowseBidButton", 
	"BidBidButton", 
	"BrowseBuyoutButton", 
	"BidBuyoutButton", 
	"BrowseCloseButton", 
	"BidCloseButton", 
	"BrowseSearchButton", 
	"AuctionsCreateAuctionButton", 
	"AuctionsCancelAuctionButton", 
	"AuctionsCloseButton", 
	"BrowseResetButton", 
	"AuctionsStackSizeMaxButton", 
	"AuctionsNumStacksMaxButton",
}

local AuctionTextFields = {
	"BrowseName", 
	"BrowseMinLevel", 
	"BrowseMaxLevel", 
	"BrowseBidPriceGold", 
	"BidBidPriceGold", 
	"AuctionsStackSizeEntry", 
	"AuctionsNumStacksEntry", 
	"StartPriceGold", 
	"BuyoutPriceGold",
	"BrowseBidPriceSilver", 
	"BrowseBidPriceCopper", 
	"BidBidPriceSilver", 
	"BidBidPriceCopper", 
	"StartPriceSilver", 
	"StartPriceCopper", 
	"BuyoutPriceSilver", 
	"BuyoutPriceCopper"
}
--[[ 
########################################################## 
AUCTIONFRAME MODR
##########################################################
]]--
local function AuctionStyle()
	--MOD.Debugging = true
	if(SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.auctionhouse ~= true) then return end 

	MOD:ApplyWindowStyle(AuctionFrame, false, true)
	
	BrowseFilterScrollFrame:RemoveTextures()
	BrowseScrollFrame:RemoveTextures()
	AuctionsScrollFrame:RemoveTextures()
	BidScrollFrame:RemoveTextures()

	MOD:ApplyCloseButtonStyle(AuctionFrameCloseButton)
	MOD:ApplyScrollFrameStyle(AuctionsScrollFrameScrollBar)

	MOD:ApplyDropdownStyle(BrowseDropDown)
	MOD:ApplyDropdownStyle(PriceDropDown)
	MOD:ApplyDropdownStyle(DurationDropDown)
	MOD:ApplyScrollFrameStyle(BrowseFilterScrollFrameScrollBar)
	MOD:ApplyScrollFrameStyle(BrowseScrollFrameScrollBar)
	IsUsableCheckButton:SetStyle("Checkbox")
	ShowOnPlayerCheckButton:SetStyle("Checkbox")
	
	ExactMatchCheckButton:RemoveTextures()
	ExactMatchCheckButton:SetStyle("Checkbox")
	--SideDressUpFrame:SetPoint("LEFT", AuctionFrame, "RIGHT", 16, 0)

	AuctionProgressFrame:RemoveTextures()
	AuctionProgressFrame:SetStyle("!_Frame", "Transparent", true)
	AuctionProgressFrameCancelButton:SetStyle("Button")
	AuctionProgressFrameCancelButton:SetStyle("!_Frame", "Default")
	AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	AuctionProgressFrameCancelButton:GetNormalTexture():InsetPoints()
	AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
	AuctionProgressFrameCancelButton:ModSize(28, 28)
	AuctionProgressFrameCancelButton:ModPoint("LEFT", AuctionProgressBar, "RIGHT", 8, 0)
	AuctionProgressBarIcon:SetTexCoord(0.67, 0.37, 0.61, 0.26)

	local AuctionProgressBarBG = CreateFrame("Frame", nil, AuctionProgressBarIcon:GetParent())
	AuctionProgressBarBG:WrapPoints(AuctionProgressBarIcon)
	AuctionProgressBarBG:SetStyle("!_Frame", "Default")
	AuctionProgressBarIcon:SetParent(AuctionProgressBarBG)

	AuctionProgressBarText:ClearAllPoints()
	AuctionProgressBarText:SetPoint("CENTER")
	AuctionProgressBar:RemoveTextures()
	AuctionProgressBar:SetStyle("Frame", "Default")
	AuctionProgressBar:SetStatusBarTexture(SV.Media.bar.default)
	AuctionProgressBar:SetStatusBarColor(1, 1, 0)

	MOD:ApplyPaginationStyle(BrowseNextPageButton)
	MOD:ApplyPaginationStyle(BrowsePrevPageButton)

	for _,gName in pairs(AuctionBidButtons) do
		if(_G[gName]) then
			_G[gName]:RemoveTextures()
			_G[gName]:SetStyle("Button")
		end
	end 

	AuctionsCloseButton:ModPoint("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 10)
	AuctionsCancelAuctionButton:ModPoint("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	BidBuyoutButton:ModPoint("RIGHT", BidCloseButton, "LEFT", -4, 0)
	BidBidButton:ModPoint("RIGHT", BidBuyoutButton, "LEFT", -4, 0)

	BrowseBuyoutButton:ModPoint("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	BrowseBidButton:ModPoint("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)

	AuctionsItemButton:RemoveTextures()
	AuctionsItemButton:SetStyle("Button")
	AuctionsItemButton:SetScript("OnUpdate", function()
		if AuctionsItemButton:GetNormalTexture()then 
			AuctionsItemButton:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
			AuctionsItemButton:GetNormalTexture():InsetPoints()
		end 
	end)
	
	for _,frame in pairs(AuctionSortLinks)do 
		_G[frame.."Left"]:Die()
		_G[frame.."Middle"]:Die()
		_G[frame.."Right"]:Die()
	end 

	MOD:ApplyTabStyle(_G["AuctionFrameTab1"])
	MOD:ApplyTabStyle(_G["AuctionFrameTab2"])
	MOD:ApplyTabStyle(_G["AuctionFrameTab3"])

	AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg1:ModPoint("TOPLEFT", 20, -103)
	AuctionFrameBrowse.bg1:ModPoint("BOTTOMRIGHT", -575, 40)
	AuctionFrameBrowse.bg1:SetStyle("!_Frame", "Inset")

	BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
	BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)

	BrowseSearchButton:ModPoint("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -34)
	BrowseResetButton:ModPoint("TOPRIGHT", BrowseSearchButton, "TOPLEFT", -4, 0)

	AuctionFrameBrowse.bg1:SetFrameLevel(AuctionFrameBrowse.bg1:GetFrameLevel()-1)
	BrowseFilterScrollFrame:ModHeight(300)
	AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	AuctionFrameBrowse.bg2:SetStyle("!_Frame", "Inset")
	AuctionFrameBrowse.bg2:ModPoint("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
	AuctionFrameBrowse.bg2:ModPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
	AuctionFrameBrowse.bg2:SetFrameLevel(AuctionFrameBrowse.bg2:GetFrameLevel() - 1)

	for i = 1, NUM_FILTERS_TO_DISPLAY do 
		local header = _G[("AuctionFilterButton%d"):format(i)]
		if(header) then
			header:RemoveTextures()
			header:SetStyle("Button")
		end
	end 

	for _,field in pairs(AuctionTextFields) do
		_G[field]:RemoveTextures()
		_G[field]:SetStyle("Editbox")
		_G[field]:SetTextInsets(-1, -1, -2, -2)
	end

	BrowseMinLevel:ClearAllPoints()
	BrowseMinLevel:ModPoint("LEFT", BrowseName, "RIGHT", 8, 0)
	BrowseMaxLevel:ClearAllPoints()
	BrowseMaxLevel:ModPoint("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
	AuctionsStackSizeEntry.Panel:SetAllPoints()
	AuctionsNumStacksEntry.Panel:SetAllPoints()

	for h = 1, NUM_BROWSE_TO_DISPLAY do 
		local button = _G["BrowseButton"..h];
		local buttonItem = _G["BrowseButton"..h.."Item"];
		local buttonTex = _G["BrowseButton"..h.."ItemIconTexture"];

		if(button and (not button.Panel)) then 
			button:RemoveTextures()
			button:SetStyle("Button", false, 1, 1, 1)
			button.Panel:ClearAllPoints()
			button.Panel:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
			button.Panel:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 5)

			if(buttonItem) then
				buttonItem:RemoveTextures()
				buttonItem:SetStyle("Icon")
				if(buttonTex) then
					buttonTex:SetParent(buttonItem.Panel)
					buttonTex:InsetPoints(buttonItem.Panel, 2, 2)
					buttonTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
					buttonTex:SetDesaturated(false)
				end

				local highLight = button:GetHighlightTexture()
				highLight:ClearAllPoints()
				highLight:ModPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, -2)
				highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 7)
				button:GetPushedTexture():SetAllPoints(highLight)
				_G["BrowseButton"..h.."Highlight"] = highLight
			end 
		end 
	end 

	for h = 1, NUM_AUCTIONS_TO_DISPLAY do 
		local button = _G["AuctionsButton"..h];
		local buttonItem = _G["AuctionsButton"..h.."Item"];
		local buttonTex = _G["AuctionsButton"..h.."ItemIconTexture"];

		if(button) then
			if(buttonTex) then 
				buttonTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				buttonTex:InsetPoints()
				buttonTex:SetDesaturated(false)
			end 

			button:RemoveTextures()
			button:SetStyle("Button")

			if(buttonItem) then 
				buttonItem:SetStyle("Button")
				buttonItem.Panel:SetAllPoints()
				buttonItem:HookScript("OnUpdate", function()
					buttonItem:GetNormalTexture():Die()
				end)

				local highLight = button:GetHighlightTexture()
				_G["AuctionsButton"..h.."Highlight"] = highLight
				highLight:ClearAllPoints()
				highLight:ModPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, 0)
				highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
				button:GetPushedTexture():SetAllPoints(highLight)
			end 
		end
	end 

	for h = 1, NUM_BIDS_TO_DISPLAY do 	
		local button = _G["BidButton"..h];
		local buttonItem = _G["BidButton"..h.."Item"];
		local buttonTex = _G["BidButton"..h.."ItemIconTexture"];

		if(button) then
			if(buttonTex) then 
				buttonTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				buttonTex:InsetPoints()
				buttonTex:SetDesaturated(false)
			end 

			button:RemoveTextures()
			button:SetStyle("Button")

			if(buttonItem) then 
				buttonItem:SetStyle("Button")
				buttonItem.Panel:SetAllPoints()
				buttonItem:HookScript("OnUpdate", function()
					buttonItem:GetNormalTexture():Die()
				end)

				local highLight = button:GetHighlightTexture()
				_G["BidButton"..h.."Highlight"] = highLight
				highLight:ClearAllPoints()
				highLight:ModPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, 0)
				highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
				button:GetPushedTexture():SetAllPoints(highLight)
			end 
		end
	end 

	BrowseScrollFrame:ModHeight(300)
	AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
	AuctionFrameBid.bg:SetStyle("!_Frame", "Inset")
	AuctionFrameBid.bg:ModPoint("TOPLEFT", 22, -72)
	AuctionFrameBid.bg:ModPoint("BOTTOMRIGHT", 66, 39)
	AuctionFrameBid.bg:SetFrameLevel(AuctionFrameBid.bg:GetFrameLevel()-1)
	BidScrollFrame:ModHeight(332)
	AuctionsScrollFrame:ModHeight(336)
	AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg1:SetStyle("!_Frame", "Inset")
	AuctionFrameAuctions.bg1:ModPoint("TOPLEFT", 15, -70)
	AuctionFrameAuctions.bg1:ModPoint("BOTTOMRIGHT", -545, 35)
	AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 2)
	AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	AuctionFrameAuctions.bg2:SetStyle("!_Frame", "Inset")
	AuctionFrameAuctions.bg2:ModPoint("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
	AuctionFrameAuctions.bg2:ModPoint("BOTTOMRIGHT", AuctionFrame, -8, 35)
	AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 2)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_AuctionUI", AuctionStyle)