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
local table 		= _G.table;
local tsort 		= table.sort;

local SV = _G["SVUI"];
local L = SV.L;
local name, obj = ...;
local MOD = SV:NewModule(name, obj, "SVUI_LootCache", "SVUI_Private_LootCache");
local Schema = MOD.Schema;
local pointList = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
};

MOD.media = {}
MOD.media.cleanupIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-CLEANUP]];
MOD.media.bagIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-BAGS]];
MOD.media.depositIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-DEPOSIT]];
MOD.media.purchaseIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-PURCHASE]];
MOD.media.reagentIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-REAGENTS]];
MOD.media.sortIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-SORT]];
MOD.media.stackIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-STACK]];
MOD.media.transferIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-TRANSFER]];
MOD.media.vendorIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-VENDOR]];
MOD.media.buttonBg = [[Interface\AddOns\SVUI_Inventory\assets\BUTTON-BG]];
MOD.media.buttonFg = [[Interface\AddOns\SVUI_Inventory\assets\BUTTON-FG]];

SV.defaults["font"]["bagdialog"]     		= {file = "SVUI Default Font",  size = 11,  outline = "OUTLINE"}
SV.defaults["font"]["bagnumber"]     		= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"}
SV.GlobalFontList["SVUI_Font_Bag"] 			= "bagdialog";
SV.GlobalFontList["SVUI_Font_Bag_Number"] 	= "bagnumber";

SV.defaults[Schema] = {
	["incompatible"] = {
		["AdiBags"] = true,
		["ArkInventory"] = true,
		["Bagnon"] = true,
	},
	["sortInverted"] = false, 
	["bags"] = {
		["xOffset"] = -40, 
		["yOffset"] = 40,
		["point"] = "BOTTOMRIGHT",
	},
	["bank"] = {
		["xOffset"] = 40, 
		["yOffset"] = 40,
		["point"] = "BOTTOMLEFT",
	},
	["bagSize"] = 34, 
	["bankSize"] = 34, 
	["alignToChat"] = false, 
	["bagWidth"] = 525, 
	["bankWidth"] = 525, 
	["currencyFormat"] = "ICON", 
	["ignoreItems"] = "", 
	["bagTools"] = true,
	["bagBar"] = {
		["enable"] = false, 
		["showBy"] = "VERTICAL", 
		["sortDirection"] = "ASCENDING", 
		["size"] = 30, 
		["spacing"] = 4, 
		["showBackdrop"] = false, 
		["mouseover"] = false, 
	},
	["specialization"] = {
		["enable"] = false, 
	}, 
	["battleground"] = {
		["enable"] = false, 
	}, 
	["primary"] = "none", 
	["secondary"] = "none", 
	["equipmentset"] = "none", 
	["durability"] = {
		["enable"] = true, 
		["onlydamaged"] = true, 
	}, 
	["itemlevel"] = {
		["enable"] = true, 
	}, 
	["misc"] = {
		setoverlay = true, 
	}
};

local bagFonts = {
	["bagdialog"] = {
		order = 1,
		name = "Bag Slot Dialog",
		desc = "Default font used in bag and bank slots"
	},
    ["bagnumber"] = {
		order = 2,
		name = "Bag Slot Numbers",
		desc = "Font used in bag and bank slots to display numeric values."
	},
};

