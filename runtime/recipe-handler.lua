local utils = require("runtime.utils")

local recipe_handler = {}

local recognized_standard_machine_types = {
    ["assembling-machine"] = true,
    ["furnace"]            = true,
    ["rocket-silo"]        = true,
}

--------------------------------------------------------------------------------
--- Gathers item requirements (educts) for a given entity (machine/turret/silo).
--- Returns a table of item->required_amount. If nothing found or not applicable,
--- returns an empty table.
---
--- @param entity LuaEntity
--- @return table<string, number>
--------------------------------------------------------------------------------
function recipe_handler.get_educts_amounts(entity)
    local entity_type = entity.type
    local educts_amounts = {} -- We'll build and return this

    -- If this isn't a standard crafting machine, check special integrations
    if not recognized_standard_machine_types[entity_type] then
        if settings.global["automatic-logistic-chests-enable-artillery-turret-integration"].value
            and entity_type == "artillery-turret" then
            utils.increment_value_in_table(educts_amounts, "artillery-shell",
                utils.modify_stack_size_according_to_settings(utils.get_stack_size("artillery-shell"), true))
            return educts_amounts
        elseif settings.global["automatic-logistic-chests-enable-rocket-silo-integration"].value
            and entity_type == "rocket-silo" then
            utils.increment_value_in_table(educts_amounts, "satellite",
                utils.modify_stack_size_according_to_settings(utils.get_stack_size("satellite"), true))
            return educts_amounts
        else
            -- Not a recognized entity, return empty
            return educts_amounts
        end
    end

    -- For recognized crafting machines, fetch the recipe
    local recipe = entity.get_recipe()
    if not recipe then
        return educts_amounts
    end

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

    return educts_amounts
end

--------------------------------------------------------------------------------
--- Gathers product outputs for a given entity (machine/turret/silo).
--- Returns a table of item->produced_amount. If nothing found or not applicable,
--- returns an empty table.
---
--- @param entity LuaEntity
--- @return table<string, number>
--------------------------------------------------------------------------------
function recipe_handler.get_products_amounts(entity)
    local entity_type = entity.type
    local products_amounts = {} -- We'll build and return this

    -- If not a recognized crafting machine, check turret integration
    if not recognized_standard_machine_types[entity_type] then
        if settings.global["automatic-logistic-chests-enable-artillery-turret-integration"].value
            and entity_type == "artillery-turret" then
            utils.increment_value_in_table(products_amounts, "artillery-shell",
                utils.modify_stack_size_according_to_settings(utils.get_stack_size("artillery-shell"), false))
            return products_amounts
        else
            return products_amounts
        end
    end

    -- For recognized crafting machines, fetch the recipe
    local recipe = entity.get_recipe()
    if not recipe then
        return products_amounts
    end

    for _, product in pairs(recipe.products) do
        if product.type == "item" and product.amount then
            local product_name = product.name
            -- Convert rocket-part -> space-science-pack, if setting is enabled
            if product_name == "rocket-part"
                and settings.global["automatic-logistic-chests-enable-rocket-silo-integration"].value then
                product_name = "space-science-pack"
            end

            local stack_size = utils.get_stack_size(product_name)
            local produced   = math.ceil(product.amount / stack_size) * stack_size
            produced         = utils.modify_stack_size_according_to_settings(produced, false)
            if produced > 0 then
                utils.increment_value_in_table(products_amounts, product_name, produced)
            end
        end
    end

    return products_amounts
end

return recipe_handler
