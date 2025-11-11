local QBCore = exports['qb-core']:GetCoreObject()
local playerBusinesses = {}
local lastPayoutTime = {}

-- Register net event to receive business ownership data from server
RegisterNetEvent('business:client:updateBusinesses', function(businessesData)
    playerBusinesses = businessesData
end)

-- Function to check if player owns a business
local function isBusinessOwned(index)
    return playerBusinesses[index] and playerBusinesses[index].owner == QBCore.Functions.GetPlayerData().citizenid
end

-- Function to open business info NUI
local function openBusinessInfo(businessIndex)
    local business = Config.Businesses[businessIndex]
    if not business then return end

    local payoutRange = business.PayoutRange or {min = Config.Payout.baseAmount, max = Config.Payout.maxAmount}
    local sellBackPrice = math.floor(business.BusinessPrice * (business.SellBackPercentage / 100))
    
    -- Calculate estimated hourly earnings
    local payoutsPerHour = 60 / Config.Payout.cooldown
    local minHourly = math.floor(payoutRange.min * payoutsPerHour)
    local maxHourly = math.floor(payoutRange.max * payoutsPerHour)
    
    -- Prepare supply information
    local supplyInfo = ""
    if business.Supplies and #business.Supplies > 0 then
        for i, supply in ipairs(business.Supplies) do
            supplyInfo = supplyInfo .. "• " .. supply.label .. ": $" .. supply.price .. "\n"
        end
    else
        supplyInfo = "No supplies required"
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openBusinessInfo',
        business = {
            name = business.BusinessName,
            price = business.BusinessPrice,
            sellBack = sellBackPrice,
            payoutMin = payoutRange.min,
            payoutMax = payoutRange.max,
            cooldown = Config.Payout.cooldown,
            minSupplies = Config.Payout.minSupplies,
            hourlyMin = minHourly,
            hourlyMax = maxHourly,
            supplies = supplyInfo,
            job = business.BusinessJob,
            suppliesRequired = business.Supplies and #business.Supplies > 0
        },
        businessIndex = businessIndex
    })
end

-- Function to close business info NUI
local function closeBusinessInfo()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeBusinessInfo'
    })
end

-- Function to open supplies menu for business owners
local function openSuppliesMenu(businessIndex)
    local business = Config.Businesses[businessIndex]
    if not business or not business.Supplies then return end

    local suppliesMenu = {}
    
    for i, supply in ipairs(business.Supplies) do
        suppliesMenu[#suppliesMenu + 1] = {
            header = supply.label,
            txt = "Price: $" .. supply.price,
            params = {
                event = "business:buySupplies",
                args = {
                    businessIndex = businessIndex,
                    supplyIndex = i
                }
            }
        }
    end
    
    suppliesMenu[#suppliesMenu + 1] = {
        header = "Close Menu",
        txt = "",
        params = {
            event = "qb-menu:closeMenu"
        }
    }
    
    exports['qb-menu']:openMenu(suppliesMenu)
end

-- Function to check payout status
local function checkPayoutStatus(businessIndex)
    QBCore.Functions.TriggerCallback('business:checkPayoutStatus', function(result)
        if result.success then
            if Config.Notify == "qb" then
                TriggerEvent('QBCore:Notify', result.message, 'success')
            elseif Config.Notify == "okok" then
                TriggerEvent('okokNotify:Alert', 'Payout', result.message, 1000, 'success', false)
            end
        else
            if Config.Notify == "qb" then
                TriggerEvent('QBCore:Notify', result.message, 'error')
            elseif Config.Notify == "okok" then
                TriggerEvent('okokNotify:Alert', 'Payout', result.message, 1000, 'error', false)
            end
        end
    end, businessIndex)
end

-- Function to collect payout
local function collectPayout(businessIndex)
    QBCore.Functions.TriggerCallback('business:collectPayout', function(result)
        if result.success then
            if Config.Notify == "qb" then
                TriggerEvent('QBCore:Notify', result.message, 'success')
            elseif Config.Notify == "okok" then
                TriggerEvent('okokNotify:Alert', 'Payout', result.message, 1000, 'success', false)
            end
            lastPayoutTime[businessIndex] = GetGameTimer()
        else
            if Config.Notify == "qb" then
                TriggerEvent('QBCore:Notify', result.message, 'error')
            elseif Config.Notify == "okok" then
                TriggerEvent('okokNotify:Alert', 'Payout', result.message, 1000, 'error', false)
            end
        end
    end, businessIndex)
end

