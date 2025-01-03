local logistics_handler = require("runtime.logistics-handler")

script.on_event(defines.events.on_robot_built_entity, function(event)
    logistics_handler.handle_container(event.entity)
end, { { filter = "type", type = "logistic-container" } })
