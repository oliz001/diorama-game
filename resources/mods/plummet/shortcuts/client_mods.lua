local function onLoadSuccessful ()

    local types = dio.events.types
    dio.events.addListener (types.CLIENT_KEY_CLICKED, onKeyClicked)

end

local function onKeyClicked (keyCode, keyCharacter, keyModifiers)

local self = instance
local keyCodes = dio.inputs.keyCodes

if self.isVisible = false then
elseif keyCode == keyCodes.J then
dio.clientChat.send (".join")
return true
    	
elseif keyCode == keyCodes.R then
dio.clientChat.send (".ready")
return true
	end
end

--------------------------------------------------

local modSettings =
{
    name = "Shortcuts",

    description = "Replaces common chat commands with keyboard shortcuts.",

    permissionsRequired =
    {
        client = true,
        player = true,
        input = true
    },
}

--------------------------------------------------
return modSettings, onLoadSuccessful