-- Function to open payout menu
local function openPayoutMenu(businessIndex)
    local payoutMenu = {
        {
            header = "Business Payout",
            txt = "Manage your business earnings",
            isMenuHeader = true
        },
        {
            header = "Check Payout Status",
            txt = "Check if you can collect payout",
            params = {
                event = "business:checkPayout",
                args = { index = businessIndex }
            }
        },
        {
            header = "Collect Payout",
            txt = "Collect your business earnings",
            params = {
                event = "business:collectPayout",
                args = { index = businessIndex }
            }
        },
        {
            header = "Close Menu",
            txt = "",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    
    exports['qb-menu']:openMenu(payoutMenu)
end

-- Register the supplies purchase event
RegisterNetEvent('business:buySupplies', function(data)
    TriggerServerEvent('business:purchaseSupplies', data.businessIndex, data.supplyIndex)
end)

-- Register payout events
RegisterNetEvent('business:checkPayout', function(data)
    checkPayoutStatus(data.index)
end)

RegisterNetEvent('business:collectPayout', function(data)
    collectPayout(data.index)
end)

-- Request business data when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('business:requestBusinessData')
end)

-- NUI Callback
RegisterNUICallback('closeBusinessInfo', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyBusiness', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('business:buyBusiness', data.businessIndex)
    cb('ok')
end)

CreateThread(function()
    print("Config.Target: " .. tostring(Config.Target))
    
    -- Wait for player to load
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(1000)
    end
    
    -- Request business data from server
    TriggerServerEvent('business:requestBusinessData')
    
    for i, business in ipairs(Config.Businesses) do
        local pedModel = business.PedModel
        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(100)
        end
        local ped = CreatePed(4, pedModel, business.PedCoords.x, business.PedCoords.y, business.PedCoords.z, business.PedCoords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetBlockingOfNonTemporaryEvents(ped, true)
        --FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)

        local buyLabel = "Buy Business ($" .. business.BusinessPrice .. ")"
        local sellLabel = "Sell Business ($" .. math.floor(business.BusinessPrice * (business.SellBackPercentage / 100)) .. ")"
        local suppliesLabel = "Buy Business Supplies"
        local payoutLabel = "Business Payout"
        local infoLabel = "View Business Info"

        if Config.Target == "ox" then
            print("Registering ox_target for business: " .. business.BusinessName)
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'business:info',
                    event = 'business:info',
                    icon = 'fas fa-info-circle',
                    label = infoLabel,
                    args = { index = i },
                    distance = 2.5,
                    canInteract = function()
                        return not isBusinessOwned(i)
                    end,
                    onSelect = function()
                        openBusinessInfo(i)
                    end
                },
                {
                    name = 'business:buy',
                    event = 'business:buy',
                    icon = 'fas fa-shopping-cart',
                    label = buyLabel,
                    args = { index = i },
                    distance = 2.5,
                    canInteract = function()
                        return not isBusinessOwned(i)
                    end,
                    onSelect = function()
                        TriggerServerEvent('business:buyBusiness', i)
                    end
                },
                {
                    name = "business:sell",
                    event = "business:sell",
                    icon = "fas fa-dollar-sign",
                    label = sellLabel,
                    args = { index = i },
                    distance = 2.5,
                    canInteract = function()
                        return isBusinessOwned(i)
                    end,
                    onSelect = function()
                        TriggerServerEvent('business:sellBusiness', i)
                    end
                },
                {
                    name = "business:supplies",
                    event = "business:supplies",
                    icon = "fas fa-box-open",
                    label = suppliesLabel,
                    args = { index = i },
                    distance = 2.5,
                    canInteract = function()
                        return isBusinessOwned(i)
                    end,
                    onSelect = function()
                        openSuppliesMenu(i)
                    end
                },
                {
                    name = "business:payout",
                    event = "business:payout",
                    icon = "fas fa-money-bill-wave",
                    label = payoutLabel,
                    args = { index = i },
                    distance = 2.5,
                    canInteract = function()
                        return isBusinessOwned(i)
                    end,
                    onSelect = function()
                        openPayoutMenu(i)
                    end
                }
            })      
        elseif Config.Target == "qb" then
            print("Registering qb-target for business: " .. business.BusinessName)
            
            -- Create target options
            local options = {
                {
                    type = "client",
                    event = "business:openInfo",
                    icon = "fas fa-info-circle",
                    label = infoLabel,
                    job = "all",
                    index = i,
                    canInteract = function()
                        return not isBusinessOwned(i)
                    end
                },
                {
                    type = "server",
                    event = "business:buyBusiness",
                    icon = "fas fa-shopping-cart",
                    label = buyLabel,
                    job = "all",
                    index = i,
                    canInteract = function()
                        return not isBusinessOwned(i)
                    end
                }
            }
            
            -- Add sell option if player owns the business
            table.insert(options, {
                type = "server",
                event = "business:sellBusiness",
                icon = "fas fa-dollar-sign",
                label = sellLabel,
                job = "all",
                index = i,
                canInteract = function()
                    return isBusinessOwned(i)
                end
            })
            
            -- Add supplies option if player owns the business
            table.insert(options, {
                type = "client",
                event = "business:openSuppliesMenu",
                icon = "fas fa-box-open",
                label = suppliesLabel,
                job = "all",
                index = i,
                canInteract = function()
                    return isBusinessOwned(i)
                end
            })
            
            -- Add payout option if player owns the business
            table.insert(options, {
                type = "client",
                event = "business:openPayoutMenu",
                icon = "fas fa-money-bill-wave",
                label = payoutLabel,
                job = "all",
                index = i,
                canInteract = function()
                    return isBusinessOwned(i)
                end
            })
            
            exports['qb-target']:AddTargetEntity(ped, {
                options = options,
                distance = 2.5
            })
        else
            print("Invalid target system specified in config.")
        end

        if business.EnableBlip then
            local blip = AddBlipForCoord(business.BlipCoords.x, business.BlipCoords.y, business.BlipCoords.z)
            SetBlipSprite(blip, business.BlipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, business.BlipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(business.BlipName)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Register client event for opening business info
RegisterNetEvent('business:openInfo', function(data)
    openBusinessInfo(data.index)
end)

-- Register client event for opening supplies menu
RegisterNetEvent('business:openSuppliesMenu', function(data)
    openSuppliesMenu(data.index)
end)

-- Register client event for opening payout menu
RegisterNetEvent('business:openPayoutMenu', function(data)
    openPayoutMenu(data.index)
end)

-- Update business ownership when player buys/sells
RegisterNetEvent('business:client:refreshBusinesses', function()
    TriggerServerEvent('business:requestBusinessData')
end)