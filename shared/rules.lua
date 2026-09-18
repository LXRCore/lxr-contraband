--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CONTRABAND — Shared rules: what qualifies, what it pays
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRContraband = LXRContraband or {}
local C = LXRContraband

local function has(list, v) for _, x in ipairs(list or {}) do if x == v then return true end end return false end

---Every catalog item a contact may ask for.
function C.Goods()
    local out = {}
    for name, def in pairs(LXRShared.Items) do
        if def.legal == false and has(Config.Contracts.categories, def.category) and not has(Config.Contracts.exclude, name) and (tonumber(def.value) or 0) > 0 then out[#out + 1] = name end
    end
    table.sort(out)
    return out
end

---Pay for a contract line.
function C.Pay(name, amount)
    return math.floor(LXRShared.ItemValue(name) * amount * Config.Contracts.premium * 100 + 0.5) / 100
end

---Roll a contract with an injectable rng (1..n).
function C.Roll(rnd)
    rnd = rnd or math.random
    local goods = C.Goods()
    if #goods == 0 or #Config.Drops == 0 then return nil end
    local name = goods[rnd(#goods)]
    local amount = Config.Contracts.amount.min + rnd(Config.Contracts.amount.max - Config.Contracts.amount.min + 1) - 1
    local drop = Config.Drops[rnd(#Config.Drops)]
    return { item = name, label = LXRShared.Items[name].label, amount = amount, drop = drop.label, coords = { x = drop.coords.x, y = drop.coords.y, z = drop.coords.z }, pay = C.Pay(name, amount), minutes = Config.Contracts.minutes }
end

function C.Contact(id) for _, c in ipairs(Config.Contacts) do if c.id == id then return c end end end
