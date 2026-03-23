# CoCo Foundry — Snowflake Platform Onboarding Skills

> An AI-powered, interactive runbook for onboarding customers to the Snowflake Data Platform.  
> From business discovery → database design → RBAC → warehouse provisioning — all in one guided flow.

---

## What Is This?

CoCo Foundry is a structured **Skills System** designed for use with an Cortex Code. The agent reads these skill files and acts as a **Snowflake Solutions Architect**, guiding customers through the full platform setup — producing **copy-paste-ready SQL** at every step.

---

## Folder Structure

```
CoCo_Foundry/
├── SKILL.md                        ← Main orchestrator (start here)
├── README.md                       ← This file
└── skills/
    ├── onboarding/
    │   └── SKILL.md                ← Business discovery questionnaire
    ├── db_design/
    │   └── SKILL.md                ← Medallion architecture & schema design
    ├── rbac/
    │   ├── SKILL.md                ← Role hierarchy & security policies
    │   ├── access_roles/SKILL.md   ← Object-level access roles (AR_)
    │   └── functional_roles/SKILL.md ← Team-based functional roles (FR_)
    └── warehouse/
        └── SKILL.md                ← Enterprise warehouse provisioning (v3)
```

---

## How To Use

### Starting the Agent

Point your AI agent at `SKILL.md` in the root of this repository. The agent will automatically route through the 5-step onboarding flow.

**Recommended prompt to kick things off:**

```
You are a Snowflake Solutions Architect. Please read SKILL.md and begin the customer onboarding process.
```

---

## The 5-Step Onboarding Flow

### Step 1 — Business Discovery 🔍
**Skill:** `skills/onboarding/SKILL.md`

The agent conducts a structured Q&A across 6 categories:

| Category | Key Questions |
|----------|---------------|
| **Business Overview** | Company name, domain, platform goals |
| **Source Systems** | Number of sources, names, total data volume, daily incremental load |
| **Environments** | DEV / QA / UAT / PROD, same account vs. separate accounts |
| **Data Sensitivity** | PII types, masking requirements, row-level security |
| **Teams & Users** | Team names, sizes, user types (Admin, Developer, Analyst, Viewer) |
| **ETL & Workload** | Load intensity, tools (dbt, Fivetran, etc.), workload isolation preference |

**What to expect:**
- Questions are asked **one category at a time** (not all at once).
- You can **skip any question** — the agent marks it `[SKIPPED]` and applies sensible defaults.
- At the end, the agent produces a filled **Business Profile** document for review.

---

### Step 2 — Database Layer Design 🗄️
**Skill:** `skills/db_design/SKILL.md`

Using the business profile from Step 1, the agent generates the full **Medallion Architecture** layer:

```
GOVERNANCE.TAGS          → Governance metadata tags
<ENV>_BRONZE.<SOURCE>    → Raw ingestion (1 schema per source)
<ENV>_SILVER.<SOURCE>    → Curated / cleansed data
<ENV>_GOLD.<DOMAIN>      → Analytics-ready data
CONFIG.CONFIG            → Configuration management
AUDIT.AUDIT_LOGGING      → Compliance and audit logs
```

**What to expect:**
- Output SQL follows `IF NOT EXISTS` (fully idempotent — safe to re-run).
- All objects tagged with governance tags (`ENVIRONMENT`, `OWNER`, `SENSITIVITY`, `LAYER`, `SOURCE_SYSTEM`, `DATA_DOMAIN`).
- Gold schemas are **auto-inferred** from your source systems if not explicitly provided.

**Execution order of generated SQL:**
1. GOVERNANCE database + tag definitions
2. Per-environment databases (Bronze, Silver, Gold)
3. Source-aligned schemas
4. Shared databases (Config, Audit)
5. Tag assignments on databases and schemas

---

### Step 3 — RBAC Configuration 🔐
**Skill:** `skills/rbac/SKILL.md`

Using the business profile and database design, the agent generates a **least-privilege role hierarchy**:

