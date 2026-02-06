local ESX = exports["es_extended"]:getSharedObject()
local inv = exports.ox_inventory

exports('GiveKey', function(id, plate)
    if not plate then return end
    local x = ESX.GetPlayerFromId(id)
    local p = plate:gsub("%s+", "")

    MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {p}, function(owner)
        if owner and owner == x.getIdentifier() then
            inv:AddItem(id, 'vehicle_key', 1, { plate = p, description = "Plate: "..p })
        end
    end)
end)

RegisterNetEvent('smg_key:server:giveKey', function(plate)
    local src = source
    if not plate then return end
    local x = ESX.GetPlayerFromId(src)
    local p = plate:gsub("%s+", "")

    local currentKeys = inv:Search(src, 'count', 'vehicle_key', {plate = p})
    if currentKeys and currentKeys > 0 then return end

    MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {p}, function(owner)
        if owner == x.getIdentifier() then
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
                return
            end
        end
    end
end)

ESX.RegisterCommand('getkey', 'user', function(x, args)
    TriggerClientEvent('smg_key:client:reqKey', x.source)
end, false)
