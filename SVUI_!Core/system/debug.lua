--[[
##############################################################################
S V U I   By: Munglunch
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
local format, find, lower, match, gsub = string.format, string.find, string.lower, string.match, string.gsub;
--[[ MATH METHODS ]]--
local floor, abs, min, max = math.floor, math.abs, math.min, math.max;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
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

local inspect ={
  _VERSION = 'inspect.lua 3.0.0',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

inspect.KEY       = setmetatable({}, {__tostring = function() return 'inspect.KEY' end})
inspect.METATABLE = setmetatable({}, {__tostring = function() return 'inspect.METATABLE' end})

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, length)
  return type(k) == 'number'
     and 1 <= k
     and k <= length
     and math.floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getNonSequentialKeys(t)
  local keys, length = {}, #t
  for k,_ in pairs(t) do
    if not isSequenceKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = setmetatable({}, {__mode = "kv"})
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or setmetatable({}, {__mode = "k"})

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
    newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
    local processedCopy = {}
    local processedKey

    for k,v in pairs(processed) do
      processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))
      if processedKey ~= nil then
        processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
      end
    end

    local mt  = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))
    setmetatable(processedCopy, mt)
    processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = {__index = Inspector}

function Inspector:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
    len = len + 1
    buffer[len] = tostring(args[i])
  end
end

function Inspector:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function Inspector:tabify()
  self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
    id              = self.maxIds[tv] + 1
    self.maxIds[tv] = id
    self.ids[tv][v] = id
  end
  return id
end

function Inspector:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function Inspector:putTable(t)
  if t == inspect.KEY or t == inspect.METATABLE then
    self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
    self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
    self:puts('{...}')
  else
    if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

    local nonSequentialKeys = getNonSequentialKeys(t)
    local length            = #t
    local mt                = getmetatable(t)
    local toStringResult    = getToStringResultSafely(t, mt)

    self:puts('{')
    self:down(function()
      if toStringResult then
        self:puts(' -- ', escape(toStringResult))
        if length >= 1 then self:tabify() end
      end

      local count = 0
      for i=1, length do
        if count > 0 then self:puts(',') end
        self:puts(' ')
        self:putValue(t[i])
        count = count + 1
      end

      for _,k in ipairs(nonSequentialKeys) do
        if count > 0 then self:puts(',') end
        self:tabify()
        self:putKey(k)
        self:puts(' = ')
        self:putValue(t[k])
        count = count + 1
      end

      if mt then
        if count > 0 then self:puts(',') end
        self:tabify()
        self:puts('<metatable> = ')
        self:putValue(mt)
      end
    end)

    if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
      self:tabify()
    elseif length > 0 then -- array tables have one extra space before closing }
      self:puts(' ')
    end

    self:puts('}')
  end
end

function Inspector:putValue(v)
  local tv = type(v)

  if tv == 'string' then
    self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
    self:puts(tostring(v))
  elseif tv == 'table' then
    self:putTable(v)
  else
    self:puts('<',tv,' ',self:getId(v),'>')
  end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
  options       = options or {}

  local depth   = options.depth   or math.huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
    root = processRecursive(process, root, {})
  end

  local inspector = setmetatable({
    depth            = depth,
    buffer           = {},
    level            = 0,
    ids              = setmetatable({}, idsMetaTable),
    maxIds           = setmetatable({}, maxIdsMetaTable),
    newline          = newline,
    indent           = indent,
    tableAppearances = countTableAppearances(root)
  }, Inspector_mt)

  inspector:putValue(root)

  return table.concat(inspector.buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })
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

local function getOriginalContext()
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

local function formatValueString(value)
    if "string" == type(value) then 
        value = gsub(value,"\n","\\n")
        if match(gsub(value,"[^'\"]",""),'^"+$') then 
            return "'"..value.."'"; 
        else 
            return '"'..gsub(value,'"','\\"')..'"';
        end 
    else 
        return inspect(value);
    end
end

local function formatKeyString(text)
    if("string" == type(text) and match(text,"^[_%a][_%a%d]*$")) then 
        return text;
    else 
        return "["..formatValueString(text).."]";
    end
end

local DUMPTABLE = {};
local CHECKTABLE = {};

local function loadDumpTable(arg)
    for key,data in pairs(arg) do
        if(type(data) == "table") then
            loadDumpTable(data);
        else
            tinsert(DUMPTABLE, "\n        "..formatKeyString(key).." = "..formatValueString(data));
        end
    end
end

local function DebugDump(arg)
    if(arg == nil) then
        return "No Result"
    elseif(type(arg) == "string") then 
        return arg
    elseif(type(arg) == "table") then
        loadDumpTable(arg)
        return table.concat(DUMPTABLE);
        -- local context = getOriginalContext()
        -- if(context) then
        --     local buffer = ""
        --     context.Write = function(self, msg)
        --         buffer = buffer.."\n"..msg
        --     end
         
        --     DevTools_RunDump(arg, context)
        --     return buffer .. "\n" .. tableOutput(arg)
        -- else
        --     return tableOutput(arg)
        -- end
    elseif(type(arg) == "number") then 
        return tostring(arg) 
    end
    return arg
end

function SV.ScriptError:DebugOutput(msg)
    if not self:IsShown() then
        self:Show()
    end
    ScriptErrorDialog.Input:SetText(msg)
end 

function SV.ScriptError:ShowDebug(header, ...)
    wipe(DUMPTABLE);
    wipe(CHECKTABLE);
    local value = (header and format("Debug %s: ", header)) or "Debug: "
    value = format("|cff11ff11 %s|r = {\n", value)
    for i = 1, select('#', ...) do
        local data = select(i, ...)
        local var;
        if(data.GetRegions) then
            var = DebugDump(data:GetRegions())
        else    
            var = DebugDump(data)
        end
        value = format("%s    [%d] = { %s\n    }\n", value, i, var)
    end
    value = format("%s}", value)
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
        if arg.Panel and arg.Panel:GetAttribute("panelID") then
            outputString = outputString.."|cff00D1FF".."StyleName: |cffFFD100"..arg.Panel:GetAttribute("panelID").."\n"
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
            outputString = outputString..inspect(bg).."\n"
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
                outputString = outputString..inspect(bg).."\n"
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
                if child.Panel and child.Panel:GetAttribute("panelID") then
                    outputString = outputString.."|cff00D1FF".."StyleName: |cffFFD100"..child.Panel:GetAttribute("panelID").."\n"
                end
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
                    outputString = outputString..inspect(bg).."\n"
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
                        outputString = outputString..inspect(bg).."\n"
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
    SV.ScriptError:SetStyle("Transparent")
    SV.ScriptError:SetScript("OnShow", ScriptError_OnShow)
    ScriptErrorDialog:SetStyle("Transparent")
    ScriptErrorDialog.Input:SetScript("OnTextChanged", ScriptError_OnTextChanged)
    SV.ScriptError:RegisterForDrag("LeftButton");
end

SV.Events:On("LOAD_ALL_ESSENTIALS", InitializeScriptError);