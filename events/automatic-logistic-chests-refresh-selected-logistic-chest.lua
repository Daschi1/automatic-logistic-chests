script.on_event("automatic-logistic-chests-refresh-selected-logistic-chest", function(event)
    local player = game.players[event.player_index]
    Logistic_container_placed(player.selected, game)
    if settings.get_player_settings(player)["automatic-logistic-chests-message-when-selected-refreshed"].value then
        player.print("Refreshed logistical chest")
    end
end)
