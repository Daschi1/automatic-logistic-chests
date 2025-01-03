local logistics_handler = require("runtime.logistics-handler")

script.on_event(prototypes.custom_input["automatic-logistic-chests-refresh-selected-logistic-chest"], function(event)
    local player = game.players[event.player_index]
    local chest = player.selected
    if chest and chest.valid then
        logistics_handler.handle_container(chest)
        if settings.get_player_settings(player)["automatic-logistic-chests-message-when-selected-refreshed"].value then
            player.print("Refreshed logistical chest")
        end
    end
end)
