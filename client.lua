ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.CraftingLocation)

        if distance < 3.0 then
            lib.showTextUI('[E] - Mở menu điều chế')
            if IsControlJustReleased(0, 38) then -- Phím E
                ESX.TriggerServerCallback('esx_crafting:checkCops', function(canCraft)
                    if canCraft then
                        OpenCraftingMenu()
                    else
                        lib.notify({
                            title = 'Không đủ cảnh sát!',
                            description = 'Cần ít nhất ' .. Config.RequiredCops .. ' cảnh sát đang làm nhiệm vụ.',
                            type = 'error',
                            position = 'center-left' -- Thay đổi vị trí
                        })
                    end
                end)
            end
        else
            lib.hideTextUI()
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
            title = 'Điều chế ' .. recipe.label,
            description = 'Nguyên liệu cho 1: ' .. ingredientsText,
            onSelect = function()
                local quantityOptions = {
                    { title = '1', onSelect = function() TriggerCraft(recipe, 1) end },
                    { title = '2', onSelect = function() TriggerCraft(recipe, 2) end },
                    { title = '5', onSelect = function() TriggerCraft(recipe, 5) end },
                    { title = '10', onSelect = function() TriggerCraft(recipe, 10) end }
                }
                lib.registerContext({
                    id = 'quantity_menu',
                    title = 'Chọn số lượng cho ' .. recipe.label,
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
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)

    lib.progressBar({
        duration = totalTime,
        label = 'Đang điều chế ' .. recipe.label .. ' (x' .. quantity .. ')',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            combat = true,
            mouse = true
        }
    })

    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    DisablePlayerFiring(PlayerId(), false)
    lib.notify({
        id = 'crafting_success',
        title = 'Thành công!',
        description = 'Bạn đã điều chế ' .. recipe.label .. ' (x' .. quantity .. ')',
        type = 'success',
        position = 'center-left' -- Thay đổi vị trí
    })
end)

RegisterNetEvent('esx_crafting:playSuccessSound')
AddEventHandler('esx_crafting:playSuccessSound', function()
    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', true)
end)

RegisterNetEvent('esx_crafting:notifyFailure')
AddEventHandler('esx_crafting:notifyFailure', function(message)
    lib.notify({
        id = 'crafting_failed',
        title = 'Thất bại!',
        description = message,
        type = 'error',
        position = 'center-left' -- Thay đổi vị trí
    })
end)
