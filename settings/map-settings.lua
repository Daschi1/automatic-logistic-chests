--- @type data.ModBoolSettingPrototype
local enable_artillery_turret_integration = {
    type = "bool-setting",
    name = "automatic-logistic-chests-enable-artillery-turret-integration",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-a[enable-artillery-turret-integration]"
}

--- @type data.ModBoolSettingPrototype
local enable_rocket_silo_integration = {
    type = "bool-setting",
    name = "automatic-logistic-chests-enable-rocket-silo-integration",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-b[enable-rocket-silo-integration]"
}

--- @type data.ModIntSettingPrototype
local maximal_inserter_range = {
    type = "int-setting",
    name = "automatic-logistic-chests-maximal-inserter-range",
    setting_type = "runtime-global",
    default_value = 2,
    minimum_value = 1,
    maximum_value = 100,
    order = "a[automatic-logistic-chests]-c[maximal-inserter-range]"
}

--- @type data.ModBoolSettingPrototype
local message_when_all_refreshed = {
    type = "bool-setting",
    name = "automatic-logistic-chests-message-when-all-refreshed",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-d[message-when-all-refreshed]"
}

--- @type data.ModBoolSettingPrototype
local need_admin_to_refresh_all = {
    type = "bool-setting",
    name = "automatic-logistic-chests-need-admin-to-refresh-all",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-e[need-admin-to-refresh-all]"
}

--- @type data.ModDoubleSettingPrototype
local provide_stack_modifier = {
    type = "double-setting",
    name = "automatic-logistic-chests-provide-stack-modifier",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = "a[automatic-logistic-chests]-f[provide-stack-modifier]"
}

--- @type data.ModDoubleSettingPrototype
local request_stack_modifier = {
    type = "double-setting",
    name = "automatic-logistic-chests-request-stack-modifier",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = "a[automatic-logistic-chests]-g[request-stack-modifier]"
}

--- @type data.ModBoolSettingPrototype
local disable_inserters = {
    type = "bool-setting",
    name = "automatic-logistic-chests-disable-inserters",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-h[disable-inserters]"
}

--- @type data.ModBoolSettingPrototype
local trash_not_requested = {
    type = "bool-setting",
    name = "automatic-logistic-chests-trash-not-requested",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-i[trash-not-requested]"
}

data:extend({
    enable_artillery_turret_integration,
    enable_rocket_silo_integration,
    maximal_inserter_range,
    message_when_all_refreshed,
    need_admin_to_refresh_all,
    provide_stack_modifier,
    request_stack_modifier,
    disable_inserters,
    trash_not_requested
})
