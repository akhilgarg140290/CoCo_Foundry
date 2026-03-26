---
name: Functional Roles
description: Generate Snowflake functional (team-based) roles that inherit from access roles, following strict role hierarchy.
---

# Functional Roles Skill

Generate **functional roles** — account-level, team-based roles assigned to users. Functional roles inherit from **database roles** (access roles) and sit below SYSADMIN in the hierarchy.

## Naming Convention

```
FR_{ENV}_{TEAM}_{LEVEL}
```

| Component | Description | Examples |
|-----------|-------------|----------|
| `FR` | Functional Role prefix | — |
| `{ENV}` | Environment | DEV, QA, PROD |
| `{TEAM}` | Team name | DATA_ENGG, ANALYTICS, MANAGERS, DATA_SCIENCE |
| `{LEVEL}` | Permission level | `ADMIN`, `DEVELOPER`, `ANALYST`, `VIEWER` |

**Examples:**
- `FR_PROD_DATA_ENGG_DEVELOPER` — Data engineers working in PROD with developer-level access
- `FR_DEV_ANALYTICS_ANALYST` — Analytics team members in DEV with analyst-level access
- `FR_PROD_ETL_SERVICE` — Service account role for ETL in PROD

## Role-to-Access-Role Mapping

Map each functional role to the appropriate **database roles** (access roles) based on team responsibilities:

> **Schema-Hiding Rule:** When `schema_hiding = Yes`, restricted roles (Analyst, Viewer, Managers) should receive **per-schema** database roles for only the schemas they need — NOT the `AR_ALL_*` aggregate roles. Admin and service roles use `AR_ALL_*` for full visibility.

### Data Engineering Team

| Functional Role | schema_hiding = No | schema_hiding = Yes |
|----------------|-------------------|-------------------|
| `FR_{ENV}_DATA_ENGG_ADMIN` | `{ENV}_BRONZE.AR_ALL_RW`, `{ENV}_SILVER.AR_ALL_RW`, `{ENV}_GOLD.AR_ALL_RO` | Same (full access) |
| `FR_{ENV}_DATA_ENGG_DEVELOPER` | `{ENV}_BRONZE.AR_ALL_RW`, `{ENV}_SILVER.AR_ALL_RW` | Same (full access) |

### Analytics Team

| Functional Role | schema_hiding = No | schema_hiding = Yes |
|----------------|-------------------|-------------------|
| `FR_{ENV}_ANALYTICS_ANALYST` | `{ENV}_SILVER.AR_ALL_RO`, `{ENV}_GOLD.AR_ALL_RO` | `{ENV}_SILVER.AR_ALL_RO` + **selected** `{ENV}_GOLD.AR_{SCHEMA}_RO` only |
| `FR_{ENV}_ANALYTICS_VIEWER` | `{ENV}_GOLD.AR_ALL_RO` | **Selected** `{ENV}_GOLD.AR_{SCHEMA}_RO` only (e.g., REPORTING) |

### Managers

| Functional Role | schema_hiding = No | schema_hiding = Yes |
|----------------|-------------------|-------------------|
| `FR_{ENV}_MANAGERS_VIEWER` | `{ENV}_GOLD.AR_ALL_RO` | **Selected** `{ENV}_GOLD.AR_{SCHEMA}_RO` only (e.g., REPORTING) |

### Data Science

| Functional Role | schema_hiding = No | schema_hiding = Yes |
|----------------|-------------------|-------------------|
| `FR_{ENV}_DATA_SCIENCE_DEVELOPER` | `{ENV}_SILVER.AR_ALL_RO`, `{ENV}_GOLD.AR_ALL_RW` | Same or selected per-schema roles as needed |

### Service Accounts (ETL Tools)

| Functional Role | schema_hiding = No | schema_hiding = Yes |
|----------------|-------------------|-------------------|
| `FR_{ENV}_ETL_SERVICE` | `{ENV}_BRONZE.AR_ALL_RW`, `{ENV}_SILVER.AR_ALL_RW` | Same (full access — service accounts need all schemas) |
| `FR_{ENV}_DBT_SERVICE` | `{ENV}_SILVER.AR_ALL_RW`, `{ENV}_GOLD.AR_ALL_RW` | Same (full access) |

## Generation Rules

### 1. Role Hierarchy
Every functional role **MUST** be granted to `SYSADMIN`:
```sql
GRANT ROLE FR_{ENV}_{TEAM}_{LEVEL} TO ROLE SYSADMIN;
```

### 2. Warehouse Access
Each functional role is granted `USAGE` on its assigned warehouse — **never `OPERATE` or `MODIFY`** unless it's an admin role.

### 3. User Assignment
Users are assigned to functional roles, **never** directly to access roles:
```sql
GRANT ROLE FR_PROD_ANALYTICS_ANALYST TO USER john.doe@company.com;
```

### 4. Environment Isolation
- DEV roles **cannot** access PROD databases
- PROD roles **cannot** access DEV databases
- This is enforced by only granting environment-specific database roles

### 5. Admin Roles Per Environment
Create one admin functional role per environment:
```
FR_{ENV}_PLATFORM_ADMIN — Inherits all RW database roles for that environment
```
This role is for environment-specific administration (not to be confused with ACCOUNTADMIN).

### 6. Restrictive Defaults
- **No cross-environment grants** — a DEV role never touches a PROD database
- **No direct table grants** — always through database roles (access roles)
- **VIEWER roles** get only `SELECT` on Gold layer — nothing else
- **Service roles** are tightly scoped to the specific databases they need

## SQL Template

Use the template at `templates/functional_roles.sql` to generate the output.
