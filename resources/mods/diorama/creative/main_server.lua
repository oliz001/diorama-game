--------------------------------------------------
local groups =
{
    tourist = 
    {
        color = "%aaa",
        canChat = true,
        canColourText = false,
    },
    builder = 
    {
        color = "%fff",
        canBuild = true,
        canDestroy = true,
        canChat = true,
        canColourText = true,
    },
    mod = 
    {
        color = "%f44",
        canBuild = true,
        canDestroy = true,
        canChat = true,
        canColourText = true,    
        canPromoteTo = {tourist = true, builder = true},
    },
    admin = 
    {
        color = "%ff4",
        canBuild = true,
        canDestroy = true,
        canChat = true,
        canColourText = true,    
        canPromoteTo = {tourist = true, builder = true, mod = true},
    }
}

--------------------------------------------------
local gravityDirNames =
{
    -- TODO should be using io.inputs.gravityDirs but inputs is not for the server
    [0] =  "NORTH",
    [1] =   "EAST",
    [2] =  "SOUTH",
    [3] =   "WEST",
    [4] =     "UP",
    [5] =   "DOWN",
}

--------------------------------------------------
local gravityDirIndices =
{
    -- TODO should be using io.inputs.gravityDirs but inputs is not for the server
    NORTH =  0,
    EAST =   1,
    SOUTH =  2,
    WEST =   3,
    UP =     4,
    DOWN =   5,
}

--------------------------------------------------
local connections = {}

--------------------------------------------------
local function stripColourCodes (text)

    local stripped = text:gsub ("\\%%", "{REPLACE}")
    local stripped = stripped:gsub ("%%...", "")
    local stripped = stripped:gsub ("{REPLACE}", "\\%%")
    return stripped
end

--------------------------------------------------
local function onUserConnected (event)

    local filename = "player_" .. event.playerName .. ".lua"
    local settings = dio.file.loadLua (filename)

    local isPasswordCorrect = true
    if settings then
        isPasswordCorrect = (settings.password == event.password)
    end

    local connection =
    {
        connectionId = event.connectionId,
        playerName = event.playerName,
        screenName = event.playerName,
        password = event.password,
        groupId = event.isSinglePlayer and "builder" or "tourist",
        isPasswordCorrect = isPasswordCorrect,
        needsSaving = event.isSinglePlayer,
        gravityDir = settings and settings.gravityDir or "DOWN",
    }

    if settings and isPasswordCorrect then
        connection.groupId = settings.permissionLevel
        connection.needsSaving = true
        dio.world.setPlayerXyz (event.playerName, settings.xyz)
        dio.world.setPlayerGravity (event.playerName, gravityDirIndices [settings.gravityDir])
    end

    connection.screenName = connection.screenName .. " [" .. connection.groupId .. "]"

    connections [event.connectionId] = connection
end

--------------------------------------------------
local function onUserDisconnected (event)

    local connection = connections [event.connectionId]
    local group = groups [connection.groupId]

    if connection.needsSaving then

        local xyz, error = dio.world.getPlayerXyz (event.playerName)
        if xyz then

            local filename = "player_" .. event.playerName .. ".lua"
            local settings =
            {
                xyz = xyz,
                password = connection.password,
                permissionLevel = connection.groupId,
                gravityDir = gravityDirNames [dio.world.getPlayerGravity (event.playerName)],
            }

            dio.file.saveLua (filename, settings, "settings")

        else
            print (error)
        end
    end

    connections [event.connectionId] = nil
end

--------------------------------------------------
local function onEntityPlaced (event)
    local connection = connections [event.playerId]
    local canBuild = groups [connection.groupId].canBuild
    event.cancel = not canBuild
end

--------------------------------------------------
local function onEntityDestroyed (event)
    local connection = connections [event.playerId]
    local canDestroy = groups [connection.groupId].canDestroy
    event.cancel = not canDestroy
end

