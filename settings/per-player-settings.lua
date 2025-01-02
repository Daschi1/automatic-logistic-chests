--- @type data.ModBoolSettingPrototype
local message_when_selected_refreshed = {
    type = "bool-setting",
    name = "automatic-logistic-chests-message-when-selected-refreshed",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a[automatic-logistic-chests]-a[message-when-selected-refreshed]"
}

data:extend({
    message_when_selected_refreshed
})
