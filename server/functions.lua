--[[
    Double Sync Framework - Server Functions
    Funções do servidor
]]

-- ============================================
-- FUNÇÕES DE JOGADOR
-- ============================================

-- Obter jogador por source
function DS.GetPlayer(source)
    return DS.Players[source]
end

-- Obter jogador por CitizenId
function DS.GetPlayerByCitizenId(citizenid)
    for _, player in pairs(DS.Players) do
        if player.PlayerData.citizenid == citizenid then
            return player
        end
    end
    return nil
end

-- Obter todos os jogadores
function DS.GetPlayers()
    return DS.Players
end

-- Criar objeto de jogador
function DS.CreatePlayer(source, citizenid, charData)
    local self = {}
    
    -- Dados do jogador
    self.PlayerData = {
        source = source,
        citizenid = citizenid,
        license = DS.GetLicense(source),
        name = GetPlayerName(source),
        charinfo = charData.charinfo or {},
        money = charData.money or DS.DeepCopy(Config.Money.Types),
        job = charData.job or { name = 'unemployed', label = 'Desempregado', grade = 0 },
        gang = charData.gang or { name = 'none', label = 'Nenhuma', grade = 0 },
        position = charData.position or Config.DefaultSpawn,
        metadata = charData.metadata or {
            hunger = 100,
            thirst = 100,
            stamina = 100,
            isdead = false,
            ishandcuffed = false
        }
    }
    
    -- Funções do jogador
    self.Functions = {}
    
    -- Setar trabalho
    self.Functions.SetJob = function(jobName, grade)
        grade = grade or 0
        local job = DS.GetJob(jobName)
        
        if not job then
            DS.Debug('Job não encontrado: ' .. jobName)
            return false
        end
        
        local gradeData = DS.GetJobGrade(jobName, grade)
        if not gradeData then
            DS.Debug('Grade não encontrado: ' .. tostring(grade))
            return false
        end
        
        self.PlayerData.job = {
            name = jobName,
            label = job.label,
            grade = grade,
            grade_name = gradeData.name,
            grade_payment = gradeData.payment,
            onduty = job.defaultDuty
        }
        
        -- Notificar cliente
        TriggerClientEvent('ds-core:client:jobUpdate', self.PlayerData.source, self.PlayerData.job)
        
        return true
    end
    
    -- Adicionar dinheiro
    self.Functions.AddMoney = function(moneyType, amount, reason)
        if not Config.Money.Types[moneyType] then
            DS.Debug('Tipo de dinheiro inválido: ' .. moneyType)
            return false
        end
        
        if amount < 0 then
            DS.Debug('Valor negativo não permitido')
            return false
        end
        
        self.PlayerData.money[moneyType] = (self.PlayerData.money[moneyType] or 0) + amount
        
        -- Notificar cliente
        TriggerClientEvent('ds-core:client:moneyUpdate', self.PlayerData.source, moneyType, self.PlayerData.money[moneyType], 'add')
        
        -- Log
        DS.Log('economy', self.PlayerData.source, self.PlayerData.citizenid, 'AddMoney', {
            type = moneyType,
            amount = amount,
            reason = reason or 'Não especificado'
        })
        
        return true
    end
    
    -- Remover dinheiro
    self.Functions.RemoveMoney = function(moneyType, amount, reason)
        if not Config.Money.Types[moneyType] then
            DS.Debug('Tipo de dinheiro inválido: ' .. moneyType)
            return false
        end
        
        if amount < 0 then
            DS.Debug('Valor negativo não permitido')
            return false
        end
        
        local currentAmount = self.PlayerData.money[moneyType] or 0
        if currentAmount < amount then
            return false
        end
        
        self.PlayerData.money[moneyType] = currentAmount - amount
        
        -- Notificar cliente
        TriggerClientEvent('ds-core:client:moneyUpdate', self.PlayerData.source, moneyType, self.PlayerData.money[moneyType], 'remove')
        
        -- Log
        DS.Log('economy', self.PlayerData.source, self.PlayerData.citizenid, 'RemoveMoney', {
            type = moneyType,
            amount = amount,
            reason = reason or 'Não especificado'
        })
        
        return true
    end
    
    -- Obter dinheiro
    self.Functions.GetMoney = function(moneyType)
        return self.PlayerData.money[moneyType] or 0
    end
    
    -- Setar metadata
    self.Functions.SetMetaData = function(key, value)
        self.PlayerData.metadata[key] = value
    end
    
    -- Obter metadata
    self.Functions.GetMetaData = function(key)
        return self.PlayerData.metadata[key]
    end
    
    -- Salvar jogador no banco
    self.Functions.Save = function()
        DS.Database.SavePlayer(self.PlayerData)
        DS.Debug('Jogador salvo: ' .. self.PlayerData.citizenid)
    end
    
    -- Notificar jogador
    self.Functions.Notify = function(message, type)
        TriggerClientEvent('ds-core:client:notify', self.PlayerData.source, message, type)
    end
    
    -- Adicionar ao registro
    DS.Players[source] = self
    
    -- Enviar dados para o cliente
    TriggerClientEvent('ds-core:client:setPlayerData', source, self.PlayerData)
    
    -- State Bag sync
    Player(source).state:set('ds:playerdata', self.PlayerData, true)
    
    DS.Print('success', 'Player criado: ' .. self.PlayerData.citizenid .. ' [' .. source .. ']')
    
    return self
end

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================

-- Obter licença do jogador
function DS.GetLicense(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, 'license:') then
            return id
        end
    end
    return nil
end

-- Obter Discord do jogador
function DS.GetDiscord(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, 'discord:') then
            return string.gsub(id, 'discord:', '')
        end
    end
    return nil
end

-- Obter Steam do jogador
function DS.GetSteam(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, 'steam:') then
            return id
        end
    end
    return nil
end

-- Verificar se tem permissão admin
function DS.HasPermission(source, permission)
    -- Implementação básica - pode ser expandida
    local player = DS.GetPlayer(source)
    if player then
        local group = player.PlayerData.metadata.group or Config.Admin.DefaultGroup
        return DS.TableContains(Config.Admin.Groups, group)
    end
    return false
end
