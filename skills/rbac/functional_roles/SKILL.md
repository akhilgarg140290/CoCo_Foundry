---
name: Functional Roles
description: Generate Snowflake functional (team-based) roles that inherit from access roles, following strict role hierarchy.
---

# Functional Roles Skill

Generate **functional roles** — team-based roles assigned to users. Functional roles inherit from access roles and sit below SYSADMIN in the hierarchy.

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

Map each functional role to the appropriate access roles based on team responsibilities:

### Data Engineering Team

| Functional Role | Inherits Access Roles | Warehouse |
|----------------|----------------------|-----------|
| `FR_{ENV}_DATA_ENGG_ADMIN` | `AR_{ENV}_BRONZE_ALL_RW`, `AR_{ENV}_SILVER_ALL_RW`, `AR_{ENV}_GOLD_ALL_RO` | `{ENV}_ETL_WH` |
| `FR_{ENV}_DATA_ENGG_DEVELOPER` | `AR_{ENV}_BRONZE_ALL_RW`, `AR_{ENV}_SILVER_ALL_RW` | `{ENV}_ETL_WH` |

### Analytics Team

| Functional Role | Inherits Access Roles | Warehouse |
|----------------|----------------------|-----------|
| `FR_{ENV}_ANALYTICS_ANALYST` | `AR_{ENV}_SILVER_ALL_RO`, `AR_{ENV}_GOLD_ALL_RO` | `{ENV}_ANALYTICS_WH` |
| `FR_{ENV}_ANALYTICS_VIEWER` | `AR_{ENV}_GOLD_ALL_RO` | `{ENV}_ANALYTICS_WH` |

### Managers

| Functional Role | Inherits Access Roles | Warehouse |
|----------------|----------------------|-----------|
| `FR_{ENV}_MANAGERS_VIEWER` | `AR_{ENV}_GOLD_ALL_RO` | `{ENV}_ADHOC_WH` |

### Data Science

| Functional Role | Inherits Access Roles | Warehouse |
|----------------|----------------------|-----------|
| `FR_{ENV}_DATA_SCIENCE_DEVELOPER` | `AR_{ENV}_SILVER_ALL_RO`, `AR_{ENV}_GOLD_ALL_RW` | `{ENV}_DS_WH` |

### Service Accounts (ETL Tools)

| Functional Role | Inherits Access Roles | Warehouse |
|----------------|----------------------|-----------|
| `FR_{ENV}_ETL_SERVICE` | `AR_{ENV}_BRONZE_ALL_RW`, `AR_{ENV}_SILVER_ALL_RW` | `{ENV}_ETL_WH` |
| `FR_{ENV}_DBT_SERVICE` | `AR_{ENV}_SILVER_ALL_RW`, `AR_{ENV}_GOLD_ALL_RW` | `{ENV}_ETL_WH` |

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
- This is enforced by only granting environment-specific access roles

### 5. Admin Roles Per Environment
Create one admin functional role per environment:
```
FR_{ENV}_PLATFORM_ADMIN — Inherits all RW access roles for that environment
```
This role is for environment-specific administration (not to be confused with ACCOUNTADMIN).

### 6. Restrictive Defaults
- **No cross-environment grants** — a DEV role never touches a PROD database
- **No direct table grants** — always through access roles
- **VIEWER roles** get only `SELECT` on Gold layer — nothing else
- **Service roles** are tightly scoped to the specific databases they need

## SQL Template

Use the template at `templates/functional_roles.sql` to generate the output.
