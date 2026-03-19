# Snowflake Medallion Architecture - Database Design Skill

## Required Inputs
| Input | Description | Example |
|-------|-------------|---------|
| `domain` | Project industry/domain | finance, healthcare, retail, manufacturing |
| `environments` | List of environments | [DEV, PROD] or [DEV, UAT, PROD] |
| `env_position` | Environment in name | prefix (DEV_BRONZE) or suffix (BRONZE_DEV) |
| `data_sources` | Source systems + descriptions | [{name: "ERP", desc: "orders, inventory"}] |
| `gold_schemas` | Analytics domains (optional) | Inferred from sources if not provided |

## Role Strategy
Use **SYSADMIN** for all object creation (databases, schemas, tags).

```sql
USE ROLE SYSADMIN;
```

## Architecture Template
```
GOVERNANCE.TAGS          → Tags for governance metadata
<ENV>_BRONZE.<SOURCE>    → Raw ingestion (1 schema per source)
<ENV>_SILVER.<SOURCE>    → Curated data (1 schema per source)  
<ENV>_GOLD.<DOMAIN>      → Analytics (inferred or specified)
CONFIG.CONFIG            → Configuration management
AUDIT.AUDIT_LOGGING      → Compliance and audit logs
```

## Standard Tags
| Tag | Values |
|-----|--------|
| ENVIRONMENT | From `environments` input |
| OWNER | data_engineering, analytics, platform, security, {domain} |
| SENSITIVITY | public, internal, confidential, pii, {domain-specific} |
| LAYER | raw, curated, analytics, config, audit |
| SOURCE_SYSTEM | From `data_sources` names + internal |
| DATA_DOMAIN | Inferred from sources and gold schemas |

## SQL Generation Rules
1. Begin with `USE ROLE SYSADMIN;`
2. All statements use `IF NOT EXISTS` (idempotent)
3. Tags fully qualified: `GOVERNANCE.TAGS.<NAME>`
4. All objects include `COMMENT`
5. Execution order: GOVERNANCE → Tags → Databases → Schemas → Tagging

## Gold Schema Inference
If `gold_schemas` not provided, derive from data sources:
- Source with customer/sales data → SALES_ANALYTICS, CUSTOMER_ANALYTICS
- Source with inventory/orders → OPERATIONS_ANALYTICS
- Source with financial data → FINANCE_ANALYTICS
- Always include: REPORTING

## Sensitivity Mapping
| Data Type | Sensitivity |
|-----------|-------------|
| Customer PII, patient data | pii |
| Financial, pricing, contracts | confidential or {domain} |
| Operational metrics | internal |
| Aggregated reporting | internal |

## Output SQL Structure
```sql
-- Set role
USE ROLE SYSADMIN;

-- 1. Governance
CREATE DATABASE IF NOT EXISTS GOVERNANCE;
CREATE SCHEMA IF NOT EXISTS GOVERNANCE.TAGS;
CREATE TAG IF NOT EXISTS GOVERNANCE.TAGS.<tag> ALLOWED_VALUES '<v1>', '<v2>';

-- 2. Per-environment databases
CREATE DATABASE IF NOT EXISTS <ENV>_BRONZE;
CREATE DATABASE IF NOT EXISTS <ENV>_SILVER;
CREATE DATABASE IF NOT EXISTS <ENV>_GOLD;

-- 3. Schemas (per environment)
CREATE SCHEMA IF NOT EXISTS <ENV>_BRONZE.<SOURCE>;
CREATE SCHEMA IF NOT EXISTS <ENV>_SILVER.<SOURCE>;
CREATE SCHEMA IF NOT EXISTS <ENV>_GOLD.<ANALYTICS_DOMAIN>;

-- 4. Shared databases
CREATE DATABASE IF NOT EXISTS CONFIG;
CREATE SCHEMA IF NOT EXISTS CONFIG.CONFIG;
CREATE DATABASE IF NOT EXISTS AUDIT;
CREATE SCHEMA IF NOT EXISTS AUDIT.AUDIT_LOGGING;

-- 5. Apply tags
ALTER DATABASE <DB> SET TAG GOVERNANCE.TAGS.<TAG> = '<value>';
ALTER SCHEMA <SCHEMA> SET TAG GOVERNANCE.TAGS.<TAG> = '<value>';
```
