local QBCore = exports['qb-core']:GetCoreObject()
local businesses = {}
local businessInventories = {}
local businessPayouts = {}
local onlinePlayers = {}

local function loadBusinesses()
    local file = LoadResourceFile(GetCurrentResourceName(), 'businesses.json')
    if file then
        businesses = json.decode(file) or {}
    else
        businesses = {} 
    end
end

local function loadBusinessInventories()
    local file = LoadResourceFile(GetCurrentResourceName(), 'business_inventories.json')
    if file then
        businessInventories = json.decode(file) or {}
    else
        businessInventories = {}
    end
end

local function loadBusinessPayouts()
    local file = LoadResourceFile(GetCurrentResourceName(), 'business_payouts.json')
    if file then
        businessPayouts = json.decode(file) or {}
    else
        businessPayouts = {}
    end
end

local function saveBusinesses()
    local jsonData = json.encode(businesses)
    SaveResourceFile(GetCurrentResourceName(), 'businesses.json', jsonData, -1)
end

local function saveBusinessInventories()
    local jsonData = json.encode(businessInventories)
    SaveResourceFile(GetCurrentResourceName(), 'business_inventories.json', jsonData, -1)
end

local function saveBusinessPayouts()
    local jsonData = json.encode(businessPayouts)
    SaveResourceFile(GetCurrentResourceName(), 'business_payouts.json', jsonData, -1)
end

local function initializeBusinesses()
    for index, business in ipairs(Config.Businesses) do
        if not businesses[index] then
            businesses[index] = { owner = nil, job = nil }
        end
        
        -- Initialize business inventory if it doesn't exist
        if not businessInventories[tostring(index)] then
            businessInventories[tostring(index)] = {
                items = {},
                slots = Config.BusinessInventory.maxSlots,
                maxWeight = Config.BusinessInventory.maxWeight
            }
        end
        
        -- Initialize business payout data if it doesn't exist
        if not businessPayouts[tostring(index)] then
            businessPayouts[tostring(index)] = {
                lastPayout = 0,
                totalEarnings = 0,
                pendingPayout = 0,
                lastOnlineCheck = os.time(),
                onlineMinutes = 0
            }
        end
    end
    saveBusinesses()
    saveBusinessInventories()
    saveBusinessPayouts()
end

-- Function to count how many businesses a player owns
local function countPlayerBusinesses(citizenid)
    local count = 0
    for index, data in pairs(businesses) do
        if data.owner == citizenid then
            count = count + 1
        end
    end
    return count
end

-- Track online players
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        onlinePlayers[Player.PlayerData.citizenid] = true
        
        -- Update last online check for all businesses owned by this player
        for index, data in pairs(businesses) do
            if data.owner == Player.PlayerData.citizenid then
                local businessKey = tostring(index)
                if businessPayouts[businessKey] then
                    businessPayouts[businessKey].lastOnlineCheck = os.time()
                else
                    -- Initialize payout data if it doesn't exist
                    businessPayouts[businessKey] = {
                        lastPayout = 0,
                        totalEarnings = 0,
                        pendingPayout = 0,
                        lastOnlineCheck = os.time(),
                        onlineMinutes = 0
                    }
                end
            end
        end
        saveBusinessPayouts()
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        -- Update online minutes before player goes offline
        updateOnlineMinutes(Player.PlayerData.citizenid)
        onlinePlayers[Player.PlayerData.citizenid] = nil
    end
end)

-- Function to update online minutes for player's businesses
local function updateOnlineMinutes(citizenid)
    local currentTime = os.time()
    
    for index, data in pairs(businesses) do
        if data.owner == citizenid then
            local businessKey = tostring(index)
            if businessPayouts[businessKey] then
                local payoutData = businessPayouts[businessKey]
                local lastCheck = payoutData.lastOnlineCheck or os.time()
                local timeSinceLastCheck = currentTime - lastCheck
                local minutesOnline = math.floor(timeSinceLastCheck / 60)
                
                if minutesOnline > 0 then
                    payoutData.onlineMinutes = (payoutData.onlineMinutes or 0) + minutesOnline
                    payoutData.lastOnlineCheck = currentTime
                    ----print("[BUSINESS] Added " .. minutesOnline .. " online minutes to business " .. index .. " for player " .. citizenid)
                end
            else
                -- Initialize payout data if it doesn't exist
                businessPayouts[businessKey] = {
                    lastPayout = 0,
                    totalEarnings = 0,
                    pendingPayout = 0,
                    lastOnlineCheck = currentTime,
                    onlineMinutes = 0
                }
            end
        end
    end
    saveBusinessPayouts()
