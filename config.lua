Config = {}

Config.Target = "qb" -- Set to either "qb" or "ox"

Config.RequireBusinessLicense = false -- Set to true if a business license is required

Config.Inventory = "qb" -- Set to "qb" or "ox" based on your preference, only needed if RequireBusinessLicense = true

Config.Notify = "qb" -- currently supports: qb, okok

Config.PayOption = "bank" -- cash or bank

-- Business inventory settings
Config.BusinessInventory = {
    maxSlots = 50, -- Maximum slots in business inventory
    maxWeight = 100000, -- Maximum weight in business inventory (100kg)
}

-- Payout settings
Config.Payout = {
    enabled = true,
    cooldown = 30, -- minutes between payouts
    minSupplies = 10, -- minimum supplies percentage required for payout
    baseAmount = 5000, -- base payout amount
    maxAmount = 20000, -- maximum payout amount
    supplyMultiplier = 2.0, -- how much supplies affect payout
}

Config.Businesses = {
    {
        EnableBlip = false,
        BusinessName = "Davis Gas Station", 
        BusinessPrice = 50000,
        BusinessJob = "gasstation1",
        BusinessGrade = 4,
        PedCoords = vector4(646.5199, 267.4792, 103.2618, 71.9377),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(646.5199, 267.4792, 103.2618),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Davis Gas Station",
        SellBackPercentage = 75,
        PayoutRange = {min = 6000, max = 8500},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 2200,
                items = {
                    {name = "water_bottle", amount = 20},
                    {name = "sandwich", amount = 15},
                    {name = "phone", amount = 5},
                    {name = "lighter", amount = 10}
                }
            },
            {
                name = "snack_supplies",
                label = "Snack Supplies",
                price = 1800,
                items = {
                    {name = "chocolate", amount = 25},
                    {name = "chips", amount = 20},
                    {name = "candy", amount = 30}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Sandy Shores Gas Station", 
        BusinessPrice = 40000,
        BusinessJob = "gasstation2",
        BusinessGrade = 4,
        PedCoords = vector4(1201.6483, 2654.7000, 37.8519, 319.1374),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(1201.6483, 2654.7000, 37.8519),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Sandy Shores Gas",
        SellBackPercentage = 75,
        PayoutRange = {min = 5000, max = 7500},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 1800,
                items = {
                    {name = "water_bottle", amount = 15},
                    {name = "sandwich", amount = 10},
                    {name = "lighter", amount = 8},
                    {name = "repairkit", amount = 3}
                }
            },
            {
                name = "outdoor_supplies",
                label = "Outdoor Supplies",
                price = 2500,
                items = {
                    {name = "water_bottle", amount = 20},
                    {name = "bandage", amount = 10},
                    {name = "flashlight", amount = 5}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Grapeseed Gas Station", 
        BusinessPrice = 35000,
        BusinessJob = "gasstation3",
        BusinessGrade = 4,
        PedCoords = vector4(1764.1459, 3332.9822, 41.4360, 215.0683),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(1764.1459, 3332.9822, 41.4360),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Grapeseed Gas",
        SellBackPercentage = 75,
        PayoutRange = {min = 4500, max = 7000},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 1600,
                items = {
                    {name = "water_bottle", amount = 12},
                    {name = "sandwich", amount = 8},
                    {name = "lighter", amount = 6},
                    {name = "phone", amount = 3}
                }
            },
            {
                name = "farming_supplies",
                label = "Farming Supplies",
                price = 2200,
                items = {
                    {name = "water_bottle", amount = 15},
                    {name = "sandwich", amount = 10},
                    {name = "bandage", amount = 8}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Paleto Bay Gas Station", 
        BusinessPrice = 45000,
        BusinessJob = "gasstation4",
        BusinessGrade = 4,
        PedCoords = vector4(1995.2512, 3779.4243, 32.1808, 214.8863),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(1995.2512, 3779.4243, 32.1808),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Paleto Bay Gas",
        SellBackPercentage = 75,
        PayoutRange = {min = 5500, max = 8500},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 2000,
                items = {
                    {name = "water_bottle", amount = 18},
                    {name = "sandwich", amount = 12},
                    {name = "lighter", amount = 10},
                    {name = "phone", amount = 4}
                }
            },
            {
                name = "fishing_supplies",
                label = "Fishing Supplies",
                price = 2800,
                items = {
                    {name = "water_bottle", amount = 15},
                    {name = "sandwich", amount = 10},
                    {name = "fishingrod", amount = 3}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Legion Square ATM Business", 
        BusinessPrice = 80000,
        BusinessJob = "atmbusiness1",
        BusinessGrade = 4,
        PedCoords = vector4(296.4062, -895.2111, 29.2352, 75.1686),
        PedModel = "s_m_m_highsec_01",
        BlipCoords = vector3(296.4062, -895.2111, 29.2352),
        BlipSprite = 434,
        BlipColor = 2,
        BlipName = "ATM Business",
        SellBackPercentage = 75,
        PayoutRange = {min = 9000, max = 13000},
        Supplies = {
            {
                name = "atm_maintenance",
                label = "ATM Maintenance",
                price = 4000,
                items = {
                    {name = "electronickit", amount = 3},
                    {name = "trojan_usb", amount = 2},
                    {name = "security_card", amount = 5}
                }
            },
            {
                name = "office_supplies",
                label = "Office Supplies",
                price = 2500,
                items = {
                    {name = "phone", amount = 10},
                    {name = "laptop", amount = 2},
                    {name = "notepad", amount = 15}
                }
            }
        }
    },
    {
        EnableBlip = true,
        BusinessName = "Strawberry Garage", 
        BusinessPrice = 120000,
        BusinessJob = "garage1",
        BusinessGrade = 4,
        PedCoords = vector4(470.9339, -1282.8169, 29.5409, 273.8464),
        PedModel = "s_m_m_autoshop_01",
        BlipCoords = vector3(470.9339, -1282.8169, 29.5409),
        BlipSprite = 290,
        BlipColor = 3,
        BlipName = "Strawberry Garage",
        SellBackPercentage = 75,
        PayoutRange = {min = 12000, max = 20000},
        Supplies = {
            {
                name = "mechanic_supplies",
                label = "Mechanic Supplies",
                price = 5500,
                items = {
                    {name = "repairkit", amount = 5},
                    {name = "advancedrepairkit", amount = 2},
                    {name = "car_tool", amount = 10}
                }
            },
            {
                name = "car_parts",
                label = "Car Parts",
                price = 7500,
                items = {
                    {name = "car_engine", amount = 2},
                    {name = "car_transmission", amount = 2},
                    {name = "car_suspension", amount = 4}
                }
            }
        }
    },
    {
        EnableBlip = true,
        BusinessName = "Strawberry Garage 2", 
        BusinessPrice = 120000,
        BusinessJob = "garage2",
        BusinessGrade = 4,
        PedCoords = vector4(-200.7752, -1378.4285, 31.2582, 210.1535),
        PedModel = "s_m_m_autoshop_01",
        BlipCoords = vector3(-200.7752, -1378.4285, 31.2582),
        BlipSprite = 290,
        BlipColor = 3,
        BlipName = "Strawberry Garage 2",
        SellBackPercentage = 75,
        PayoutRange = {min = 12000, max = 20000},
        Supplies = {
            {
                name = "mechanic_supplies",
                label = "Mechanic Supplies",
                price = 5500,
                items = {
                    {name = "repairkit", amount = 5},
                    {name = "advancedrepairkit", amount = 2},
                    {name = "car_tool", amount = 10}
                }
            },
            {
                name = "car_parts",
                label = "Car Parts",
                price = 7500,
                items = {
                    {name = "car_engine", amount = 2},
                    {name = "car_transmission", amount = 2},
                    {name = "car_suspension", amount = 4}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Davis Gas & Service", 
        BusinessPrice = 90000,
        BusinessJob = "gasstation5",
        BusinessGrade = 4,
        PedCoords = vector4(289.5773, -1266.7827, 29.4408, 82.1149),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(289.5773, -1266.7827, 29.4408),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Davis Gas & Service",
        SellBackPercentage = 75,
        PayoutRange = {min = 10000, max = 15000},
        Supplies = {
            {
                name = "premium_gas_supplies",
                label = "Premium Gas Supplies",
                price = 3500,
                items = {
                    {name = "water_bottle", amount = 25},
                    {name = "sandwich", amount = 20},
                    {name = "phone", amount = 8},
                    {name = "lighter", amount = 15}
                }
            },
            {
                name = "car_care_supplies",
                label = "Car Care Supplies",
                price = 4500,
                items = {
                    {name = "repairkit", amount = 3},
                    {name = "car_cleaner", amount = 10},
                    {name = "car_wax", amount = 5}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Strawberry Gas Station", 
        BusinessPrice = 75000,
        BusinessJob = "gasstation6",
        BusinessGrade = 4,
        PedCoords = vector4(1210.8466, -1388.9408, 35.3769, 178.8161),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(1210.8466, -1388.9408, 35.3769),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Strawberry Gas",
        SellBackPercentage = 75,
        PayoutRange = {min = 8000, max = 12000},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 3200,
                items = {
                    {name = "water_bottle", amount = 22},
                    {name = "sandwich", amount = 18},
                    {name = "phone", amount = 6},
                    {name = "lighter", amount = 12}
                }
            },
            {
                name = "premium_snacks",
                label = "Premium Snacks",
                price = 2600,
                items = {
                    {name = "chocolate", amount = 30},
                    {name = "chips", amount = 25},
                    {name = "candy", amount = 35},
                    {name = "energy_drink", amount = 15}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Little Seoul Gas Station", 
        BusinessPrice = 250000,
        BusinessJob = "gasstation7",
        BusinessGrade = 4,
        PedCoords = vector4(-531.1439, -1221.3998, 18.4550, 332.8288),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(-531.1439, -1221.3998, 18.4550),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Little Seoul Gas Station",
        SellBackPercentage = 75,
        PayoutRange = {min = 10000, max = 15000},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 3200,
                items = {
                    {name = "water_bottle", amount = 22},
                    {name = "sandwich", amount = 18},
                    {name = "phone", amount = 6},
                    {name = "lighter", amount = 12}
                }
            },
            {
                name = "premium_snacks",
                label = "Premium Snacks",
                price = 2600,
                items = {
                    {name = "chocolate", amount = 30},
                    {name = "chips", amount = 25},
                    {name = "candy", amount = 35},
                    {name = "energy_drink", amount = 15}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Tatavian Mountians Gas Station", 
        BusinessPrice = 75000,
        BusinessJob = "gasstation8",
        BusinessGrade = 4,
        PedCoords = vector4(2559.0525, 373.6850, 108.6211, 264.3923),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(2559.0525, 373.6850, 108.6211),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Tatavian Mountians Gas Station",
        SellBackPercentage = 75,
        PayoutRange = {min = 5000, max = 7000},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 3200,
                items = {
                    {name = "water_bottle", amount = 22},
                    {name = "sandwich", amount = 18},
                    {name = "phone", amount = 6},
                    {name = "lighter", amount = 12}
                }
            },
            {
                name = "premium_snacks",
                label = "Premium Snacks",
                price = 2600,
                items = {
                    {name = "chocolate", amount = 30},
                    {name = "chips", amount = 25},
                    {name = "candy", amount = 35},
                    {name = "energy_drink", amount = 15}
                }
            }
        }
    },
    {
        EnableBlip = false,
        BusinessName = "Ron Alternates Gas Station", 
        BusinessPrice = 75000,
        BusinessJob = "gasstation9",
        BusinessGrade = 4,
        PedCoords = vector4(2548.9375, 2582.0667, 37.9590, 106.2817),
        PedModel = "s_m_m_autoshop_02",
        BlipCoords = vector3(2548.9375, 2582.0667, 37.9590),
        BlipSprite = 361,
        BlipColor = 5,
        BlipName = "Ron Alternates Gas Station",
        SellBackPercentage = 75,
        PayoutRange = {min = 5000, max = 7000},
        Supplies = {
            {
                name = "gas_station_supplies",
                label = "Gas Station Supplies",
                price = 3200,
                items = {
                    {name = "water_bottle", amount = 22},
                    {name = "sandwich", amount = 18},
                    {name = "phone", amount = 6},
                    {name = "lighter", amount = 12}
                }
            },
            {
                name = "premium_snacks",
                label = "Premium Snacks",
                price = 2600,
                items = {
                    {name = "chocolate", amount = 30},
                    {name = "chips", amount = 25},
                    {name = "candy", amount = 35},
                    {name = "energy_drink", amount = 15}
                }
            }
        }
    }
}
