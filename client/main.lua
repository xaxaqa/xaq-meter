local ESX = exports["es_extended"]:getSharedObject()
local meterActive = false
local fareAmount = 0
local startTime = 0
local lastPosition = nil
local displayUI = false

local function isValidTaxi(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    for _, taxiModel in ipairs(Config.TaxiVehicles) do
        if string.lower(modelName) == string.lower(taxiModel) then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        if meterActive then
            if not IsPedInAnyVehicle(ped, false) then
                TriggerEvent('esx_taximeter:stopMeter', true)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if meterActive then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local currentPos = GetEntityCoords(vehicle)
            
            if lastPosition then
                local speed = GetEntitySpeed(vehicle)
                if speed > 0.1 then
                    fareAmount = fareAmount + Config.PricePerSecond
                else
                    fareAmount = fareAmount + Config.WaitingPricePerSecond
                end
            end
            
            lastPosition = currentPos
            SendNUIMessage({
                type = "updateMeter",
                fare = math.max(Config.MinimumFare, math.floor(fareAmount * 100) / 100)
            })
        end
    end
end)

RegisterNetEvent('esx_taximeter:stopMeter')
AddEventHandler('esx_taximeter:stopMeter', function(forced)
    if meterActive then
        meterActive = false
        SendNUIMessage({
            type = "showMeter",
            display = false,
            fareAmount = math.floor(fareAmount * 100) / 100,
            forced = forced
        })
        if not forced then
            ESX.ShowNotification('Final fare: $' .. math.floor(fareAmount * 100) / 100)
        end
        fareAmount = 0
        displayUI = false
    end
end)

RegisterCommand('startmeter', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 and isValidTaxi(vehicle) then
        meterActive = true
        fareAmount = Config.BasePrice
        startTime = GetGameTimer()
        lastPosition = GetEntityCoords(vehicle)
        displayUI = true
        
        SendNUIMessage({
            type = "showMeter",
            display = true,
            fare = fareAmount,
            starting = true
        })
    else
        ESX.ShowNotification('You must be in a taxi to use the meter!')
    end
end)

RegisterCommand('stopmeter', function()
    TriggerEvent('esx_taximeter:stopMeter', false)
end) 