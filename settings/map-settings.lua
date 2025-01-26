--- @type data.ModBoolSettingPrototype
local message_when_all_refreshed = {
    type = "bool-setting",
    name = "automatic-logistic-chests-message-when-all-refreshed",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-a[message-when-all-refreshed]"
}

--- @type data.ModBoolSettingPrototype
local need_admin_to_refresh_all = {
    type = "bool-setting",
    name = "automatic-logistic-chests-need-admin-to-refresh-all",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-b[need-admin-to-refresh-all]"
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
local disable_inserters = {
    type = "bool-setting",
    name = "automatic-logistic-chests-disable-inserters",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-d[disable-inserters]"
}

--- @type data.ModDoubleSettingPrototype
local provide_stack_modifier = {
    type = "double-setting",
    name = "automatic-logistic-chests-provide-stack-modifier",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = "a[automatic-logistic-chests]-e[provide-stack-modifier]"
}

--- @type data.ModDoubleSettingPrototype
local request_stack_modifier = {
    type = "double-setting",
    name = "automatic-logistic-chests-request-stack-modifier",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 100,
    order = "a[automatic-logistic-chests]-f[request-stack-modifier]"
}

--- @type data.ModBoolSettingPrototype
local trash_not_requested = {
    type = "bool-setting",
    name = "automatic-logistic-chests-trash-not-requested",
    setting_type = "runtime-global",
    default_value = true,
    order = "a[automatic-logistic-chests]-g[trash-not-requested]"
}

--- @type data.ModBoolSettingPrototype
local request_from_buffer_chests = {
    type = "bool-setting",
    name = "automatic-logistic-chests-request-from-buffer-chests",
    setting_type = "runtime-global",
    default_value = false,
    order = "a[automatic-logistic-chests]-h[request-from-buffer-chests]"
}

--- @type data.ModStringSettingPrototype
local educt_integrations = {
    type = "string-setting",
    name = "automatic-logistic-chests-educt-integrations",
    setting_type = "runtime-global",
    default_value = "artillery-turret=artillery-shell;rocket-silo=satellite",
    allow_blank = true,
    order = "a[automatic-logistic-chests]-i[educt-integrations]"
}

--- @type data.ModStringSettingPrototype
local product_integrations = {
    type = "string-setting",
    name = "automatic-logistic-chests-product-integrations",
    setting_type = "runtime-global",
    default_value = "rocket-silo=space-science-pack",
    allow_blank = true,
    order = "a[automatic-logistic-chests]-j[product-integrations]"
}

data:extend({
    message_when_all_refreshed,
    need_admin_to_refresh_all,
    maximal_inserter_range,
    disable_inserters,
    provide_stack_modifier,
    request_stack_modifier,
    trash_not_requested,
    request_from_buffer_chests,
    educt_integrations,
    product_integrations
})
