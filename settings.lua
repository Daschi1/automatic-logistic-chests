data:extend({
    -- runtime-global
    {
        type = "bool-setting",
        name = "automatic-logistic-chests-enable-artillery-turret-integration",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "automatic-logistic-chests-enable-rocket-silo-integration",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "int-setting",
        name = "automatic-logistic-chests-maximal-inserter-range",
        setting_type = "runtime-global",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 100
    },
    {
        type = "bool-setting",
        name = "automatic-logistic-chests-message-when-all-refreshed",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "automatic-logistic-chests-need-admin-to-refresh-all",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "double-setting",
        name = "automatic-logistic-chests-provide-stack-modifier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.1,
        maximum_value = 100
    },
    {
        type = "double-setting",
        name = "automatic-logistic-chests-request-stack-modifier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.1,
        maximum_value = 100
    },
    -- runtime-per-user
    {
        type = "bool-setting",
        name = "automatic-logistic-chests-message-when-selected-refreshed",
        setting_type = "runtime-per-user",
        default_value = true
    }
})