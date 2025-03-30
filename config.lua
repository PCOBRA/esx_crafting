Config = {}

Config.CraftingRecipes = {
    {
        result = 'bread',
        ingredients = {
            ['wheat'] = 2,
            ['water'] = 1
        },
        time = 5000 -- Thời gian điều chế cho 1 vật phẩm
    },
    {
        result = 'weapon_pistol',
        ingredients = {
            ['metalscrap'] = 10,
            ['gunpowder'] = 5
        },
        time = 10000 -- Thời gian điều chế cho 1 vật phẩm
    }
}

Config.CraftingLocation = vector3(100.0, 200.0, 30.0)
Config.RequiredCops = 2
Config.PoliceJob = 'police'
Config.MaxDistance = 3.0
Config.MaxQuantity = 10 -- Giới hạn tối đa số lượng vật phẩm mỗi lần
Config.MaxCraftingPlayers = 3 -- Giới hạn tối đa số người điều chế cùng lúc