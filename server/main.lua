--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CONTRABAND — Server: contracts, drops, the tip-off
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local C = LXRContraband
local RES = GetCurrentResourceName()
local contracts = {}   -- src → contract + deadline
local cooldown = {}
local buckets = {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function nearCoords(src, c, dist)
    local ped = GetPlayerPed(src)
    return ped ~= 0 and #(GetEntityCoords(ped) - vector3(c.x, c.y, c.z)) <= dist
end
local function lawOnDuty()
    for _, P in pairs(LXRCore.Players) do
        local def = LXRShared.Jobs[P.PlayerData.job.name]
        if def and (def.type == 'leo' or def.type == 'federal') and P.PlayerData.job.onduty then return true end
    end
    return false
end

LXR.RPC.Register('lxr-contraband:take', function(src, contactId)
    if limited(src) then return false, 'rate' end
    local P, contact = player(src), C.Contact(contactId)
    if not P or not contact then return false, 'invalid' end
    if not nearCoords(src, contact.coords, Config.Security.maxDistance) then return false, 'too_far' end
    if Config.Contracts.oneAtATime and contracts[src] then return false, 'already' end
    if GetGameTimer() - (cooldown[src] or 0) < Config.Contracts.cooldownMs then return false, 'cooldown' end
    local job = C.Roll()
    if not job then return false, 'invalid' end
    job.deadline = os.time() + job.minutes * 60
    contracts[src] = job
    LXRCore.Emit('lxr:contraband:taken', nil, src, job.item, job.amount, job.drop)
    return true, job
end)

LXR.RPC.Register('lxr-contraband:deliver', function(src)
    if limited(src) then return false, 'rate' end
    local P, job = player(src), contracts[src]
    if not P or not job then return false, 'no_contract' end
    if os.time() > job.deadline then contracts[src] = nil return false, 'expired' end
    if not nearCoords(src, job.coords, Config.Security.dropRadius) then return false, 'too_far' end
    if LXRCore.Inventory.GetItemCount(src, job.item) < job.amount then return false, 'short', job.label end
    if not P.Functions.RemoveItem(job.item, job.amount, nil, 'contraband:delivered') then return false, 'short', job.label end
    P.Functions.AddMoney('cash', job.pay, 'contraband:' .. job.item)
    contracts[src] = nil
    cooldown[src] = GetGameTimer()
    LXRCore.Emit('lxr:contraband:delivered', nil, src, job.item, job.amount, job.pay)
    if Config.Debug.log then LXRCore.Log.info('contraband', ('delivered %dx %s for $%.2f'):format(job.amount, job.item, job.pay), { source = src }) end
    local tipped = false
    if math.random() < Config.Risk.tipOff and GetResourceState('lxr-dispatch') == 'started' and (not Config.Risk.tipOffOnlyIfLawOnDuty or lawOnDuty()) then
        tipped = true
        exports['lxr-dispatch']:Raise({ kind = Config.Risk.tipOffKind, coords = vector3(job.coords.x, job.coords.y, job.coords.z), title = Lang:t('call.tipoff'), message = Lang:t('call.tipoff_msg', { place = job.drop }) })
    end
    return true, { pay = job.pay, tipped = tipped }
end)

RegisterNetEvent('lxr-contraband:server:drop', function()
    local src = source
    if limited(src) or not contracts[src] then return end
    contracts[src] = nil
    LXRCore.Emit('lxr:contraband:dropped', nil, src)
end)

CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for src, job in pairs(contracts) do
            if now > job.deadline then contracts[src] = nil TriggerClientEvent('lxr-contraband:client:expired', src) end
        end
    end
end)
AddEventHandler('playerDropped', function() contracts[source] = nil cooldown[source] = nil buckets[source] = nil end)
CreateThread(function() if Config.Debug.printBanner then print(('^1[lxr-contraband]^7 v%s — %d contacts, %d drops, %d goods'):format(GetResourceMetadata(RES, 'version', 0), #Config.Contacts, #Config.Drops, #C.Goods())) end end)

exports('HasContract', function(src) return contracts[src] ~= nil end)
exports('Goods', C.Goods)
