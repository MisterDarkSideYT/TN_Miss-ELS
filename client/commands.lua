RegisterNetEvent('kjELS:toggleExtra')
AddEventHandler('kjELS:toggleExtra', function(vehicle, extra)
    if not vehicle or not extra then
        CancelEvent()
        return
    end

    extra = tonumber(extra) or -1
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not DoesExtraExist(vehicle, extra) then
        print('Extra ' .. extra .. ' does not exist on your ' .. model .. '!')
        CancelEvent()
        return
    end

    -- see if the extra is currently on or off
    local toggle = IsVehicleExtraTurnedOn(vehicle, extra)
    
    -- disable auto repairs
    SetVehicleAutoRepairDisabled(vehicle, true)

    -- toggle the extra
    SetVehicleExtra(vehicle, extra, toggle)
end)

RegisterCommand('extra', function(source, args)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then return end

    local vehicle = GetVehiclePedIsIn(ped)
    local extra = args[1] or -1

    TriggerEvent('kjELS:toggleExtra', vehicle, extra)
end)

RegisterNetEvent('kjELS:toggleMisc')
AddEventHandler('kjELS:toggleMisc', function(vehicle, misc)
    if not vehicle or not misc then
        CancelEvent()
        return
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not DoesMiscExist(vehicle, Misc) then
        print('Misc ' .. extra .. ' does not exist on your ' .. model .. '!')
        CancelEvent()
        return
    end

    -- see if the extra is currently on or off
    local index = IsVehicleMiscTurnedOn(vehicle, Misc)
    
    SetVehicleModKit(vehicle, 0)

    SetVehicleMod(vehicle, misc, index, false)
end)

RegisterCommand('misc', function(source, args)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then return end

    local vehicle = GetVehiclePedIsIn(ped)
    local misc = args[1] or -1

    if not string.match(misc, '%a') then
        print('Misc must be a single letter!')
        return
    end

    TriggerEvent('kjELS:toggleMisc', vehicle, ConvertMiscNameToId(misc))
end)