```
ACCOUNTADMIN
    └── SECURITYADMIN  (manages all roles)
    └── SYSADMIN
            ├── FR_DATA_ENGG      (Functional Role — Data Engineers)
            ├── FR_ANALYTICS      (Functional Role — Analysts)
            └── FR_MANAGERS       (Functional Role — Managers)
                    └── AR_<ENV>_<DB>_<SCHEMA>_RO / RW  (Access Roles)
```

**What to expect:**
- The agent asks **9 clarifying security questions** before generating any SQL.
- If PII was declared in Step 1, it will ask additional masking strategy questions.
- Output includes:
  - Access role DDL with explicitly defined grants (no `ALL PRIVILEGES`)
  - Functional role DDL with `FUTURE GRANTS` applied
  - Dynamic data masking policies (if PII = Yes)
  - Row access policies (if requested)
  - A role hierarchy diagram + grant summary table

**Key rules followed automatically:**
- Never grant privileges directly to users — always through roles
- Service accounts (dbt, Fivetran, etc.) get dedicated functional roles
- Read-write and read-only access roles are always separated

---

### Step 4 — Warehouse Provisioning ⚙️
**Skill:** `skills/warehouse/SKILL.md`

Using the team structure and ETL load from Step 1, the agent sizes and provisions **enterprise-grade warehouses** with built-in cost controls.

**Sizing logic:**

| Data Volume | Base Size |
|-------------|-----------|
| < 100 GB | XSMALL |
| 100 – 500 GB | SMALL |
| 500 GB – 2 TB | MEDIUM |
| 2 – 10 TB | LARGE |
| 10 – 50 TB | XLARGE |
| > 50 TB | 2XLARGE |

Adjustments are automatically applied for: ETL/BI/ADHOC purpose, DEV environment downgrade, and HIGH criticality upgrade.

**Naming conventions generated:**

| Object | Pattern |
|--------|---------|
| Warehouse | `WH_<TEAM>_<ENV>_<PURPOSE>` |
| Role | `ROLE_<TEAM>_<ENV>` |
| Resource Monitor | `RM_<TEAM>_<ENV>` |

**What to expect:**
- SQL includes `CREATE`, `ALTER` (drift correction), and `GRANT` statements.
- **Resource monitors** are mandatory — cost quotas are enforced with `NOTIFY` at 80% and `SUSPEND` at 100%.
- Auto-suspend defaults: DEV=120s, QA=300s, PROD varies by purpose.
- For very large ETL (>10TB), separate `ETL_LOAD` and `ETL_TRANSFORM` warehouses are generated.
- `DRY_RUN=TRUE` mode available — outputs decision logic only, no SQL.

---

### Step 5 — Review & Deliver 📦

The agent compiles everything into a single, organized delivery document:

1. **Business Profile Summary**
2. **Database Architecture SQL** (Medallion layer + governance tags)
3. **RBAC SQL** (roles, grants, masking, row policies)
4. **Warehouse SQL** (warehouses, monitors, grants)
5. **Recommended Next Steps**

All SQL is **copy-paste ready** for Snowflake Worksheets or a CI/CD pipeline.

---

## Skipping Steps

You can jump directly to any sub-skill. Just ask the agent:

```
"Skip onboarding — here's my business profile: [paste profile]"
"I only need RBAC — my environments are DEV and PROD, my teams are..."
"Just generate warehouse SQL for a MEDIUM ETL team in PROD."
```

---

## Important Rules (The Agent Always Follows These)

1. **Always starts with Onboarding** unless explicitly told otherwise.
2. **Never grants more access than necessary** — when in doubt, the agent asks.
3. **All SQL is idempotent** — uses `IF NOT EXISTS` throughout.
4. **Cost controls are always applied** — resource monitors are never optional in PROD.
5. **Follows Snowflake-recommended role hierarchy** — ACCOUNTADMIN is never used in daily operations.

---

## Tips for Best Results

- ✅ Answer Category 4 (Data Sensitivity) fully — this directly shapes your security posture.
- ✅ Provide all source system names — they become your Bronze/Silver schema names.
- ✅ Specify your ETL tools — the agent will create dedicated service account roles for them.
- ⚠️ If you skip PII questions, the agent will warn you that masking defaults to **"No masking"**.
