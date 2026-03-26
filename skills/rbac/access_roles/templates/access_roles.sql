-- ============================================================================
-- ACCESS ROLES (DATABASE ROLES) — Snowflake RBAC
-- Generated for: {{COMPANY_NAME}}
-- Environment:   {{ENV}}
-- Schema Hiding: {{SCHEMA_HIDING}}
-- ============================================================================
-- IMPORTANT: Run this script with SYSADMIN role (database owner).
-- Database roles are scoped to their owning database and automatically
-- have USAGE on that database.
-- ============================================================================

USE ROLE SYSADMIN;


-- ============================================================================
-- IF SCHEMA_HIDING = NO: Database-level access roles only
-- ============================================================================
-- Use this section if schema-level hiding is NOT required.
-- All schemas are visible to any role granted AR_ALL_*.

CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_ALL_RO
    COMMENT = 'RO access to all schemas in {{ENV}}_{{DB}}';
CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_ALL_RW
    COMMENT = 'RW access to all schemas in {{ENV}}_{{DB}}';

GRANT USAGE ON ALL SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
GRANT SELECT ON ALL TABLES IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
GRANT SELECT ON ALL VIEWS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
GRANT SELECT ON FUTURE TABLES IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
GRANT SELECT ON FUTURE VIEWS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;

GRANT USAGE ON ALL SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT SELECT ON ALL VIEWS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT SELECT ON FUTURE VIEWS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT CREATE TABLE, CREATE VIEW ON ALL SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
GRANT CREATE TABLE, CREATE VIEW ON FUTURE SCHEMAS IN DATABASE {{ENV}}_{{DB}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;


-- ============================================================================
-- IF SCHEMA_HIDING = YES: Per-schema database roles + aggregates
-- ============================================================================
-- Use this section if schema-level hiding IS required.
-- Repeat the block below for EACH schema in the database.

-- ---- Per-schema role: {{SCHEMA}} ----
CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO
    COMMENT = 'RO access to {{SCHEMA}} schema in {{ENV}}_{{DB}}';
CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW
    COMMENT = 'RW access to {{SCHEMA}} schema in {{ENV}}_{{DB}}';

GRANT USAGE ON SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO;
GRANT SELECT ON ALL TABLES IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO;
GRANT SELECT ON ALL VIEWS IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO;
GRANT SELECT ON FUTURE TABLES IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO;

GRANT USAGE ON SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA {{ENV}}_{{DB}}.{{SCHEMA}} TO DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW;

-- ---- Repeat above block for each schema: {{SCHEMA_2}}, {{SCHEMA_3}}, ... ----


-- ============================================================================
-- AGGREGATE ROLES (always created, even with schema hiding)
-- ============================================================================
-- AR_ALL_RO/RW inherit all per-schema roles. Used by admin and service roles.

CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_ALL_RO
    COMMENT = 'RO access to ALL schemas in {{ENV}}_{{DB}} (aggregates per-schema RO roles)';
CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_ALL_RW
    COMMENT = 'RW access to ALL schemas in {{ENV}}_{{DB}} (aggregates per-schema RW roles)';

GRANT DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RO TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RO;
-- ... repeat for each schema

GRANT DATABASE ROLE {{ENV}}_{{DB}}.AR_{{SCHEMA}}_RW TO DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW;
-- ... repeat for each schema


-- ============================================================================
-- UNMASK ROLE (if dynamic data masking is required)
-- ============================================================================

CREATE DATABASE ROLE IF NOT EXISTS {{ENV}}_{{DB}}.AR_UNMASK
    COMMENT = 'Exemption role for dynamic data masking in {{ENV}}_{{DB}}';


-- ============================================================================
-- GRANT DATABASE ROLES TO FUNCTIONAL ROLES
-- ============================================================================
-- Admin/service roles → use AR_ALL_* (full access, all schemas visible)
-- Restricted roles   → use AR_{SCHEMA}_* (only specified schemas visible)

-- Full access (admin/service roles):
GRANT DATABASE ROLE {{ENV}}_{{DB}}.AR_ALL_RW TO ROLE FR_{{ENV}}_PLATFORM_ADMIN;

-- Schema-hiding (restricted roles — only specified schemas visible):
GRANT DATABASE ROLE {{ENV}}_GOLD.AR_REPORTING_RO TO ROLE FR_{{ENV}}_ANALYTICS_VIEWER;
-- (FINANCE_ANALYTICS schema remains invisible to this role)
