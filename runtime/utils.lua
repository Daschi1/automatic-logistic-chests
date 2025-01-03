local utils = {}

--------------------------------------------------------------------------------
--- Check if two positions are within 0.5 tile distance in both X and Y.
---
--- @param position1 MapPosition
--- @param position2 MapPosition
--- @return boolean
--------------------------------------------------------------------------------
function utils.compare_positions(position1, position2)
    return (position1.x > position2.x - 0.5 and position1.x < position2.x + 0.5)
        and (position1.y > position2.y - 0.5 and position1.y < position2.y + 0.5)
end

--------------------------------------------------------------------------------
--- Safely increments table[key] by value, creating it if it doesn’t exist.
---
--- @param table table<string, number>
--- @param key string
--- @param value number
--------------------------------------------------------------------------------
function utils.increment_value_in_table(table, key, value)
    if table[key] == nil then
        table[key] = 0
    end
    table[key] = table[key] + value
end

--------------------------------------------------------------------------------
--- Returns stack_size for a given item name.
--- (Assumes prototypes.item[item_name].stack_size is valid.)
---
--- @param item_name string
--- @return number
--------------------------------------------------------------------------------
function utils.get_stack_size(item_name)
    return prototypes.item[item_name].stack_size
end

--------------------------------------------------------------------------------
--- Applies a global setting multiplier for request or provide amounts.
---
--- @param amount number
--- @param is_request boolean
--- @return number
--------------------------------------------------------------------------------
function utils.modify_stack_size_according_to_settings(amount, is_request)
    if is_request then
        return math.ceil(amount * settings.global["automatic-logistic-chests-request-stack-modifier"].value)
    else
        return math.ceil(amount * settings.global["automatic-logistic-chests-provide-stack-modifier"].value)
    end
end

return utils