end

-- Periodically update online minutes for all online players
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        for citizenid, _ in pairs(onlinePlayers) do
            updateOnlineMinutes(citizenid)
        end
    end
end)

-- Send business data to client
local function sendBusinessDataToClient(source)
    TriggerClientEvent('business:client:updateBusinesses', source, businesses)
end

-- Function to add items to business inventory
local function addItemsToBusinessInventory(businessIndex, items)
    local businessKey = tostring(businessIndex)
    
    if not businessInventories[businessKey] then
        businessInventories[businessKey] = {
            items = {},
            slots = Config.BusinessInventory.maxSlots,
            maxWeight = Config.BusinessInventory.maxWeight
        }
    end

    local inventory = businessInventories[businessKey]
    local totalWeight = 0
    
    -- Calculate current inventory weight
    for _, item in pairs(inventory.items) do
        if item and item.weight and item.amount then
            totalWeight = totalWeight + (item.weight * item.amount)
        end
    end
    
    -- Add new items
    for _, newItem in ipairs(items) do
        local itemInfo = QBCore.Shared.Items[newItem.name]
        if itemInfo then
            local itemWeight = itemInfo.weight or 1
            local totalItemWeight = itemWeight * newItem.amount
            
            -- Check if there's enough space
            if (totalWeight + totalItemWeight) <= inventory.maxWeight then
                local existingItem = nil
                local existingIndex = nil
                
                for i, existing in ipairs(inventory.items) do
                    if existing and existing.name == newItem.name then
                        existingItem = existing
                        existingIndex = i
                        break
                    end
                end
                
                if existingItem then
                    existingItem.amount = existingItem.amount + newItem.amount
                else
                    table.insert(inventory.items, {
                        name = newItem.name,
                        amount = newItem.amount,
                        label = itemInfo.label or newItem.name,
                        weight = itemInfo.weight or 1,
                        description = itemInfo.description or "",
                        type = itemInfo.type or "item",
                        unique = itemInfo.unique or false,
                        useable = itemInfo.useable or false,
                        image = itemInfo.image or "placeholder.png"
                    })
                end
                
                totalWeight = totalWeight + totalItemWeight
            else
                return false, "Not enough space in business inventory"
            end
        else
            --print("[BUSINESS ERROR] Item not found in QBCore.Shared.Items: " .. tostring(newItem.name))
        end
    end
    
    saveBusinessInventories()
    return true, "Items added to business inventory"
end

-- Function to get business inventory
local function getBusinessInventory(businessIndex)
    local businessKey = tostring(businessIndex)
    return businessInventories[businessKey] or {
        items = {},
        slots = Config.BusinessInventory.maxSlots,
        maxWeight = Config.BusinessInventory.maxWeight
    }
end

-- Function to calculate business supplies percentage
local function calculateSuppliesPercentage(businessIndex)
    local businessKey = tostring(businessIndex)
    local inventory = getBusinessInventory(businessIndex)
    
    if not inventory or not inventory.items then
        return 0
    end
    
    local totalItems = 0
    local totalAmount = 0
    
    for _, item in pairs(inventory.items) do
        if item and item.amount then
            totalItems = totalItems + 1
            totalAmount = totalAmount + item.amount
        end
    end
    
    -- Calculate percentage based on item count and amounts
    if totalItems == 0 then
        return 0
    end
    
    -- Simple calculation: average of item amounts (assuming max 100 per item type)
    local averageAmount = totalAmount / totalItems
    local percentage = math.min(100, (averageAmount / 100) * 100)
    
    return math.floor(percentage)
end

