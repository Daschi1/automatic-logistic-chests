--------------------------------------------------------------------------------
--- Integration Parsing Module
--- This module provides functions to parse user-defined entity integrations
--- from a runtime-global string setting into a Lua table structure.
--- The format for each setting is:
---   <entity-type> = <item[:quality]>, <item[:quality]>; <entity-type> = ...
---
--- Example:
---   "artillery-turret = artillery-shell; rocket-silo = satellite:epic"
--- This would parse into:
---   {
---     ["artillery-turret"] = {
---       { item = "artillery-shell", quality = "normal" },
---     },
---     ["rocket-silo"] = {
---       { item = "satellite", quality = "epic" },
---     }
---   }
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--- Utility function to trim leading/trailing whitespace from a string.
---
--- @param s string
--- @return string trimmed
--------------------------------------------------------------------------------
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------
--- Gathers valid quality names by iterating over prototypes["quality"].
--- Also ensures "normal" is always included.
--- In a real mod, you would likely do this in data stage and store the result.
---
--- @return table<string, boolean> # Mapping of lowercase quality -> true
--------------------------------------------------------------------------------
local function get_valid_quality_names()
    local valid_qualities = {}

    if prototypes and prototypes["quality"] then
        for quality_name, _ in pairs(prototypes["quality"]) do
            valid_qualities[quality_name] = true
        end
    end

    -- Always add "normal" to the valid set
    valid_qualities["normal"] = true

    return valid_qualities
end

--------------------------------------------------------------------------------
--- Parses a single integration setting string (e.g., for educts or products).
---
--- Expected format:
---   "entity-type = item1[:quality], item2[:quality]; entity2 = item3:epic"
---
--- Rules:
---  - Semicolons (`;`) separate multiple entity definitions.
---  - Commas (`,`) separate multiple items within the same entity definition.
---  - If `:quality` is omitted, defaults to `"normal"`.
---  - Valid quality names are taken from `data.raw["quality"]` plus `"normal"`.
---  - If a non-"normal" quality is specified but `script.feature_flags.quality` is false/nil,
---    we force it to `"normal"` and warn the user.
---
--- Localized warnings:
---   * {"automatic-logistic-chests.invalid-integration-syntax", <line>}
---   * {"automatic-logistic-chests.empty-entity-or-item-list", <line>}
---   * {"automatic-logistic-chests.unknown-quality", <quality>}
---   * {"automatic-logistic-chests.quality-disabled", <quality>}
---
--- @param raw_string string The raw user input from the mod setting.
--- @usage parse_integration_setting("artillery-turret = artillery-shell:epic; rocket-silo = satellite")
--- @usage parse_integration_setting("machine = itemA, itemB:rare")
--- @usage parse_integration_setting("")
---
--- @return table<string, table> # Map of entity-type -> list of { item:string, quality:string }
--------------------------------------------------------------------------------
local function parse_integration_setting(raw_string)
    local result = {}

    -- Fetch the valid qualities
    local valid_qualities_from_data = get_valid_quality_names()
    local quality_feature_enabled = (script and script.feature_flags and script.feature_flags.quality)

    -- Split on semicolons to separate entity definitions
    for entity_def in string.gmatch(raw_string, "([^;]+)") do
        local trimmed_def = trim(entity_def)
        if trimmed_def ~= "" then
            -- Example entity_def: "artillery-turret = artillery-shell, explosive-shell:epic"

            -- Split on '=' to separate "entity-type" from the item definitions
            local parts = {}
            for piece in string.gmatch(trimmed_def, "([^=]+)") do
                table.insert(parts, trim(piece))
            end

            -- We expect exactly 2 parts (entity and items)
            if #parts ~= 2 then
                if game and game.print then
                    game.print({ "automatic-logistic-chests.invalid-integration-syntax", trimmed_def })
                end
                goto continue
            end

            local entity_type = parts[1]
            local items_string = parts[2]

            if entity_type == "" or items_string == "" then
                if game and game.print then
                    game.print({ "automatic-logistic-chests.empty-entity-or-item-list", trimmed_def })
                end
                goto continue
            end

            local item_list = {}
            -- Split items by comma
            for item_def in string.gmatch(items_string, "([^,]+)") do
                local trimmed_item_def = trim(item_def)
                if trimmed_item_def ~= "" then
                    -- item[:quality]
                    local subparts = {}
                    for piece in string.gmatch(trimmed_item_def, "([^:]+)") do
                        table.insert(subparts, trim(piece))
                    end

                    local item_name = subparts[1] or ""
                    local quality_name = "normal" -- default

                    if #subparts == 2 then
                        local q = subparts[2]
                        if q and q ~= "" then
                            local q_lower = q:lower()

                            -- Check if it's recognized by data OR "normal"
                            if valid_qualities_from_data[q_lower] then
                                -- If non-normal, check feature flag
                                if q_lower ~= "normal" then
                                    if quality_feature_enabled then
                                        quality_name = q_lower
                                    else
                                        -- Force to normal, warn user
                                        quality_name = "normal"
                                        if game and game.print then
                                            game.print({ "automatic-logistic-chests.quality-disabled", q_lower })
                                        end
                                    end
                                else
                                    -- It's recognized and is "normal"
                                    quality_name = "normal"
                                end
                            else
                                -- Unknown quality => fallback to normal, warn user
                                quality_name = "normal"
                                if game and game.print then
                                    game.print({ "automatic-logistic-chests.unknown-quality", q_lower })
                                end
                            end
                        end
                    end

                    if item_name ~= "" then
                        table.insert(item_list, {
                            item    = item_name,
                            quality = quality_name
                        })
                    end
                end
            end

            if #item_list > 0 then
                result[entity_type] = item_list
            end
        end
        ::continue::
    end

    return result
