--[[
##############################################################################
S V U I   By: S.Jackson
############################################################################## ]]-- 
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local type      = _G.type;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert   = _G.tinsert;
local string    = _G.string;
local math      = _G.math;
local table     = _G.table;
--[[ STRING METHODS ]]--
local format, find, lower, match = string.format, string.find, string.lower, string.match;
--[[ MATH METHODS ]]--
local floor, abs, min, max = math.floor, math.abs, math.min, math.max;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat, tdump = table.remove, table.copy, table.wipe, table.sort, table.concat, table.dump;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
SV.ScriptError = _G["SVUI_ScriptError"];
local ScriptErrorDialog = _G["SVUI_ScriptErrorDialog"];
local ScriptErrorScrollBar = _G["SVUI_ScriptErrorDialogScrollBar"];

local DevTools_Dump = _G.DevTools_Dump;
local DevTools_RunDump = _G.DevTools_RunDump;
--[[ 
########################################################## 
CUSTOM MESSAGE WINDOW
##########################################################
]]--
local ScriptError_OnShow = function(self)
    if self.Source then
        local txt = self.Source;
        self.Title:SetText(txt);
    end
end

local ScriptError_OnTextChanged = function(self, userInput)
    if userInput then return end 
    local _, max = ScriptErrorScrollBar:GetMinMaxValues()
    for i = 1, max do
      ScrollFrameTemplate_OnMouseWheel(ScriptErrorDialog, -1)
    end
end
--[[ 
########################################################## 
OTHER SLASH COMMANDS
##########################################################
]]--
local function GetOriginalContext()
    UIParentLoadAddOn("Blizzard_DebugTools")
    local orig_DevTools_RunDump = DevTools_RunDump
    local originalContext
    DevTools_RunDump = function(value, context)
        originalContext = context
    end
    DevTools_Dump("")
    DevTools_RunDump = orig_DevTools_RunDump
    return originalContext
end

local function SV_Dump(value)
    local context = GetOriginalContext()
    local buffer = ""
    context.Write = function(self, msg)
        buffer = buffer.."\n"..msg
    end
 
    DevTools_RunDump(value, context)
    return buffer.."\n"..table.dump(value)
end

local function DebugDump(any)
    if type(any)=="string" then 
        return any
    elseif type(any) == "table" then
        return SV_Dump(any)
    elseif any==nil or type(any)=="number" then 
        return tostring(any) 
    end
    return any
end

function SV.ScriptError:DebugOutput(msg)
    if not self:IsShown() then
        self:Show()
    end
    ScriptErrorDialog.Input:SetText(msg)
end 

function SV.ScriptError:ShowDebug(header, ...)
    local value = (header and format("Debug %s: ", header)) or "Debug: "
    value = format("|cff11ff11 %s|r", value)
    for i = 1, select('#', ...), 2 do
        local name = select(i, ...)
        local var = DebugDump(select(i+1, ...))
        value = format("%s %s = ", value, name)..var
    end
    self.Source = header;
    self:DebugOutput(value)
end

_G.DebugThisFrame = function(arg)
    local outputString = " ";
    if arg then
        arg = _G[arg] or GetMouseFocus()
    else
        arg = GetMouseFocus()
    end
    if arg and (arg.GetName and arg:GetName()) then
        local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
        outputString = outputString.."|cffCC0000----------------------------".."\n"
        outputString = outputString.."|cffCC00FF--Mouseover Frame".."|r".."\n"
        outputString = outputString.."|cffCC0000----------------------------|r".."\n"
        outputString = outputString.."|cff00D1FF".."Name: |cffFFD100"..arg:GetName().."\n"
        if arg:GetParent() and arg:GetParent():GetName() then
            outputString = outputString.."|cff00D1FF".."Parent: |cffFFD100"..arg:GetParent():GetName().."\n"
        end
        outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",arg:GetWidth()).."\n"
        outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",arg:GetHeight()).."\n"
        outputString = outputString.."|cff00D1FF".."Strata: |cffFFD100"..arg:GetFrameStrata().."\n"
        outputString = outputString.."|cff00D1FF".."Level: |cffFFD100"..arg:GetFrameLevel().."\n"
        outputString = outputString.."|cff00D1FF".."IsShown: |cffFFD100"..tostring(arg:IsShown()).."\n"
        if arg.Panel and arg.Panel:GetAttribute("panelPadding") then
            outputString = outputString.."|cff00D1FF".."Padding: |cffFFD100"..arg.Panel:GetAttribute("panelPadding").."\n"
        end
        if arg.Panel and arg.Panel:GetAttribute("panelOffset") then
            outputString = outputString.."|cff00D1FF".."Offset: |cffFFD100"..arg.Panel:GetAttribute("panelOffset").."\n"
        end
        if arg.GetID and arg:GetID() then
            outputString = outputString.."|cff00D1FF".."ID: |cffFFD100"..arg:GetID().."\n"
        end
        if xOfs then
            outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",xOfs).."\n"
        end
        if yOfs then
            outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",yOfs).."\n"
        end
        if relativeTo and relativeTo:GetName() then
            outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint.."\n"
        end
        local bg = arg:GetBackdrop()
        if type(bg) == "table" then
            outputString = outputString.."|cffFF9900>> BACKDROP --------------------------|r".."\n"
            outputString = outputString..tdump(bg).."\n"
        end
        if arg._template then
            outputString = outputString.."Template Name: |cff00FF55"..arg._template.."\n"
        end
        if arg.Panel then
            local cpt, crt, crp, cxo, cyo = arg.Panel:GetPoint()
            outputString = outputString.."|cffFF8800>> backdropFrame --------------------------|r".."\n"
            outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",arg.Panel:GetWidth()).."\n"
            outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",arg.Panel:GetHeight()).."\n"
            outputString = outputString.."|cff00D1FF".."Strata: |cffFFD100"..arg.Panel:GetFrameStrata().."\n"
            outputString = outputString.."|cff00D1FF".."Level: |cffFFD100"..arg.Panel:GetFrameLevel().."\n"
            if cxo then
                outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",cxo).."\n"
            end
            if cyo then
                outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",cyo).."\n"
            end
            if crt and crt:GetName() then
                outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..cpt.."|r anchored to "..crt:GetName().."'s |cffFFD100"..crp.."\n"
            end
            bg = arg.Panel:GetBackdrop()
            if type(bg) == "table" then
                outputString = outputString.."|cffFF9900>> BACKDROP --------------------------|r".."\n"
                outputString = outputString..tdump(bg).."\n"
            end
            if arg.Panel.Skin then
                local cpt, crt, crp, cxo, cyo = arg.Panel.Skin:GetPoint()
                outputString = outputString.."|cffFF7700>> backdropTexture --------------------------|r".."\n"
                outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",arg.Panel.Skin:GetWidth()).."\n"
                outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",arg.Panel.Skin:GetHeight()).."\n"
                if cxo then
                    outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",cxo).."\n"
                end
                if cyo then
                    outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",cyo).."\n"
                end
                if crt and crt:GetName() then
                    outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..cpt.."|r anchored to "..crt:GetName().."'s |cffFFD100"..crp.."\n"
                end
                bg = arg.Panel.Skin:GetTexture()
                if bg then
                    outputString = outputString.."|cff00D1FF".."Texture: |cffFFD100"..bg.."\n"
                end
            end
        end
        local childFrames = { arg:GetChildren() }
        if #childFrames > 0 then
            outputString = outputString.."|cffCC00FF>>>> Child Frames----------------------------".."|r".."\n".."\n"
            for _, child in ipairs(childFrames) do
                local cpt, crt, crp, cxo, cyo = child:GetPoint()
                if child:GetName() then
                    outputString = outputString.."\n\n|cff00FF55++"..child:GetName().."|r".."\n"
                else
                    outputString = outputString.."\n\n|cff99FF55+!!+".."Anonymous Frame".."|r".."\n"
                end
                outputString = outputString.."|cffCC00FF----------------------------|r".."\n"
                outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",child:GetWidth()).."\n"
                outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",child:GetHeight()).."\n"
                outputString = outputString.."|cff00D1FF".."Strata: |cffFFD100"..child:GetFrameStrata().."\n"
                outputString = outputString.."|cff00D1FF".."Level: |cffFFD100"..child:GetFrameLevel().."\n"
                if child.Panel and child.Panel:GetAttribute("panelPadding") then
                    outputString = outputString.."|cff00D1FF".."Padding: |cffFFD100"..child.Panel:GetAttribute("panelPadding").."\n"
                end
                if child.Panel and child.Panel:GetAttribute("panelOffset") then
                    outputString = outputString.."|cff00D1FF".."Offset: |cffFFD100"..child.Panel:GetAttribute("panelOffset").."\n"
                end
                if cxo then
                    outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",cxo).."\n"
                end
                if cyo then
                    outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",cyo).."\n"
                end
                if crt and crt:GetName() then
                    outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..cpt.."|r anchored to "..crt:GetName().."'s |cffFFD100"..crp.."\n"
                end
                bg = child:GetBackdrop()
                if type(bg) == "table" then
                    outputString = outputString.."|cffFF9900>> BACKDROP --------------------------|r".."\n"
                    outputString = outputString..tdump(bg).."\n"
                end
                if child._template then
                    outputString = outputString.."Template Name: |cff00FF55"..child._template.."\n"
                end
                if child.Panel then
                    local cpt, crt, crp, cxo, cyo = child.Panel:GetPoint()
                    outputString = outputString.."|cffFF8800>> backdropFrame --------------------------|r".."\n"
                    outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",child.Panel:GetWidth()).."\n"
                    outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",child.Panel:GetHeight()).."\n"
                    outputString = outputString.."|cff00D1FF".."Strata: |cffFFD100"..child.Panel:GetFrameStrata().."\n"
                    outputString = outputString.."|cff00D1FF".."Level: |cffFFD100"..child.Panel:GetFrameLevel().."\n"
                    if cxo then
                        outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",cxo).."\n"
                    end
                    if cyo then
                        outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",cyo).."\n"
                    end
                    if crt and crt:GetName() then
                        outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..cpt.."|r anchored to "..crt:GetName().."'s |cffFFD100"..crp.."\n"
                    end
                    bg = child.Panel:GetBackdrop()
                    if type(bg) == "table" then
                        outputString = outputString.."|cffFF9900>> BACKDROP --------------------------|r".."\n"
                        outputString = outputString..tdump(bg).."\n"
                    end
                    if child._skin then
                        local cpt, crt, crp, cxo, cyo = child._skin:GetPoint()
                        outputString = outputString.."|cffFF7700>> backdropTexture --------------------------|r".."\n"
                        outputString = outputString.."|cff00D1FF".."Width: |cffFFD100"..format("%.2f",child._skin:GetWidth()).."\n"
                        outputString = outputString.."|cff00D1FF".."Height: |cffFFD100"..format("%.2f",child._skin:GetHeight()).."\n"
                        if cxo then
                            outputString = outputString.."|cff00D1FF".."X: |cffFFD100"..format("%.2f",cxo).."\n"
                        end
                        if cyo then
                            outputString = outputString.."|cff00D1FF".."Y: |cffFFD100"..format("%.2f",cyo).."\n"
                        end
                        if crt and crt:GetName() then
                            outputString = outputString.."|cff00D1FF".."Point: |cffFFD100"..cpt.."|r anchored to "..crt:GetName().."'s |cffFFD100"..crp.."\n"
                        end
                        bg = child._skin:GetTexture()
                        if bg then
                            outputString = outputString.."|cffFF9900----------------------------|r".."\n"
                            outputString = outputString..bg.."\n"
                        end
                        outputString = outputString.."|cffCC0000----------------------------|r".."\n"
                    end
                end
            end
            outputString = outputString.."\n\n"
        end
    elseif arg == nil or arg == "" then
        outputString = outputString.."Invalid frame name".."\n"
    else
        outputString = outputString.."Could not find frame info".."\n"
    end
    SV.ScriptError:DebugOutput(outputString)
    --ScriptErrorDialog:SetVerticalScroll(1)
end

_G.SlashCmdList["SVUI_FRAME_DEBUG"] = DebugThisFrame;
_G.SLASH_SVUI_FRAME_DEBUG1 = "/svdf"

--SetCVar('scriptProfile',1)

local function InitializeScriptError()
    SV.ScriptError:SetParent(SV.Screen)
    SV.ScriptError.Source = "";
    SV.ScriptError:SetStyle("!_Frame", "Transparent")
    SV.ScriptError:SetScript("OnShow", ScriptError_OnShow)
    ScriptErrorDialog:SetStyle("!_Frame", "Transparent")
    ScriptErrorDialog.Input:SetScript("OnTextChanged", ScriptError_OnTextChanged)
    SV.ScriptError:RegisterForDrag("LeftButton");
end

SV.Events:On("LOAD_ALL_ESSENTIALS", InitializeScriptError);