-- Function to calculate payout amount based on supplies
local function calculatePayoutAmount(businessIndex)
    local suppliesPercentage = calculateSuppliesPercentage(businessIndex)
    
    -- No payout if supplies are below minimum threshold
    if suppliesPercentage < Config.Payout.minSupplies then
        return 0
    end
    
    -- Calculate payout based on supplies percentage
    local baseAmount = Config.Payout.baseAmount
    local maxAmount = Config.Payout.maxAmount
    local multiplier = Config.Payout.supplyMultiplier
    
    -- Higher supplies = higher payout
    local payoutMultiplier = (suppliesPercentage / 100) * multiplier
    local payoutAmount = baseAmount * payoutMultiplier
    
    -- Ensure payout doesn't exceed maximum
    payoutAmount = math.min(maxAmount, payoutAmount)
    
    return math.floor(payoutAmount)
end

-- Function to calculate accumulated payouts based on ONLINE TIME
local function calculateAccumulatedPayout(businessIndex)
    local businessKey = tostring(businessIndex)
    if not businessPayouts[businessKey] then
        return 0
    end
    
    local payoutData = businessPayouts[businessKey]
    local onlineMinutes = payoutData.onlineMinutes or 0
    
    -- Calculate how many payouts have accumulated based on online minutes
    local accumulatedPayouts = math.floor(onlineMinutes / Config.Payout.cooldown)
    
    if accumulatedPayouts <= 0 then
        return payoutData.pendingPayout or 0
    end
    
    -- Calculate total accumulated amount
    local totalAccumulated = payoutData.pendingPayout or 0
    for i = 1, accumulatedPayouts do
        local payoutAmount = calculatePayoutAmount(businessIndex)
        totalAccumulated = totalAccumulated + payoutAmount
    end
    
    return totalAccumulated
end

-- Function to consume supplies for payout
local function consumeSuppliesForPayout(businessIndex, payoutCount)
    local businessKey = tostring(businessIndex)
    local inventory = getBusinessInventory(businessIndex)
    
    if not inventory or not inventory.items then
        return false
    end
    
    -- Remove a small amount of each item (simulating business usage)
    for _, item in pairs(inventory.items) do
        if item and item.amount then
            local consumeAmount = math.max(1, math.floor(item.amount * 0.1 * payoutCount)) -- Consume 10% of each item per payout
            item.amount = math.max(0, item.amount - consumeAmount)
        end
    end
    
    -- Clean up items with 0 amount
    local newItems = {}
    for _, item in pairs(inventory.items) do
        if item and item.amount and item.amount > 0 then
            table.insert(newItems, item)
        end
    end
    
    inventory.items = newItems
    businessInventories[businessKey] = inventory
    saveBusinessInventories()
    
    return true
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        loadBusinesses()
        loadBusinessInventories()
        loadBusinessPayouts()
        initializeBusinesses()
        --print("[BUSINESS] Business system initialized")
        --print("[BUSINESS] Loaded " .. #Config.Businesses .. " businesses")
    end
end)

-- Event for clients to request business data
RegisterNetEvent('business:requestBusinessData', function()
    local src = source
    sendBusinessDataToClient(src)
end)

