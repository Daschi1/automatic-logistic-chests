--------------------------------------------------------------------------------
--- Recipe Handler Module
--- Provides functions to gather educts (inputs), products (outputs), and
--- associated quality levels for various entities.
--------------------------------------------------------------------------------

local inserter_handler                  = require("runtime.inserter-handler")
local utils                             = require("runtime.utils")
local integration_parsing               = require("settings.integration-parsing")

--------------------------------------------------------------------------------
--- Recognized standard machines are those that use normal recipe logic.
--- If an entity is not in this set AND not in the custom integration maps,
--- then we return empty results.
--- (all children of https://lua-api.factorio.com/latest/prototypes/CraftingMachinePrototype.html)
--------------------------------------------------------------------------------
local recognized_standard_machine_types = {
    ["assembling-machine"] = true,
    ["furnace"]            = true,
    ["rocket-silo"]        = true,
}

--------------------------------------------------------------------------------
--- The main table returned by this module.
--------------------------------------------------------------------------------
local recipe_handler                    = {}

--------------------------------------------------------------------------------
--- Gather educt amounts and the quality of the first encountered recipe
--- based on inserters picking items from the chest.
---
--- @param chest LuaEntity # The chest entity being analyzed.
--- @param surrounding_inserters LuaEntity[] # A list of inserters around the chest.
--- @return table<string, number> educts_amounts # A table mapping item names to amounts.
--- @return string first_quality # The quality of the first recipe encountered, or "normal".
--------------------------------------------------------------------------------
function recipe_handler.gather_educts_and_quality(chest, surrounding_inserters)
    local educts_amounts = {}
    local first_quality = "normal"

    for _, inserter in pairs(surrounding_inserters) do
        if inserter_handler.is_inserter_picking_from_chest(inserter, chest) then
            local drop_target = inserter.drop_target
            if drop_target and drop_target.valid then
                local sub_educts = recipe_handler.get_educts_amounts(drop_target)
                utils.increment_values_from_table(educts_amounts, sub_educts)
                if first_quality == "normal" then
                    first_quality = recipe_handler.get_recipe_educt_quality(drop_target)
                end
            end
        end
    end

    return educts_amounts, first_quality
end

--------------------------------------------------------------------------------
--- Gather product amounts and the quality of the first encountered recipe
--- based on inserters dropping items into the chest.
---
--- @param chest LuaEntity # The chest entity being analyzed.
--- @param surrounding_inserters LuaEntity[] # A list of inserters around the chest.
--- @return table<string, number> products_amounts # A table mapping item names to amounts.
--- @return string first_quality # The quality of the first recipe encountered, or "normal".
--------------------------------------------------------------------------------
function recipe_handler.gather_products_and_quality(chest, surrounding_inserters)
    local products_amounts = {}
    local first_quality = "normal"

    for _, inserter in pairs(surrounding_inserters) do
        if inserter_handler.is_inserter_dropping_into_chest(inserter, chest) then
            local pickup_target = inserter.pickup_target
            if pickup_target and pickup_target.valid then
                local sub_products = recipe_handler.get_products_amounts(pickup_target)
                utils.increment_values_from_table(products_amounts, sub_products)
                if first_quality == "normal" then
                    first_quality = recipe_handler.get_recipe_product_quality(pickup_target)
                end
            end
        end
    end

    return products_amounts, first_quality
end

--------------------------------------------------------------------------------
--- Returns a table of item -> required_amount (educts) for a given entity.
---
--- If the entity name is in the custom integration (integration_parsing.get_parsed_educt_integrations()),
--- we return the user-defined items. Otherwise, if entity type is in recognized_standard_machine_types,
--- we parse the recipe. If neither applies, we return an empty table.
---
--- @param entity LuaEntity
--- @return table<string, number> educts_amounts
--------------------------------------------------------------------------------
function recipe_handler.get_educts_amounts(entity)
    local educts_amounts = {}

    -- 1) Check user-defined custom integration
    local entity_name = entity.name
    local custom_integration = integration_parsing.get_parsed_educt_integrations()[entity_name]
    if custom_integration then
        for _, entry in pairs(custom_integration) do
            local item_name = entry.item
            local stack_size = utils.get_stack_size(item_name)
            local needed = utils.modify_stack_size_according_to_settings(stack_size, true)
            utils.increment_value_in_table(educts_amounts, item_name, needed)
        end
        return educts_amounts
    end

    -- 2) If not in custom map, check recognized standard machine
    local entity_type = entity.type
    if recognized_standard_machine_types[entity_type] then
        local recipe = entity.get_recipe()
        if not recipe or not recipe.valid then
            return educts_amounts
        end

        -- Collect educts from the recipe
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.type == "item" and ingredient.amount then
                local stack_size = utils.get_stack_size(ingredient.name)
                local needed = math.ceil(ingredient.amount / stack_size) * stack_size
                needed = utils.modify_stack_size_according_to_settings(needed, true)
                if needed > 0 then
                    utils.increment_value_in_table(educts_amounts, ingredient.name, needed)
                end
            end
        end
    end

    return educts_amounts
