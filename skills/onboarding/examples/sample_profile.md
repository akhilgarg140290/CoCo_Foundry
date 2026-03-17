# Business Profile — MedCare Health Systems

> Generated on: 2026-03-17

## 1. Business Overview

| Field | Value |
|-------|-------|
| **Company / Project Name** | MedCare Health Systems |
| **Business Domain** | Healthcare |
| **Business Overview** | Regional healthcare provider moving EHR, billing, and scheduling data to Snowflake for unified analytics and regulatory reporting. |

## 2. Source Systems

| Field | Value |
|-------|-------|
| **Number of Source Systems** | 4 |
| **Source System Names** | Epic EHR, SAP Billing, Kronos Scheduling, Flat Files (CSV) |
| **Average Total Data Volume** | 10 TB |
| **Daily Incremental Load** | 25 GB/day |

## 3. Environments

| Field | Value |
|-------|-------|
| **Number of Environments** | 3 |
| **Environment Names** | DEV, QA, PROD |
| **Account Strategy** | Same account with naming conventions |

## 4. Data Sensitivity & Security

| Field | Value |
|-------|-------|
| **Contains PII?** | Yes |
| **PII Types** | SSN, Patient Name, DOB, Email, Phone |
| **Schema-Level Hiding** | Yes |
| **Dynamic Data Masking** | Yes |
| **Row-Level Security** | No |

## 5. Teams & Users

| Team | Size | User Types |
|------|------|------------|
| Data Engineering | 5 | Admin, Developer |
| Analytics | 8 | Analyst, Viewer |
| Managers | 3 | Viewer |
| Data Science | 2 | Developer, Analyst |

## 6. ETL & Workload

| Field | Value |
|-------|-------|
| **ETL Load Intensity** | Medium |
| **ETL Tools** | dbt, Fivetran |
| **Separate Warehouses per Workload** | Yes |
