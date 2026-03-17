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
CREATE WAREHOUSE IF NOT EXISTS {{ENV}}_ETL_WH
    WITH
    WAREHOUSE_SIZE      = '{{ETL_WH_SIZE}}'      -- X-SMALL | SMALL | MEDIUM | LARGE
    AUTO_SUSPEND        = 120                      -- seconds
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{ETL_MAX_CLUSTERS}}    -- 1 for single, 2-3 for multi-cluster
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = 'ETL and data loading warehouse for {{ENV}}';


-- ============================================================================
-- 2. ANALYTICS WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS {{ENV}}_ANALYTICS_WH
    WITH
    WAREHOUSE_SIZE      = '{{ANALYTICS_WH_SIZE}}'
    AUTO_SUSPEND        = 300
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{ANALYTICS_MAX_CLUSTERS}}
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = 'Analytics and BI queries warehouse for {{ENV}}';


-- ============================================================================
-- 3. AD-HOC WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS {{ENV}}_ADHOC_WH
    WITH
    WAREHOUSE_SIZE      = '{{ADHOC_WH_SIZE}}'
    AUTO_SUSPEND        = 60
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = 1
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = 'Ad-hoc and exploratory queries warehouse for {{ENV}}';


-- ============================================================================
-- 4. DATA SCIENCE WAREHOUSE
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS {{ENV}}_DS_WH
    WITH
    WAREHOUSE_SIZE      = '{{DS_WH_SIZE}}'
    AUTO_SUSPEND        = 300
    AUTO_RESUME         = TRUE
    MIN_CLUSTER_COUNT   = 1
    MAX_CLUSTER_COUNT   = {{DS_MAX_CLUSTERS}}
    SCALING_POLICY      = 'STANDARD'
    INITIALLY_SUSPENDED = TRUE
    COMMENT             = 'Data science workloads warehouse for {{ENV}}';


-- ============================================================================
-- 5. RESOURCE MONITORS (recommended)
-- ============================================================================
-- Prevents runaway costs by setting credit limits per warehouse.

CREATE OR REPLACE RESOURCE MONITOR {{ENV}}_ETL_MONITOR
    WITH
    CREDIT_QUOTA       = {{ETL_CREDIT_QUOTA}}       -- e.g., 100
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE {{ENV}}_ETL_WH SET RESOURCE_MONITOR = {{ENV}}_ETL_MONITOR;

CREATE OR REPLACE RESOURCE MONITOR {{ENV}}_ANALYTICS_MONITOR
    WITH
    CREDIT_QUOTA       = {{ANALYTICS_CREDIT_QUOTA}}
    FREQUENCY          = 'MONTHLY'
    START_TIMESTAMP    = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY
        ON 90 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE {{ENV}}_ANALYTICS_WH SET RESOURCE_MONITOR = {{ENV}}_ANALYTICS_MONITOR;
