local logistics_handler = require("runtime.logistics-handler")

script.on_event(prototypes.custom_input["automatic-logistic-chests-refresh-all-logistic-chests"], function(event)
	local player = game.players[event.player_index]
	if settings.global["automatic-logistic-chests-need-admin-to-refresh-all"].value and not player.admin then
		return
	end
	if settings.global["automatic-logistic-chests-message-when-all-refreshed"].value then
		game.print("Refreshing all logistical chests")
	end
	local chests = player.surface.find_entities_filtered({ type = "logistic-container" })
	for _, chest in pairs(chests) do
		logistics_handler.handle_container(chest)
	end
end)
