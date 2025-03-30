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
                            position = 'top'
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
        for item, amount in pairs(recipe.ingredients) do
            ingredientsText = ingredientsText .. item .. ': ' .. amount .. ' '
        end
        table.insert(options, {
            title = 'Điều chế ' .. recipe.result,
            description = 'Nguyên liệu cho 1: ' .. ingredientsText,
            onSelect = function()
                lib.inputDialog('Nhập số lượng', {
                    { 
                        type = 'number', 
                        label = 'Số lượng', 
                        description = 'Nhập số lượng muốn điều chế (tối đa ' .. Config.MaxQuantity .. ')', 
                        required = true, 
                        min = 1, 
                        max = Config.MaxQuantity 
                    }
                }, function(input)
                    if input then
                        local quantity = tonumber(input[1])
                        if quantity and quantity > 0 then
                            TriggerServerEvent('esx_crafting:craftItem', recipe, quantity)
                        else
                            lib.notify({
                                title = 'Lỗi!',
                                description = 'Số lượng không hợp lệ!',
                                type = 'error',
                                position = 'top'
                            })
                        end
                    end
                end)
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
        label = 'Đang điều chế ' .. recipe.result .. ' (x' .. quantity .. ')',
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
end)

RegisterNetEvent('esx_crafting:playSuccessSound')
AddEventHandler('esx_crafting:playSuccessSound', function()
    PlaySoundFrontend(-1, 'PURCHASE', 'HUD_LIQUOR_STORE_SOUNDSET', true)
end)