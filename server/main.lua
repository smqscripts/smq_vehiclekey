local ESX = exports["es_extended"]:getSharedObject()
local inv = exports.ox_inventory

RegisterNetEvent('smg_key:server:toggleLock', function(netId, plate)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    
    if not DoesEntityExist(vehicle) then return end

    local hasKey = inv:Search(src, 'count', 'vehicle_key', {plate = plate})

    if hasKey and hasKey > 0 then
        local current = Entity(vehicle).state.lockStatus or 1
        local newState = (current == 2) and 1 or 2
        
        Entity(vehicle).state.lockStatus = newState
        TriggerClientEvent('smg_key:client:syncEffects', -1, netId)
        
        local msg = newState == 2 and 'Vehicle locked' or 'Vehicle unlocked'
        TriggerClientEvent('ox_lib:notify', src, { type = (newState == 2 and 'inform' or 'success'), description = msg })
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You don't have keys for this vehicle" })
    end
end)

exports('GiveKey', function(id, plate)
    if not plate then return end
    local xPlayer = ESX.GetPlayerFromId(id)
    local p = plate:gsub("%s+", "")

    MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {p}, function(owner)
        if owner and owner == xPlayer.getIdentifier() then
            inv:AddItem(id, 'vehicle_key', 1, { plate = p, description = "Plate: "..p })
        end
    end)
end)

RegisterNetEvent('smg_key:server:giveKey', function(plate)
    local src = source
    if not plate then return end
    local xPlayer = ESX.GetPlayerFromId(src)
    local p = plate:gsub("%s+", "")

    local hasKey = inv:Search(src, 'count', 'vehicle_key', {plate = p})
    if hasKey and hasKey > 0 then return end

    MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {p}, function(owner)
        if owner == xPlayer.getIdentifier() then
            inv:AddItem(src, 'vehicle_key', 1, { plate = p, description = "Plate: "..p })
        end
    end)
end)

RegisterNetEvent('smg_key:server:remKey', function(plate)
    local src = source
    local p = plate:gsub("%s+", "")
    local items = inv:GetInventoryItems(src)
    
    if items then
        for _, v in pairs(items) do
            if v.name == 'vehicle_key' and v.metadata and v.metadata.plate == p then
                inv:RemoveItem(src, 'vehicle_key', 1, nil, v.slot)
                break
            end
        end
    end
end)

ESX.RegisterCommand('getkey', 'user', function(xPlayer, args)
    TriggerClientEvent('smg_key:client:reqKey', xPlayer.source)
end, false)
