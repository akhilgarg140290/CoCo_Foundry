-- ============================================================================
-- FUNCTIONAL ROLES — Snowflake RBAC
-- Generated for: {{COMPANY_NAME}}
-- Environment:   {{ENV}}
-- ============================================================================
-- IMPORTANT: Run this script with SECURITYADMIN role.
-- Functional roles inherit from access roles and are assigned to users.
-- ============================================================================

USE ROLE SECURITYADMIN;

-- ============================================================================
-- 1. CREATE FUNCTIONAL ROLES
-- ============================================================================

-- ---- Platform Admin (per environment) ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_PLATFORM_ADMIN
    COMMENT = 'Platform admin for {{ENV}} — inherits all RW access roles';

-- ---- Data Engineering ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_DATA_ENGG_ADMIN
    COMMENT = 'Data Engineering admin in {{ENV}}';
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_DATA_ENGG_DEVELOPER
    COMMENT = 'Data Engineering developer in {{ENV}}';

-- ---- Analytics ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_ANALYTICS_ANALYST
    COMMENT = 'Analytics analyst in {{ENV}}';
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_ANALYTICS_VIEWER
    COMMENT = 'Analytics viewer in {{ENV}}';

-- ---- Managers ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_MANAGERS_VIEWER
    COMMENT = 'Manager viewer role in {{ENV}} — Gold layer read-only';

-- ---- Data Science ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_DATA_SCIENCE_DEVELOPER
    COMMENT = 'Data Science developer in {{ENV}}';

-- ---- Service Accounts ----
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_ETL_SERVICE
    COMMENT = 'ETL service account role in {{ENV}}';
CREATE ROLE IF NOT EXISTS FR_{{ENV}}_DBT_SERVICE
    COMMENT = 'dbt service account role in {{ENV}}';


-- ============================================================================
-- 2. GRANT ACCESS ROLES TO FUNCTIONAL ROLES
-- ============================================================================

-- ---- Platform Admin ----
GRANT ROLE AR_{{ENV}}_BRONZE_ALL_RW TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RW TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RW   TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;

-- ---- Data Engineering Admin ----
GRANT ROLE AR_{{ENV}}_BRONZE_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RO   TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;

-- ---- Data Engineering Developer ----
GRANT ROLE AR_{{ENV}}_BRONZE_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER;
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER;

-- ---- Analytics Analyst ----
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RO TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RO   TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;

-- ---- Analytics Viewer ----
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RO TO ROLE FR_{{ENV}}_ANALYTICS_VIEWER;

-- ---- Managers Viewer ----
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RO TO ROLE FR_{{ENV}}_MANAGERS_VIEWER;

-- ---- Data Science Developer ----
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RO TO ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER;
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RW   TO ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER;

-- ---- ETL Service ----
GRANT ROLE AR_{{ENV}}_BRONZE_ALL_RW TO ROLE FR_{{ENV}}_ETL_SERVICE;
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RW TO ROLE FR_{{ENV}}_ETL_SERVICE;

-- ---- dbt Service ----
GRANT ROLE AR_{{ENV}}_SILVER_ALL_RW TO ROLE FR_{{ENV}}_DBT_SERVICE;
GRANT ROLE AR_{{ENV}}_GOLD_ALL_RW   TO ROLE FR_{{ENV}}_DBT_SERVICE;


-- ============================================================================
-- 3. WAREHOUSE GRANTS (USAGE only — no OPERATE or MODIFY)
-- ============================================================================

GRANT USAGE ON WAREHOUSE {{ENV}}_ETL_WH       TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;
GRANT USAGE ON WAREHOUSE {{ENV}}_ETL_WH       TO ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER;
GRANT USAGE ON WAREHOUSE {{ENV}}_ETL_WH       TO ROLE FR_{{ENV}}_ETL_SERVICE;
GRANT USAGE ON WAREHOUSE {{ENV}}_ETL_WH       TO ROLE FR_{{ENV}}_DBT_SERVICE;
GRANT USAGE ON WAREHOUSE {{ENV}}_ANALYTICS_WH TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
GRANT USAGE ON WAREHOUSE {{ENV}}_ANALYTICS_WH TO ROLE FR_{{ENV}}_ANALYTICS_VIEWER;
GRANT USAGE ON WAREHOUSE {{ENV}}_ADHOC_WH     TO ROLE FR_{{ENV}}_MANAGERS_VIEWER;
GRANT USAGE ON WAREHOUSE {{ENV}}_DS_WH        TO ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER;

-- Platform admin gets USAGE + OPERATE on all warehouses
GRANT USAGE, OPERATE ON WAREHOUSE {{ENV}}_ETL_WH       TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT USAGE, OPERATE ON WAREHOUSE {{ENV}}_ANALYTICS_WH TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT USAGE, OPERATE ON WAREHOUSE {{ENV}}_ADHOC_WH     TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT USAGE, OPERATE ON WAREHOUSE {{ENV}}_DS_WH        TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;


-- ============================================================================
-- 4. ROLE HIERARCHY — GRANT ALL FUNCTIONAL ROLES TO SYSADMIN
-- ============================================================================

GRANT ROLE FR_{{ENV}}_PLATFORM_ADMIN         TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_DATA_ENGG_ADMIN        TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER    TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_ANALYTICS_ANALYST      TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_ANALYTICS_VIEWER       TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_MANAGERS_VIEWER        TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_ETL_SERVICE            TO ROLE SYSADMIN;
GRANT ROLE FR_{{ENV}}_DBT_SERVICE            TO ROLE SYSADMIN;


-- ============================================================================
-- 5. ASSIGN USERS TO FUNCTIONAL ROLES (customize per customer)
-- ============================================================================

-- GRANT ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER TO USER "{{USERNAME}}";
-- GRANT ROLE FR_{{ENV}}_ANALYTICS_ANALYST   TO USER "{{USERNAME}}";
