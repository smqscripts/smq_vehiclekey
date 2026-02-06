local ESX = exports["es_extended"]:getSharedObject()
local ox_inv = exports.ox_inventory

local function plateTrim(plate)
    return plate and plate:gsub("^%s*(.-)%s*$", "%1") or nil
end

local function processKeyGive(target, plate)
    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer or not plate then return end
    
    local clean = plateTrim(plate)
    MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {clean}, function(owner)
        if owner == xPlayer.getIdentifier() then
            ox_inv:AddItem(target, 'vehicle_key', 1, {
                plate = clean,
                description = "Klíč od vozidla: " .. clean
            })
        end
    end)
end

exports('GiveKey', processKeyGive)

RegisterNetEvent('smg_key:server:requestKey', function(plate)
    processKeyGive(source, plate)
end)

RegisterNetEvent('smg_key:server:removeKey', function(plate)
    local _src = source
    local clean = plateTrim(plate)
    local playerInv = ox_inv:GetInventoryItems(_src)
    
    if playerInv then
        for _, item in pairs(playerInv) do
            if item.name == 'vehicle_key' and item.metadata and plateTrim(item.metadata.plate) == clean then
                ox_inv:RemoveItem(_src, 'vehicle_key', 1, nil, item.slot)
                break 
            end
        end
    end
end)

ESX.RegisterCommand('getkey', 'user', function(xPlayer, args, showError)
    TriggerClientEvent('smg_key:client:requestNearbyKey', xPlayer.source)
end, false)
