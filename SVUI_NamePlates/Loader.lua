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

local SV = _G["SVUI"];
local L = SV.L
local MOD = SV:NewModule(...);
local Schema = MOD.Schema;
local positionTable = {
	TOPLEFT = "TOPLEFT", 
	LEFT = "LEFT", 
	BOTTOMLEFT = "BOTTOMLEFT", 
	RIGHT = "RIGHT", 
	TOPRIGHT = "TOPRIGHT", 
	BOTTOMRIGHT = "BOTTOMRIGHT", 
	CENTER = "CENTER", 
	TOP = "TOP", 
	BOTTOM = "BOTTOM",
	RIGHTTOP = "RIGHTTOP",
    LEFTTOP = "LEFTTOP",
    RIGHTBOTTOM = "RIGHTBOTTOM",
    LEFTBOTTOM = "LEFTBOTTOM"
};

local activeFilter,filters;

MOD.media = {}
MOD.media.healthBar = [[Interface\BUTTONS\WHITE8X8]];
MOD.media.castBar = [[Interface\AddOns\SVUI_!Core\assets\textures\Bars\GRADIENT]];
MOD.media.comboIcon = [[Interface\AddOns\SVUI_NamePlates\assets\COMBO-POINT]];
MOD.media.topArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-TOP]];
MOD.media.bottomArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-BOTTOM]];
MOD.media.rightArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-RIGHT]];
MOD.media.leftArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-LEFT]];
MOD.media.roles = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-ROLES]];

SV.defaults["font"]["platename"]     	= {file = "SVUI Caps Font",   	size = 9,   outline = "OUTLINE"}
SV.defaults["font"]["platenumber"]   	= {file = "SVUI Caps Font",   	size = 9,   outline = "OUTLINE"}
SV.defaults["font"]["plateaura"]     	= {file = "SVUI Caps Font",   	size = 9,   outline = "OUTLINE"}

SV.GlobalFontList["SVUI_Font_NamePlate"] = "platename";
SV.GlobalFontList["SVUI_Font_NamePlate_Aura"] = "plateaura";
SV.GlobalFontList["SVUI_Font_NamePlate_Number"] = "platenumber";

SV.defaults[Schema] = {
	["themed"] = true,
	["filter"] = {}, 
	["font"] = DIALOGUE_FONT, 
	["fontSize"] = 10, 
	["fontOutline"] = "OUTLINE", 
	["comboPoints"] = true, 
	["nonTargetAlpha"] = 0.6, 
	["combatHide"] = false, 
	["colorNameByValue"] = true, 
	["showthreat"] = true, 
	["targetcount"] = true, 
	["pointer"] = {
		["enable"] = true, 
		["colorMatchHealthBar"] = true, 
		["color"] = {0.9, 1, 0.9}, 
	}, 
	["healthBar"] = {
		["lowThreshold"] = 0.4, 
		["width"] = 108, 
		["height"] = 10, 
		["text"] = {
			["enable"] = false, 
			["format"] = "CURRENT", 
			["xOffset"] = 0, 
			["yOffset"] = 0, 
			["attachTo"] = "CENTER", 
		}, 
	}, 
	["castBar"] = {
		["height"] = 8, 
		["color"] = {1, 0.81, 0}, 
		["noInterrupt"] = {1, 0.25, 0.25}, 
		["text"] = {
			["enable"] = false, 
			["xOffset"] = 2, 
			["yOffset"] = 0, 
		}, 
	}, 
	["raidHealIcon"] = {
		["xOffset"] =  -4, 
		["yOffset"] = 6, 
		["size"] = 36, 
		["attachTo"] = "LEFT", 
	}, 
	["threat"] = {
		["enable"] = false, 
		["goodScale"] = 1, 
		["badScale"] = 1, 
		["goodColor"] = {0.29, 0.68, 0.3}, 
		["badColor"] = {0.78, 0.25, 0.25}, 
		["goodTransitionColor"] = {0.85, 0.77, 0.36}, 
		["badTransitionColor"] = {0.94, 0.6, 0.06}, 
	}, 
	["auras"] = {
		["font"] = "SVUI Number Font", 
		["fontSize"] = 7, 
		["fontOutline"] = "OUTLINE", 
		["numAuras"] = 5, 
		["additionalFilter"] = "CC"
	}, 
	["reactions"] = {
		["tapped"] = {0.6, 0.6, 0.6}, 
		["friendlyNPC"] = { 0.31, 0.45, 0.63}, 
		["friendlyPlayer"] = {0.29, 0.68, 0.3}, 
		["neutral"] = {0.85, 0.77, 0.36}, 
		["enemy"] = {0.78, 0.25, 0.25}, 
	}, 
};

