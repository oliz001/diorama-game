--------------------------------------------------
local modsToLoad = 
{
    {
        folder = "diorama",
        modName = "creative",
        versionRequired = {major = 1, minor = 0},
    },
    {
        folder = "diorama",
        modName = "blocks",
        versionRequired = {major = 1, minor = 0},
    },    
    {
        folder = "diorama",
        modName = "motd",
        versionRequired = {major = 1, minor = 0},
    },
    {
        folder = "diorama",
        modName = "spawn",
        versionRequired = {major = 1, minor = 0},
    },
}

--------------------------------------------------
local mods = {}

--------------------------------------------------
local function main ()

    local regularPermissions = 
    {
        blocks = true,
        client = true,
        file = true,
        player = true,
        serverChat = true,
    }

    for _, modData in ipairs (modsToLoad) do
        local mod, error = dio.mods.load (modData, regularPermissions)
        if mod then
            mods [modData.modName] = mod
        else
            print (error)
        end
    end    
end

--------------------------------------------------
main ()
