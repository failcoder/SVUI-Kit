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
local L = SV.L;
local name, obj = ...
local MOD = SV:NewPackage(name, obj, nil, "SVUI_Private_Extras");
local Schema = MOD.Schema;

SV.defaults[Schema] = {
	["enable"] = true,
	["autoRoll"] = false, 
	["vendorGrays"] = true, 
	["autoAcceptInvite"] = false, 
	["autorepchange"] = false, 
	["pvpautorelease"] = false, 
	["autoquestcomplete"] = false, 
	["autoquestreward"] = false, 
	["autoquestaccept"] = false, 
	["autodailyquests"] = false, 
	["autopvpquests"] = false, 
	["skipcinematics"] = false, 
	["mailOpener"] = true,
	["autoRepair"] = "PLAYER",
	["threatbar"] = false, 
    ["bubbles"] = true, 
    ["woot"] = true, 
    ["pvpinterrupt"] = true, 
    ["lookwhaticando"] = false,
    ["reactionChat"] = false,
    ["reactionEmote"] = false,
    ["sharingiscaring"] = false, 
    ["arenadrink"] = true, 
    ["stupidhat"] = true,
	["totems"] = {
	    ["enable"] = true, 
	    ["showBy"] = "VERTICAL", 
	    ["sortDirection"] = "ASCENDING", 
	    ["size"] = 40, 
	    ["spacing"] = 4
	}
};

