local isBusy = false

local function handleToggle()
    if isBusy then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = lib.getClosestVehicle(coords, 4.0, false)

    if not vehicle or vehicle == 0 then return end
    
    local plate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "")
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    isBusy = true
    
    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
    TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
    
    TriggerServerEvent('smg_key:server:toggleLock', netId, plate)

    SetTimeout(800, function() isBusy = false end)
end

lib.addKeybind({
    name = 'veh_lock_sys',
    description = 'Lock/Unlock Vehicle',
    defaultKey = 'L',
    onPressed = function()
        handleToggle()
    end
})

RegisterNetEvent('smg_key:client:syncEffects', function(netId)
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        SetVehicleLights(vehicle, 2)
        PlayVehicleDoorOpenSound(vehicle, 0)
        SetTimeout(200, function()
            SetVehicleLights(vehicle, 0)
        end)
    end
end)

AddStateBagChangeHandler('lockStatus', nil, function(bagName, key, value, _unused, replicated)
    local netId = tonumber(bagName:gsub('entity:', ''))
    local entity = NetToVeh(netId)
    if DoesEntityExist(entity) then
        SetVehicleDoorsLocked(entity, value)
    end
end)

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
