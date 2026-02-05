# smq_vehiclekey 🔑
---
## 🛠️ Dependencies
To ensure the script works correctly, the following resources are required:
* **ox_lib**: Used for notifications, keybinds, and animation requests.
* **ox_inventory**: Required for handling keys as items with metadata.
* **es_extended**: Built for the ESX Framework.
* **oxmysql**: Required for verifying vehicle ownership in the database.

---

## 📦 Item Setup
Add the following item to your `ox_inventory/data/items.lua`:

```lua
['vehicle_key'] = {
    label = 'Vehicle Key',
    weight = 10,
    stack = false,
    close = true,
    description = 'A key used to control a specific vehicle.'
},

## 🔗 Server-side Export for other resources:
    exports.smq_vehiclekey:GiveKey(source, plate)

🚀 Features
Highly Optimized: Runs at 0.00ms on idle; uses native keybinds instead of intensive loops.

Metadata System: Each key is uniquely bound to a specific license plate.

Garage Integration: Compatible with cd_garage to automatically give or remove keys.

Visual Effects: Includes key fob click animation and vehicle light flashing upon (un)locking.

🔗 Links & Support
Discord: https://discord.gg/z7x6dD3yXm

GitHub: https://github.com/smqscripts/smq_vehiclekey

Video: Preview: https://www.youtube.com/watch?v=2VFBPLvbceU


