local inserter_handler                  = require("runtime.inserter-handler")
local utils                             = require("runtime.utils")

local recipe_handler                    = {}

-- children of https://lua-api.factorio.com/latest/prototypes/CraftingMachinePrototype.html
local recognized_standard_machine_types = {
    ["assembling-machine"] = true,
    ["furnace"]            = true,
    ["rocket-silo"]        = true,
}

--------------------------------------------------------------------------------
--- Gather educt amounts and the quality of the first recipe based on inserters interacting with the chest.
--- The function evaluates which inserters are picking items from the chest,
--- retrieves the educt amounts from their drop targets, and identifies the
--- quality of the first recipe encountered.
---
--- @param chest LuaEntity # The chest entity being analyzed.
--- @param surrounding_inserters LuaEntity[] # List of inserter entities surrounding the chest.
--- @return table<string, number>, string # A table mapping item names to their respective amounts, and the quality of the first recipe encountered.
--------------------------------------------------------------------------------
function recipe_handler.gather_educts_and_quality(chest, surrounding_inserters)
    local educts_amounts = {}
    local first_quality = ""
    for _, inserter in pairs(surrounding_inserters) do
        if inserter_handler.is_inserter_picking_from_chest(inserter, chest) then
            local drop_target = inserter.drop_target
            if drop_target and drop_target.valid then
                educts_amounts = recipe_handler.get_educts_amounts(drop_target)
                if first_quality == "" then
                    first_quality = recipe_handler.get_recipe_quality(drop_target)
                end
            end
        end
    end
    return educts_amounts, first_quality
end

--------------------------------------------------------------------------------
--- Gather product amounts and the quality of the first recipe based on inserters interacting with the chest.
--- The function evaluates which inserters are dropping items into the chest,
--- retrieves the product amounts from their pickup targets, and identifies the
--- quality of the first recipe encountered.
---
--- @param chest LuaEntity # The chest entity being analyzed.
--- @param surrounding_inserters LuaEntity[] # List of inserter entities surrounding the chest.
--- @return table<string, number>, string # A table mapping item names to their respective amounts, and the quality of the first recipe encountered.
--------------------------------------------------------------------------------
function recipe_handler.gather_products_and_quality(chest, surrounding_inserters)
    local products_amounts = {}
    local first_quality = ""
    for _, inserter in pairs(surrounding_inserters) do
        if inserter_handler.is_inserter_dropping_into_chest(inserter, chest) then
            local pickup_target = inserter.pickup_target
            if pickup_target and pickup_target.valid then
                products_amounts = recipe_handler.get_products_amounts(pickup_target)
                if first_quality == "" then
                    first_quality = recipe_handler.get_recipe_quality(pickup_target)
                end
            end
        end
    end
    return products_amounts, first_quality
end

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
    if not recipe or not recipe.valid then
        return educts_amounts
    end

    -- If recipe is valid, collect edcut amounts
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
    if not recipe or not recipe.valid then
        return products_amounts
    end

    -- If recipe is valid, collect product amounts
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

--------------------------------------------------------------------------------
--- Gathers recipe quality for a crafting machine.
--- Returns a table of item->produced_amount. If nothing found or not applicable,
--- returns an empty table.
---
--- @param entity LuaEntity
--- @return string
--------------------------------------------------------------------------------
function recipe_handler.get_recipe_quality(entity)
    -- Check if entity is a recognized crafting machine
    local entity_type = entity.type
    if not recognized_standard_machine_types[entity_type] then
        return "normal"
    end

    -- For recognized crafting machines, fetch the quality
    local _, quality = entity.get_recipe()
    if not quality or not quality.valid then
        return "normal"
    end

    return quality.name
end

return recipe_handler
