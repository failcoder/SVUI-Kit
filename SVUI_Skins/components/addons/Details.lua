--[[
##############################################################################
S V U I   By: Munglunch
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
STYLE
##########################################################
]]--
local function StyleDetails()
	assert(_detalhes, "AddOn Not Loaded")

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

	local reset_tooltip = function()
		_detalhes:SetTooltipBackdrop ("Blizzard Tooltip", 16, {1, 1, 1, 1})
		_detalhes:DelayOptionsRefresh()
	end

	_detalhes:InstallSkin ("Comics Style", {
		file = [[Interface\AddOns\Details\images\skins\elvui.tga]],
		author = "SVUI", 
		version = "1.0", 
		site = "unknown", 
		desc = "Style to match SVUI!", 
		
		--general
		can_change_alpha_head = true, 

		--icon anchors
		icon_anchor_main = {-4, -5},
		icon_anchor_plugins = {-7, -13},
		icon_plugins_size = {19, 18},
		
		--micro frames
		micro_frames = {color = {0.525490, 0.525490, 0.525490, 1}, font = "SVUI Caps Font", size = 11},
		
		-- the four anchors (for when the toolbar is on the top side)
		icon_point_anchor = {-35, -0.5},
		left_corner_anchor = {-107, 0},
		right_corner_anchor = {96, 0},
		
		-- the four anchors (for when the toolbar is on the bottom side)
		icon_point_anchor_bottom = {-37, 12},
		left_corner_anchor_bottom = {-107, 0},
		right_corner_anchor_bottom = {96, 0},
		callback = function (self, instance) end,
		control_script_on_start = nil,
		control_script = nil,
		instance_cprops = {
			menu_icons_size = 0.90,
			menu_anchor = {16, 2, side = 2},
			menu_anchor_down = {16, -2},
			plugins_grow_direction = 1,
			menu_icons = {shadow = true},
			attribute_text = {enabled = true, anchor = {-20, 5}, text_face = "SVUI Default Font", text_size = 12, text_color = {1, 1, 1, .7}, side = 1, shadow = true},
			hide_icon = true,
			desaturated_menu = false,
			bg_alpha = 0.51,
			bg_r = 0.3294,
			bg_g = 0.3294,
			bg_b = 0.3294,
			show_statusbar = false,

			row_info = {
					texture = "Skyline",
					texture_class_colors = true, 
					alpha = 0.80, 
					texture_background_class_color = false,
					texture_background = "Details D'ictum",
					fixed_texture_color = {0, 0, 0},
					fixed_texture_background_color = {0, 0, 0, 0.471},
					space = {left = 1, right = -2, between = 0},
					backdrop = {enabled = true, size = 4, color = {0, 0, 0, 1}, texture = "Details BarBorder 2"},
					icon_file = [[Interface\AddOns\Details\images\classes_small_alpha]],
					start_after_icon = false,
			},

			wallpaper = {
				overlay = {1, 1,	1},
				width = 256,
				texcoord = {49/1024, 305/1024, 774/1024, 646/1024},
				enabled = true,
				anchor = "all",
				height = 128,
				alpha = 0.8,
				texture = [[Interface\AddOns\Details\images\skins\elvui]],
			}
		},
		
		skin_options = {
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON2_DESC"]},
			{type = "button", name = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3"], func = reset_tooltip, desc = Loc ["STRING_OPTIONS_SKIN_ELVUI_BUTTON3_DESC"]},
		}
	})	
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("Details", StyleDetails)