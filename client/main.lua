local isBusy = false

local function handleToggle()
    if isBusy then return end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = lib.getClosestVehicle(pos, 4.0, false)

    if not vehicle or vehicle == 0 then return end
    
    local vPos = GetEntityCoords(vehicle)
    if #(pos - vPos) > 5.0 then return end

    local plate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "")
    local hasKey = exports.ox_inventory:Search('count', 'vehicle_key', {plate = plate})

    if hasKey and hasKey > 0 then
        isBusy = true
        lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
        TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
        
        local lockStatus = GetVehicleDoorLockStatus(vehicle)
        local newState = lockStatus > 1 and 1 or 2
        
        if not NetworkHasControlOfEntity(vehicle) then
            NetworkRequestControlOfEntity(vehicle)
        end

        SetVehicleDoorsLocked(vehicle, newState)
        SetVehicleLights(vehicle, 2)
        PlayVehicleDoorOpenSound(vehicle, 0)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        
        lib.notify({
            title = 'Vehicle',
            description = newState == 2 and 'Vehicle Locked' or 'Vehicle Unlocked',
            type = newState == 2 and 'inform' or 'success'
        })
        
        SetTimeout(600, function() isBusy = false end)
    else
        lib.notify({ description = 'No keys for '..plate, type = 'error' })
    end
end

lib.addKeybind({
    name = 'veh_lock_sys',
    description = 'Lock/Unlock',
    defaultKey = 'L',
    onPressed = function()
        handleToggle()
    end
})

RegisterNetEvent('smg_key:client:reqKey', function()
    local ped = PlayerPedId()
    local v = lib.getClosestVehicle(GetEntityCoords(ped), 3.5, false)
    if v then TriggerServerEvent('smg_key:server:giveKey', GetVehicleNumberPlateText(v)) end
end)

RegisterNetEvent('cd_garage:AddKeys', function(plate)
    if plate then TriggerServerEvent('smg_key:server:giveKey', plate) end
end)

RegisterNetEvent('cd_garage:StoreVehicle', function()
    local v = GetVehiclePedIsIn(PlayerPedId(), true)
    if v ~= 0 then TriggerServerEvent('smg_key:server:remKey', GetVehicleNumberPlateText(v)) end
end)
