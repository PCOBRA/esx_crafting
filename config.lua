Config = {}

Config.CraftingRecipes = {
    {
        result = 'bread',
        label = 'Bánh mì',
        ingredients = {
            ['gotap'] = { amount = 2, label = 'Gạo tấp' },
            ['water'] = { amount = 1, label = 'Nước' }
        },
        time = 5000
    },
    {
        result = 'weapon_pistol',
        label = 'Súng ngắn',
        ingredients = {
            ['metalscrap'] = { amount = 10, label = 'Phế liệu kim loại' },
            ['gunpowder'] = { amount = 5, label = 'Thuốc súng' }
        },
        time = 10000
    }
}

Config.CraftingLocation = vector3(2588.76, 4849.24, 34.96)
Config.RequiredCops = 0
Config.PoliceJob = 'police'
Config.MaxDistance = 3.0
Config.MaxQuantity = 10
Config.MaxCraftingPlayers = 3
Config.WebhookURL = 'YOUR_DISCORD_WEBHOOK_URL_HERE' -- Thay bằng URL webhook Discord của bạn
