--- @type data.CustomInputPrototype
local refresh_selected_logistic_chest = {
    type = "custom-input",
    name = "automatic-logistic-chests-refresh-selected-logistic-chest",
    key_sequence = "SHIFT + R"
}

--- @type data.CustomInputPrototype
local refresh_all_logistic_chests = {
    type = "custom-input",
    name = "automatic-logistic-chests-refresh-all-logistic-chests",
    key_sequence = "CONTROL + R"
}

data:extend({
    refresh_selected_logistic_chest,
    refresh_all_logistic_chests
})
