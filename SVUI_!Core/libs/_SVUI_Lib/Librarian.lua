--[[
Librarian is a library used to manage localization, packages, scripts, animations and data embedded
into the SVUI core addon.

It's main purpose is to keep all methods and logic needed to properly keep
core add-ins functioning outside of the core object and away from other libraries like LibStub.                                                                     
--]]
local _G = getfenv(0)

local Librarian = _G["Librarian"]

if not Librarian then
    Librarian = Librarian or {libs = {}, arrested = {}, warrants = {}}
    _G["Librarian"] = Librarian
    
    function Librarian:NewLibrary(libName)
        assert(type(libName) == "string", "Missing Library Name")
        self.libs[libName] = self.libs[libName] or {}
        return self.libs[libName]
    end
    
    function Librarian:Fetch(libName, silent)
        if not self.libs[libName] and not silent then
            error(("Cannot find a library instance of %q."):format(tostring(libName)), 2)
        end
        return self.libs[libName]
    end

    local dead = function() return end

    function Librarian:LockLibrary(lib)
        if((warrants[lib]) or (not LibStub) or (not LibStub.libs)) then return end
        for libName,libObj in pairs(LibStub.libs) do
            if(libName:find(lib) and (not arrested[libName])) then
                warrants[lib] = true
                arrested[libName] = {}
                for k,v in pairs(libObj) do
                    if(type(v) == 'function') then
                        arrested[libName][k] = v
                        v = dead
                    end
                end
            end
        end
    end

    function Librarian:UnlockLibrary(lib)
        if((not LibStub) or (not LibStub.libs)) then return end
        for libName,libObj in pairs(LibStub.libs) do
            if(libName:find(lib) and (arrested[libName])) then
                for k,v in pairs(arrested[libName]) do
                    libObj[k] = v
                end
                warrants[lib] = nil
                arrested[libName] = nil
            end
        end
    end

    setmetatable(Librarian, { __call = Librarian.Fetch })
end
