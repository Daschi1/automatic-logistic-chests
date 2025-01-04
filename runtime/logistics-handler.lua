local recipe_handler    = require("runtime.recipe-handler")
local inserter_handler  = require("runtime.inserter-handler")
local utils             = require("runtime.utils")

local logistics_handler = {}

--------------------------------------------------------------------------------
--- For a Requester chest, set up logistic requests according to educts.
---
--- @param chest       LuaEntity The logistic requester chest
--- @param surrounding_inserters LuaEntity[]
--------------------------------------------------------------------------------
local function handle_requester(chest, surrounding_inserters)
    -- Step 1: Gather educts amounts
    local educts_amounts = recipe_handler.gather_educts(chest, surrounding_inserters)

    -- Step 2: Exit early if no educts are found
    if utils.table_length(educts_amounts) == 0 then return end

    -- Step 3: Retrieve the logistics point
    local logistics_point = chest.get_requester_point()
    if not logistics_point then return end

    -- Step 4: Retrieve and clear the logistics section
    local logistics_section = nil
    for _, section in pairs(logistics_point.sections) do
        if section and section.valid and section.group == "" then
            logistics_section = section
            for slot_index = 1, section.filters_count do
                section.clear_slot(slot_index)
            end
        end
    end

    -- Step 5: Exit early if logistics section is invalid
    if not logistics_section or not logistics_section.valid then return end

    -- Step 6: Fill request slots with educt requests
    local request_slot = 1
    for item_name, target_amount in pairs(educts_amounts) do
        local chest_slots = chest.prototype.get_inventory_size(defines.inventory.chest) or 1
        local request_count = utils.table_length(educts_amounts)

        local stack_size = utils.get_stack_size(item_name)
        local max_chest_slots_per_req = math.floor(chest_slots / request_count)
        local max_allowed = max_chest_slots_per_req * stack_size
        local final_amount = math.min(target_amount, max_allowed)

        logistics_section.set_slot(request_slot, {
            value = item_name,
            min   = final_amount
        })
        request_slot = request_slot + 1
    end
end

--------------------------------------------------------------------------------
--- For a Storage chest, configure inserters and set `entity.storage_filter`.
---
--- @param chest        LuaEntity
--- @param surrounding_inserters LuaEntity[]
--------------------------------------------------------------------------------
local function handle_storage(chest, surrounding_inserters)
    -- Step 1: Gather products amounts
    local products_amounts = recipe_handler.gather_products(chest, surrounding_inserters)

    -- Step 2: Configure the inserters around the chest to handle specific products
    inserter_handler.configure_inserter_filter_condition(surrounding_inserters, chest, products_amounts)

    -- Step 3: Determine the appropriate storage filter
    local old_storage_filter = chest.storage_filter
    local first_product_name = nil
    for product_name, _ in pairs(products_amounts) do
        first_product_name = product_name
        break
    end

    -- Step 4: Exit early if no valid products is found
    if not first_product_name then return end

    -- Step 5: Update the storage filter
    if not old_storage_filter or utils.table_length(products_amounts) == 1 then
        -- Set the filter if there is no previous filter or only one possible product
        chest.storage_filter = first_product_name
    elseif utils.table_length(products_amounts) > 1 then
        -- If there are multiple products and a previous filter exists
        if not products_amounts[old_storage_filter.name] then
            -- Set the filter only if the previous filter is invalid (does not appear in the current product list)
            chest.storage_filter = first_product_name
        end
    end
end

--------------------------------------------------------------------------------
--- For non-requester and non-storage (e.g. passive provider, active provider), configure inserters.
---
--- @param chest        LuaEntity
--- @param surrounding_inserters LuaEntity[]
--------------------------------------------------------------------------------
local function handle_other(chest, surrounding_inserters)
    -- Step 1: Gather products amounts
    local products_amounts = recipe_handler.gather_products(chest, surrounding_inserters)

    -- Step 2: Configure inserter filter condition
    inserter_handler.configure_inserter_filter_condition(surrounding_inserters, chest, products_amounts)
end

--------------------------------------------------------------------------------
--- For a Buffer chest, set up logistic requests and configure inserters.
---
--- @param chest              LuaEntity
--- @param surrounding_inserters LuaEntity[]
--------------------------------------------------------------------------------
local function handle_buffer(chest, surrounding_inserters)
    -- Step 1: Handle logistic requests
    handle_requester(chest, surrounding_inserters)

    -- Step 2: Configure inserters
    handle_other(chest, surrounding_inserters)
end

--------------------------------------------------------------------------------
--- Main entry point logistic container placed/refresh event.
--- Handles the logic depending on logistic_mode (requester, storage, etc.).
---
--- @param chest LuaEntity
--------------------------------------------------------------------------------
function logistics_handler.handle_container(chest)
    if not (chest and chest.valid) then return end

    local logistic_mode = chest.prototype.logistic_mode
    if not logistic_mode then return end

    -- Step 1: Find all surrounding inserters
    local maximal_range = settings.global["automatic-logistic-chests-maximal-inserter-range"].value
    local surrounding_inserters = chest.surface.find_entities_filtered {
        area = {
            { x = chest.position.x - maximal_range, y = chest.position.y - maximal_range },
            { x = chest.position.x + maximal_range, y = chest.position.y + maximal_range }
        },
        type = "inserter"
    }

    -- Step 2: Exit early if no inserters are found
    if utils.table_length(surrounding_inserters) == 0 then return end

    -- Step 3: Handle the container logic based on logistic_mode
    if logistic_mode == "requester" then
        handle_requester(chest, surrounding_inserters)
    elseif logistic_mode == "storage" then
        handle_storage(chest, surrounding_inserters)
    elseif logistic_mode == "buffer" then
        handle_buffer(chest, surrounding_inserters)
    else
        handle_other(chest, surrounding_inserters)
    end
end

return logistics_handler