local plateFonts = {
	["platename"] = {
		order = 1,
		name = "Nameplate Names",
		desc = "Used on nameplates for unit names."
	},
	["platenumber"] = {
		order = 2,
		name = "Nameplate Numbers",
		desc = "Used on nameplates for health and level numbers."
	},
    ["plateaura"] = {
		order = 3,
		name = "Nameplate Auras",
		desc = "Used on nameplates for aura texts."
	},
};

local function UpdateFilterGroupOptions()
	if not activeFilter or not SV.db['NamePlates']['filter'][activeFilter] then 
		SV.Options.args[Schema].args.Filters.args.filterGroup=nil;
		return 
	end 
	SV.Options.args[Schema].args.Filters.args.filterGroup = {
		type = "group",
		name = activeFilter,
		guiInline = true,
		order = -10,
		get = function(d)return SV.db["NamePlates"]["filter"][activeFilter][d[#d]] end,
		set = function(d,e)
			SV.db["NamePlates"]["filter"][activeFilter][d[#d]] = e;
			MOD:PlateIteration("AssertFiltering")
			MOD:UpdateAllPlates()
			UpdateFilterGroupOptions()
		end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"],
				desc = L["Use this filter."]
			},
			hide = {
				type = "toggle",
				order = 2,
				name = L["Hide"],
				desc = L["Prevent any nameplate with this unit name from showing."]
			},
			customColor = {
				type = "toggle",
				order = 3,
				name = L["Custom Color"],
				desc = L["Disable threat coloring for this plate and use the custom color."]
			},
			color = {
				type = "color",
				order = 4,
				name = L["Color"],
				get = function(key)
					local color = SV.db["NamePlates"]["filter"][activeFilter][key[#key]]
					if color then 
						return color[1],color[2],color[3],color[4]
					end 
				end,
				set = function(key,r,g,b)
					SV.db["NamePlates"]["filter"][activeFilter][key[#key]] = {}
					local color = SV.db["NamePlates"]["filter"][activeFilter][key[#key]]
					if color then 
						color = {r,g,b};
						UpdateFilterGroupOptions()
						MOD:PlateIteration("CheckFilterAndHealers")
						MOD:UpdateAllPlates()
					end 
				end
			},
			customScale = {
				type = "range",
				name = L["Custom Scale"],
				desc = L["Set the scale of the nameplate."],
				min = 0.67,
				max = 2,
				step = 0.01
			}
		}
	}
end 

function MOD:LoadOptions()
	SV:GenerateFontOptionGroup("NamePlate", 5, "Fonts used in name plates.", plateFonts)
	
	SV.Options.args[Schema] = {
		type = "group",
		name = Schema,
		childGroups = "tab",
		args = {
			commonGroup = {
				order = 1,
				type = 'group',
				name = L['NamePlate Options'],
				childGroups = "tree",
				args = {
					intro={
						order = 1,
						type = 'description',
						name = L["NAMEPLATE_DESC"],
						width = 'full'
					},
					common = {
						order = 1,
						type = "group",
						name = L["General"],
						get = function(d)return SV.db[Schema][d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d]);MOD:UpdateAllPlates() end,
						args = {
							combatHide = {
								type = "toggle",
								order = 1,
								name = L["Combat Toggle"],
								desc = L["Toggle the nameplates to be invisible outside of combat and visible inside combat."],
								set = function(d,e)MOD:ChangeDBVar(e,d[#d])MOD:CombatToggle()end
							},
							comboPoints = {
								type = "toggle",
								order = 2,
								name = L["Combo Points"],
								desc = L["Display combo points on nameplates."]
							},
							colorNameByValue = {
								type = "toggle",
								order = 3,
								name = L["Color Name By Health Value"]
							},
							showthreat = {
								type = "toggle",
								order = 4,
								name = L["Threat Text"],
								desc = L["Display threat level as text on targeted,	boss or mouseover nameplate."]
							},
							nonTargetAlpha = {
								type = "range",
								order = 5,
								name = L["Non-Target Alpha"],
								desc = L["Alpha of nameplates that are not your current target."],
								min = 0,
								max = 1,
								step = 0.01,
								isPercent = true
							},
							reactions = {
								order = 200,
								type = "group",
								name = L["Reaction Coloring"],
								guiInline = true,
								get = function(key)
									local color = SV.db[Schema].reactions[key[#key]]
									if color then 
										return color[1],color[2],color[3],color[4]
									end 
								end,
								set = function(key,r,g,b)
									local color = {r,g,b}
									MOD:ChangeDBVar(color, key[#key], "reactions")
									MOD:UpdateAllPlates() 
								end,
								args = {
									friendlyNPC = {
										type = "color",
										order = 1,
										name = L["Friendly NPC"],
										hasAlpha = false
									},
									friendlyPlayer = {
										name = L["Friendly Player"],
										order = 2,
										type = "color",
										hasAlpha = false
									},
									neutral = {
										name = L["Neutral"],
										order = 3,
										type = "color",
										hasAlpha = false
									},
									enemy = {
										name = L["Enemy"],
										order = 4,
										type = "color",
										hasAlpha = false
									},
									tapped = {
										name = L["Tagged NPC"],
										order = 5,
										type = "color",
										hasAlpha = false
									}
								}
							},
						}
					},
					healthBar = {
						type = "group",
						order = 2,
						name = L["Health Bar"],
						get = function(d)return SV.db[Schema].healthBar[d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d],"healthBar");MOD:UpdateAllPlates()end,
						args = {
							width = {
								type = "range",
								order = 1,
								name = L["Width"],
								desc = L["Controls the width of the nameplate"],
								type = "range",
								min = 50,
								max = 125,
								step = 1
							},
							height = {
								type = "range",
								order = 2,
								name = L["Height"],
								desc = L["Controls the height of the nameplate"],
								type = "range",
								min = 4,
								max = 30,
								step = 1
							},
							lowThreshold = {
								type = "range",
								order = 3,
								name = L["Low Health Threshold"],
								desc = L["Color the border of the nameplate yellow when it reaches this point,it will be colored red when it reaches half this value."],
								isPercent = true,
								min = 0,
								max = 1,
								step = 0.01
							},
							fontGroup = {
								order = 4,
								type = "group",
								name = L["Fonts"],
								guiInline = true,
								get = function(d)return SV.db[Schema].healthBar.text[d[#d]]end,
								set = function(d,e)MOD:ChangeDBVar(e,d[#d],"healthBar","text");MOD:UpdateAllPlates()end,
								args = {
									enable = {
										type = "toggle",
										name = L["Enable"],
										order = 1
									},
									attachTo = {
										type = "select",
										order = 2,
										name = L["Attach To"],
										values = {
											TOPLEFT = "TOPLEFT",
											LEFT = "LEFT",
											BOTTOMLEFT = "BOTTOMLEFT",
											RIGHT = "RIGHT",
											TOPRIGHT = "TOPRIGHT",
											BOTTOMRIGHT = "BOTTOMRIGHT",
											CENTER = "CENTER",
											TOP = "TOP",
											BOTTOM = "BOTTOM"
										}
									},
									format = {
										type = "select",
										order = 3,
										name = L["Format"],
										values = {
											["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
											["CURRENT_PERCENT"] = L["Current - Percent"],
											["CURRENT_MAX"] = L["Current - Max"],
											["CURRENT"] = L["Current"],
											["PERCENT"] = L["Percent"],
											["DEFICIT"] = L["Deficit"]
										}
									},
									xOffset = {
										type = "range",
										order = 4,
										name = L["X-Offset"],
										min = -150,
										max = 150,
										step = 1
									},
									yOffset = {
										type = "range",
										order = 5,
										name = L["Y-Offset"],
										min = -150,
										max = 150,
										step = 1
									}
								}
							}
						}
					},
					castBar = {
						type = "group",
						order = 3,
						name = L["Cast Bar"],
						get = function(d)return SV.db[Schema].castBar[d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d],"castBar");MOD:UpdateAllPlates()end,
						args = {
							height = {
								type = "range",
								order = 1,
								name = L["Height"],
								type = "range",
								min = 4,
								max = 30,
								step = 1
							},
							colors = {
								order = 100,
								type = "group",
								name = L["Colors"],
								guiInline = true,
								get = function(key)
									local color = SV.db[Schema].castBar[key[#key]]
									if color then 
										return color[1],color[2],color[3],color[4]
									end 
								end,
								set = function(key,r,g,b)
									local color = {r,g,b}
									MOD:ChangeDBVar(color, key[#key], "castBar")
									MOD:UpdateAllPlates() 
								end,
								args = {
									color = {
										type = "color",
										order = 1,
										name = L["Can Interrupt"],
										hasAlpha = false
									},
									noInterrupt = {
										name = "No Interrupt",
										order = 2,
										type = "color",
										hasAlpha = false
									}
								}
							}
						}
					},
					pointer = {
						type = "group",
						order = 4,
						name = L["Target Indicator"],
						get = function(d)return SV.db[Schema].pointer[d[#d]]end,
						set = function(d,e) MOD:ChangeDBVar(e,d[#d],"pointer"); _G.WorldFrame.elapsed = 3; MOD:UpdateAllPlates() end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"]
							},
							colorMatchHealthBar = {
								order = 2,
								type = "toggle",
								name = L["Color By Healthbar"],
								desc = L["Match the color of the healthbar."],
								set = function(key, value)
									MOD:ChangeDBVar(value, key[#key], "pointer");
									if value then
										_G.WorldFrame.elapsed = 3 
									end 
								end
							},
							color = {
								type = "color",
								name = L["Color"],
								order = 3,
								disabled = function()return SV.db[Schema].pointer.colorMatchHealthBar end,
								get = function(key)
									local color = SV.db[Schema].pointer[key[#key]]
									if color then 
										return color[1],color[2],color[3],color[4]
									end 
								end,
								set = function(key,r,g,b)
									local color = {r,g,b}
									MOD:ChangeDBVar(color, key[#key], "pointer")
									MOD:UpdateAllPlates() 
								end,
							}
						}
					},
					raidHealIcon = {
						type = "group",
						order = 5,
						name = L["Raid Icon"],
						get = function(d)return SV.db[Schema].raidHealIcon[d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d],"raidHealIcon")MOD:UpdateAllPlates()end,
						args = {
							attachTo = {
								type = "select",
								order = 1,
								name = L["Attach To"],
								values = positionTable
							},
							xOffset = {
								type = "range",
								order = 2,
								name = L["X-Offset"],
								min = -150,
								max = 150,
								step = 1
							},
							yOffset = {
								type = "range",
								order = 3,
								name = L["Y-Offset"],
								min = -150,
								max = 150,
								step = 1
							},
							size = {
								order = 4,
								type = "range",
								name = L["Size"],
								width = "full",
								min = 10,
								max = 200,
								step = 1
							},
						}
					},
					auras = {
						type = "group",
						order = 4,
						name = L["Auras"],
						get = function(d)return SV.db[Schema].auras[d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d],"auras")MOD:UpdateAllPlates()end,
						args = {
							numAuras = {
								type = "range",
								order = 1,
								name = L["Number of Auras"],
								min = 2,
								max = 8,
								step = 1
							},
							additionalFilter = {
								type = "select",
								order = 2,
								name = L["Additional Filter"],
								values = function()
									filters = {}
									filters[""] = _G.NONE;
									for j in pairs(SV.filters.Custom) do 
										filters[j] = j 
									end 
									return filters 
								end
							},
							configureButton = {
								order = 4,
								name = L["Configure Selected Filter"],
								type = "execute",
								width = "full",
								func = function()ns:SetToFilterConfig(SV.db[Schema].auras.additionalFilter)end
							},
							fontGroup = {
								order = 100,
								type = "group",
								guiInline = true,
								name = L["Fonts"],
								args = {
									font = {
										type = "select",
										dialogControl = "LSM30_Font",
										order = 4,
										name = L["Font"],
										values = AceGUIWidgetLSMlists.font
									},
									fontSize = {
										order = 5,
										name = L["Font Size"],
										type = "range",
										min = 6,
										max = 22,
										step = 1
									},
									fontOutline = {
										order = 6,
										name = L["Font Outline"],
										desc = L["Set the font outline."],
										type = "select",
										values = {
											["NONE"] = L["None"],
											["OUTLINE"] = "OUTLINE",
											["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
											["THICKOUTLINE"] = "THICKOUTLINE"
										}
									}
								}
							}
						}
					},
					threat = {
						type = "group",
						order = 6,
						name = L["Threat"],
						get = function(d)return SV.db[Schema].threat[d[#d]]end,
						set = function(d,e)MOD:ChangeDBVar(e,d[#d],"threat")MOD:UpdateAllPlates()end,
						args = {
							enable = {
								type = "toggle",
								order = 1,
								name = L["Enable"]
							},
							scaling = {
								type = "group",
								name = L["Scaling"],
								guiInline = true,
								order = 2,
								args = {
									goodScale = {
										type = "range",
										name = L["Good"],
										order = 1,
										min = 0.5,
										max = 1.5,
										step = 0.01,
										isPercent = true
									},
									badScale = {
										type = "range",
										name = L["Bad"],
										order = 1,
										min = 0.5,
										max = 1.5,
										step = 0.01,
										isPercent = true
									}
								}
							},
							colors = {
								order = 3,
								type = "group",
								name = L["Colors"],
								guiInline = true,
								get = function(key)
									local color = SV.db[Schema].threat[key[#key]]
									if color then 
										return color[1],color[2],color[3],color[4]
									end 
								end,
								set = function(key,r,g,b)
									local color = {r,g,b}
									MOD:ChangeDBVar(color, key[#key], "threat")
									MOD:UpdateAllPlates() 
								end,
								args = {
									goodColor = {
										type = "color",
										order = 1,
										name = L["Good"],
										hasAlpha = false
									},
									badColor = {
										name = L["Bad"],
										order = 2,
										type = "color",
										hasAlpha = false
									},
									goodTransitionColor = {
										name = L["Good Transition"],
										order = 3,
										type = "color",
										hasAlpha = false
									},
									badTransitionColor = {
										name = L["Bad Transition"],
										order = 4,
										type = "color",
										hasAlpha = false
									}
								}
							}
						}
					},
					filters = {
						type = "group",
						order = 200,
						name = L["Filters"],
						args = {
							addname = {
								type = "input",
								order = 1,
								name = L["Add Name"],
								get = function(d)return""end,
								set = function(d,e)
									if SV.db["NamePlates"]["filter"][e]then 
										SV:AddonMessage(L["Filter already exists!"])
										return 
									end 
									SV.db["NamePlates"]["filter"][e] = {
										["enable"] = true,
										["hide"] = false,
										["customColor"] = false,
										["customScale"] = 1,
										["color"] = {
											g = 104/255,
											h = 138/255,
											i = 217/255
										}
									}
									UpdateFilterGroupOptions()
									MOD:UpdateAllPlates()
								end
							},
							deletename = {
								type = "input",
								order = 2,
								name = L["Remove Name"],
								get = function(d)return""end,
								set = function(d,e)
									if SV.db["NamePlates"]["filter"][e] then 
										SV.db["NamePlates"]["filter"][e].enable = false;
										SV:AddonMessage(L["You can't remove a default name from the filter,disabling the name."])
									else 
										SV.db["NamePlates"]["filter"][e] = nil;
										SV.Options.args[Schema].args.Filters.args.filterGroup = nil 
									end 
									UpdateFilterGroupOptions()
									MOD:UpdateAllPlates()
								end
							},
							selectFilter = {
								order = 3,
								type = "select",
								name = L["Select Filter"],
								get = function(d)return activeFilter end,
								set = function(d,e)activeFilter = e;UpdateFilterGroupOptions()end,
								values = function()
									filters = {}
									if(SV.db["NamePlates"]["filter"]) then
										for j in pairs(SV.db["NamePlates"]["filter"])do 
											filters[j] = j 
										end 
									end
									return filters 
								end
							}
						}
					}
				}
			}
		}
	}
end