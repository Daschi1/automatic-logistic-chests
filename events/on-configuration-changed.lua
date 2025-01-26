local integration_parsing = require("settings.integration-parsing")

--------------------------------------------------------------------------------
--- Called when the mod version changes or user modifies the mod settings, etc.
--------------------------------------------------------------------------------
script.on_configuration_changed(function()
    -- Re-parse integration settings in case something changed.
    integration_parsing.parse_and_save_integration_settings(true)
end)
