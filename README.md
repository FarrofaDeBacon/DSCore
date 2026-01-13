# 🤠 Double Sync Framework

<div align="center">
  <h3>A Modern RedM Framework for Roleplay Servers</h3>
  <p>Build your Wild West dream server with ease</p>
  
  ![Version](https://img.shields.io/badge/version-1.0.0-blue)
  ![License](https://img.shields.io/badge/license-GPL--3.0-green)
  ![RedM](https://img.shields.io/badge/platform-RedM-red)
</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎮 **Multi-Character** | Create up to 3 characters per player |
| 💰 **Economy System** | Cash, Bank, Gold with paycheck support |
| 👔 **Job System** | Sheriff, Doctor, Farmer, Miner, and more |
| 🎬 **Animations** | Advanced animation system with presets and emotes |
| 📊 **Modern HUD** | Health, hunger, thirst, stamina, money display |
| 🔄 **Callbacks** | Bidirectional client ↔ server callbacks |
| 🌍 **Localization** | English, Portuguese, Spanish support |
| 💾 **Database** | MySQL/MariaDB with oxmysql |

---

## 🚀 Quick Install (txAdmin)

1. Open txAdmin → **Deployer**
2. Select **Remote URL (recipe)**
3. Paste this URL:
```
https://raw.githubusercontent.com/DoubleSync/ds-core/main/recipe.yaml
```
4. Follow the setup wizard
5. Start your server!

---

## 📦 Manual Installation

### Requirements
- RedM Server Artifacts
- [oxmysql](https://github.com/overextended/oxmysql/releases)
- MySQL/MariaDB

### Steps

1. **Clone Repository**
```bash
git clone https://github.com/DoubleSync/ds-core.git
```

2. **Copy to Server**
```
resources/[ds]/ds-core/
```

3. **Import Database**
```sql
SOURCE ds-core/database/ds_schema.sql;
```

4. **Configure server.cfg**
```cfg
set mysql_connection_string "mysql://root:password@localhost/doublesync"
ensure oxmysql
ensure ds-core
```

5. **Start Server**

---

## 🎮 Commands

| Command | Description |
|---------|-------------|
| `/charselect` | Open character selection |
| `/showhud` | Show HUD |
| `/hidehud` | Hide HUD |
| `/emote [name]` | Play emote (wave, sit, smoke, drink) |
| `/addmoney [id] [type] [amount]` | Admin: Add money |
| `/setjob [id] [job] [grade]` | Admin: Set job |
| `/players` | List online players |

---

## 🔧 Configuration

Edit `config/config.lua`:

```lua
Config.Debug = true              -- Enable debug logs
Config.Locale = 'en'             -- Language: en, pt-br, es
Config.MaxCharacters = 3         -- Max characters per player
Config.ServerName = 'My Server'  -- Server name
```

---

## 📁 Structure

```
ds-core/
├── config/          # Configuration files
├── shared/          # Shared utilities
├── client/          # Client scripts
├── server/          # Server scripts
├── nui/             # UI interfaces
│   ├── character/   # Character selection
│   └── hud/         # HUD display
├── locales/         # Translation files
└── database/        # SQL schema
```

---

## 🔌 API Usage

```lua
-- Get core object
local DS = exports['ds-core']:GetCoreObject()

-- Get player
local Player = DS.GetPlayer(source)

-- Economy
Player.Functions.AddMoney('cash', 100)
Player.Functions.RemoveMoney('bank', 50)

-- Callbacks
DS.TriggerCallback('ds-core:getPlayerData', function(data)
    print(data.citizenid)
end)

-- Animations (client)
DS.PlayAnim(dict, anim, flags, duration)
DS.PlayPreset('drink')
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Support

- [Discord](https://discord.gg/doublesync)
- [Issues](https://github.com/DoubleSync/ds-core/issues)

---

<div align="center">
  Made with ❤️ by Double Sync Team
</div>