function MOD:LoadOptions()
	SV:GenerateFontOptionGroup("Bags", 7, "Fonts used in bag slots.", bagFonts)
	
	SV.Options.args[Schema] = {
		type = 'group',
		name = Schema,
		childGroups = "tab",
		get = function(a)return SV.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]) end,
		args = {
			intro = {
				order = 1, 
				type = "description", 
				name = L["BAGS_DESC"]
			},
			bagGroups={
				order = 2,
				type = 'group',
				name = L['Bag Options'],
				guiInline = true, 
				args = {
					common = {
						order = 1, 
						type = "group",
						guiInline = true, 
						name = L["General"],
						args = {
							bagSize = {
								order = 1, 
								type = "range", 
								name = L["Button Size (Bag)"], 
								desc = L["The size of the individual buttons on the bag frame."], 
								min = 15, 
								max = 45, 
								step = 1, 
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end,
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bankSize = {
								order = 2, 
								type = "range", 
								name = L["Button Size (Bank)"], 
								desc = L["The size of the individual buttons on the bank frame."], 
								min = 15, 
								max = 45, 
								step = 1, 
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end,
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bagWidth = {
								order = 3, 
								type = "range", 
								name = L["Panel Width (Bags)"], 
								desc = L["Adjust the width of the bag frame."], 
								min = 150, 
								max = 700, 
								step = 1, 
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end, 
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bankWidth = {
								order = 4, 
								type = "range", 
								name = L["Panel Width (Bank)"], 
								desc = L["Adjust the width of the bank frame."], 
								min = 150, 
								max = 700, 
								step = 1, 
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end, 
								disabled = function() return SV.db[Schema].alignToChat end
							},
							currencyFormat = {
								order = 5, 
								type = "select", 
								name = L["Currency Format"], 
								desc = L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"], 
								values = {
									["ICON"] = L["Icons Only"], 
									["ICON_TEXT"] = L["Icons and Text"]
								},
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshTokens() end
							},
							sortInverted = {
								order = 6, 
								type = "toggle", 
								name = L["Sort Inverted"], 
								desc = L["Direction the bag sorting will use to allocate the items."]
							},
							bagTools = {
								order = 7, 
								type = "toggle", 
								name = L["Profession Tools"], 
								desc = L["Enable/Disable Prospecting, Disenchanting and Milling buttons on the bag frame."], 
								set = function(a,b)MOD:ChangeDBVar(b,a[#a])SV:StaticPopup_Show("RL_CLIENT")end
							},
							ignoreItems = {
								order = 8, 
								name = L["Ignore Items"], 
								desc = L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."], 
								type = "input", 
								width = "full", 
								multiline = true, 
								set = function(a,b) SV.db[Schema][a[#a]] = b end
							}
						}
					},
					position = {
						order = 2, 
						type = "group", 
						guiInline = true, 
						name = L["Bag/Bank Positioning"], 
						args = {
							alignToChat = {
								order = 1, 
								type = "toggle", 
								name = L["Align To Docks"], 
								desc = L["Align the width of the bag frame to fit inside dock windows."], 
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames() end
							},
							bags = {
								order = 2, 
								type = "group", 
								name = L["Bag Position"],
								guiInline = true, 
								get = function(key) return SV.db[Schema].bags[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bags"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1, 
										name = L["Anchor Point"], 
										type = "select",
										values = pointList, 
									},
									xOffset = {
										order = 2, 
										type = "range", 
										name = L["X Offset"],
										min = -600, 
										max = 600, 
										step = 1,
									},
									yOffset = {
										order = 3, 
										type = "range", 
										name = L["Y Offset"],
										min = -600, 
										max = 600, 
										step = 1,
									},
								}
							},
							bank = {
								order = 3, 
								type = "group", 
								name = L["Bank Position"],
								guiInline = true, 
								get = function(key) return SV.db[Schema].bank[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bank"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1, 
										name = L["Anchor Point"], 
										type = "select",
										values = pointList, 
									},
									xOffset = {
										order = 2, 
										type = "range", 
										name = L["X Offset"],
										min = -600, 
										max = 600, 
										step = 1,
									},
									yOffset = {
										order = 3, 
										type = "range", 
										name = L["Y Offset"],
										min = -600, 
										max = 600, 
										step = 1,
									},
								}
							},	
						}
					},
					bagBar = {
						order = 4,
						type = "group",
						name = L["Bag-Bar"],
						guiInline = true, 
						get = function(key) return SV.db[Schema].bagBar[key[#key]] end,
						set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); MOD:ModifyBagBar() end,
						args={
							enable = {
								order = 1,
								type = "toggle",
								name = L["Bags Bar Enabled"],
								desc = L["Enable/Disable the Bag-Bar."],
								get = function() return SV.db[Schema].bagBar.enable end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); SV:StaticPopup_Show("RL_CLIENT")end
							},
							mouseover = {
								order = 2, 
								name = L["Mouse Over"], 
								desc = L["Hidden unless you mouse over the frame."], 
								type = "toggle"
							},
							showBackdrop = {
								order = 3, 
								name = L["Backdrop"], 
								desc = L["Show/Hide bag bar backdrop"], 
								type = "toggle"
							},
							spacer = {
								order = 4, 
								name = "", 
								type = "description", 
								width = "full", 
							},
							size = {
								order = 5, 
								type = "range", 
								name = L["Button Size"], 
								desc = L["Set the size of your bag buttons."], 
								min = 24, 
								max = 60, 
								step = 1
							},
							spacing = {
								order = 6, 
								type = "range", 
								name = L["Button Spacing"], 
								desc = L["The spacing between buttons."], 
								min = 1, 
								max = 10, 
								step = 1
							},
							sortDirection = {
								order = 7, 
								type = "select", 
								name = L["Sort Direction"], 
								desc = L["The direction that the bag frames will grow from the anchor."], 
								values = {
									["ASCENDING"] = L["Ascending"], 
									["DESCENDING"] = L["Descending"]
								}
							},
							showBy = {
								order = 8, 
								type = "select", 
								name = L["Bar Direction"], 
								desc = L["The direction that the bag frames be (Horizontal or Vertical)."], 
								values = {
									["VERTICAL"] = L["Vertical"], 
									["HORIZONTAL"] = L["Horizontal"]
								}
							}
						}
					},
					gear = {
						order = 4,
						type = 'group',
						name = MOD.TitleID,
						get = function(key) return SV.db[Schema][key[#key]]end,
						set = function(key, value) SV.db[Schema][key[#key]] = value; MOD:ReLoad()end,
						args={
							intro={
								order = 1,
								type = 'description',
								name = function() 
									if(GetNumEquipmentSets()==0) then 
										return ("%s\n|cffFF0000Must create an equipment set to use some of these features|r"):format(L["EQUIPMENT_DESC"])
									else 
										return L["EQUIPMENT_DESC"] 
									end 
								end
							},
							specialization = {
								order = 2,
								type = "group",
								name = L["Specialization"],
								guiInline = true,
								disabled = function() return GetNumEquipmentSets() == 0 end,
								args = {
									enable = {
										type = "toggle",
										order = 1,
										name = L["Enable"],
										desc = L["Enable/Disable the specialization switch."],
										get = function(key)
											return SV.db[Schema].specialization.enable 
										end,
										set = function(key, value) 
											SV.db[Schema].specialization.enable = value 
										end
									},
									primary = {
										type = "select",
										order = 2,
										name = L["Primary Talent"],
										desc = L["Choose the equipment set to use for your primary specialization."],
										disabled = function()
											return not SV.db[Schema].specialization.enable 
										end,
										values = function()
											local h = {["none"] = L["No Change"]}
											for i = 1, GetNumEquipmentSets()do 	
												local name = GetEquipmentSetInfo(i)
												if name then
													h[name] = name 
												end 
											end 
											tsort(h, sortingFunction)
											return h 
										end
									},
									secondary = {
										type = "select",
										order = 3,
										name = L["Secondary Talent"],
										desc = L["Choose the equipment set to use for your secondary specialization."],
										disabled = function() return not SV.db[Schema].specialization.enable end,
										values = function()	
											local h = {["none"] = L["No Change"]}
											for i = 1, GetNumEquipmentSets()do 
												local name = GetEquipmentSetInfo(i)
												if name then h[name] = name end 
											end 
											tsort(h, sortingFunction)
											return h 
										end
									}
								}
							},
							battleground = {
								order = 3,
								type = "group",
								name = L["Battleground"],
								guiInline = true,
								disabled = function()return GetNumEquipmentSets() == 0 end,
								args = {
									enable = {
										type = "toggle",
										order = 1,
										name = L["Enable"],
										desc = L["Enable/Disable the battleground switch."],
										get = function(e)return SV.db[Schema].battleground.enable end,
										set = function(e,value)SV.db[Schema].battleground.enable = value end
									},
									equipmentset = {
										type = "select",
										order = 2,
										name = L["Equipment Set"],
										desc = L["Choose the equipment set to use when you enter a battleground or arena."],
										disabled = function()return not SV.db[Schema].battleground.enable end,
										values = function()
											local h = {["none"] = L["No Change"]}
											for i = 1,GetNumEquipmentSets()do 
												local name = GetEquipmentSetInfo(i)
												if name then h[name] = name end 
											end 
											tsort(h, sortingFunction)
											return h 
										end
									}
								}
							},
							intro2 = {
								type = "description",
								name = L["DURABILITY_DESC"],
								order = 4
							},
							durability = {
								type = "group",
								name = DURABILITY,
								guiInline = true,
								order = 5,
								get = function(e)return SV.db[Schema].durability[e[#e]]end,
								set = function(e,value)SV.db[Schema].durability[e[#e]] = value; MOD:ReLoad()end,
								args = {
									enable = {
										type = "toggle",
										order = 1,
										name = L["Enable"],
										desc = L["Enable/Disable the display of durability information on the character screen."]
									},
									onlydamaged = {
										type = "toggle",
										order = 2,
										name = L["Damaged Only"],
										desc = L["Only show durability information for items that are damaged."],
										disabled = function()return not SV.db[Schema].durability.enable end
									}
								}
							},
							intro3 = {
								type = "description",
								name = L["ITEMLEVEL_DESC"],
								order = 6
							},
							itemlevel = {
								type = "group",
								name = STAT_AVERAGE_ITEM_LEVEL,
								guiInline = true,
								order = 7,
								get = function(e)return SV.db[Schema].itemlevel[e[#e]]end,
								set = function(e,value)SV.db[Schema].itemlevel[e[#e]] = value; MOD:ReLoad()end,
								args = {
									enable = {
										type = "toggle",
										order = 1,
										name = L["Enable"],
										desc = L["Enable/Disable the display of item levels on the character screen."]
									}
								}
							},
							misc = {
								type = "group",
								name = L["Miscellaneous"],
								guiInline = true,
								order = 8,
								get = function(e) return SV.db[Schema].misc[e[#e]] end,
								set = function(e,value) SV.db[Schema].misc[e[#e]] = value end,
								args = {
									setoverlay = {
										type = "toggle",
										order = 1,
										name = L["Equipment Set Overlay"],
										desc = L["Show the associated equipment sets for the items in your bags (or bank)."],
										set = function(e,value)
											SV.db[Schema].misc[e[#e]] = value;
											SV:StaticPopup_Show("RL_CLIENT");
										end
									}
								}
							}
						}
					},
				}
			}
		}
	};
end