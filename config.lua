--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  █████╗ ██████╗  █████╗ ███╗   ██╗██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝███████║██████╔╝███████║██╔██╗ ██║██║  ██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██╔══██╗██╔══██║██║╚██╗██║██║  ██║
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║██████╔╝██║  ██║██║ ╚████║██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝

    🐺 LXR Contraband System

    This configuration file controls the contraband selling system for RedM.
    Players can sell contraband items to NPCs for dynamic prices.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    Server:      https://servers.redm.net/servers/detail/8gj7eb

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.0.0
    Performance Target: Optimized for minimal server overhead and client FPS impact

    Framework Support:
    - LXR Core (Primary)
    - RSG Core (Primary)
    - VORP Core (Supported / Legacy)
    - Standalone (Fallback)

    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════

    Script Author: iBoss21 / The Lux Empire for The Land of Wolves

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-contraband"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[

        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════

        Expected: %s
        Got: %s

        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.

        🐺 wolves.land - The Land of Wolves

        ═══════════════════════════════════════════════════════════════════════════════

    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name      = 'The Land of Wolves 🐺',
    tagline   = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    developer = 'iBoss21 / The Lux Empire',
    website   = 'https://www.wolves.land',
    discord   = 'https://discord.gg/CrKcWdfd3A',
    github    = 'https://github.com/iBoss21',
    store     = 'https://theluxempire.tebex.io',
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core  (Primary)
    2. RSG-Core  (Primary)
    3. VORP Core (Supported / Legacy)
    4. Standalone (Fallback)

    Set to 'auto' to let the resource detect the framework automatically,
    or set manually to one of: 'lxr-core', 'rsg-core', 'vorp_core', 'standalone'
]]
Config.Framework = 'auto'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONTRABAND CONFIGURATION ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Set to true to only check slots 1-5 for contraband items to sell.
Config.QuickSlots = false

Config.Contraband = {
    ['apple_moonshine']    = { min = 0.5,  max = 0.9 },
    ['cider_moonshine']    = { min = 0.3,  max = 0.5 },
    ['tropical_moonshine'] = { min = 0.1,  max = 0.3 },
    ['tobacco']            = { min = 0.05, max = 0.1 },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Debug = false -- Enable debug prints and extra logging

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF CONFIGURATION ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Startup banner
CreateThread(function()
    Wait(1000)
    print([[

        ═══════════════════════════════════════════════════════════════════════════════

            ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
            ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
            ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
            ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
            ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
            ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

        ═══════════════════════════════════════════════════════════════════════════════
        🐺 CONTRABAND SYSTEM - SUCCESSFULLY LOADED
        ═══════════════════════════════════════════════════════════════════════════════

        Version:   1.0.0
        Server:    The Land of Wolves 🐺

        Framework: Auto-detect enabled
        Debug:     ]] .. (Config.Debug and 'ENABLED' or 'DISABLED') .. [[

        ═══════════════════════════════════════════════════════════════════════════════

        Developer: iBoss21 / The Lux Empire
        Website:   https://www.wolves.land
        Discord:   https://discord.gg/CrKcWdfd3A

        ═══════════════════════════════════════════════════════════════════════════════

    ]])
end)