-- FIXED: Handle table parameter from qb-target
RegisterNetEvent('business:buyBusiness', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Extract index from data (qb-target sends a table)
    local index = type(data) == "table" and data.index or data
    
    -- Check if index is valid
    if not index or not Config.Businesses[index] then
        --print("[BUSINESS ERROR] Invalid business index: " .. tostring(index))
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "This business is not available", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'This business is not available', 1000, 'error', false)
        end
        return
    end
    
    local business = Config.Businesses[index]
    local money = Player.PlayerData.money[Config.PayOption]

    --print("[BUSINESS] Player " .. Player.PlayerData.citizenid .. " attempting to buy business: " .. business.BusinessName)

    -- NEW: Check if player already owns maximum businesses
    local ownedBusinesses = countPlayerBusinesses(Player.PlayerData.citizenid)
    if ownedBusinesses >= 2 then
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You already own the maximum of 2 businesses", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'You already own the maximum of 2 businesses', 1000, 'error', false)
        end
        return
    end

    if Config.RequireBusinessLicense then
        local hasLicense = false

        if Config.Inventory == "qb" then
            hasLicense = exports['qb-inventory']:HasItem(src, 'business_license', 1)
        elseif Config.Inventory == "ox" then
            hasLicense = Player.Functions.GetItemByName('business_license') and Player.Functions.GetItemByName('business_license').amount > 0
        end

        if not hasLicense then
            if Config.Notify == "qb" then
                TriggerClientEvent('QBCore:Notify', src, "You need a business license to purchase this", 'error')
            elseif Config.Notify == "okok" then
                TriggerClientEvent('okokNotify:Alert', src, 'Error', 'You need a business license to purchase this', 1000, 'error', false)
            else
                --print("There is no valid notify script enabled")
            end
            return
        end
    end

    if businesses[index] and businesses[index].owner == Player.PlayerData.citizenid then
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You already own this business", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'You already own this business', 1000, 'error', false)
        else
            --print("There is no valid notify script enabled")
        end
        return
    end

    if businesses[index] and businesses[index].owner ~= nil then
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "This business is already owned by someone else", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'This business is already owned by someone else', 1000, 'error', false)
        else
            --print("There is no valid notify script enabled")
        end
        return
    end

    if money >= business.BusinessPrice then
        if Config.PayOption == "cash" then
            Player.Functions.RemoveMoney('cash', business.BusinessPrice)
        elseif Config.PayOption == "bank" then
            Player.Functions.RemoveMoney('bank', business.BusinessPrice)
        else
            --print("Incorrect payment option selected")
            return 
        end
        
        Player.Functions.SetJob(business.BusinessJob, business.BusinessGrade)

        businesses[index] = {
            owner = Player.PlayerData.citizenid,
            job = business.BusinessJob
        }

        -- Initialize payout data for the new business
        local businessKey = tostring(index)
        businessPayouts[businessKey] = {
            lastPayout = 0,
            totalEarnings = 0,
            pendingPayout = 0,
            lastOnlineCheck = os.time(),
            onlineMinutes = 0
        }

        saveBusinesses() 
        saveBusinessPayouts()
        
        -- Update all clients about the business ownership change
        TriggerClientEvent('business:client:refreshBusinesses', -1)

        --print("[BUSINESS] Business purchased successfully: " .. business.BusinessName .. " by " .. Player.PlayerData.citizenid)
        --print("[BUSINESS] Player now owns " .. (ownedBusinesses + 1) .. "/2 businesses")

        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You have purchased the business and are now the owner of " .. business.BusinessName, 'success')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Success', "You have purchased the business and are now the owner of " .. business.BusinessName, 1000, 'success', false)
        else
            --print("There is no valid notify script enabled")
        end
    else
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You don't have enough money", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', "You don't have enough money", 1000, 'error', false)
        else
            --print("There is no valid notify script enabled")
        end
    end
end)

-- FIXED: Handle table parameter from qb-target
RegisterNetEvent('business:sellBusiness', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Extract index from data (qb-target sends a table)
    local index = type(data) == "table" and data.index or data
    
    -- Check if index is valid
    if not index or not Config.Businesses[index] then
        --print("[BUSINESS ERROR] Invalid business index: " .. tostring(index))
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "This business is not available", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'This business is not available', 1000, 'error', false)
        end
        return
    end
    
    local business = Config.Businesses[index]

    -- Check if the player owns the business
    if businesses[index] and businesses[index].owner == Player.PlayerData.citizenid then
        local refund = math.floor(business.BusinessPrice * (business.SellBackPercentage / 100))
        if Config.PayOption == "cash" then
            Player.Functions.AddMoney('cash', refund)
        elseif Config.PayOption == "bank" then
            Player.Functions.AddMoney('bank', refund)
        else
            --print("Incorrect payment option selected")
            return 
        end
        
        Player.Functions.SetJob('unemployed', 0)

        businesses[index] = { owner = nil, job = nil } 
        saveBusinesses()
        
        -- Clear business inventory when sold
        local businessKey = tostring(index)
        if businessInventories[businessKey] then
            businessInventories[businessKey].items = {}
            saveBusinessInventories()
        end
        
        -- Clear payout data when sold
        if businessPayouts[businessKey] then
            businessPayouts[businessKey] = {
                lastPayout = 0,
                totalEarnings = 0,
                pendingPayout = 0,
                lastOnlineCheck = os.time(),
                onlineMinutes = 0
            }
            saveBusinessPayouts()
        end
        
        -- Update all clients about the business ownership change
        TriggerClientEvent('business:client:refreshBusinesses', -1)
        
        --print("[BUSINESS] Business sold: " .. business.BusinessName .. " by " .. Player.PlayerData.citizenid)
        
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You have sold the business and received $" .. refund, 'success')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Success', "You have sold the business and received $" .. refund, 1000, 'success', false)
        else
            --print("There is no valid notify script enabled")
        end
    else
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You don't own this business", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', "You don't own this business", 1000, 'error', false)
        else
            --print("There is no valid notify script enabled")
        end
    end
