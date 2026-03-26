-- ============================================================================
-- VIRTUAL WAREHOUSES — Snowflake
-- Generated for: {{COMPANY_NAME}}
-- Environment:   {{ENV}}
-- ============================================================================
-- IMPORTANT: Run this script with SYSADMIN role.
-- ============================================================================

USE ROLE SYSADMIN;

-- ============================================================================
-- 1. ETL WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS WH_{{ENV}}_{{TEAM}}_ETL
    WITH
    WAREHOUSE_SIZE      = '{{ETL_WH_SIZE}}'      -- X-SMALL | SMALL | MEDIUM | LARGE
    AUTO_SUSPEND        = 120                      -- seconds
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{ETL_MAX_CLUSTERS}}    -- 1 for single, 2-3 for multi-cluster
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = '{{TEAM}} {{ENV}} warehouse for ETL | Volume: {{DATA_VOLUME}}';


-- ============================================================================
-- 2. ANALYTICS WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS WH_{{ENV}}_{{TEAM}}_ANALYTICS
    WITH
    WAREHOUSE_SIZE      = '{{ANALYTICS_WH_SIZE}}'
    AUTO_SUSPEND        = 300
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{ANALYTICS_MAX_CLUSTERS}}
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = '{{TEAM}} {{ENV}} warehouse for ANALYTICS | Volume: {{DATA_VOLUME}}';


-- ============================================================================
-- 3. AD-HOC WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS WH_{{ENV}}_{{TEAM}}_ADHOC
    WITH
    WAREHOUSE_SIZE      = '{{ADHOC_WH_SIZE}}'
    AUTO_SUSPEND        = 60
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = 1
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = '{{TEAM}} {{ENV}} warehouse for ADHOC | Volume: {{DATA_VOLUME}}';


-- ============================================================================
-- 4. DATA SCIENCE WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS WH_{{ENV}}_{{TEAM}}_DS
    WITH
    WAREHOUSE_SIZE      = '{{DS_WH_SIZE}}'
    AUTO_SUSPEND        = 300
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{DS_MAX_CLUSTERS}}
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = '{{TEAM}} {{ENV}} warehouse for DS | Volume: {{DATA_VOLUME}}';


-- ============================================================================
-- 5. RESOURCE MONITORS (recommended)
-- ============================================================================
-- Prevents runaway costs by setting credit limits per warehouse.

CREATE OR REPLACE RESOURCE MONITOR RM_{{ENV}}_ETL
    WITH
    CREDIT_QUOTA       = {{ETL_CREDIT_QUOTA}}         -- e.g., 100
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE WH_{{ENV}}_{{TEAM}}_ETL SET RESOURCE_MONITOR = RM_{{ENV}}_ETL;

CREATE OR REPLACE RESOURCE MONITOR RM_{{ENV}}_ANALYTICS
    WITH
    CREDIT_QUOTA       = {{ANALYTICS_CREDIT_QUOTA}}
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE WH_{{ENV}}_{{TEAM}}_ANALYTICS SET RESOURCE_MONITOR = RM_{{ENV}}_ANALYTICS;

CREATE OR REPLACE RESOURCE MONITOR RM_{{ENV}}_ADHOC
    WITH
    CREDIT_QUOTA       = {{ADHOC_CREDIT_QUOTA}}
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE WH_{{ENV}}_{{TEAM}}_ADHOC SET RESOURCE_MONITOR = RM_{{ENV}}_ADHOC;

CREATE OR REPLACE RESOURCE MONITOR RM_{{ENV}}_DS
    WITH
    CREDIT_QUOTA       = {{DS_CREDIT_QUOTA}}
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE WH_{{ENV}}_{{TEAM}}_DS SET RESOURCE_MONITOR = RM_{{ENV}}_DS;
