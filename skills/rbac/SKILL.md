---
name: RBAC Configuration
description: Generate restrictive, least-privilege RBAC setup for Snowflake including access roles, functional roles, masking policies, and row access policies.
---

# RBAC Configuration Skill

Generate a complete, **restrictive, least-privilege** RBAC setup for Snowflake. This skill follows the Snowflake-recommended role hierarchy and security best practices.

## Prerequisites

Before running this skill, ensure the **Business Profile** has been completed via the Onboarding Questionnaire skill. You need:
- Environment names (DEV, QA, PROD)
- Database and schema names
- Teams and user types
- PII requirements
- Schema-level hiding requirements

## RBAC Discovery Questions

**Before generating any SQL**, ask the user these clarifying questions to ensure the RBAC is correctly scoped. Do NOT skip these — they are critical for a secure setup.

### Security Scope Questions

| # | Question | Why It Matters |
|---|----------|---------------|
| R1 | Do you need **database-level access roles**? (separate read/write roles per database) | Controls who can access each database. Recommended: **Yes** |
| R2 | Do you need **schema-level access roles**? (separate read/write roles per schema) | Finer-grained control within each database. Recommended for sensitive schemas: **Yes** |
| R3 | Do you need **dynamic data masking policies** on PII columns? | Masks sensitive data (SSN, Email, etc.) for non-privileged roles |
| R4 | Which columns/tables contain PII that need masking? | Needed to generate masking policy DDL |
| R5 | Do you need **row access policies**? (restrict rows visible to certain roles) | Used for multi-tenant or department-scoped data |
| R6 | Should **SYSADMIN** be the parent of all custom roles? | Snowflake best practice: Yes — ensures SYSADMIN can manage all objects |
| R7 | Do you need **separate admin roles** per environment? (e.g., DEV_ADMIN, PROD_ADMIN) | Prevents dev users from accidentally modifying production |
| R8 | Should service accounts (ETL tools, dbt) have **dedicated functional roles**? | Best practice: Yes — isolates automated workloads |
| R9 | Do you need **tag-based masking** (governance tags) or **column-level masking**? | Tag-based scales better for large schemas; column-level is more explicit |

### If PII Data = Yes, additionally ask:

| # | Question | Why It Matters |
|---|----------|---------------|
| M1 | What **masking strategy**: full mask, partial mask, or hash? | e.g., SSN → `***-**-1234` (partial) vs. `*********` (full) |
| M2 | Which roles should see **unmasked data**? | Typically only admin or compliance roles |
| M3 | Should masking apply in **all environments** or only PROD? | Dev may need real data for testing, or masked data for security |

## Sub-Skills

| Skill | Path | Purpose |
|-------|------|---------|
| **Access Roles** | `access_roles/SKILL.md` | Database/schema-level read/write roles and their grants |
| **Functional Roles** | `functional_roles/SKILL.md` | Team-based roles that inherit from access roles |

## Snowflake RBAC Best Practices (MUST FOLLOW)

```
                    ACCOUNTADMIN
                         │
                    ┌────┴────┐
               SECURITYADMIN  SYSADMIN
                    │              │
                    │    ┌─────────┼──────────┐
                    │    │         │           │
                    │  FR_DATA  FR_ANALYTICS  FR_MANAGERS
                    │  _ENGG        │           │
                    │    │     ┌────┴────┐      │
                    │    │     │         │      │
                    │  AR_DB  AR_DB    AR_DB   AR_DB
                    │  _RW   _RO     _RO     _RO
                    │
              (manages all roles)
```

### Rules

1. **ACCOUNTADMIN** — never used for daily operations. Only for account-level changes.
2. **SECURITYADMIN** — owns and manages all custom roles. Grants role assignments.
3. **SYSADMIN** — parent of all custom functional roles. Owns all databases and schemas.
4. **Access Roles (AR_)** — grant object-level privileges (SELECT, INSERT, etc.). Named: `AR_{ENV}_{DB}_{SCHEMA}_{RO|RW}`
5. **Functional Roles (FR_)** — assigned to users. Inherit from access roles. Named: `FR_{ENV}_{TEAM}_{LEVEL}`
6. **Never grant privileges directly to users** — always through roles.
7. **Never grant ALL PRIVILEGES** — be explicit about what is granted.
8. **Use FUTURE GRANTS** — ensures new objects automatically inherit the correct permissions.
9. **Separate read-only and read-write access** — distinct access roles for each.
10. **Service accounts get dedicated roles** — ETL, dbt, Fivetran each get their own functional role.

## Output

After collecting answers, read the sub-skills and generate:
1. Access roles SQL (via `access_roles/SKILL.md`)
2. Functional roles SQL (via `functional_roles/SKILL.md`)
3. Masking policies SQL (if PII = Yes)
4. Role hierarchy diagram (text-based)
5. Grant summary table

Deliver all SQL in a single, well-commented script organized by section.
