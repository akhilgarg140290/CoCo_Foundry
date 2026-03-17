---
name: Onboarding Questionnaire
description: Interactive business discovery questionnaire to capture customer requirements for Snowflake platform setup.
---

# Onboarding Questionnaire Skill

Conduct an interactive Q&A session with the customer to build a complete business profile. This profile drives all downstream configuration (RBAC, warehouses, environments).

## Instructions

1. **Present questions one category at a time** (not all at once) to avoid overwhelming the user.
2. **Allow skipping** — if the user says "skip", mark the field as `[SKIPPED]` and move on.
3. **Suggest defaults** where applicable (shown in the questions below).
4. **Validate answers** — e.g., if data volume seems unusually high/low, confirm with the user.
5. After all categories are complete, **generate a filled Business Profile** using the template at `templates/business_profile.md`.

## Question Flow

### Category 1: Business Overview

Ask these questions together:

| # | Question | Example / Default |
|---|----------|-------------------|
| 1.1 | What is your **company/project name**? | — |
| 1.2 | What is your **business domain**? | Healthcare, Finance, Retail, etc. |
| 1.3 | Brief **business overview** — what does the platform need to accomplish? | — |

### Category 2: Source Systems

| # | Question | Example / Default |
|---|----------|-------------------|
| 2.1 | How many **source systems** do you have? | e.g., 5 |
| 2.2 | What are the **names of the source systems**? | e.g., SAP, Salesforce, MySQL DB, Flat Files, API |
| 2.3 | What is the **average total data volume** across all sources? | e.g., 10 TB |
| 2.4 | What is the **expected daily incremental load volume**? | e.g., 50 GB/day |

### Category 3: Environments

| # | Question | Example / Default |
|---|----------|-------------------|
| 3.1 | How many **environments** do you need? | Default: 3 (DEV, QA, PROD) |
| 3.2 | What are the **environment names**? | e.g., DEV, QA, UAT, PROD |
| 3.3 | Should environments be in **separate Snowflake accounts** or the **same account with naming conventions**? | Default: Same account |

### Category 4: Data Sensitivity & Security

| # | Question | Example / Default |
|---|----------|-------------------|
| 4.1 | Does your data contain **PII** (Personally Identifiable Information)? | Yes / No |
| 4.2 | If PII: What **types of PII** data? | e.g., SSN, Email, Phone, Address, DOB |
| 4.3 | Is **schema-level hiding** required? (restrict visibility of certain schemas to specific roles) | Yes / No |
| 4.4 | Do you need **dynamic data masking** on PII columns? | Yes / No |
| 4.5 | Do you need **row-level security** (row access policies)? | Yes / No |

### Category 5: Teams & Users

| # | Question | Example / Default |
|---|----------|-------------------|
| 5.1 | What **teams** will use the platform? | e.g., Data Engineering, Analytics, Managers, Data Science |
| 5.2 | What is the **size of each team**? | e.g., Data Engineering: 5, Analytics: 10 |
| 5.3 | What **types of users** are in each team? | e.g., Admin, Developer, Analyst, Viewer |

### Category 6: ETL & Workload

| # | Question | Example / Default |
|---|----------|-------------------|
| 6.1 | What is the expected **ETL load intensity**? | Light / Medium / Heavy |
| 6.2 | What **ETL tools** do you use or plan to use? | e.g., dbt, Fivetran, Informatica, Custom Python |
| 6.3 | Do you need **separate warehouses** per workload type (ETL vs. BI vs. Ad-hoc)? | Default: Yes (recommended) |

## After Completion

1. Generate a filled `business_profile.md` using the template.
2. Present the summary to the user for review.
3. Ask: *"Would you like to proceed to RBAC configuration, warehouse setup, or both?"*
4. Route to the appropriate sub-skill(s).

## Handling Skips

- If the user skips an entire category, note it as `[SKIPPED — using defaults]`.
- If critical security questions (Category 4) are skipped, **warn the user** that PII handling defaults to "No masking" and confirm they accept the risk.
