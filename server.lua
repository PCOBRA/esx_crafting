ESX = exports['es_extended']:getSharedObject()

-- Hàm gửi webhook Discord
local function sendToDiscord(message)
    if Config.WebhookURL and Config.WebhookURL ~= 'YOUR_DISCORD_WEBHOOK_URL_HERE' then
        local embed = {
            {
                ["color"] = 16711680, -- Màu đỏ cho thất bại, xanh (65280) cho thành công
                ["title"] = "Crafting Log",
                ["description"] = message,
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                ["footer"] = {
                    ["text"] = "ESX Crafting System"
                }
            }
        }
        PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

ESX.RegisterServerCallback('esx_crafting:checkCops', function(source, cb)
    local copCount = 0
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job.name == Config.PoliceJob and xPlayer.job.onduty then
            copCount = copCount + 1
        end
    end
    cb(copCount >= Config.RequiredCops)
end)

local craftingPlayers = {}

RegisterServerEvent('esx_crafting:craftItem')
AddEventHandler('esx_crafting:craftItem', function(recipe, quantity)
    local source = source
    if not source then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local inventory = exports.ox_inventory
    local playerName = xPlayer.getName() or "Unknown"

    local currentCraftingCount = 0
    for _ in pairs(craftingPlayers) do
        currentCraftingCount = currentCraftingCount + 1
    end
    if currentCraftingCount >= Config.MaxCraftingPlayers then
        TriggerClientEvent('esx_crafting:notifyFailure', source, 'Đã có quá nhiều người đang điều chế tại bàn này! (Tối đa ' .. Config.MaxCraftingPlayers .. ')')
        sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") thất bại khi điều chế " .. recipe.label .. " x" .. quantity .. ": Quá nhiều người điều chế.")
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(playerCoords - Config.CraftingLocation)
    if distance > Config.MaxDistance then
        TriggerClientEvent('esx_crafting:notifyFailure', source, 'Bạn quá xa bàn điều chế!')
        sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") thất bại khi điều chế " .. recipe.label .. " x" .. quantity .. ": Quá xa bàn điều chế.")
        return
    end

    if quantity > Config.MaxQuantity then
        TriggerClientEvent('esx_crafting:notifyFailure', source, 'Số lượng vượt quá giới hạn tối đa (' .. Config.MaxQuantity .. ')!')
        sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") thất bại khi điều chế " .. recipe.label .. " x" .. quantity .. ": Số lượng vượt quá giới hạn.")
        return
    end

    local hasIngredients = true
    local missingItems = {}
    for item, data in pairs(recipe.ingredients) do
        local requiredAmount = data.amount * quantity
        local itemCount = inventory:Search(source, 'count', item) or 0
        if itemCount < requiredAmount then
            hasIngredients = false
            table.insert(missingItems, 'cần ' .. requiredAmount .. ' ' .. data.label)
        end
    end

    local canAddItem = inventory:CanCarryItem(source, recipe.result, quantity)
    if not canAddItem then
        TriggerClientEvent('esx_crafting:notifyFailure', source, 'Túi đồ của bạn không đủ chỗ!')
        sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") thất bại khi điều chế " .. recipe.label .. " x" .. quantity .. ": Túi đồ không đủ chỗ.")
        return
    end

    if hasIngredients then
        for item, data in pairs(recipe.ingredients) do
            inventory:RemoveItem(source, item, data.amount * quantity)
        end

        craftingPlayers[source] = true
        local resultItem = recipe.result
        local resultLabel = recipe.label

        TriggerClientEvent('esx_crafting:freezePlayer', source, recipe, quantity)

        local totalTime = recipe.time * quantity
        Citizen.Wait(totalTime)

        xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            craftingPlayers[source] = nil
            return
        end
        inventory = exports.ox_inventory

        if craftingPlayers[source] then
            local success = inventory:AddItem(source, resultItem, quantity)
            if success then
                TriggerClientEvent('esx_crafting:playSuccessSound', source)
                sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") đã điều chế thành công " .. resultLabel .. " x" .. quantity .. ".")
            end
        end

        craftingPlayers[source] = nil
    else
        local missingMessage = 'Bạn không đủ nguyên liệu: ' .. table.concat(missingItems, ', ')
        TriggerClientEvent('esx_crafting:notifyFailure', source, missingMessage)
        sendToDiscord("Người chơi " .. playerName .. " (ID: " .. source .. ") thất bại khi điều chế " .. recipe.label .. " x" .. quantity .. ": " .. missingMessage .. ".")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if craftingPlayers[source] then
        craftingPlayers[source] = nil
    end
end)
