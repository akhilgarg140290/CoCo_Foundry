---
name: Access Roles
description: Generate Snowflake access roles with least-privilege grants at database, schema, and table levels.
---

# Access Roles Skill

Generate **access roles** — the lowest level of the RBAC hierarchy. Access roles are granted object-level privileges and are then assigned to functional roles.

## Naming Convention

```
AR_{ENV}_{DATABASE}_{SCHEMA}_{ACCESS_LEVEL}
```

| Component | Description | Examples |
|-----------|-------------|----------|
| `AR` | Access Role prefix | — |
| `{ENV}` | Environment | DEV, QA, PROD |
| `{DATABASE}` | Database short name | BRONZE, SILVER, GOLD |
| `{SCHEMA}` | Schema name (or `ALL` for db-wide) | SAP, SALESFORCE, COMMON |
| `{ACCESS_LEVEL}` | Permission level | `RO` (read-only), `RW` (read-write) |

**Examples:**
- `AR_PROD_BRONZE_SAP_RO` — Read-only access to the SAP schema in PROD Bronze DB
- `AR_DEV_SILVER_ALL_RW` — Read-write access to all schemas in DEV Silver DB

## Generation Rules

### 1. Database-Level Access Roles
For each `{ENV}` × `{DATABASE}` combination, create:
- `AR_{ENV}_{DB}_ALL_RO` — `USAGE` on database, `USAGE` on all schemas, `SELECT` on all tables/views
- `AR_{ENV}_{DB}_ALL_RW` — Above + `INSERT`, `UPDATE`, `DELETE`, `CREATE TABLE`, `CREATE VIEW`

### 2. Schema-Level Access Roles (if schema-level hiding = Yes)
For each `{ENV}` × `{DATABASE}` × `{SCHEMA}` combination, create:
- `AR_{ENV}_{DB}_{SCHEMA}_RO` — `USAGE` on database, `USAGE` on specific schema, `SELECT` on tables/views in that schema
- `AR_{ENV}_{DB}_{SCHEMA}_RW` — Above + `INSERT`, `UPDATE`, `DELETE`

### 3. Future Grants (CRITICAL)
Always include `GRANT ... ON FUTURE <objects>` to ensure new tables/views automatically get the correct permissions.

### 4. Restrictive Defaults
- **No `ALL PRIVILEGES`** — always enumerate specific privileges
- **No `GRANT ... WITH GRANT OPTION`** — unless explicitly required
- **MONITOR privilege** — only for admin roles
- **CREATE SCHEMA** — only for RW roles at the database level

## SQL Template

Use the template at `templates/access_roles.sql` to generate the output. Fill in variables from the business profile.

## Masking Policy Integration

If PII masking is required, access roles determine who sees masked vs. unmasked data:

| Role Type | Masking Behavior |
|-----------|-----------------|
| `_RO` roles | See **masked** PII data |
| `_RW` roles | See **masked** PII data (unless explicitly unmasked) |
| `AR_*_UNMASK` | Special role granted to see unmasked data — assign only to compliance/admin |

Create an additional role per environment:
```
AR_{ENV}_{DB}_UNMASK — Exempted from masking policies
```
