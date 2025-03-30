ESX = exports['es_extended']:getSharedObject()

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
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventory = exports.ox_inventory

    -- Kiểm tra số người đang điều chế
    local currentCraftingCount = 0
    for _ in pairs(craftingPlayers) do
        currentCraftingCount = currentCraftingCount + 1
    end
    if currentCraftingCount >= Config.MaxCraftingPlayers then
        lib.notify({
            id = 'crafting_failed',
            title = 'Thất bại!',
            description = 'Đã có quá nhiều người đang điều chế tại bàn này! (Tối đa ' .. Config.MaxCraftingPlayers .. ')',
            type = 'error',
            position = 'top'
        }, xPlayer.source)
        return
    end

    -- Kiểm tra khoảng cách trước khi bắt đầu
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(playerCoords - Config.CraftingLocation)
    if distance > Config.MaxDistance then
        lib.notify({
            id = 'crafting_failed',
            title = 'Thất bại!',
            description = 'Bạn quá xa bàn điều chế!',
            type = 'error',
            position = 'top'
        }, xPlayer.source)
        return
    end

    -- Kiểm tra số lượng không vượt quá giới hạn
    if quantity > Config.MaxQuantity then
        lib.notify({
            id = 'crafting_failed',
            title = 'Thất bại!',
            description = 'Số lượng vượt quá giới hạn tối đa (' .. Config.MaxQuantity .. ')!',
            type = 'error',
            position = 'top'
        }, xPlayer.source)
        return
    end

    -- Kiểm tra nguyên liệu dựa trên số lượng
    local hasIngredients = true
    for item, amount in pairs(recipe.ingredients) do
        local requiredAmount = amount * quantity
        local itemCount = inventory:Search(xPlayer.source, 'count', item) or 0
        if itemCount < requiredAmount then
            hasIngredients = false
            break
        end
    end

    -- Kiểm tra trọng lượng kho đồ dựa trên số lượng
    local canAddItem = inventory:CanCarryItem(xPlayer.source, recipe.result, quantity)
    if not canAddItem then
        lib.notify({
            id = 'crafting_failed',
            title = 'Thất bại!',
            description = 'Túi đồ của bạn không đủ chỗ!',
            type = 'error',
            position = 'top'
        }, xPlayer.source)
        return
    end

    if hasIngredients then
        -- Xóa nguyên liệu dựa trên số lượng
        for item, amount in pairs(recipe.ingredients) do
            inventory:RemoveItem(xPlayer.source, item, amount * quantity)
        end

        craftingPlayers[source] = true

        TriggerClientEvent('esx_crafting:freezePlayer', xPlayer.source, recipe, quantity)

        local totalTime = recipe.time * quantity
        Citizen.Wait(totalTime)

        if craftingPlayers[source] then
            inventory:AddItem(xPlayer.source, recipe.result, quantity)
            lib.notify({
                id = 'crafting_success',
                title = 'Thành công!',
                description = 'Bạn đã điều chế ' .. recipe.result .. ' (x' .. quantity .. ')',
                type = 'success',
                position = 'top'
            }, xPlayer.source)
            TriggerClientEvent('esx_crafting:playSuccessSound', xPlayer.source)
        end

        craftingPlayers[source] = nil
    else
        lib.notify({
            id = 'crafting_failed',
            title = 'Thất bại!',
            description = 'Bạn không đủ nguyên liệu',
            type = 'error',
            position = 'top'
        }, xPlayer.source)
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if craftingPlayers[source] then
        craftingPlayers[source] = nil
    end
end)