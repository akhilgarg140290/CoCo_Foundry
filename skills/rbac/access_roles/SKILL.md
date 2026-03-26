---
name: Access Roles (Database Roles)
description: Generate Snowflake DATABASE ROLES as access roles with least-privilege grants at database and schema levels. Supports schema-level hiding.
---

# Access Roles Skill (Database Roles)

Generate **access roles** as **Snowflake database roles** — scoped to their owning database for tighter encapsulation. Database roles are granted object-level privileges and are then granted to account-level functional roles.

## Why Database Roles?

- **Encapsulation** — database roles are scoped to their database; they cannot access objects outside it.
- **No GRANT USAGE ON DATABASE needed** — database roles automatically have USAGE on their owning database.
- **Cleaner RBAC** — the environment and database context is implied by the database name.
- **Portability** — database roles travel with the database during replication or cloning.

## Naming Convention

Database roles live inside the database:

```
{ENV}_{DATABASE}.AR_{SCHEMA}_{ACCESS_LEVEL}
```

| Component | Description | Examples |
|-----------|-------------|----------|
| `{ENV}_{DATABASE}` | The owning database | DEV_BRONZE, PROD_SILVER, PROD_GOLD |
| `AR` | Access Role prefix | — |
| `{SCHEMA}` | Schema name (or `ALL` for aggregate) | ERP, CRM, REPORTING, ALL |
| `{ACCESS_LEVEL}` | Permission level | `RO` (read-only), `RW` (read-write) |

**Examples:**
- `PROD_BRONZE.AR_SAP_RO` — Read-only access to the SAP schema in PROD Bronze DB
- `DEV_SILVER.AR_ALL_RW` — Read-write access to all schemas in DEV Silver DB

## Generation Rules

### 0. Role for Creation
Database roles are created by the **database owner**. Use `SYSADMIN` (not SECURITYADMIN):
```sql
USE ROLE SYSADMIN;
```

### 1. Schema-Level Hiding Logic (CRITICAL)

**If `schema_hiding = No`:**
- Create only `AR_ALL_RO` and `AR_ALL_RW` per database
- Grant `USAGE ON ALL SCHEMAS`, `SELECT ON ALL TABLES`, `FUTURE` grants at the database level
- All schemas are visible to any role granted these database roles

**If `schema_hiding = Yes`:**
- Create **per-schema** database roles: `AR_{SCHEMA}_RO` and `AR_{SCHEMA}_RW` for every schema
- Each per-schema role grants `USAGE` on only that specific schema + `SELECT`/DML on tables in that schema only
- Schemas NOT explicitly granted are **invisible** to the functional role
- Additionally create **aggregate** roles `AR_ALL_RO` and `AR_ALL_RW` that inherit all per-schema roles:
  ```sql
  GRANT DATABASE ROLE {DB}.AR_{SCHEMA1}_RO TO DATABASE ROLE {DB}.AR_ALL_RO;
  GRANT DATABASE ROLE {DB}.AR_{SCHEMA2}_RO TO DATABASE ROLE {DB}.AR_ALL_RO;
  -- ... repeat for all schemas
  ```
- Admin and service account functional roles use `AR_ALL_*` (full access)
- Restricted functional roles (analysts, viewers) receive only specific per-schema roles

### 2. Per-Schema Database Role Pattern
For each schema when `schema_hiding = Yes`:

```sql
-- RO role
CREATE DATABASE ROLE IF NOT EXISTS {ENV}_{DB}.AR_{SCHEMA}_RO;
GRANT USAGE ON SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RO;
GRANT SELECT ON ALL TABLES IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RO;
GRANT SELECT ON ALL VIEWS IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RO;
GRANT SELECT ON FUTURE TABLES IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RO;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RO;

-- RW role
CREATE DATABASE ROLE IF NOT EXISTS {ENV}_{DB}.AR_{SCHEMA}_RW;
GRANT USAGE ON SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RW;
GRANT SELECT, INSERT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RW;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA {ENV}_{DB}.{SCHEMA} TO DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA}_RW;
```

### 3. Aggregate Roles (AR_ALL_*)
Always create aggregate roles that inherit all per-schema roles:

```sql
CREATE DATABASE ROLE IF NOT EXISTS {ENV}_{DB}.AR_ALL_RO;
CREATE DATABASE ROLE IF NOT EXISTS {ENV}_{DB}.AR_ALL_RW;

-- RO aggregate inherits all per-schema RO
GRANT DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA1}_RO TO DATABASE ROLE {ENV}_{DB}.AR_ALL_RO;
GRANT DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA2}_RO TO DATABASE ROLE {ENV}_{DB}.AR_ALL_RO;

-- RW aggregate inherits all per-schema RW
GRANT DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA1}_RW TO DATABASE ROLE {ENV}_{DB}.AR_ALL_RW;
GRANT DATABASE ROLE {ENV}_{DB}.AR_{SCHEMA2}_RW TO DATABASE ROLE {ENV}_{DB}.AR_ALL_RW;
```

### 4. Future Grants (CRITICAL)
Always include `GRANT ... ON FUTURE <objects>` at the schema level to ensure new tables/views automatically get the correct permissions.

### 5. Granting Database Roles to Functional Roles
Database roles are granted to account-level functional roles using:
```sql
-- Full access (admin/service roles):
GRANT DATABASE ROLE {ENV}_{DB}.AR_ALL_RW TO ROLE FR_{ENV}_{TEAM}_{LEVEL};

-- Schema-hiding (restricted roles — only selected schemas):
GRANT DATABASE ROLE {ENV}_GOLD.AR_REPORTING_RO TO ROLE FR_{ENV}_ANALYTICS_VIEWER;
-- (other Gold schemas remain hidden)
```

### 6. Restrictive Defaults
- **No `ALL PRIVILEGES`** — always enumerate specific privileges
- **No `GRANT ... WITH GRANT OPTION`** — unless explicitly required
- **MONITOR privilege** — only for admin roles
- **CREATE SCHEMA** — only for RW roles at the database level
- **No GRANT USAGE ON DATABASE** — database roles inherit this automatically

## SQL Template

Use the template at `templates/access_roles.sql` to generate the output.

## Masking Policy Integration

If PII masking is required, access roles determine who sees masked vs. unmasked data:

| Role Type | Masking Behavior |
|-----------|-----------------|
| `AR_*_RO` database roles | See **masked** PII data |
| `AR_*_RW` database roles | See **masked** PII data (unless explicitly unmasked) |
| `AR_UNMASK` database role | Special role granted to see unmasked data — assign only to compliance/admin |

Create an additional database role per database:
```
{ENV}_{DB}.AR_UNMASK — Exempted from masking policies
```
