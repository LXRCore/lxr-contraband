--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚══════╝

    🐺 LXR Contraband System - Server Script
    server/server.lua

    ═══════════════════════════════════════════════════════════════════════════════
    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SELL EVENT ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

RegisterNetEvent('lxr-contraband:server:sell', function(data)
    local src    = source
    local Player = LXRFramework.GetPlayer(src)

    if not Player then
        if Config.Debug then
            print(('[lxr-contraband] ⚠ Could not find player for source: %s'):format(src))
        end
        return
    end

    if Player.RemoveItem(data.name, data.amount, data.slot) then
        Player.AddMoney('cash', data.amount * data.price, 'sold-contraband')
        TriggerClientEvent('inventory:client:ItemBox', src, data.name, 'remove')
    end
end)