local Config = {
    Language = 'cz' 
}

local Locales = {
    ['en'] = {
        title = 'Vehicle',
        locked = 'Locked',
        unlocked = 'Unlocked',
        no_key = 'You do not have keys for this vehicle.',
        keybind_desc = 'Lock/Unlock Vehicle'
    },
    ['cz'] = {
        title = 'Vozidlo',
        locked = 'Zamknuto',
        unlocked = 'Odemknuto',
        no_key = 'Nemáš klíče od tohoto vozidla.',
        keybind_desc = 'Zamknout/Odemknout vozidlo'
    }
}

local lang = Locales[Config.Language]

Citizen.CreateThread(function()
    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
end)

local function toggleLock(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
    local count = exports.ox_inventory:Search('count', 'vehicle_key', {plate = plate})
    
    if (count or 0) > 0 then
        TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
        
        local isLocked = GetVehicleDoorLockStatus(vehicle) > 1
        local newLockStatus = isLocked and 1 or 2
        
        SetVehicleDoorsLocked(vehicle, newLockStatus)
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        
        lib.notify({
            title = lang.title,
            description = isLocked and lang.unlocked or lang.locked,
            type = isLocked and 'success' or 'inform'
        })
    else
        lib.notify({ description = lang.no_key, type = 'error' })
    end
end

-- Keybind L
lib.addKeybind({
    name = 'lock_vehicle',
    description = lang.keybind_desc,
    defaultKey = 'L',
    onPressed = function()
        local vehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, false)
        if vehicle then toggleLock(vehicle) end
    end
})

RegisterNetEvent('smg_key:client:requestNearbyKey', function()
    local vehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, false)
    if vehicle then
        TriggerServerEvent('smg_key:server:requestKey', GetVehicleNumberPlateText(vehicle))
    end
end)

RegisterNetEvent('cd_garage:AddKeys', function(plate)
    if plate then TriggerServerEvent('smg_key:server:requestKey', plate) end
end)

RegisterNetEvent('cd_garage:StoreVehicle', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
    if veh ~= 0 then
        TriggerServerEvent('smg_key:server:removeKey', GetVehicleNumberPlateText(veh))
    end
end)