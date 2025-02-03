local utils = {}

--------------------------------------------------------------------------------
--- Utility function to check if two positions are within the same tile.
---
--- @param position1 MapPosition
--- @param position2 MapPosition
--- @return boolean
--------------------------------------------------------------------------------
function utils.are_positions_within_same_tile(position1, position2)
    return position1.x > position2.x - 0.5 and position1.x < position2.x + 0.5 and
        position1.y > position2.y - 0.5 and position1.y < position2.y + 0.5
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
--- Safely increments all items from `source_table` into `target_table`.
--- For each key in `source_table`, adds its value to the corresponding
--- key in `target_table`. Creates the key in `target_table` if it doesn't exist.
---
--- @param target_table table<string, number> The table to be modified.
--- @param source_table table<string, number> The table to read from.
--------------------------------------------------------------------------------
function utils.increment_values_from_table(target_table, source_table)
    for key, amount in pairs(source_table) do
        if not target_table[key] then
            target_table[key] = 0
        end
        target_table[key] = target_table[key] + amount
    end
end

--------------------------------------------------------------------------------
--- Counts the number of entries in a table, including both array-like and
--- non-array-like tables.
---
--- @param table table
--- @return number
--------------------------------------------------------------------------------
function utils.table_length(table)
    local count = 0
    for _, _ in pairs(table) do
        count = count + 1
    end
    return count
end

--------------------------------------------------------------------------------
--- Returns stack_size for a given item name.
--- (Assumes prototypes.item[item_name].stack_size is valid.)
---
--- @param item_name string
--- @return number
--------------------------------------------------------------------------------
function utils.get_stack_size(item_name)
    local item = prototypes.item[item_name]
    assert(item, "No item prototype found for '" .. item_name .. "'.")
    return item.stack_size
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
