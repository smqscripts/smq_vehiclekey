local lang = {
    title = 'Vozidlo',
    locked = 'Zamknuto',
    unlocked = 'Odemknuto',
    no_key = 'Nemáš klíče od tohoto vozidla.',
    bind = 'Zamknout/Odemknout vozidlo'
}

-- Načtení animace při startu
CreateThread(function()
    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
end)

local function toggleVehicleState(veh)
    local plate = GetVehicleNumberPlateText(veh):gsub("^%s*(.-)%s*$", "%1")
    local hasItem = exports.ox_inventory:Search('count', 'vehicle_key', {plate = plate})
    
    if (hasItem or 0) > 0 then
        TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
        
        local isLocked = GetVehicleDoorLockStatus(veh) > 1
        local newState = isLocked and 1 or 2
        
        SetVehicleDoorsLocked(veh, newState)
        SetVehicleLights(veh, 2)
        Wait(200)
        SetVehicleLights(veh, 0)
        
        lib.notify({
            title = lang.title,
            description = isLocked and lang.unlocked or lang.locked,
            type = isLocked and 'success' or 'inform'
        })
    else
        lib.notify({ description = lang.no_key, type = 'error' })
    end
end

lib.addKeybind({
    name = 'veh_lock_system',
    description = lang.bind,
    defaultKey = 'L',
    onPressed = function()
        local veh = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, false)
        if veh then toggleVehicleState(veh) end
    end
})

RegisterNetEvent('smg_key:client:requestNearbyKey', function()
    local veh = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, false)
    if veh then
        TriggerServerEvent('smg_key:server:requestKey', GetVehicleNumberPlateText(veh))
    end
end)

RegisterNetEvent('cd_garage:AddKeys', function(plate)
    if plate then TriggerServerEvent('smg_key:server:requestKey', plate) end
end)

RegisterNetEvent('cd_garage:StoreVehicle', function()
    local pedVeh = GetVehiclePedIsIn(PlayerPedId(), true)
    if pedVeh ~= 0 then
        TriggerServerEvent('smg_key:server:removeKey', GetVehicleNumberPlateText(pedVeh))
    end
end)