end)

-- Event for purchasing business supplies
RegisterNetEvent('business:purchaseSupplies', function(businessIndex, supplyIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Check if index is valid
    if not businessIndex or not Config.Businesses[businessIndex] then
        --print("[BUSINESS ERROR] Invalid business index: " .. tostring(businessIndex))
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "This business is not available", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', 'This business is not available', 1000, 'error', false)
        end
        return
    end
    
    local business = Config.Businesses[businessIndex]
    
    -- Check if player owns the business
    if not businesses[businessIndex] or businesses[businessIndex].owner ~= Player.PlayerData.citizenid then
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You don't own this business", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', "You don't own this business", 1000, 'error', false)
        end
        return
    end
    
    -- Check if business has supplies configured
    if not business.Supplies or not business.Supplies[supplyIndex] then
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "This supply option is not available", 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', "This supply option is not available", 1000, 'error', false)
        end
        return
    end
    
    local supply = business.Supplies[supplyIndex]
    local money = Player.PlayerData.money[Config.PayOption]
    
    -- Check if player has enough money
    if money >= supply.price then
        -- Remove money from player
        Player.Functions.RemoveMoney(Config.PayOption, supply.price)
        
        -- Add items to business inventory
        local success, message = addItemsToBusinessInventory(businessIndex, supply.items)
        
        if success then
            -- Debug --print to verify items were added
            local businessKey = tostring(businessIndex)
            --print("[BUSINESS] Items added to business " .. businessKey .. " inventory: " .. json.encode(businessInventories[businessKey].items))
            
            if Config.Notify == "qb" then
                TriggerClientEvent('QBCore:Notify', src, "You purchased " .. supply.label .. " for $" .. supply.price .. " - Items added to business storage", 'success')
            elseif Config.Notify == "okok" then
                TriggerClientEvent('okokNotify:Alert', src, 'Success', "You purchased " .. supply.label .. " for $" .. supply.price .. " - Items added to business storage", 1000, 'success', false)
            end
        else
            -- Refund money if items couldn't be added
            Player.Functions.AddMoney(Config.PayOption, supply.price)
            if Config.Notify == "qb" then
                TriggerClientEvent('QBCore:Notify', src, message, 'error')
            elseif Config.Notify == "okok" then
                TriggerClientEvent('okokNotify:Alert', src, 'Error', message, 1000, 'error', false)
            end
        end
    else
        if Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, "You don't have enough money to purchase " .. supply.label, 'error')
        elseif Config.Notify == "okok" then
            TriggerClientEvent('okokNotify:Alert', src, 'Error', "You don't have enough money to purchase " .. supply.label, 1000, 'error', false)
        end
    end
end)