end

--------------------------------------------------------------------------------
--- The main table returned by this module.
--------------------------------------------------------------------------------
local integration_parsing = {}

--------------------------------------------------------------------------------
--- Force-parses and updates 'storage.educt_integrations' and 'storage.product_integrations'
--- from the current mod settings, overwriting any previously stored data.
---
--- @param ignore_previous boolean? If true, it forcibly re-parses even if the raw setting has not changed. Defaults to false.
--------------------------------------------------------------------------------
function integration_parsing.parse_and_save_integration_settings(ignore_previous)
    local force = ignore_previous == true

    -- Educt setting check
    local raw_educt = settings.global["automatic-logistic-chests-educt-integrations"].value
    --- @cast raw_educt string
    if force or (raw_educt ~= storage.educt_integrations_raw) then
        storage.educt_integrations = parse_integration_setting(raw_educt)
        storage.educt_integrations_raw = raw_educt
    end

    -- Product setting check
    local raw_product = settings.global["automatic-logistic-chests-product-integrations"].value
    --- @cast raw_product string
    if force or (raw_product ~= storage.product_integrations_raw) then
        storage.product_integrations = parse_integration_setting(raw_product)
        storage.product_integrations_raw = raw_product
    end
end

--------------------------------------------------------------------------------
--- Returns the parsed educt integrations table.
--- If the user has changed the setting since the last parse,
--- this will re-parse the setting before returning it.
---
--- @return table<string, table> # entity-> list of {item, quality}
--------------------------------------------------------------------------------
function integration_parsing.get_parsed_educt_integrations()
    -- Call parse_and_save_integration_settings() with ignore_previous=false
    -- so it only re-parses if the raw setting has changed.
    integration_parsing.parse_and_save_integration_settings(false)
    return storage.educt_integrations
end

--------------------------------------------------------------------------------
--- Returns the parsed product integrations table.
--- If the user has changed the setting since the last parse,
--- this will re-parse the setting before returning it.
---
--- @return table<string, table> # entity-> list of {item, quality}
--------------------------------------------------------------------------------
function integration_parsing.get_parsed_product_integrations()
    -- Call parse_and_save_integration_settings() with ignore_previous=false
    -- so it only re-parses if the raw setting has changed.
    integration_parsing.parse_and_save_integration_settings(false)
    return storage.product_integrations
end

return integration_parsing
