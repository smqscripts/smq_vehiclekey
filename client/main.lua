local busy = false

function toggle_veh_lock()
    if busy then return end
    
    local ped = PlayerPedId()
    local veh = lib.getClosestVehicle(GetEntityCoords(ped), 4.0, false)

    if veh and veh ~= 0 then
        busy = true
        
        lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
        TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
        
        TriggerServerEvent('smg_key:server:toggleLock', NetworkGetNetworkIdFromEntity(veh))

        Citizen.SetTimeout(800, function()
            busy = false
        end)
    end
end

lib.addKeybind({
    name = 'veh_lock_sys',
    description = 'Lock/Unlock',
    defaultKey = 'L',
    onPressed = function()
        toggle_veh_lock()
    end
})

RegisterNetEvent('smg_key:client:syncEffects')
AddEventHandler('smg_key:client:syncEffects', function(netId)
    if NetworkDoesNetworkIdExist(netId) then
        local veh = NetToVeh(netId)
        if DoesEntityExist(veh) then
            SetVehicleLights(veh, 2)
            PlayVehicleDoorOpenSound(veh, 0)
            Citizen.SetTimeout(200, function()
                SetVehicleLights(veh, 0)
            end)
        end
    end
end)

AddStateBagChangeHandler('lockStatus', nil, function(bag, key, val)
    local netId = tonumber(bag:gsub('entity:', ''))
    if not netId then return end
    local veh = NetToVeh(netId)
    if DoesEntityExist(veh) then
        SetVehicleDoorsLocked(veh, val)
    end
end)

RegisterNetEvent('smg_key:client:reqKey', function()
    local veh = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 4.0, false)
    if DoesEntityExist(veh) then 
        TriggerServerEvent('smg_key:server:giveKey', NetworkGetNetworkIdFromEntity(veh)) 
    end
end)
