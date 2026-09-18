--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CONTRABAND — Offline tests: goods from the catalog, pay, contract roll, locale parity
     Usage (from the lxr-contraband folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE) os.exit(2) end
local Shim = require('tests.lib.fxshim')
for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/catalog.lua', 'shared/items.lua', 'shared/prices.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil Locale = nil
Shim.load('shared/locale.lua') Shim.load('locales/en.lua') Shim.load('locales/ka.lua') Shim.load('config.lua') Shim.load('shared/rules.lua')
local C = LXRContraband

local passed, failed = 0, 0
local function test(name, fn) local okT, err = xpcall(fn, debug.traceback) if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-contraband offline tests')
test('goods are illegal catalog items with a ledger value', function()
    local goods = C.Goods()
    assert(#goods >= 5, 'expected at least five kinds of goods, got ' .. #goods)
    for _, n in ipairs(goods) do
        local def = LXRShared.Items[n]
        assert(def and def.legal == false, n .. ' must be illegal')
        assert(LXRShared.ItemValue(n) > 0, n .. ' must have a price')
        for _, x in ipairs(Config.Contracts.exclude) do assert(x ~= n, n .. ' is excluded') end
    end
end)
test('pay is ledger × amount × premium', function()
    local n = C.Goods()[1]
    eq(C.Pay(n, 4), math.floor(LXRShared.ItemValue(n) * 4 * Config.Contracts.premium * 100 + 0.5) / 100)
    assert(C.Pay(n, 4) > LXRShared.ItemValue(n) * 4, 'the fence pays over the ledger')
end)
test('a rolled contract is complete and deterministic under an injected rng', function()
    local job = C.Roll(function(n) return 1 end)
    assert(job, 'roll')
    eq(job.item, C.Goods()[1]) eq(job.amount, Config.Contracts.amount.min) eq(job.drop, Config.Drops[1].label) eq(job.minutes, Config.Contracts.minutes)
    assert(job.coords.x and job.pay > 0 and job.label)
    local hi = C.Roll(function(n) return n end)
    eq(hi.amount, Config.Contracts.amount.max) eq(hi.drop, Config.Drops[#Config.Drops].label)
end)
test('contacts resolve by id; drops carry coords', function()
    for _, c in ipairs(Config.Contacts) do assert(C.Contact(c.id) == c) assert(c.ped and c.coords) end
    assert(C.Contact('nobody') == nil)
    for _, d in ipairs(Config.Drops) do assert(d.label and d.coords) end
    assert(Config.Risk.tipOff >= 0 and Config.Risk.tipOff <= 1)
end)
test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)
print(('%d passed, %d failed'):format(passed, failed))
if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local job = C.Roll(function(n) return math.max(1, math.floor(n / 2)) end)
    job.deadline = os.time() + 14 * 60 + 37
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode({ action = 'show', payload = job, lang = Config.Lang, locale = Lang.bundle(), brand = { name = 'The Land of Wolves', theme = 'night' } }) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
