function Compare_positions(position1, position2)
	return position1.x > position2.x - 0.5 and position1.x < position2.x + 0.5 and position1.y > position2.y - 0.5 and position1.y < position2.y + 0.5
end

function Increment_value_in_table(table, key, value)
	if table[key] == nil then
		table[key] = 0
	end
	table[key] = table[key] + value
end

function Get_stack_size(item)
	return prototypes.item[item].stack_size
end

function Modify_stack_size(amount, is_request)
	if is_request then
		return math.ceil(amount * settings.global["automatic-logistic-chests-request-stack-modifier"].value)
	else
		return math.ceil(amount * settings.global["automatic-logistic-chests-provide-stack-modifier"].value)
	end
end

local crafting_machine_types = {
    ["assembling-machine"] = true,
    ["furnace"] = true,
    ["rocket-silo"] = true,
}

function Get_educts_amounts(game, entity, educts_amounts)
	local type = entity.type
	if not crafting_machine_types[type] then
		if settings.global["automatic-logistic-chests-enable-artillery-turret-integration"].value and type == "artillery-turret" then
			Increment_value_in_table(educts_amounts, "artillery-shell", Modify_stack_size(Get_stack_size("artillery-shell"), true))
			return true
		elseif settings.global["automatic-logistic-chests-enable-rocket-silo-integration"].value and type == "rocket-silo" then
			Increment_value_in_table(educts_amounts, "satellite", Modify_stack_size(Get_stack_size("satellite"), true))
			return true
		else
			return false
		end
	end
	if not entity.get_recipe() then
		return false
	end
	for _, educt in ipairs(entity.get_recipe().ingredients) do
		local name = educt.name
        local amount = 0;
		if educt.type == "item" and educt.amount then
            local stack_size = Get_stack_size(name)
            amount = Modify_stack_size(math.ceil( educt.amount / stack_size ) * stack_size, true)
		end

        if amount > 0 then
			Increment_value_in_table(educts_amounts, name, amount)
		end
	end
	return true
end

function Get_products_amounts(game, entity, products_amounts)
	local type = entity.type
	if not crafting_machine_types[type] then
		if settings.global["automatic-logistic-chests-enable-artillery-turret-integration"].value and type == "artillery-turret" then
			Increment_value_in_table(products_amounts, "artillery-shell", Modify_stack_size(Get_stack_size("artillery-shell"), false))
			return true
		else
			return false
		end
	end
	if not entity.get_recipe() then
		return false
	end
	for _, product in ipairs(entity.get_recipe().products) do
		local name = product.name
		local amount = 0
		if product.type == "item" and product.amount then
			if settings.global["automatic-logistic-chests-enable-rocket-silo-integration"].value and name == "rocket-part" then
				name = "space-science-pack"
			end
            local stack_size = Get_stack_size(name)
            amount = Modify_stack_size(math.ceil( product.amount / stack_size ) * stack_size, false)
		end

		if amount > 0 then
			Increment_value_in_table(products_amounts, name, amount)
		end
	end
	return true
end

function Table_length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end