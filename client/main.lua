local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local PlayerGang = {}
local PlayerJob = {}

local Markers = false
local HouseMarkers = false
local InputIn = false
local InputOut = false
local currentGarage = nil
local currentGarageIndex = nil
local garageZones = {}
local lasthouse = nil
local blipsZonesLoaded = false

local function ClearMenu()
    TriggerEvent("qb-menu:closeMenu")
end

local function closeMenuFull()
    ClearMenu()
end

local function DestroyZone(type, index)
    if garageZones[type .. "_" .. index] then
        garageZones[type .. "_" .. index].zonecombo:destroy()
        garageZones[type .. "_" .. index].zone:destroy()
    end
end

local function SetupGarageMenu(id, garage)
    local GarageMenu = {
        id = 'garage' .. id,
        title = 'Garage ' .. garage.label,
        icon = 'car',
        items = {}
    }

    GarageMenu['items'] = {{
        id = 'access_garage',
        title = 'Access Garage',
        icon = 'warehouse',
        type = 'client',
        event = "qb-garages:client:toggleAccessGarageMenu",
        params = {
            type = garage.type,
            garage = garage,
            index = currentGarageIndex,
        },
        shouldClose = true
    }, {
        id = 'park_vehicle',
        title = 'Park Vehicle',
        icon = 'square-parking',
        type = 'client',
        event = 'qb-garages:client:parkVehicle',
        shouldClose = false
    }}

    exports['qb-radialmenu']:AddOption(GarageMenu, 'garage' .. id)
end

local function RemoveGarageMenu(garageId)
    exports['qb-radialmenu']:RemoveOption('garage' .. garageId)
end

local function CreateZone(type, garage, index)
    garageZones[type .. "_" .. index] = {}
    print(type .. "_" .. index)
    garageZones[type .. "_" .. index] = PolyZone:Create(garage.zone.shape, {
        name = type .. "_" .. index,
        minZ = garage.zone.minZ,
        maxZ = garage.zone.maxZ,
        debugPoly = true,
        data = garage
    })

    garageZones[type .. "_" .. index]:onPlayerInOut(function(isPointInside)
        if isPointInside then
            SetupGarageMenu(type .. "_" .. index, garageZones[type .. "_" .. index].data)
            currentGarage = garageZones[type .. "_" .. index].data
            currentGarageIndex = index
            QBCore.Functions.Notify(Lang:t("info.enter_garage"), "primary", 3000)
        else
            RemoveGarageMenu(type .. "_" .. index)
        end
    end)

    -- garageZones[type .. "_" .. index].zone = BoxZone:Create(
    --     coords, size, size, {
    --     minZ = minz,
    --     maxZ = maxz,
    --     name = type,
    --     debugPoly = true,
    --     heading = heading
    -- })

    -- garageZones[type .. "_" .. index].zonecombo = ComboZone:Create({ garageZones[type .. "_" .. index].zone },
    -- { name = "box" .. type, debugPoly = false })

    -- garageZones[type .. "_" .. index].zonecombo:onPlayerInOut(function(isPointInside)
    --     if isPointInside then
    --         local text
    --         if type == "in" then
    --             if garage.type == "house" then
    --                 text = Lang:t("info.park_e")
    --             else
    --                 text = Lang:t("info.park_e") .. "<br>" .. garage.label
    --             end
    --             exports['qb-core']:DrawText(text, 'left')
    --             InputIn = true
    --         elseif type == "out" then
    --             if garage.type == "house" then
    --                 text = Lang:t("info.car_e")
    --             else
    --                 text = Lang:t("info." .. garage.vehicle .. "_e") .. "<br>" .. garage.label
    --             end

    --             exports['qb-core']:DrawText(text, 'left')
    --             InputOut = true
    --         elseif type == "marker" then
    --             currentGarage = garage
    --             currentGarageIndex = index
    --             CreateZone("out", garage, index)
    --             if garage.type ~= "depot" then
    --                 CreateZone("in", garage, index)
    --                 Markers = true
    --             else
    --                 HouseMarkers = true
    --             end
    --         elseif type == "hmarker" then
    --             currentGarage = garage
    --             currentGarage.type = "house"
    --             currentGarageIndex = index
    --             CreateZone("house", garage, index)
    --             HouseMarkers = true
    --         elseif type == "house" then
    --             if IsPedInAnyVehicle(PlayerPedId(), false) then
    --                 exports['qb-core']:DrawText(Lang:t("info.park_e"), 'left')
    --                 InputIn = true
    --             else
    --                 exports['qb-core']:DrawText(Lang:t("info.car_e"), 'left')
    --                 InputOut = true
    --             end
    --         end
    --     else
    --         if type == "marker" then
    --             if currentGarage == garage then
    --                 if garage.type ~= "depot" then
    --                     Markers = false
    --                 else
    --                     HouseMarkers = false
    --                 end
    --                 DestroyZone("in", index)
    --                 DestroyZone("out", index)
    --                 currentGarage = nil
    --                 currentGarageIndex = nil
    --             end
    --         elseif type == "hmarker" then
    --             HouseMarkers = false
    --             DestroyZone("house", index)
    --         elseif type == "house" then
    --             exports['qb-core']:HideText()
    --             InputIn = false
    --             InputOut = false
    --         elseif type == "in" then
    --             exports['qb-core']:HideText()
    --             InputIn = false
    --         elseif type == "out" then
    --             closeMenuFull()
    --             exports['qb-core']:HideText()
    --             InputOut = false
    --         end
    --     end
    -- end)
