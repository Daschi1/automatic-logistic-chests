script.on_event(defines.events.on_built_entity, function(event)
    Logistic_container_placed(event.entity, game)
end, { { filter = "type", type = "logistic-container" } })
