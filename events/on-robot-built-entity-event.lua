script.on_event(defines.events.on_robot_built_entity, function (event)
    Logistic_container_placed(event.created_entity, game)
end, { { filter = "type", type = "logistic-container" } })