end

--------------------------------------------------------------------------------
--- Returns a table of item -> produced_amount (products) for a given entity.
---
--- If the entity name is in the custom integration (integration_parsing.get_parsed_product_integrations()),
--- we return the user-defined items. Otherwise, if entity type is in recognized_standard_machine_types,
--- we parse the recipe. If neither applies, we return an empty table.
---
--- @param entity LuaEntity
--- @return table<string, number> products_amounts
--------------------------------------------------------------------------------
function recipe_handler.get_products_amounts(entity)
    local products_amounts = {}

    -- 1) Check user-defined custom integration
    local entity_name = entity.name
    local custom_integration = integration_parsing.get_parsed_product_integrations()[entity_name]
    if custom_integration then
        for _, entry in pairs(custom_integration) do
            local item_name = entry.item
            local stack_size = utils.get_stack_size(item_name)
            local produced = utils.modify_stack_size_according_to_settings(stack_size, false)
            utils.increment_value_in_table(products_amounts, item_name, produced)
        end
        return products_amounts
    end

    -- 2) If not in custom map, check recognized standard machine
    local entity_type = entity.type
    if recognized_standard_machine_types[entity_type] then
        local recipe = entity.get_recipe()
        if not recipe or not recipe.valid then
            return products_amounts
        end

        for _, product in pairs(recipe.products) do
            if product.type == "item" and product.amount then
                local product_name = product.name
                local stack_size = utils.get_stack_size(product_name)
                local amt = math.ceil(product.amount / stack_size) * stack_size
                amt = utils.modify_stack_size_according_to_settings(amt, false)
                if amt > 0 then
                    utils.increment_value_in_table(products_amounts, product_name, amt)
                end
            end
        end
    end

    return products_amounts
end

--------------------------------------------------------------------------------
--- Gets the quality of the educt recipe for a given entity.
--- 1) If the entity name is in `integration_parsing.get_parsed_educt_integrations()`, returns the quality
---    of the first listed item (default "normal" if missing).
--- 2) Otherwise, if the entity type is a recognized standard machine, we call
---    `entity.get_recipe()`, then read the second return value as `quality`.
--- 3) Returns "normal" if neither applies or no valid quality is found.
---
--- @param entity LuaEntity
--- @return string # The quality name, e.g. "normal", "epic", etc.
--------------------------------------------------------------------------------
function recipe_handler.get_recipe_educt_quality(entity)
    -- 1) Check user-defined custom integration first
    local entity_name = entity.name
    local custom_integration = integration_parsing.get_parsed_educt_integrations()[entity_name]
    if custom_integration and #custom_integration > 0 then
        -- Return the quality from the first entry (defaulting to "normal")
        return custom_integration[1].quality or "normal"
    end

    -- 2) If recognized standard machine, fetch the recipe's quality
    local entity_type = entity.type
    if recognized_standard_machine_types[entity_type] then
        local _, quality = entity.get_recipe()
        if quality and quality.valid then
            return quality.name
        end
    end

    -- 3) Otherwise, default to "normal"
    return "normal"
end

--------------------------------------------------------------------------------
--- Gets the quality of the product recipe for a given entity.
--- 1) If the entity name is in `integration_parsing.get_parsed_product_integrations()`, returns the quality
---    of the first listed item (default "normal" if missing).
--- 2) Otherwise, if the entity type is a recognized standard machine, we call
---    `entity.get_recipe()`, then read the second return value as `quality`.
--- 3) Returns "normal" if neither applies or no valid quality is found.
---
--- @param entity LuaEntity
--- @return string # The quality name, e.g. "normal", "epic", etc.
--------------------------------------------------------------------------------
function recipe_handler.get_recipe_product_quality(entity)
    -- 1) Check user-defined custom integration first
    local entity_name = entity.name
    local custom_integration = integration_parsing.get_parsed_product_integrations()[entity_name]
    if custom_integration and #custom_integration > 0 then
        -- Return the quality from the first entry (defaulting to "normal")
        return custom_integration[1].quality or "normal"
    end

    -- 2) If recognized standard machine, fetch the recipe's quality
    local entity_type = entity.type
    if recognized_standard_machine_types[entity_type] then
        local _, quality = entity.get_recipe()
        if quality and quality.valid then
            return quality.name
        end
    end

    -- 3) Otherwise, default to "normal"
    return "normal"
end

return recipe_handler
