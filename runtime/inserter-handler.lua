local utils = require("runtime.utils")

local inserter_handler = {}

--------------------------------------------------------------------------------
--- Retrieve the first product and its amount from a products table.
---
--- @param products_amounts table<string, number>
--- @return string|nil, number|nil
--------------------------------------------------------------------------------
local function get_first_product(products_amounts)
    for product_name, amount in pairs(products_amounts) do
        return product_name, amount
    end
    return nil, nil
end

--------------------------------------------------------------------------------
--- Helper function to set control behavior conditions for an inserter.
---
--- @param control_behavior LuaGenericOnOffControlBehavior
--- @param condition CircuitConditionDefinition|nil
--------------------------------------------------------------------------------
local function set_inserter_conditions(control_behavior, condition)
    if condition then
        control_behavior.connect_to_logistic_network = true
        control_behavior.logistic_condition = condition
    else
        control_behavior.connect_to_logistic_network = false
        control_behavior.logistic_condition = nil
    end
end

--------------------------------------------------------------------------------
--- Check if an inserter picks up items from a specific chest.
---
--- @param inserter LuaEntity
--- @param chest LuaEntity
--- @return boolean
--------------------------------------------------------------------------------
function inserter_handler.is_inserter_picking_from_chest(inserter, chest)
    local pickup_position = inserter.pickup_position
    return inserter.surface_index == chest.surface_index and
        utils.are_positions_within_same_tile(pickup_position, chest.position)
end

--------------------------------------------------------------------------------
--- Check if an inserter drops items into a specific chest.
---
--- @param inserter LuaEntity
--- @param chest LuaEntity
--- @return boolean
--------------------------------------------------------------------------------
function inserter_handler.is_inserter_dropping_into_chest(inserter, chest)
    local drop_position = inserter.drop_position
    return inserter.surface_index == chest.surface_index and
        utils.are_positions_within_same_tile(drop_position, chest.position)
end

--------------------------------------------------------------------------------
--- Configure the logistic/circuit filter conditions for inserters dropping into a chest.
---
--- @param surrounding_inserters LuaEntity[]
--- @param chest LuaEntity
--- @param products_amounts table<string, number>
--------------------------------------------------------------------------------
function inserter_handler.configure_inserter_filter_condition(surrounding_inserters, chest, products_amounts)
    -- Retrieve map setting
    local disable_inserters_setting = settings.global["automatic-logistic-chests-disable-inserters"].value

    -- Retrieve the first product and amount
    local first_product_name, first_product_amount = get_first_product(products_amounts)

    -- Iterate over inserters and configure their conditions
    for _, inserter in pairs(surrounding_inserters) do
        if inserter_handler.is_inserter_dropping_into_chest(inserter, chest) then
            local control_behavior = inserter.get_or_create_control_behavior()

            if control_behavior and control_behavior.valid and control_behavior.type == defines.control_behavior.type.inserter then
                ---@cast control_behavior LuaInserterControlBehavior

                if disable_inserters_setting and first_product_name and first_product_amount then
                    -- Configure the logistic/circuit filter conditions
                    local condition = {
                        comparator = "<",
                        first_signal = { type = "item", name = first_product_name },
                        constant = first_product_amount
                    }
                    set_inserter_conditions(control_behavior, condition)
                else
                    -- Reset conditions if setting is disabled or no product exists
                    set_inserter_conditions(control_behavior, nil)
                end
            end
        end
    end
end

return inserter_handler
