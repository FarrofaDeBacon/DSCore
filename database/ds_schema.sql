-- ============================================
-- Double Sync Framework - Database Schema
-- Version: 1.0.0
-- ============================================

-- Players table
CREATE TABLE IF NOT EXISTS `ds_players` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL UNIQUE,
    `license` VARCHAR(100) NOT NULL,
    `name` VARCHAR(100),
    `charinfo` JSON DEFAULT '{}',
    `money` JSON DEFAULT '{"cash":100,"bank":500,"gold":0}',
    `job` JSON DEFAULT '{"name":"unemployed","label":"Unemployed","grade":0}',
    `gang` JSON DEFAULT '{"name":"none","label":"None","grade":0}',
    `position` JSON DEFAULT NULL,
    `metadata` JSON DEFAULT '{"hunger":100,"thirst":100,"stamina":100,"isdead":false}',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_license` (`license`),
    INDEX `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Logs table
CREATE TABLE IF NOT EXISTS `ds_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL,
    `source` INT,
    `citizenid` VARCHAR(50),
    `message` TEXT,
    `data` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_type` (`type`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bans table
CREATE TABLE IF NOT EXISTS `ds_bans` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `license` VARCHAR(100) NOT NULL,
    `discord` VARCHAR(50),
    `reason` TEXT,
    `banned_by` VARCHAR(100),
    `expire_at` TIMESTAMP NULL,
    `permanent` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inventory table (for future use)
CREATE TABLE IF NOT EXISTS `ds_inventory` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `items` JSON DEFAULT '[]',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`citizenid`) REFERENCES `ds_players`(`citizenid`) ON DELETE CASCADE,
    INDEX `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
