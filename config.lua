--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  █████╗ ██████╗  █████╗ ███╗   ██╗██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔══██╗
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝███████║██████╔╝███████║██╔██╗ ██║██║  ██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██╔══██╗██╔══██║██║╚██╗██║██║  ██║
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║██████╔╝██║  ██║██║ ╚████║██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝

    LXR Core - Contraband

    The trade nobody admits to. A contact at a fence hands out running
    contracts — so many of an illegal thing to a dead drop out in the
    country before the clock runs out — and pays over the ledger for the
    risk. Carrying it is the risk: a tip-off at the drop can put the law on
    the wire, and the law seizes what it finds. Everything illegal in the
    core catalog qualifies; nothing here is a second list.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (interact points; one 30 s expiry tick on the server)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONTACTS ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Contacts = {
    { id = 'emerald', label = 'The man behind Emerald Station', coords = vector3(1524.10, 442.30, 90.68), heading = 220.0, ped = 'u_m_m_emrfarmhand_01' },
    { id = 'vanhorn', label = 'The Van Horn dock hand', coords = vector3(2975.20, 520.60, 44.80), heading = 300.0, ped = 'u_m_m_vhtbartender_01' },
}

-- dead drops the contracts send runners to (a random one each time)
Config.Drops = {
    { label = 'the burnt cabin north of Valentine', coords = vector3(-215.30, 1148.20, 152.40) },
    { label = 'the hollow oak by Flatneck Station', coords = vector3(-330.60, -285.10, 89.90) },
    { label = 'the old mill on Kamassa', coords = vector3(1965.40, -1100.30, 41.60) },
    { label = 'the boathouse at Lagras', coords = vector3(2089.10, -616.40, 42.10) },
    { label = 'the ruined chapel near Rhodes', coords = vector3(1156.40, -1585.90, 71.20) },
    { label = 'the coal chute at Annesburg', coords = vector3(2840.60, 1400.20, 78.10) },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CONTRACTS ═════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Contracts = {
    -- what the contacts ask for: illegal catalog items (legal = false) in these categories; quantity range; pay over the ledger
    categories = { 'contraband', 'alcohol', 'material', 'ammo' },
    exclude = { 'bank_bag', 'strongbox', 'mail_bag', 'counterfeit_plate', 'still_kit', 'blood_dollar' },
    amount = { min = 6, max = 20 },
    premium = 2.0,               -- × ledger value: the fence pays for the risk
    minutes = 20,                -- to reach the drop
    cooldownMs = 600000,         -- per runner between contracts
    oneAtATime = true,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE RISK ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Risk = {
    tipOff = 0.25,               -- chance a delivery raises a call to the law (lxr-dispatch)
    tipOffKind = 'lawcall',
    tipOffOnlyIfLawOnDuty = true,
}

Config.Security = { rateLimit = { windowMs = 2000, burst = 6 }, maxDistance = 4.0, promptDistance = 2.5, dropRadius = 6.0 }
Config.Debug = { printBanner = true, log = true }
