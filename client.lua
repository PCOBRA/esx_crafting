ESX = exports['es_extended']:getSharedObject()
local isNearCrafting = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.CraftingLocation)

        if distance < 3.0 then
            if not isNearCrafting then
                lib.showTextUI('[E] - Điều Chế')
                isNearCrafting = true
            end
            if IsControlJustReleased(0, 38) then -- Phím E
                ESX.TriggerServerCallback('esx_crafting:checkCops', function(canCraft)
                    if canCraft then
                        OpenCraftingMenu()
                    else
                        lib.notify({
                            title = 'Không Đủ FNPD!',
                            description = 'Cần ít nhất ' .. Config.RequiredCops .. ' cảnh sát đang làm nhiệm vụ.',
                            type = 'error',
                            position = 'center-left'
                        })
                    end
                end)
            end
        elseif isNearCrafting then
            lib.hideTextUI()
            isNearCrafting = false
        end
    end
end)

function OpenCraftingMenu()
    local options = {}
    for _, recipe in ipairs(Config.CraftingRecipes) do
        local ingredientsText = ''
        for item, data in pairs(recipe.ingredients) do
            ingredientsText = ingredientsText .. data.label .. ': ' .. data.amount .. ' '
        end
        table.insert(options, {
            title = 'Điều Chế ' .. recipe.label,
            description = 'Nguyên liệu cần 1x: ' .. ingredientsText,
            onSelect = function()
                local quantityOptions = {
                    { title = '1', onSelect = function() TriggerCraft(recipe, 1) end },
                    { title = '2', onSelect = function() TriggerCraft(recipe, 2) end },
                    { title = '5', onSelect = function() TriggerCraft(recipe, 5) end },
                    { title = '10', onSelect = function() TriggerCraft(recipe, 10) end }
                }
                lib.registerContext({
                    id = 'quantity_menu',
                    title = 'Số Lượng ' .. recipe.label,
                    options = quantityOptions
                })
                lib.showContext('quantity_menu')
            end
        })
    end

    lib.registerContext({
        id = 'crafting_menu',
        title = 'Menu Điều Chế',
        options = options
    })
    lib.showContext('crafting_menu')
end

function TriggerCraft(recipe, quantity)
    TriggerServerEvent('esx_crafting:craftItem', recipe, quantity)
end

RegisterNetEvent('esx_crafting:freezePlayer')
AddEventHandler('esx_crafting:freezePlayer', function(recipe, quantity)
    local ped = PlayerPedId()
    local totalTime = recipe.time * quantity
    FreezeEntityPosition(ped, true)
    DisablePlayerFiring(PlayerId(), true)
    DisableControlAction(0, 24, true) -- Tấn công
    DisableControlAction(0, 25, true) -- Ngắm
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)

    local success = exports['ox_lib']:progressBar({
        duration = totalTime,
        label = 'Đang Điều Chế ' .. recipe.label .. ' (x' .. quantity .. ')',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            combat = true,
            mouse = false -- Không khóa chuột
        }
    })

    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    DisablePlayerFiring(PlayerId(), false)
    EnableControlAction(0, 24, true)
    EnableControlAction(0, 25, true)
    if success then
        lib.notify({
            id = 'crafting_success',
            title = 'Thành Công!',
            description = 'Bạn đã điều chế ' .. recipe.label .. ' (x' .. quantity .. ')',
            type = 'success',
            position = 'center-left'
        })
    end
end)

RegisterNetEvent('esx_crafting:playSuccessSound')
AddEventHandler('esx_crafting:playSuccessSound', function()
    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', true)
end)

RegisterNetEvent('esx_crafting:notifyFailure')
AddEventHandler('esx_crafting:notifyFailure', function(message)
    lib.notify({
        id = 'crafting_failed',
        title = 'Thất Bại!',
        description = message,
        type = 'error',
        position = 'center-left'
    })
end)
