local recipe_handler    = require("runtime.recipe-handler")
local inserter_handler  = require("runtime.inserter-handler")
local utils             = require("runtime.utils")

local logistics_handler = {}

--------------------------------------------------------------------------------
--- For a Requester chest, set up logistic requests according to educts.
---
--- @param chest       LuaEntity The logistic requester chest
--- @param educts_amounts     table<string, number> Table of item->needed amounts
--------------------------------------------------------------------------------
local function handle_requester(chest, educts_amounts)
    if utils.table_length(educts_amounts) == 0 then return end

    local logistics_point = chest.get_requester_point()
    if not logistics_point then return end

    -- Retrieve logistics section
    local logistics_section = nil
    for _, section in pairs(logistics_point.sections) do
        if section and section.valid and section.group == "" then
            logistics_section = section
            -- Clear existing slots
            for slot_index = 1, section.filters_count do
                section.clear_slot(slot_index)
            end
        end
    end
    -- If logistics_section is not valid, exit early
    if not logistics_section or not logistics_section.valid then return end

    -- Fill request slots with educt requests
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
--- @param products_amounts    table<string, number>
--------------------------------------------------------------------------------
local function handle_storage(chest, surrounding_inserters, products_amounts)
    -- 1) Configure inserter filter condition
    inserter_handler.configure_inserter_filter_condition(surrounding_inserters, chest, products_amounts)

    -- 2) Update the storage chest filter based on available products
    local old_storage_filter = chest.storage_filter
    local first_product_name = nil

    -- Retrieve the first product name (if any) from the list
    for product_name, _ in pairs(products_amounts) do
        first_product_name = product_name
        break -- Stop after retrieving the first entry
    end
    if not first_product_name then return end

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
--- For non-requester and non-storage (e.g. passive provider, buffer, active provider), configure inserters.
---
--- @param chest        LuaEntity
--- @param surrounding_inserters LuaEntity[]
--- @param products_amounts    table<string, number>
--------------------------------------------------------------------------------
local function handle_other(chest, surrounding_inserters, products_amounts)
    -- 1) Configure inserter filter condition
    inserter_handler.configure_inserter_filter_condition(surrounding_inserters, chest, products_amounts)
end

--------------------------------------------------------------------------------
--- Main entry point logistic container placed/refresh event.
--- Gathers relevant data (surrounding inserters, educts/products), then
--- defers to specific methods depending on logistic_mode (requester, storage, etc.).
---
--- @param chest LuaEntity
--------------------------------------------------------------------------------
function logistics_handler.handle_container(chest)
    if not (chest and chest.valid) then return end

    local logistic_mode = chest.prototype.logistic_mode
    if not logistic_mode then return end

    -- 1) Find all surrounding inserters
    local maximal_range = settings.global["automatic-logistic-chests-maximal-inserter-range"].value
    local surrounding_inserters = chest.surface.find_entities_filtered {
        area = {
            { x = chest.position.x - maximal_range, y = chest.position.y - maximal_range },
            { x = chest.position.x + maximal_range, y = chest.position.y + maximal_range }
        },
        type = "inserter"
    }

    -- If no inserters around, nothing else to do
    if utils.table_length(surrounding_inserters) == 0 then return end

    -- 2) Prepare educts/products tables.
    local educts_amounts = {}
    local products_amounts = {}
    -- For "requester" mode, we gather educts_amounts from any relevant machines that the inserters are "picking up from the chest".
    -- For "storage"/others, we gather product_amounts if the inserter are "dropping into the chest".
    for _, inserter in pairs(surrounding_inserters) do
        -- Check if chest is 'requester' or not
        if logistic_mode == "requester" then
            if inserter_handler.is_inserter_picking_from_chest(inserter, chest) then
                local drop_target = inserter.drop_target
                if drop_target and drop_target.valid then
                    educts_amounts = recipe_handler.get_educts_amounts(drop_target)
                end
            end
        else
            if inserter_handler.is_inserter_dropping_into_chest(inserter, chest) then
                local pickup_target = inserter.pickup_target
                if pickup_target and pickup_target.valid then
                    products_amounts = recipe_handler.get_products_amounts(pickup_target)
                end
            end
        end
    end

    -- 3) Now handle the container logic based on logistic_mode
    if logistic_mode == "requester" then
        handle_requester(chest, educts_amounts)
    elseif logistic_mode == "storage" then
        handle_storage(chest, surrounding_inserters, products_amounts)
    else
        handle_other(chest, surrounding_inserters, products_amounts)
    end
end

return logistics_handler
