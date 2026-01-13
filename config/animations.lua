--[[
    Double Sync Framework - Animations Config
    Animation dictionaries and presets
]]

AnimationsConfig = {}

-- ============================================
-- COMMON ANIMATION DICTIONARIES
-- ============================================
AnimationsConfig.Dictionaries = {
    -- General actions
    'amb_misc@world_human_hang_out_saloon@female@base',
    'amb_misc@world_human_hang_out_saloon@male@base',
    'amb_misc@world_human_drinking@female@base',
    'amb_misc@world_human_drinking@male@base',
    'amb_misc@world_human_eating@male@base',
    'amb_misc@world_human_eating@female@base',
    'amb_misc@world_human_smoking@male@base',
    'amb_misc@world_human_smoking@female@base',
    
    -- Work
    'amb_work@world_human_pickaxe@male@base',
    'amb_work@world_human_wood_chopping@male@base',
    'amb_work@world_human_hammering@male@base',
    
    -- Social
    'gestures@m@standing@casual',
    'gestures@f@standing@casual',
    'reaction@intimidation@unarmed@male@basevariations',
    
    -- Medical
    'mech_loco@ped_loco_action_bandage_b@crouch@idle_a',
    'mini_games@dominos@seated@r_hand@male@idle_a',
    
    -- Emotes
    'anim@emotes@mp@male@tip_hat',
    'anim@emotes@mp@female@wave',
    'anim@emotes@shared@sit_ground@generic',
    'anim@emotes@shared@sit_chair@generic'
}

-- ============================================
-- ANIMATION PRESETS
-- ============================================
AnimationsConfig.Presets = {
    -- Eat
    eat = {
        dict = 'amb_misc@world_human_eating@male@base',
        anim = 'base',
        flags = 49,
        duration = 5000,
        props = {
            -- Pode adicionar props aqui
        }
    },
    
    -- Drink
    drink = {
        dict = 'amb_misc@world_human_drinking@male@base',
        anim = 'base',
        flags = 49,
        duration = 4000
    },
    
    -- Smoke
    smoke = {
        dict = 'amb_misc@world_human_smoking@male@base',
        anim = 'base',
        flags = 49,
        duration = 10000
    },
    
    -- Heal/Bandage
    heal = {
        dict = 'mech_loco@ped_loco_action_bandage_b@crouch@idle_a',
        anim = 'idle_a',
        flags = 1,
        duration = 8000
    },
    
    -- Mining
    mine = {
        dict = 'amb_work@world_human_pickaxe@male@base',
        anim = 'base',
        flags = 1,
        duration = -1
    },
    
    -- Woodcutting
    chop = {
        dict = 'amb_work@world_human_wood_chopping@male@base',
        anim = 'base',
        flags = 1,
        duration = -1
    },
    
    -- Hammering
    hammer = {
        dict = 'amb_work@world_human_hammering@male@base',
        anim = 'base',
        flags = 1,
        duration = -1
    },
    
    -- Sit on ground
    sit_ground = {
        dict = 'anim@emotes@shared@sit_ground@generic',
        anim = 'sit_ground_idle_a',
        flags = 1,
        duration = -1
    },
    
    -- Wave
    wave = {
        dict = 'anim@emotes@mp@female@wave',
        anim = 'wave',
        flags = 49,
        duration = 2500
    },
    
    -- Greet (tip hat)
    greet = {
        dict = 'anim@emotes@mp@male@tip_hat',
        anim = 'tip_hat',
        flags = 49,
        duration = 2000
    }
}

-- ============================================
-- SCENARIOS
-- ============================================
AnimationsConfig.Scenarios = {
    'WORLD_HUMAN_BARTENDER_CLEAN_GLASS',
    'WORLD_HUMAN_WRITE_NOTEBOOK',
    'WORLD_HUMAN_SIT_DRINK_BEER',
    'WORLD_HUMAN_SIT_EAT',
    'WORLD_HUMAN_SMOKE_CIGARETTE',
    'WORLD_HUMAN_WRITE_LETTER',
    'WORLD_HUMAN_LEAN_BAR',
    'WORLD_HUMAN_LEAN_WALL',
    'WORLD_HUMAN_HANG_OUT_STREET'
}

-- ============================================
-- FLAGS DE ANIMAÇÃO
-- ============================================
-- Referência para flags de animação
AnimationsConfig.Flags = {
    ANIM_FLAG_NORMAL = 0,
    ANIM_FLAG_REPEAT = 1,
    ANIM_FLAG_STOP_LAST_FRAME = 2,
    ANIM_FLAG_UPPERBODY = 16,
    ANIM_FLAG_ENABLE_PLAYER_CONTROL = 32,
    ANIM_FLAG_CANCELABLE = 120
}

return AnimationsConfig