function MOD:LoadOptions()
	SV.Options.args[Schema] = {
		type = "group", 
		name = Schema,
		get = function(a)return SV.db[Schema][a[#a]]end, 
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]); end, 
		args = {
			common = {
				order = 1, 
				type = "group", 
				name = L["General"], 
				guiInline = true, 
				args = {
					woot = {
						order = 1,
						type = 'toggle',
						name = L["Say Thanks"],
						desc = L["Thank someone when they cast specific spells on you. Typically resurrections"], 
						get = function(j)return SV.db[Schema].woot end,
						set = function(j,value)SV.db[Schema].woot = value;MOD:ToggleReactions()end
					},
					pvpinterrupt = {
						order = 2,
						type = 'toggle',
						name = L["Report PVP Actions"],
						desc = L["Announce your interrupts, as well as when you have been sapped!"],
						get = function(j)return SV.db[Schema].pvpinterrupt end,
						set = function(j,value)SV.db[Schema].pvpinterrupt = value;MOD:ToggleReactions()end
					},
					lookwhaticando = {
						order = 3,
						type = 'toggle',
						name = L["Report Spells"],
						desc = L["Announce various helpful spells cast by players in your party/raid"],
						get = function(j)return SV.db[Schema].lookwhaticando end,
						set = function(j,value)SV.db[Schema].lookwhaticando = value;MOD:ToggleReactions()end
					},
					sharingiscaring = {
						order = 4,
						type = 'toggle',
						name = L["Report Shareables"],
						desc = L["Announce when someone in your party/raid has laid a feast or repair bot"],
						get = function(j)return SV.db[Schema].sharingiscaring end,
						set = function(j,value)SV.db[Schema].sharingiscaring = value;MOD:ToggleReactions()end
					},
					reactionChat = {
						order = 5,
						type = 'toggle',
						name = L["Report in Chat"],
						desc = L["Announcements will be sent to group chat channels"],
						get = function(j)return SV.db[Schema].reactionChat end,
						set = function(j,value)SV.db[Schema].reactionChat = value;MOD:ToggleReactions()end
					},
					reactionEmote = {
						order = 6,
						type = 'toggle',
						name = L["Auto Emotes"],
						desc = L["Some announcements are accompanied by player emotes."],
						get = function(j)return SV.db[Schema].reactionEmote end,
						set = function(j,value)SV.db[Schema].reactionEmote = value;MOD:ToggleReactions()end
					},
					threatbar = {
						order = 7, 
						type = "toggle", 
						name = L['Threat Thermometer'], 
						get = function(j)return SV.db[Schema].threatbar end, 
						set = function(j, value)SV.db[Schema].threatbar = value;SV:StaticPopup_Show("RL_CLIENT")end
					},
					totems = {
						order = 8, 
						type = "toggle", 
						name = L["Totems"], 
						get = function(j)
							return SV.db[Schema].totems.enable
						end, 
						set = function(j, value)
							SV.db[Schema].totems.enable = value;
							SV:StaticPopup_Show("RL_CLIENT")
						end
					},
					size = {
						order = 9, 
						type = 'range',
						width = "full",
						name = L["Totem Button Size"], 
						min = 24, 
						max = 60, 
						step = 1,
						get = function(j)
							return SV.db[Schema].totems[j[#j]]
						end, 
						set = function(j, value)
							SV.db[Schema].totems[j[#j]] = value
						end
					},
					spacing = {
						order = 10, 
						type = 'range', 
						width = "full",
						name = L['Totem Button Spacing'], 
						min = 1, 
						max = 10, 
						step = 1,
						get = function(j)
							return SV.db[Schema].totems[j[#j]]
						end, 
						set = function(j, value)
							SV.db[Schema].totems[j[#j]] = value
						end
					},
					sortDirection = {
						order = 11, 
						type = 'select', 
						name = L["Totem Sort Direction"], 
						values = {
							['ASCENDING'] = L['Ascending'], 
							['DESCENDING'] = L['Descending']
						},
						get = function(j)
							return SV.db[Schema].totems[j[#j]]
						end, 
						set = function(j, value)
							SV.db[Schema].totems[j[#j]] = value
						end
					},
					showBy = {
						order = 12, 
						type = 'select', 
						name = L['Totem Bar Direction'], 
						values = {
							['VERTICAL'] = L['Vertical'], 
							['HORIZONTAL'] = L['Horizontal']
						},
						get = function(j)
							return SV.db[Schema].totems[j[#j]]
						end, 
						set = function(j, value)
							SV.db[Schema].totems[j[#j]] = value
						end
					},
					bubbles = {
						order = 13,
						type = "toggle",
						name = L['Chat Bubbles Style'],
						desc = L['Style the blizzard chat bubbles.'],
						get = function(j)return SV.db[Schema].bubbles end,
						set = function(j,value)SV.db[Schema].bubbles = value;SV:StaticPopup_Show("RL_CLIENT")end
					},
				}
			},	
			automations = {
				order = 2, 
				type = "group", 
				name = L["General"], 
				guiInline = true, 
				args = {
					intro = {
						order = 1, 
						type = "description", 
						name = L["Adjust the behavior of the many automations."]
					},
					automationGroup1 = {
						order = 2, 
						type = "group", 
						guiInline = true, 
						name = L["Task Minions"],
						desc = L['Minions that can make certain tasks easier by handling them automatically.'],
						args = {
							mailOpener = {
								order = 1,
								type = 'toggle',
								name = L["Enable Mail Helper"],
								get = function(j)return SV.db[Schema].mailOpener end,
								set = function(j,value)SV.db[Schema].mailOpener = value;MOD:ToggleMailMinions()end
							},
							autoAcceptInvite = {
								order = 2,
								name = L['Accept Invites'],
								desc = L['Automatically accept invites from guild/friends.'],
								type = 'toggle',
								get = function(j)return SV.db[Schema].autoAcceptInvite end,
								set = function(j,value)SV.db[Schema].autoAcceptInvite = value end
							},
							vendorGrays = {
								order = 3,
								name = L['Vendor Grays'],
								desc = L['Automatically vendor gray items when visiting a vendor.'],
								type = 'toggle',
								get = function(j)return SV.db[Schema].vendorGrays end,
								set = function(j,value)SV.db[Schema].vendorGrays = value end
							},
							autoRoll = {
								order = 4,
								name = L['Auto Greed/DE'],
								desc = L['Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level.'],
								type = 'toggle',
								get = function(j)return SV.db[Schema].autoRoll end,
								set = function(j,value)SV.db[Schema].autoRoll = value end,
								disabled = function()return not SV.db.general.lootRoll end
							},
							pvpautorelease = {
								order = 5,
								type = "toggle",
								name = L['PvP Autorelease'],
								desc = L['Automatically release body when killed inside a battleground.'],
								get = function(j)return SV.db[Schema].pvpautorelease end,
								set = function(j,value)SV.db[Schema].pvpautorelease = value;SV:StaticPopup_Show("RL_CLIENT")end
							},
							autorepchange = {
								order = 6,
								type = "toggle",
								name = L['Track Reputation'],
								desc = L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'],
								get = function(j)return SV.db[Schema].autorepchange end,
								set = function(j,value)SV.db[Schema].autorepchange = value end
							},
							skipcinematics = {
								order = 7,
								type = "toggle",
								name = L['Skip Cinematics'],
								desc = L['Automatically skip any cinematic sequences.'],
								get = function(j)return SV.db[Schema].skipcinematics end,
								set = function(j,value) SV.db[Schema].skipcinematics = value; SV:StaticPopup_Show("RL_CLIENT") end
							},
							autoRepair = {
								order = 8,
								name = L['Auto Repair'],
								desc = L['Automatically repair using the following method when visiting a merchant.'],
								type = 'select',
								values = {
									['NONE'] = NONE,
									['GUILD'] = GUILD,
									['PLAYER'] = PLAYER
								},
								get = function(j)return SV.db[Schema].autoRepair end,
								set = function(j,value)SV.db[Schema].autoRepair = value end
							},
						}
					},
					automationGroup2 = {
						order = 3, 
						type = "group", 
						guiInline = true, 
						name = L["Quest Minions"],
						desc = L['Minions that can make questing easier by automatically accepting/completing quests.'],
						args = {
							autoquestaccept = {
								order = 1,
								type = "toggle",
								name = L['Accept Quests'],
								desc = L['Automatically accepts quests as they are presented to you.'],
								get = function(j)return SV.db[Schema].autoquestaccept end,
								set = function(j,value) SV.db[Schema].autoquestaccept = value end
							},
							autoquestcomplete = {
								order = 2,
								type = "toggle",
								name = L['Complete Quests'],
								desc = L['Automatically complete quests when possible.'],
								get = function(j)return SV.db[Schema].autoquestcomplete end,
								set = function(j,value)SV.db[Schema].autoquestcomplete = value end
							},
							autoquestreward = {
								order = 3,
								type = "toggle",
								name = L['Select Quest Reward'],
								desc = L['Automatically select the quest reward with the highest vendor sell value.'],
								get = function(j)return SV.db[Schema].autoquestreward end,
								set = function(j,value)SV.db[Schema].autoquestreward = value end
							},
							autodailyquests = {
								order = 4,
								type = "toggle",
								name = L['Only Automate Dailies'],
								desc = L['Force the auto accept functions to only respond to daily quests. NOTE: This does not apply to daily heroics for some reason.'],
								get = function(j)return SV.db[Schema].autodailyquests end,
								set = function(j,value)SV.db[Schema].autodailyquests = value end
							},
							autopvpquests = {
								order = 5,
								type = "toggle",
								name = L['Accept PVP Quests'],
								get = function(j)return SV.db[Schema].autopvpquests end,
								set = function(j,value)SV.db[Schema].autopvpquests = value end
							},
						}
					}, 
				}
			}
		}
	}
end