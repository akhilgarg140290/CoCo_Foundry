---
name: Virtual Warehouse Setup
description: Size and create Snowflake virtual warehouses based on team structure, ETL load, and concurrency requirements.
---

# Virtual Warehouse Setup Skill

Generate Snowflake virtual warehouse creation SQL based on the customer's team structure, ETL workload, and concurrency needs.

## Prerequisites

Requires the completed **Business Profile** from the Onboarding skill. Key inputs:
- Teams and team sizes
- ETL load intensity (Light / Medium / Heavy)
- ETL tools in use
- Whether separate warehouses per workload type are desired

## Warehouse Strategy

### Recommended: Workload-Based Isolation

Separate warehouses prevent resource contention between different workload types.

| Warehouse | Purpose | Who Uses It | Sizing Guide |
|-----------|---------|-------------|-------------|
| `{ENV}_ETL_WH` | Data loading & transformation | Data Engineers, ETL tools, dbt | Based on ETL load intensity |
| `{ENV}_ANALYTICS_WH` | BI queries & dashboards | Analysts, BI tools (Tableau, Looker) | Based on analytics team size |
| `{ENV}_ADHOC_WH` | Exploratory / ad-hoc queries | Managers, ad-hoc users | Small, auto-suspend quickly |
| `{ENV}_DS_WH` | Data science workloads | Data Scientists | Medium, may need higher memory |

### Sizing Matrix

| ETL Load | ETL WH Size | Analytics WH Size | Ad-Hoc WH Size | DS WH Size |
|----------|------------|-------------------|-----------------|------------|
| **Light** (< 10 GB/day) | X-SMALL | X-SMALL | X-SMALL | X-SMALL |
| **Medium** (10–100 GB/day) | SMALL | SMALL | X-SMALL | SMALL |
| **Heavy** (> 100 GB/day) | MEDIUM–LARGE | MEDIUM | SMALL | MEDIUM |

### Auto-Suspend & Auto-Resume

| Warehouse Type | Auto-Suspend | Auto-Resume | Rationale |
|---------------|-------------|-------------|-----------|
| ETL | 120 seconds | Yes | Short idle periods between loads |
| Analytics | 300 seconds | Yes | Users may pause between queries |
| Ad-Hoc | 60 seconds | Yes | Minimize cost for infrequent use |
| Data Science | 300 seconds | Yes | Longer think time between runs |

## Questions to Ask

| # | Question | Default |
|---|----------|---------|
| W1 | Confirm warehouse sizing based on ETL load intensity? | Use sizing matrix above |
| W2 | Do you need **multi-cluster warehouses** for concurrency? | No (unless team > 15 users) |
| W3 | What is the **maximum clusters** for multi-cluster? | 3 |
| W4 | Any **resource monitors** / credit limits needed? | Recommended: Yes |
| W5 | Should warehouses **auto-suspend** when idle? | Yes (always) |

## SQL Template

Use `templates/warehouse_config.sql` to generate the output.
