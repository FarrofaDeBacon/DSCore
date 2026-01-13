--[[
    Double Sync Framework - Jobs Definition
    Server jobs definition
]]

DS.Jobs = {
    -- ============================================
    -- UNEMPLOYED (Default)
    -- ============================================
    ['unemployed'] = {
        label = 'Desempregado',
        type = 'none',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Cidadão', payment = 0 }
        }
    },
    
    -- ============================================
    -- PUBLIC JOBS
    -- ============================================
    ['sheriff'] = {
        label = 'Xerife',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Recruta', payment = 50 },
            [1] = { name = 'Deputado', payment = 75 },
            [2] = { name = 'Deputado Sênior', payment = 100 },
            [3] = { name = 'Xerife', payment = 150 },
            [4] = { name = 'Xerife Chefe', payment = 200 }
        }
    },
    
    ['doctor'] = {
        label = 'Médico',
        type = 'medical',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Aprendiz', payment = 40 },
            [1] = { name = 'Enfermeiro', payment = 60 },
            [2] = { name = 'Médico', payment = 90 },
            [3] = { name = 'Cirurgião', payment = 120 },
            [4] = { name = 'Médico Chefe', payment = 150 }
        }
    },
    
    -- ============================================
    -- CIVILIAN JOBS
    -- ============================================
    ['farmer'] = {
        label = 'Fazendeiro',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trabalhador', payment = 30 },
            [1] = { name = 'Agricultor', payment = 45 },
            [2] = { name = 'Fazendeiro', payment = 60 },
            [3] = { name = 'Dono de Fazenda', payment = 80 }
        }
    },
    
    ['miner'] = {
        label = 'Minerador',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Aprendiz', payment = 35 },
            [1] = { name = 'Minerador', payment = 50 },
            [2] = { name = 'Minerador Experiente', payment = 70 },
            [3] = { name = 'Capataz', payment = 100 }
        }
    },
    
    ['lumberjack'] = {
        label = 'Lenhador',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Ajudante', payment = 30 },
            [1] = { name = 'Lenhador', payment = 45 },
            [2] = { name = 'Lenhador Experiente', payment = 60 },
            [3] = { name = 'Mestre Lenhador', payment = 80 }
        }
    },
    
    ['hunter'] = {
        label = 'Caçador',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Novato', payment = 25 },
            [1] = { name = 'Caçador', payment = 40 },
            [2] = { name = 'Caçador Experiente', payment = 60 },
            [3] = { name = 'Mestre Caçador', payment = 85 }
        }
    },
    
    ['blacksmith'] = {
        label = 'Ferreiro',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Aprendiz', payment = 35 },
            [1] = { name = 'Ferreiro', payment = 55 },
            [2] = { name = 'Ferreiro Mestre', payment = 80 },
            [3] = { name = 'Dono da Forja', payment = 110 }
        }
    },
    
    ['saloon'] = {
        label = 'Saloon',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Ajudante', payment = 20 },
            [1] = { name = 'Garçom', payment = 35 },
            [2] = { name = 'Bartender', payment = 50 },
            [3] = { name = 'Dono', payment = 80 }
        }
    },
    
    ['stablehand'] = {
        label = 'Estábulo',
        type = 'job',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Ajudante', payment = 25 },
            [1] = { name = 'Tratador', payment = 40 },
            [2] = { name = 'Domador', payment = 60 },
            [3] = { name = 'Gerente', payment = 85 }
        }
    }
}

-- ============================================
-- GANGS (Optional)
-- ============================================
DS.Gangs = {
    ['none'] = {
        label = 'Nenhuma',
        grades = {
            [0] = { name = 'Nenhum', payment = 0 }
        }
    },
    
    ['outlaw'] = {
        label = 'Fora da Lei',
        grades = {
            [0] = { name = 'Novato', payment = 0 },
            [1] = { name = 'Membro', payment = 0 },
            [2] = { name = 'Veterano', payment = 0 },
            [3] = { name = 'Braço Direito', payment = 0 },
            [4] = { name = 'Líder', payment = 0 }
        }
    }
}

-- ============================================
-- JOB FUNCTIONS
-- ============================================

-- Get job info
function DS.GetJob(jobName)
    return DS.Jobs[jobName]
end

-- Check if job exists
function DS.JobExists(jobName)
    return DS.Jobs[jobName] ~= nil
end

-- Get job grade
function DS.GetJobGrade(jobName, grade)
    if not DS.Jobs[jobName] then return nil end
    return DS.Jobs[jobName].grades[grade]
end

-- Add new job
function DS.AddJob(jobName, jobData)
    if DS.Jobs[jobName] then
        DS.Debug('Job já existe: ' .. jobName)
        return false
    end
    DS.Jobs[jobName] = jobData
    DS.Debug('Job adicionado: ' .. jobName)
    return true
end

-- Get all jobs
function DS.GetAllJobs()
    return DS.Jobs
end

-- Get gang
function DS.GetGang(gangName)
    return DS.Gangs[gangName]
end

-- Check if law job
function DS.IsLeoJob(jobName)
    local job = DS.Jobs[jobName]
    return job and job.type == 'leo'
end

-- Check if medical job
function DS.IsMedicalJob(jobName)
    local job = DS.Jobs[jobName]
    return job and job.type == 'medical'
end