-- Callback to check payout status
QBCore.Functions.CreateCallback('business:checkPayoutStatus', function(source, cb, businessIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Check if player owns the business
    if not businesses[businessIndex] or businesses[businessIndex].owner ~= Player.PlayerData.citizenid then
        cb({success = false, message = "You don't own this business"})
        return
    end
    
    -- Check if payout system is enabled
    if not Config.Payout.enabled then
        cb({success = false, message = "Payout system is disabled"})
        return
    end
    
    -- Update online minutes before checking
    updateOnlineMinutes(Player.PlayerData.citizenid)
    
    -- Check supplies
    local suppliesPercentage = calculateSuppliesPercentage(businessIndex)
    
    if suppliesPercentage < Config.Payout.minSupplies then
        cb({success = false, message = "Not enough supplies (" .. suppliesPercentage .. "%). Minimum required: " .. Config.Payout.minSupplies .. "%"})
        return
    end
    
    -- Calculate accumulated payout
    local accumulatedPayout = calculateAccumulatedPayout(businessIndex)
    
    if accumulatedPayout <= 0 then
        cb({success = false, message = "No payout available yet. Stay online to accumulate payouts!"})
        return
    end
    
    local businessKey = tostring(businessIndex)
    local onlineMinutes = businessPayouts[businessKey].onlineMinutes or 0
    local minutesUntilNext = Config.Payout.cooldown - (onlineMinutes % Config.Payout.cooldown)
    
    cb({
        success = true, 
        message = "Accumulated Payout: $" .. accumulatedPayout .. " (Supplies: " .. suppliesPercentage .. "%) - Next payout in " .. minutesUntilNext .. " minutes"
    })
end)

-- Callback to collect payout
QBCore.Functions.CreateCallback('business:collectPayout', function(source, cb, businessIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Check if player owns the business
    if not businesses[businessIndex] or businesses[businessIndex].owner ~= Player.PlayerData.citizenid then
        cb({success = false, message = "You don't own this business"})
        return
    end
    
    -- Check if payout system is enabled
    if not Config.Payout.enabled then
        cb({success = false, message = "Payout system is disabled"})
        return
    end
    
    -- Update online minutes before collecting
    updateOnlineMinutes(Player.PlayerData.citizenid)
    
    -- Check supplies
    local suppliesPercentage = calculateSuppliesPercentage(businessIndex)
    
    if suppliesPercentage < Config.Payout.minSupplies then
        cb({success = false, message = "Not enough supplies (" .. suppliesPercentage .. "%). Minimum required: " .. Config.Payout.minSupplies .. "%"})
        return
    end
    
    -- Calculate accumulated payout
    local accumulatedPayout = calculateAccumulatedPayout(businessIndex)
    
    if accumulatedPayout <= 0 then
        cb({success = false, message = "No payout available yet. Stay online to accumulate payouts!"})
        return
    end
    
    -- Calculate how many payouts have accumulated
    local businessKey = tostring(businessIndex)
    local onlineMinutes = businessPayouts[businessKey].onlineMinutes or 0
    local accumulatedPayouts = math.floor(onlineMinutes / Config.Payout.cooldown)
    
    if accumulatedPayouts <= 0 then
        accumulatedPayouts = 1
    end
    
    -- Give payout to player
    Player.Functions.AddMoney(Config.PayOption, accumulatedPayout)
    
    -- Update payout data (reset online minutes used for this payout)
    local minutesUsed = accumulatedPayouts * Config.Payout.cooldown
    businessPayouts[businessKey].onlineMinutes = math.max(0, onlineMinutes - minutesUsed)
    businessPayouts[businessKey].totalEarnings = (businessPayouts[businessKey].totalEarnings or 0) + accumulatedPayout
    businessPayouts[businessKey].pendingPayout = 0
    saveBusinessPayouts()
    
    -- Consume supplies for all accumulated payouts
    consumeSuppliesForPayout(businessIndex, accumulatedPayouts)
    
    --print("[BUSINESS] Payout collected: $" .. accumulatedPayout .. " for business " .. businessIndex .. " by " .. Player.PlayerData.citizenid)
    --print("[BUSINESS] Online minutes used: " .. minutesUsed .. ", remaining: " .. businessPayouts[businessKey].onlineMinutes)
    
    cb({
        success = true, 
        message = "Payout collected: $" .. accumulatedPayout .. " (" .. accumulatedPayouts .. " payouts from " .. minutesUsed .. " online minutes)"
    })
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Send business data to client when player loads
    sendBusinessDataToClient(src)
        
    for index, data in pairs(businesses) do
        if data.owner == Player.PlayerData.citizenid then
            Player.Functions.SetJob(data.job, Config.Businesses[index].BusinessGrade)
        end
    end
end)