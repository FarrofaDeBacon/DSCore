# Double Sync Framework - Guia de Instalação Rápido

## 📋 O que você precisa

- [ ] Servidor RedM (artifacts)
- [ ] oxmysql (banco de dados)
- [ ] MariaDB/MySQL rodando
- [ ] License key do Cfx.re

---

## 🚀 Instalação em 5 Minutos

### 1️⃣ Estrutura de Pastas

Crie esta estrutura:
```
D:\REDM-SERVER\
├── server-files\        ← Artifacts do RedM aqui
└── server-data\
    ├── server.cfg
    └── resources\
        ├── [standalone]\
        │   └── oxmysql\  ← Download: github.com/overextended/oxmysql
        └── [ds]\
            └── ds-core\  ← Copiar de D:\FRAMEWORK\ds-core
```

### 2️⃣ Baixar Artifacts

1. Acesse: https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/
2. Baixe a versão mais recente (recommended)
3. Extraia em `D:\REDM-SERVER\server-files\`

### 3️⃣ Criar Banco de Dados

No MySQL/MariaDB:
```sql
CREATE DATABASE doublesync;
USE doublesync;
SOURCE D:/FRAMEWORK/ds-core/database/ds_schema.sql;
```

### 4️⃣ Configurar server.cfg

Crie `D:\REDM-SERVER\server-data\server.cfg`:
```cfg
sv_hostname "Double Sync RP"
sv_maxclients 32
sv_licenseKey "COLE_SUA_LICENCA_AQUI"

set mysql_connection_string "mysql://root:SENHA@localhost/doublesync"

ensure oxmysql
ensure ds-core
```

### 5️⃣ Script de Início

Crie `D:\REDM-SERVER\start.cmd`:
```batch
@echo off
cd /d D:\REDM-SERVER\server-files
FXServer.exe +exec ../server-data/server.cfg
pause
```

### 6️⃣ Iniciar e Testar

1. Execute `start.cmd`
2. Abra RedM → F8 → `connect localhost:30120`
3. Teste: `/charselect`, `/showhud`

---

## ⚠️ Problemas Comuns

| Erro | Solução |
|------|---------|
| oxmysql not found | Renomear pasta para `oxmysql` |
| Database error | Verificar senha no connection_string |
| License invalid | Obter em keymaster.fivem.net |

---

## 🎮 Comandos de Teste

```
/charselect     → Seleção de personagem
/showhud        → Mostrar HUD
/hidehud        → Esconder HUD
/emote wave     → Acenar
/testanim       → Testar animação
/addmoney 1 cash 1000  → Dar dinheiro
/setjob 1 sheriff 3    → Definir trabalho
```