end

local function doCarDamage(currentVehicle, veh)
    local engine = veh.engine + 0.0
    local body = veh.body + 0.0

    Wait(100)
    if VisuallyDamageCars then
        if body < 900.0 then
            SmashVehicleWindow(currentVehicle, 0)
            SmashVehicleWindow(currentVehicle, 1)
            SmashVehicleWindow(currentVehicle, 2)
            SmashVehicleWindow(currentVehicle, 3)
            SmashVehicleWindow(currentVehicle, 4)
            SmashVehicleWindow(currentVehicle, 5)
            SmashVehicleWindow(currentVehicle, 6)
            SmashVehicleWindow(currentVehicle, 7)
        end
        if body < 800.0 then
            SetVehicleDoorBroken(currentVehicle, 0, true)
            SetVehicleDoorBroken(currentVehicle, 1, true)
            SetVehicleDoorBroken(currentVehicle, 2, true)
            SetVehicleDoorBroken(currentVehicle, 3, true)
            SetVehicleDoorBroken(currentVehicle, 4, true)
            SetVehicleDoorBroken(currentVehicle, 5, true)
            SetVehicleDoorBroken(currentVehicle, 6, true)
        end
        if engine < 700.0 then
            SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
        end
        if engine < 500.0 then
            SetVehicleTyreBurst(currentVehicle, 0, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 5, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 6, false, 990.0)
            SetVehicleTyreBurst(currentVehicle, 7, false, 990.0)
        end
    end
    SetVehicleEngineHealth(currentVehicle, engine)
    SetVehicleBodyHealth(currentVehicle, body)

end

local function CheckPlayers(vehicle, garage)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
            if garage then
                SetEntityCoords(seat, garage.takeVehicle.x, garage.takeVehicle.y, garage.takeVehicle.z)
            end
        end
    end
    SetVehicleDoorsLocked(vehicle)
    Wait(1500)
    QBCore.Functions.DeleteVehicle(vehicle)
end

-- Functions
local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

RegisterNetEvent('qb-garages:client:takeOutGarage', function(data)
    local type = data.type
    local vehicle = data.vehicle
    local garage = data.garage
    local index = data.index

    local freeSpawnPoint = nil
    for k, point in pairs(currentGarage.spawnPoints) do
        local veh, distance = QBCore.Functions.GetClosestVehicle(vector3(point.x, point.y, point.z))
        if distance > 1.75 then
            freeSpawnPoint = point
            break
        end
    end

    if not freeSpawnPoint then
        QBCore.Functions.Notify(Lang:t("error.no_parking_space_available"), "error", 7500)
        return
    end 

    QBCore.Functions.TriggerCallback('qb-garage:server:IsSpawnOk', function(spawn)
        if spawn then
            QBCore.Functions.TriggerCallback('qb-garage:server:spawnvehicle', function(netId, properties)
                local veh = NetToVeh(netId)
                QBCore.Functions.SetVehicleProperties(veh, properties)
                exports['LegacyFuel']:SetFuel(veh, vehicle.fuel)
                doCarDamage(veh, vehicle)
                TriggerServerEvent('qb-garage:server:updateVehicleState', 0, vehicle.plate, index)
                closeMenuFull()
                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                SetVehicleEngineOn(veh, true, true)
                if type == "house" then
                    exports['qb-core']:DrawText(Lang:t("info.park_e"), 'left')
                    InputOut = false
                    InputIn = true
                end
            end, vehicle, freeSpawnPoint, true)
        else
            QBCore.Functions.Notify(Lang:t("error.not_impound"), "error", 5000)
        end
    end, vehicle.plate, type)
end)

