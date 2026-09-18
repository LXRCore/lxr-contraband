<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# lxr-contraband — Running contracts, for LXRCore

A contact standing behind a fence hands out work: so many of an illegal
thing, to a dead drop out in the country, before the clock runs out. He
pays over the ledger because carrying it is the risk — a delivery can be
seen, and a seen delivery puts a call on the law's wire. There is no second
item list: whatever the core catalog marks illegal is what the contacts
ask for, priced from the catalog ledger.

![The contract note](docs/img/contract.png)

## What it does

* **Contacts** — peds at `Config.Contacts` (Emerald Station, Van Horn) with
  an **Ask for work** option through lxr-interact.
* **Contracts** — rolled from the illegal catalog: item, amount, a random
  dead drop, pay = ledger value × amount × `premium`, `minutes` to get there.
  One at a time, with a cooldown after each.
* **The note** — a small card on the LXR UI Kit with the goods, the drop
  and a countdown; a treasure blip marks the drop.
* **The drop** — **Leave the goods** at the drop takes the items and pays
  cash. With `Config.Risk.tipOff` odds (and, by default, only when law is on
  duty) a call goes out through lxr-dispatch with the drop's coordinates.
* **Events** — `lxr:contraband:taken`, `lxr:contraband:delivered`,
  `lxr:contraband:dropped`.

## Install

```cfg
ensure lxr-core
ensure lxr-interact
ensure lxr-dispatch   # optional: the tip-off
ensure lxr-contraband
```

## API

| Name | Side | Purpose |
|---|---|---|
| `HasContract(src)` | server | is this player running goods |
| `Goods()` | server | what the contacts may ask for |
| `HasContract()` | client | local mirror |

## Licence

© 2026 iBoss21 / LXRCore — All Rights Reserved. See `LICENSE`.
