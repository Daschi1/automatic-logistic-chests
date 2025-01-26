local integration_parsing = require("settings.integration-parsing")

--------------------------------------------------------------------------------
--- Called when a new game is created or when a mod is first added to an existing save.
--------------------------------------------------------------------------------
script.on_init(function()
    -- Parse and store the user-defined integration settings into storage.
    integration_parsing.parse_and_save_integration_settings(true)
end)