--------------------------------------------------
local function onChatReceived (event)

    local connection = connections [event.authorConnectionId]
    local group = groups [connection.groupId]
    local canColourText = group.canColourText    

    if not canColourText then
        print ("INCOMING CHAT " .. event.text)
        event.text = stripColourCodes (event.text)
        print ("OUTGOING CHAT " .. event.text)
    end

    if event.text:sub (1, 1) ~= "." then
        return
    end

    if event.text == ".help" then

        event.targetConnectionId = event.authorConnectionId
        event.text = ".help, .motd, .spawn, .tp <X> <Y> <Z>, .tp <player>, .coords, .coords <player>, .group, .showPassword, .listPlayerGroups, .listGroups, .setHome, .home"

    elseif event.text == ".help mod" then

        event.targetConnectionId = event.authorConnectionId
        event.text = ".setGroup <player> <group>"

    elseif event.text == ".showPassword" then

        local connection = connections [event.authorConnectionId]

        event.targetConnectionId = event.authorConnectionId
        if connection.isPasswordCorrect then
            event.text = "Your password (validated) = " .. connection.password
        else
            event.text = "Your password (UNVALIDATED) = " .. connection.password
        end

    elseif event.text == ".group" then

        local connection = connections [event.authorConnectionId]

        event.targetConnectionId = event.authorConnectionId
        event.text = "Your group = " .. connection.groupId

    elseif event.text == ".listGroups" then

        event.targetConnectionId = event.authorConnectionId
        event.text = "All groups = tourist, builder, mod, admin"

    elseif event.text == ".listPlayerGroups" then

        event.targetConnectionId = event.authorConnectionId
        event.text = ""
        for groupId, group in pairs (groups) do
            local isNewAdd = true
            for _, connection in pairs (connections) do
                if connection.groupId == groupId then
                    if isNewAdd then
                        event.text = group.color .. event.text .. "[" .. groupId .. "] = "
                        isNewAdd = false
                    end
                    event.text = event.text .. connection.playerName .. ", "
                end
            end
        end

    else

        local connection = connections [event.authorConnectionId]
        local canPromoteTo = groups [connection.groupId].canPromoteTo

        if canPromoteTo then

            local commandIdx = event.text:find (".setGroup")

            if commandIdx == 1 then

                local words = {}
                for word in event.text:gmatch ("[^ ]+") do
                    table.insert (words, word)
                end

                event.targetConnectionId = event.authorConnectionId
                event.text = "FAILED: .setGroup [playerName] [permissionLevel]";

                if #words >= 3 then

                    local groupToSet = words [3]

                    if groups [groupToSet] and canPromoteTo [groupToSet] then
                        local playerToPromote = words [2]

                        local hasPromoted = false
                        for _, promoteConnection in pairs (connections) do
                            if promoteConnection.playerName == playerToPromote and promoteConnection.isPasswordCorrect then

                                local isPlayerLowerLevel = canPromoteTo [promoteConnection.groupId]
                                if isPlayerLowerLevel then
                                    promoteConnection.groupId = groupToSet
                                    promoteConnection.needsSaving = true
                                    hasPromoted = true
                                end
                            end
                        end

                        if hasPromoted then
                            event.text = "SUCCESS: .setGroup " .. playerToPromote .. " -> " .. groupToSet;                        
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------
local function onLoadSuccessful ()

    -- dio.players.setPlayerAction (player, actions.LEFT_CLICK, outcomes.DESTROY_BLOCK)

    local types = dio.events.types
    dio.events.addListener (types.SERVER_USER_CONNECTED, onUserConnected)
    dio.events.addListener (types.SERVER_PLAYER_SAVE, onUserDisconnected)
    dio.events.addListener (types.SERVER_ENTITY_PLACED, onEntityPlaced)
    dio.events.addListener (types.SERVER_ENTITY_DESTROYED, onEntityDestroyed)
    dio.events.addListener (types.SERVER_CHAT_RECEIVED, onChatReceived)

end

--------------------------------------------------
local modSettings = 
{
    description =
    {
        name = "Creative",
        description = "This is required to play the game!",
        help =
        {
            showPassword = "Show your group.",
            group = "Show your group.",
            listGroups = "Show all available groups.",
            setGroup = "(mod, admin only) Change the group a player is in.",
        },
    },

    permissionsRequired = 
    {
        file = true,
        inputs = true,
        player = true,
    },
}

--------------------------------------------------
return modSettings, onLoadSuccessful
