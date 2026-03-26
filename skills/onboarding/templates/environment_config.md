# Environment Configuration — {{COMPANY_NAME}}

## Naming Convention

All Snowflake objects follow the pattern: `{ENV}_{LAYER}_{OBJECT_NAME}`

| Prefix | Meaning |
|--------|---------|
| `DEV_` | Development environment |
| `QA_`  | Quality Assurance / Testing |
| `UAT_` | User Acceptance Testing |
| `PROD_`| Production |

## Database Naming

| Environment | Bronze DB | Silver DB | Gold DB |
|-------------|-----------|-----------|---------|
| DEV | `DEV_BRONZE_DB` | `DEV_SILVER_DB` | `DEV_GOLD_DB` |
| QA  | `QA_BRONZE_DB`  | `QA_SILVER_DB`  | `QA_GOLD_DB`  |
| PROD| `PROD_BRONZE_DB`| `PROD_SILVER_DB`| `PROD_GOLD_DB`|

## Schema Naming

Within each database, schemas follow source system naming:

```
{ENV}_{LAYER}_DB
  ├── {SOURCE_SYSTEM_1}     -- e.g., SAP
  ├── {SOURCE_SYSTEM_2}     -- e.g., SALESFORCE
  ├── COMMON                -- shared/reference data
  └── AUDIT                 -- audit/logging tables
```

## Warehouse Naming

| Warehouse | Purpose | Size |
|-----------|---------|------|
| `WH_{ENV}_{TEAM}_ETL`       | ETL / data loading     | {{ETL_WH_SIZE}} |
| `WH_{ENV}_{TEAM}_ANALYTICS` | BI / reporting queries  | {{ANALYTICS_WH_SIZE}} |
| `WH_{ENV}_{TEAM}_ADHOC`     | Ad-hoc / exploration    | {{ADHOC_WH_SIZE}} |
| `WH_{ENV}_{TEAM}_DS`        | Data science workloads  | {{DS_WH_SIZE}} |

## Resource Monitor Naming

| Monitor | Scope |
|---------|-------|
| `RM_{ENV}_{PURPOSE}` | Per-purpose resource monitor |
