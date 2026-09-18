--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CONTRABAND — Client: contacts, the contract note, the drop
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local C = LXRContraband
local N = Citizen.InvokeNative
local contacts, job, dropBlip = {}, nil, nil

local function toast(key, kind, vars) LXRCore.Notify(Lang:t(key, vars), kind or 'info') end
local function page(action, payload) SendNUIMessage({ action = action, payload = payload, brand = LXRCore.Brand, lang = Config.Lang, locale = Lang.bundle() }) end

local function clearJob()
    job = nil
    if dropBlip then RemoveBlip(dropBlip) dropBlip = nil end
    exports['lxr-interact']:Remove('lxr-contraband:drop')
    page('hide')
end

local function take(contact)
    local ok, res = LXR.RPC.Server('lxr-contraband:take', contact.id)
    if not ok then return toast('error.' .. tostring(res), 'error') end
    job = res
    dropBlip = N(0x554D9D53F696D002, 1664425300, res.coords.x, res.coords.y, res.coords.z)
    if dropBlip and dropBlip ~= 0 then N(0x74F74D3207ED525C, dropBlip, joaat('blip_ambient_treasure'), true) N(0x9CB1A1623062F402, dropBlip, Lang:t('ui.drop')) end
    exports['lxr-interact']:AddPoint('lxr-contraband:drop', vector3(res.coords.x, res.coords.y, res.coords.z), { label = Lang:t('ui.drop'), distance = Config.Security.dropRadius, options = {
        { label = Lang:t('ui.leave_goods'), key = 'J', onSelect = function()
            local ok2, r2, extra = LXR.RPC.Server('lxr-contraband:deliver')
            if not ok2 then return toast('error.' .. tostring(r2), 'error', { label = extra }) end
            toast('info.paid', 'success', { amount = ('%.2f'):format(r2.pay) })
            if r2.tipped then toast('info.tipped', 'warning') end
            clearJob()
        end },
    }})
    page('show', res)
end

RegisterNetEvent('lxr-contraband:client:expired', function() toast('error.expired', 'error') clearJob() end)
RegisterCommand('contract_drop', function() if job then TriggerServerEvent('lxr-contraband:server:drop') clearJob() end end, false)

local function spawnContact(c)
    local model = joaat(c.ped)
    if not IsModelValid(model) then return end
    RequestModel(model)
    local t = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < t do Wait(10) end
    if not HasModelLoaded(model) then return end
    local ped = CreatePed(model, c.coords.x, c.coords.y, c.coords.z - 1.0, c.heading or 0.0, false, false, false, false)
    N(0x283978A15512B2FE, ped, true)
    SetEntityInvincible(ped, true) SetBlockingOfNonTemporaryEvents(ped, true) FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(model)
    contacts[c.id] = ped
    exports['lxr-interact']:AddEntity('lxr-contraband:' .. c.id, ped, { label = c.label, distance = Config.Security.promptDistance, options = {
        { label = Lang:t('ui.ask_work'), key = 'J', canInteract = function() return job == nil end, onSelect = function() take(c) end },
        { label = Lang:t('ui.walk_away'), key = 'E', canInteract = function() return job ~= nil end, onSelect = function() TriggerServerEvent('lxr-contraband:server:drop') clearJob() end },
    }})
end
local function removeContact(c)
    local ped = contacts[c.id]
    if not ped then return end
    exports['lxr-interact']:Remove('lxr-contraband:' .. c.id)
    if DoesEntityExist(ped) then DeleteEntity(ped) end
    contacts[c.id] = nil
end

CreateThread(function()
    while GetResourceState('lxr-interact') ~= 'started' do Wait(1000) end
    while true do
        if LocalPlayer.state.isLoggedIn then
            local pos = GetEntityCoords(PlayerPedId())
            for _, c in ipairs(Config.Contacts) do
                local d = #(pos - c.coords)
                if d < 60.0 and not contacts[c.id] then spawnContact(c) elseif d > 80.0 and contacts[c.id] then removeContact(c) end
            end
        end
        Wait(2000)
    end
end)

RegisterNetEvent('lxr:client:unloaded', function() clearJob() for _, c in ipairs(Config.Contacts) do removeContact(c) end end)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then clearJob() for _, c in ipairs(Config.Contacts) do removeContact(c) end end end)
exports('HasContract', function() return job ~= nil end)