local function enterVehicle(veh, indexgarage, type, garage)
    local plate = QBCore.Functions.GetPlate(veh)
    if GetVehicleNumberOfPassengers(veh) == 0 then
        QBCore.Functions.TriggerCallback('qb-garage:server:checkOwnership', function(owned)
            if owned then
                local bodyDamage = math.ceil(GetVehicleBodyHealth(veh))
                local engineDamage = math.ceil(GetVehicleEngineHealth(veh))
                local totalFuel = exports['LegacyFuel']:GetFuel(veh)
                local vehProperties = QBCore.Functions.GetVehicleProperties(veh)
                if vehProperties then
                    vehProperties = json.encode(vehProperties)
                end
                TriggerServerEvent('qb-garage:server:updateVehicle', 1, totalFuel, engineDamage, bodyDamage, vehProperties, plate, indexgarage, type, PlayerGang.name)
                CheckPlayers(veh, garage)
                if type == "house" then
                    exports['qb-core']:DrawText(Lang:t("info.car_e"), 'left')
                    InputOut = true
                    InputIn = false
                end

                if plate then
                    TriggerServerEvent('qb-garages:server:UpdateOutsideVehicle', plate, nil)
                end
                QBCore.Functions.Notify(Lang:t("success.vehicle_parked"), "primary", 4500)
            else
                QBCore.Functions.Notify(Lang:t("error.not_owned"), "error", 3500)
            end
        end, plate, type, indexgarage, PlayerGang.name)
    else
        QBCore.Functions.Notify(Lang:t("error.vehicle_occupied"), "error", 5000)
    end
end

local function CreateBlipsZones()
    if blipsZonesLoaded then return end

    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerGang = PlayerData.gang
    PlayerJob = PlayerData.job
    for index, garage in pairs(Garages) do
        if garage.showBlip then
            local Garage = AddBlipForCoord(garage.takeVehicle.x, garage.takeVehicle.y, garage.takeVehicle.z)
            SetBlipSprite(Garage, garage.blipNumber)
            SetBlipDisplay(Garage, 4)
            SetBlipScale(Garage, 0.60)
            SetBlipAsShortRange(Garage, true)
            SetBlipColour(Garage, 3)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(garage.blipName)
            EndTextCommandSetBlipName(Garage)
        end
        if garage.type == "job" then
            if PlayerJob.name == garage.job then
                CreateZone("marker", garage, index)
            end
        elseif garage.type == "gang" then
            if PlayerGang.name == garage.job then
                CreateZone("marker", garage, index)
            end
        else
            CreateZone("marker", garage, index)
        end
    end
    blipsZonesLoaded = true
end

--Menus
local function MenuGarage(type, garage, indexgarage)
    local type = type
    local garage = garage
    local indexgarage = indexgarage
    local header
    local leave
    if type == "house" then
        header = Lang:t("menu.header." .. type .. "_car", { value = garage.label })
        leave = Lang:t("menu.leave.car")
    else
        header = Lang:t("menu.header." .. type .. "_" .. garage.vehicle, { value = garage.label })
        leave = Lang:t("menu.leave." .. garage.vehicle)
    end

    QBCore.Functions.TriggerCallback("qb-garage:server:GetGarageVehicles", function(result)
        if result == nil then
            QBCore.Functions.Notify(Lang:t("error.no_vehicles"), "error", 5000)
        else
            local MenuGarageOptions = {
                {
                    header = header,
                    isMenuHeader = true
                },
            }
            for _, v in pairs(result) do
                local enginePercent = round(v.engine / 10, 0)
                local bodyPercent = round(v.body / 10, 0)
                local currentFuel = v.fuel
                local vname = QBCore.Shared.Vehicles[v.vehicle].name

                if v.state == 0 then
                    v.state = Lang:t("status.out")
                elseif v.state == 1 then
                    v.state = Lang:t("status.garaged")
                elseif v.state == 2 then
                    v.state = Lang:t("status.impound")
                end
                if type == "depot" then
                    MenuGarageOptions[#MenuGarageOptions + 1] = {
                        header = Lang:t('menu.header.depot', { value = vname, value2 = v.depotprice }),
                        txt = Lang:t('menu.text.depot', { value = v.plate, value2 = currentFuel, value3 = enginePercent, value4 = bodyPercent }),
                        params = {
                            event = "qb-garages:client:TakeOutDepot",
                            args = {
                                vehicle = v,
                                type = type,
                                garage = garage,
                                index = indexgarage,
                            }
                        }
                    }
                else
                    MenuGarageOptions[#MenuGarageOptions + 1] = {
                        header = Lang:t('menu.header.garage', { value = vname, value2 = v.plate }),
                        txt = Lang:t('menu.text.garage', { value = v.state, value2 = currentFuel, value3 = enginePercent, value4 = bodyPercent }),
                        params = {
                            event = "qb-garages:client:takeOutGarage",
                            args = {
                                vehicle = v,
                                type = type,
                                garage = garage,
                                index = indexgarage,
                            }
                        }
                    }
                end
            end

            MenuGarageOptions[#MenuGarageOptions + 1] = {
                header = leave,
                txt = "",
                params = {
                    event = "qb-menu:closeMenu",
                }
            }
            exports['qb-menu']:openMenu(MenuGarageOptions)
        end
    end, indexgarage, type, garage.vehicle)
