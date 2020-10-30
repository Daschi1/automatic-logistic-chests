function Logistic_container_placed(entity, game)
    if entity and entity.type and entity.type == "logistic-container" then
        if entity.prototype and entity.prototype.logistic_mode then
            local maximal_inserter_range = settings.global["automatic-logistic-chests-maximal-inserter-range"].value
            local surrounding_inserters = entity.surface.find_entities_filtered{ area = {
                {
                    x = entity.position.x - maximal_inserter_range,
                    y = entity.position.y - maximal_inserter_range
                }, {
                    x = entity.position.x + maximal_inserter_range,
                    y = entity.position.y + maximal_inserter_range
                }
            }, type = "inserter"}
            if Table_length(surrounding_inserters) > 0 then
                if entity.prototype.logistic_mode == "requester" then
                    local educts_amounts = {}
                    for i = 1, Table_length(surrounding_inserters) do
                        local inserter = surrounding_inserters[i]
                        if Compare_positions(inserter.pickup_position, entity.position) then
                            if inserter.drop_target then
                                if not Get_educts_amounts(game, inserter.drop_target, educts_amounts) then
                                    return
                                end
                            end
                        end
                    end

                    if Table_length(educts_amounts) > 0 then
						for request_slot = 1, entity.request_slot_count do
							entity.clear_request_slot(request_slot)
						end

						local request_slot = 1
                        for ingredient in pairs(educts_amounts) do
                            local amount = educts_amounts[ingredient]
							entity.set_request_slot({
								name = ingredient,
								count = amount
							}, request_slot)
							request_slot = request_slot + 1
						end
                    end
                else
                    for i = 1, Table_length(surrounding_inserters) do
                        local inserter = surrounding_inserters[i];
						if Compare_positions(inserter.drop_position, entity.position) then
							if inserter.pickup_target then
                                local products_amounts = {}
                                if not Get_products_amounts(game, inserter.pickup_target, products_amounts) then
                                    return
                                end

								for product in pairs(products_amounts) do
									local amount = products_amounts[product]

									local condition = {
										condition = {
											comparator = "<",
											first_signal = {
												type = "item",
												name = product
											},
											constant = amount
										}
									}

									local control_behavior = inserter.get_or_create_control_behavior()

									if not (control_behavior.get_circuit_network(defines.wire_type.green) or control_behavior.get_circuit_network(defines.wire_type.red) or control_behavior.connect_to_logistic_network) then
											control_behavior.connect_to_logistic_network = true
											control_behavior.logistic_condition = condition
											control_behavior.circuit_condition = condition
									end
								end
							end
						end
                    end
                end
            end
        end
    end
end