local ESX = exports["es_extended"]:getSharedObject()
local ox_inventory = exports.ox_inventory

local Config = {
    Language = 'cz' 
}

local Locales = {
    ['en'] = { key_desc = 'Vehicle key: ' },
    ['cz'] = { key_desc = 'Klíč od vozidla: ' }
}

local lang = Locales[Config.Language]

local function clean(plate)
    if not plate then return nil end
    return plate:gsub("^%s*(.-)%s*$", "%1")
end

local function giveKey(src, plate)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not plate then return end
    
    local cleanPlate = clean(plate)
    exports.oxmysql:scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {cleanPlate}, function(owner)
        if owner == xPlayer.getIdentifier() then
            ox_inventory:AddItem(src, 'vehicle_key', 1, {
                plate = cleanPlate,
                description = lang.key_desc .. cleanPlate
            })
        end
    end)
end

exports('GiveKey', giveKey)

-- Původní eventy
RegisterNetEvent('smg_key:server:requestKey', function(plate)
    giveKey(source, plate)
end)

-- /getkey 
ESX.RegisterCommand('getkey', 'user', function(xPlayer, args, showError)
    TriggerClientEvent('smg_key:client:requestNearbyKey', xPlayer.source)
end, false)

RegisterNetEvent('smg_key:server:removeKey', function(plate)
    local src = source
    local cleanPlate = clean(plate)
    local items = ox_inventory:GetInventoryItems(src)
    
    if items then
        for _, item in pairs(items) do
            if item.name == 'vehicle_key' and item.metadata and clean(item.metadata.plate) == cleanPlate then
                ox_inventory:RemoveItem(src, 'vehicle_key', 1, nil, item.slot)
                break 
            end
        end
    end
end)