end

RegisterNetEvent('qb-garages:client:toggleAccessGarageMenu', function()
    if currentGarage.type == "job" then
        if PlayerJob.name == currentGarage.job then
            MenuGarage(currentGarage.type, currentGarage, currentGarageIndex)
        end
    elseif currentGarage.type == "gang" then
        if PlayerGang.name == currentGarage.job then
            MenuGarage(currentGarage.type, currentGarage, currentGarageIndex)
        end
    else
        MenuGarage(currentGarage.type, currentGarage, currentGarageIndex)
    end
end)

RegisterNetEvent('qb-garages:client:parkVehicle', function()
    local ped = PlayerPedId()
    local curVeh = GetVehiclePedIsIn(ped)
    local vehClass = GetVehicleClass(curVeh)

    --Check vehicle type for garage
    if currentGarage.vehicle == "car" or not currentGarage.vehicle then
        if vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 then
            if currentGarage.type == "job" then
                if PlayerJob.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
                end
            elseif currentGarage.type == "gang" then
                if PlayerGang.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
                end
            else
                enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
            end
        else
            QBCore.Functions.Notify(Lang:t("error.not_correct_type"), "error", 3500)
        end
    elseif currentGarage.vehicle == "air" then
        if vehClass == 15 or vehClass == 16 then
            if currentGarage.type == "job" then
                if PlayerJob.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
                end
            elseif currentGarage.type == "gang" then
                if PlayerGang.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
                end
            else
                enterVehicle(curVeh, currentGarageIndex, currentGarage.type)
            end
        else
            QBCore.Functions.Notify(Lang:t("error.not_correct_type"), "error", 3500)
        end
    elseif currentGarage.vehicle == "sea" then
        if vehClass == 14 then
            if currentGarage.type == "job" then
                if PlayerJob.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type, currentGarage)
                end
            elseif currentGarage.type == "gang" then
                if PlayerGang.name == currentGarage.job then
                    enterVehicle(curVeh, currentGarageIndex, currentGarage.type, currentGarage)
                end
            else
                enterVehicle(curVeh, currentGarageIndex, currentGarage.type, currentGarage)
            end
        else
            QBCore.Functions.Notify(Lang:t("error.not_correct_type"), "error", 3500)
        end
    end
end)

RegisterNetEvent('qb-garages:client:setHouseGarage', function(house, hasKey)
    if HouseGarages[house] then
        if lasthouse ~= house then
            if lasthouse then
                DestroyZone("hmarker", lasthouse)
            end
            if hasKey and HouseGarages[house].takeVehicle.x then
                CreateZone("hmarker", HouseGarages[house], house)
                lasthouse = house
            end
        end
    end
end)

RegisterNetEvent('qb-garages:client:houseGarageConfig', function(garageConfig)
    HouseGarages = garageConfig
end)

RegisterNetEvent('qb-garages:client:addHouseGarage', function(house, garageInfo)
    HouseGarages[house] = garageInfo
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    CreateBlipsZones()
end)

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateBlipsZones()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)

RegisterNetEvent('qb-garages:client:TakeOutDepot', function(data)
    local vehicle = data.vehicle

    if vehicle.depotprice ~= 0 then
        TriggerServerEvent("qb-garage:server:PayDepotPrice", data)
    else
        TriggerEvent("qb-garages:client:takeOutGarage", data)
    end
end)
