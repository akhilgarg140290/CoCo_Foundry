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
-- 2. GRANT DATABASE ROLES (ACCESS ROLES) TO FUNCTIONAL ROLES
-- ============================================================================
-- If schema_hiding = No:  use AR_ALL_* for all roles
-- If schema_hiding = Yes: admin/service roles use AR_ALL_*,
--                         restricted roles use per-schema AR_{SCHEMA}_* only

-- ---- Platform Admin (always full access) ----
GRANT DATABASE ROLE {{ENV}}_BRONZE.AR_ALL_RW TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RW TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RW   TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;

-- ---- Data Engineering Admin (always full access) ----
GRANT DATABASE ROLE {{ENV}}_BRONZE.AR_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RO   TO ROLE FR_{{ENV}}_DATA_ENGG_ADMIN;

-- ---- Data Engineering Developer (always full access on Bronze+Silver) ----
GRANT DATABASE ROLE {{ENV}}_BRONZE.AR_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER;
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RW TO ROLE FR_{{ENV}}_DATA_ENGG_DEVELOPER;

-- ---- Analytics Analyst ----
-- schema_hiding = No:
--   GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RO TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
--   GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RO   TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
-- schema_hiding = Yes (grant only permitted schemas):
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RO TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_{{VISIBLE_SCHEMA_1}}_RO TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_{{VISIBLE_SCHEMA_2}}_RO TO ROLE FR_{{ENV}}_ANALYTICS_ANALYST;
-- ... add per-schema grants for each schema the analyst should see
-- Hidden schemas are NOT granted → invisible to this role

-- ---- Analytics Viewer ----
-- schema_hiding = No:
--   GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RO TO ROLE FR_{{ENV}}_ANALYTICS_VIEWER;
-- schema_hiding = Yes:
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_{{VISIBLE_SCHEMA_1}}_RO TO ROLE FR_{{ENV}}_ANALYTICS_VIEWER;
-- Typically only REPORTING schema for viewers

-- ---- Managers Viewer ----
-- schema_hiding = No:
--   GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RO TO ROLE FR_{{ENV}}_MANAGERS_VIEWER;
-- schema_hiding = Yes:
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_{{VISIBLE_SCHEMA_1}}_RO TO ROLE FR_{{ENV}}_MANAGERS_VIEWER;

-- ---- Data Science Developer ----
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RO TO ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RW   TO ROLE FR_{{ENV}}_DATA_SCIENCE_DEVELOPER;

-- ---- ETL Service (always full access) ----
GRANT DATABASE ROLE {{ENV}}_BRONZE.AR_ALL_RW TO ROLE FR_{{ENV}}_ETL_SERVICE;
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RW TO ROLE FR_{{ENV}}_ETL_SERVICE;

-- ---- dbt Service (always full access) ----
GRANT DATABASE ROLE {{ENV}}_SILVER.AR_ALL_RW TO ROLE FR_{{ENV}}_DBT_SERVICE;
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_ALL_RW   TO ROLE FR_{{ENV}}_DBT_SERVICE;


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
