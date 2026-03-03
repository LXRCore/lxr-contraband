--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚══════╝

    🐺 LXR Contraband System - Framework Bridge
    shared/framework.lua

    ═══════════════════════════════════════════════════════════════════════════════
    Multi-framework detection and unified API bridge.

    Supported Frameworks:
      1. LXR-Core  (Primary)      — resource: lxr-core
      2. RSG-Core  (Primary)      — resource: rsg-core
      3. VORP Core (Legacy)       — resource: vorp_core
      4. Standalone (Fallback)

    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK DETECTION ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    LXRFramework is a shared table populated differently on client vs server:

    CLIENT:
        LXRFramework.Name       -- detected framework name (string)
        LXRFramework.Core       -- raw core export object (when applicable)

    SERVER:
        LXRFramework.Name       -- detected framework name (string)
        LXRFramework.Core       -- raw core export object (when applicable)
        LXRFramework.GetPlayer  -- function(src) -> unified player object
            .RemoveItem(name, amount, slot) -> bool
            .AddMoney(account, amount, reason)
            .GetInventory(slots) -> table
]]

LXRFramework = {}

local function detectFramework()
    local fw = Config.Framework

    -- Auto-detection: probe active resources
    if fw == 'auto' then
        if GetResourceState('lxr-core') == 'started' then
            fw = 'lxr-core'
        elseif GetResourceState('rsg-core') == 'started' then
            fw = 'rsg-core'
        elseif GetResourceState('vorp_core') == 'started' then
            fw = 'vorp_core'
        else
            fw = 'standalone'
        end
    end

    LXRFramework.Name = fw

    if Config.Debug then
        print(('[lxr-contraband] 🐺 Framework detected: %s'):format(fw))
    end
end

detectFramework()

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER-SIDE BRIDGE ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

if IsDuplicityVersion() then -- server context

    -- ── LXR-Core ──────────────────────────────────────────────────────────────
    if LXRFramework.Name == 'lxr-core' then
        LXRFramework.Core = exports['lxr-core']

        ---Returns a unified player wrapper for lxr-core.
        ---@param src number  server source
        LXRFramework.GetPlayer = function(src)
            local Player = LXRFramework.Core:GetPlayer(src)
            if not Player then return nil end

            return {
                ---Remove an item from the player's inventory.
                ---@param name string  item name
                ---@param amount number
                ---@param slot number|nil
                ---@return boolean
                RemoveItem = function(name, amount, slot)
                    return Player.Functions.RemoveItem(name, amount, slot)
                end,

                ---Add money to the player.
                ---@param account string  e.g. 'cash'
                ---@param amount number
                ---@param reason string|nil
                AddMoney = function(account, amount, reason)
                    Player.Functions.AddMoney(account, amount, reason)
                end,

                ---Get inventory slot data.
                ---@param from number  start slot
                ---@param to number    end slot
                ---@return table
                GetInventory = function(from, to)
                    return exports['lxr-inventory']:GetSlotData(from, to)
                end,
            }
        end

    -- ── RSG-Core ───────────────────────────────────────────────────────────────
    elseif LXRFramework.Name == 'rsg-core' then
        LXRFramework.Core = exports['rsg-core']

        LXRFramework.GetPlayer = function(src)
            local Player = LXRFramework.Core:GetPlayer(src)
            if not Player then return nil end

            return {
                RemoveItem = function(name, amount, slot)
                    return Player.Functions.RemoveItem(name, amount, slot)
                end,

                AddMoney = function(account, amount, reason)
                    Player.Functions.AddMoney(account, amount, reason)
                end,

                GetInventory = function(from, to)
                    return exports['rsg-inventory']:GetSlotData(from, to)
                end,
            }
        end

    -- ── VORP Core ──────────────────────────────────────────────────────────────
    elseif LXRFramework.Name == 'vorp_core' then
        local VORPcore  = nil
        local VORPinv   = nil

        -- VORP uses a callback-based bootstrap pattern
        TriggerEvent('getCore', function(obj) VORPcore = obj end)
        TriggerEvent('vorpInventory:getInventory', function(obj) VORPinv = obj end)

        LXRFramework.GetPlayer = function(src)
            if not VORPcore then return nil end
            local character = VORPcore.getUser(src).getUsedCharacter()

            return {
                RemoveItem = function(name, amount, _slot)
                    if VORPinv then
                        VORPinv.subItem(src, name, amount)
                        return true
                    end
                    return false
                end,

                AddMoney = function(_account, amount, _reason)
                    character.addCurrency(0, amount) -- 0 = cash in VORP
                end,

                GetInventory = function(from, to)
                    -- VORP does not expose a direct slot-range API;
                    -- return an empty table so callers degrade gracefully.
                    return {}
                end,
            }
        end

    -- ── Standalone (fallback) ─────────────────────────────────────────────────
    else
        LXRFramework.GetPlayer = function(_src)
            return nil
        end
    end

end -- end server context
