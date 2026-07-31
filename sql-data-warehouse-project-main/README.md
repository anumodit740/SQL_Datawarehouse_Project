<div align="center">

# 🏛️ Home Credit Risk Analytics Data Warehouse

### SQL Server Medallion Architecture Project

[![SQL Server](https://img.shields.io/badge/SQL_Server-2019+-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-FFD700?style=for-the-badge)](docs/architecture_explanation.md)
[![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](powerbi/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

*An enterprise-grade data warehouse built on the Home Credit Default Risk dataset, implementing Medallion Architecture with Bronze-Silver-Gold layers, star schema modeling, and business-ready analytics for credit risk assessment.*

[📖 Documentation](docs/) · [📊 Analytics](analytics/) · [📈 Power BI](powerbi/) · [🔍 Data Dictionary](docs/data_dictionary.md)

---

</div>

## 📋 Table of Contents

- [Business Problem](#-business-problem)
- [Project Summary](#-project-summary)
- [Dataset](#-dataset)
- [Tech Stack](#-tech-stack)
- [Architecture Overview](#-architecture-overview)
- [Medallion Layers](#-medallion-layers)
- [Data Model — Gold Layer](#-data-model--gold-layer)
- [Key Features](#-key-features)
- [Data Quality Framework](#-data-quality-framework)
- [Business Insights](#-business-insights)
- [Power BI Dashboard Plan](#-power-bi-dashboard-plan)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)
- [Interview Talking Points](#-interview-talking-points)
- [Future Improvements](#-future-improvements)
- [Author](#-author)

---

## 💼 Business Problem

> **How can a lending institution identify high-risk loan applicants and reduce default rates using historical data?**

Home Credit serves customers with limited or no traditional credit history. The challenge is to build a **centralized analytics platform** that:

- Identifies customer segments with elevated default probability
- Analyzes payment behavior patterns that predict loan default
- Leverages bureau credit history for comprehensive risk assessment
- Enables data-driven lending decisions through interactive dashboards
- Supports regulatory compliance with auditable data transformations

This data warehouse transforms **60M+ raw records** across 8 source tables into **actionable risk intelligence** through a structured Medallion Architecture pipeline.

---

## 🎯 Project Summary

| Attribute | Detail |
|-----------|--------|
| **Project** | Home Credit Risk Analytics Data Warehouse |
| **Domain** | Credit Risk Analytics & Financial Services |
| **Architecture** | Medallion (Bronze → Silver → Gold) |
| **Data Volume** | ~60M+ records across 8 source tables |
| **Database** | SQL Server 2019+ |
| **Key Deliverable** | Analytics-ready star schema with risk segmentation |

### What This Project Delivers

✅ End-to-end ETL pipeline from raw CSV to analytics-ready views  
✅ Comprehensive data cleaning & standardization (20+ derived columns)  
✅ Star schema dimensional model (1 dimension + 3 facts + 1 report view)  
✅ Risk segmentation engine (High / Medium / Low risk classification)  
✅ 30+ business analytics SQL queries  
✅ Data quality validation framework across all layers  
✅ Power BI dashboard specifications with DAX measures  

---

## 📊 Dataset

**Source:** [Kaggle — Home Credit Default Risk](https://www.kaggle.com/competitions/home-credit-default-risk/data)

| Table | Records | Domain |
|-------|---------|--------|
| `application_train` | **307,511** | Primary loan applications with default labels |
| `application_test` | **48,744** | Test applications (no target) |
| `bureau` | **1,716,428** | Credit bureau history records |
| `bureau_balance` | **27,299,925** | Monthly bureau balance snapshots |
| `previous_application` | **1,670,214** | Historical loan applications |
| `installments_payments` | **13,605,401** | Individual payment transactions |
| `POS_CASH_balance` | **10,001,358** | Point-of-sale cash balance records |
| `credit_card_balance` | **3,840,312** | Credit card statement data |

> 📁 CSV files are stored locally at `C:\home-credit-default-risk\` and excluded from the repository due to size constraints.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Database** | SQL Server 2019+ | Data warehouse engine |
| **Language** | T-SQL | ETL logic & analytics queries |
| **IDE** | SSMS / Azure Data Studio | Development & debugging |
| **Architecture** | Medallion (Bronze-Silver-Gold) | Layered data transformation |
| **Modeling** | Star Schema (Kimball) | Dimensional modeling |
| **BI Tool** | Power BI | Dashboards & visualization |
| **Version Control** | Git & GitHub | Source code management |
| **Diagrams** | Mermaid | Architecture & data flow diagrams |

---

## 🏛️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SOURCE LAYER                                 │
│  Kaggle CSV Files (8 tables, ~60M+ records)                        │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ BULK INSERT
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🥉 BRONZE LAYER              Raw Data Ingestion                    │
│  ─────────────────────────────────────────────────────────────────  │
│  • Exact replica of source files                                    │
│  • All columns NVARCHAR(255) — no type casting                     │
│  • Truncate & Load strategy                                         │
│  • Data lineage via dwh_load_date                                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Stored Procedures
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🥈 SILVER LAYER              Cleaned & Standardized                │
│  ─────────────────────────────────────────────────────────────────  │
│  • Type casting (TRY_CAST) & NULL handling                         │
│  • Categorical standardization (M→Male, Y→Yes)                     │
│  • 20+ derived columns (age_years, risk ratios, payment flags)     │
│  • Business rule application                                        │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Views (Star Schema)
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  🏆 GOLD LAYER                Business-Ready Analytics              │
│  ─────────────────────────────────────────────────────────────────  │
│  • dim_customer (demographics & profile)                            │
│  • fact_loan_application (financial metrics & default flag)         │
│  • fact_payment_behavior (aggregated payment patterns)              │
│  • fact_credit_history (bureau credit summary)                      │
│  • report_customer_risk_summary (risk segmentation mart)           │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  📊 ANALYTICS & REPORTING     Power BI / SQL Queries                │
└─────────────────────────────────────────────────────────────────────┘
```

> 📐 See detailed diagrams: [`docs/diagrams/`](docs/diagrams/)

---

## 🔶 Medallion Layers

### 🥉 Bronze Layer — Raw Ingestion

| Aspect | Detail |
|--------|--------|
| **Strategy** | Truncate & Load via `BULK INSERT` |
| **Schema** | All columns `NVARCHAR(255)` — no transformations |
| **Tables** | 8 main tables + 2 reference tables |
| **Purpose** | Audit trail, data lineage, rollback capability |

### 🥈 Silver Layer — Cleaning & Enrichment

| Transformation | Example |
|---------------|---------|
| **Type Casting** | `TRY_CAST(SK_ID_CURR AS INT)` |
| **NULL Handling** | `NULLIF(value, '')` for empty strings |
| **Standardization** | `M → Male`, `F → Female`, `Y → Yes`, `N → No` |
| **Age Calculation** | `ABS(DAYS_BIRTH) / 365.25 → age_years` |
| **Financial Ratios** | `credit_amount / income_total → credit_income_ratio` |
| **Payment Flags** | `underpaid_flag`, `late_payment_flag`, `dpd_flag` |
| **Risk Indicators** | `overdue_flag`, `credit_debt_ratio`, `credit_utilization_ratio` |

### 🏆 Gold Layer — Star Schema Views

| Object | Type | Grain | Records |
|--------|------|-------|---------|
| `gold.dim_customer` | Dimension | 1 per customer | ~307K |
| `gold.fact_loan_application` | Fact | 1 per application | ~307K |
| `gold.fact_payment_behavior` | Fact | 1 per customer (aggregated) | Varies |
| `gold.fact_credit_history` | Fact | 1 per customer (aggregated) | Varies |
| `gold.report_customer_risk_summary` | Report | 1 per customer (joined) | ~307K |

---

## 📐 Data Model — Gold Layer

```mermaid
erDiagram
    dim_customer ||--o{ fact_loan_application : "customer_id"
    dim_customer ||--o{ fact_payment_behavior : "customer_id"
    dim_customer ||--o{ fact_credit_history : "customer_id"

    dim_customer {
        bigint customer_key PK
        int customer_id BK
        varchar gender
        decimal age_years
        varchar education_type
        varchar occupation_type
        varchar income_type
        varchar family_status
        varchar housing_type
        varchar owns_car
        varchar owns_realty
    }

    fact_loan_application {
        int customer_id FK
        tinyint default_flag
        decimal income_total
        decimal credit_amount
        decimal annuity_amount
        decimal credit_income_ratio
        decimal annuity_income_ratio
    }

    fact_payment_behavior {
        int customer_id FK
        int total_installments
        int late_payment_count
        int underpaid_count
        decimal payment_completion_ratio
        decimal avg_payment_delay_days
    }

    fact_credit_history {
        int customer_id FK
        int total_bureau_records
        int active_credit_count
        int overdue_credit_count
        decimal total_credit_sum
        decimal avg_credit_debt_ratio
    }
```

### Risk Segmentation Logic

```
┌─────────────────────────────────────────────────────────────┐
│  🔴 HIGH RISK                                               │
│  • default_flag = 1                                         │
│  • OR late_payment_count ≥ 3                                │
│  • OR underpaid_count ≥ 3                                   │
│  • OR overdue_credit_count ≥ 2                              │
├─────────────────────────────────────────────────────────────┤
│  🟡 MEDIUM RISK                                             │
│  • credit_income_ratio ≥ 5                                  │
│  • OR annuity_income_ratio ≥ 0.4                            │
│  • OR active_credit_count ≥ 5                               │
├─────────────────────────────────────────────────────────────┤
│  🟢 LOW RISK                                                │
│  • All other customers                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## ⭐ Key Features

| Feature | Description |
|---------|-------------|
| **Enterprise ETL** | Stored procedures with `TRY/CATCH` error handling and execution timing |
| **Derived Analytics** | 20+ business columns created at Silver layer (ratios, flags, scores) |
| **Star Schema** | Kimball-style dimensional model with surrogate keys |
| **Risk Engine** | Multi-factor risk segmentation combining default, payment, and bureau data |
| **Data Quality** | Validation scripts across Bronze, Silver, and Gold layers |
| **Audit Trail** | `dwh_load_date` metadata on every record across all layers |

---

## ✅ Data Quality Framework

Comprehensive validation is implemented across all three layers:

| Check Type | Bronze | Silver | Gold |
|-----------|--------|--------|------|
| Row Count Validation | ✅ | ✅ | ✅ |
| NULL Business Key Checks | ✅ | ✅ | ✅ |
| Duplicate Detection | ✅ | ✅ | ✅ |
| Referential Integrity | — | — | ✅ |
| Financial Sanity Checks | — | ✅ | ✅ |
| Category Standardization | — | ✅ | — |
| Risk Segment Validation | — | — | ✅ |
| Sample Record Inspection | ✅ | ✅ | ✅ |

> 📄 See full details: [`docs/data_quality_summary.md`](docs/data_quality_summary.md)

---

## 💡 Business Insights

The Gold layer enables these key analytics capabilities:

| Insight Area | Key Questions Answered |
|-------------|----------------------|
| **Default Risk** | Overall default rate, high-risk segments, default predictors |
| **Customer Segmentation** | Risk by age, income, education, occupation, family status |
| **Payment Behavior** | Late payment patterns, underpayment trends, completion ratios |
| **Bureau History** | Active vs overdue credits, debt ratios, credit bureau patterns |
| **Financial Profile** | Credit-to-income analysis, annuity burden, credit distribution |

> 📊 See analytics queries: [`analytics/`](analytics/) · Detailed insights: [`docs/business_insights.md`](docs/business_insights.md)

---

## 📈 Power BI Dashboard Plan

| Page | Focus | Key Visuals |
|------|-------|-------------|
| **Executive Overview** | KPI cards, risk overview | Total customers, default rate %, total credit, avg income |
| **Customer Risk Segmentation** | Demographic risk analysis | Risk by age, income, education, occupation |
| **Credit & Bureau Analysis** | Bureau credit history | Active vs closed credits, debt ratios, overdue analysis |
| **Payment Behavior** | Payment pattern analysis | Late payments, completion ratio, installment trends |

> 📋 See full specifications: [`powerbi/`](powerbi/) · DAX measures: [`powerbi/dax_measures.md`](powerbi/dax_measures.md)

---

## 📁 Project Structure

```
sql-data-warehouse-project/
│
├── 📄 README.md                          ← You are here
│
├── 📂 scripts/                           ← ETL Pipeline (Complete ✅)
│   ├── init_database.sql                 ← Database & schema creation
│   ├── 📂 bronze/                        ← Raw data ingestion
│   │   ├── ddl_bronze_*.sql              ← Table definitions (5 files)
│   │   ├── proc_load_bronze.sql          ← Bulk loading procedure
│   │   └── proc_load_bronze_clean.sql    ← Clean loading variant
│   ├── 📂 silver/                        ← Data cleaning & enrichment
│   │   ├── ddl_silver_*.sql              ← Table definitions (5 files)
│   │   ├── proc_load_silver_*.sql        ← Transformation procedures (5 files)
│   │   └── proc_load_silver.sql          ← Orchestration procedure
│   ├── 📂 gold/                          ← Star schema views
│   │   ├── ddl_gold_dimensions.sql       ← dim_customer view
│   │   ├── ddl_gold_facts.sql            ← 3 fact views
│   │   ├── ddl_gold_reports.sql          ← Risk summary report view
│   │   └── validation_gold.sql           ← Gold layer validation
│   └── 📂 tests/                         ← Data quality checks
│       ├── quality_checks_bronze.sql
│       ├── quality_checks_silver.sql
│       └── quality_checks_gold.sql
│
├── 📂 analytics/                         ← Business SQL Queries
│   ├── 01_customer_risk_analysis.sql
│   ├── 02_loan_default_analysis.sql
│   ├── 03_income_credit_analysis.sql
│   ├── 04_payment_behavior_analysis.sql
│   ├── 05_bureau_credit_history_analysis.sql
│   └── 06_powerbi_kpi_queries.sql
│
├── 📂 docs/                              ← Documentation
│   ├── project_overview.md
│   ├── business_problem.md
│   ├── architecture_explanation.md
│   ├── data_flow.md
│   ├── data_dictionary.md
│   ├── gold_layer_explanation.md
│   ├── business_insights.md
│   ├── interview_questions.md
│   ├── data_quality_summary.md
│   ├── future_improvements.md
│   └── 📂 diagrams/                      ← Mermaid Architecture Diagrams
│       ├── high_level_architecture.mmd
│       ├── medallion_architecture.mmd
│       ├── data_flow_lineage.mmd
│       ├── source_to_gold_mapping.mmd
│       ├── gold_star_schema.mmd
│       ├── project_workflow.mmd
│       └── analytics_consumption_layer.mmd
│
├── 📂 powerbi/                           ← Power BI Support
│   ├── dashboard_requirements.md
│   ├── dashboard_page_design.md
│   ├── kpi_definitions.md
│   ├── dax_measures.md
│   ├── powerbi_data_model.md
│   └── visualization_plan.md
│
└── 📂 datasets/
    └── README.txt                        ← Dataset source instructions
```

---

## 🚀 How to Run

### Prerequisites
- SQL Server 2019+ (Developer or Express edition)
- SSMS or Azure Data Studio
- ~10 GB free disk space
- [Download Kaggle dataset](https://www.kaggle.com/competitions/home-credit-default-risk/data)

### Step-by-Step Execution

```sql
-- Step 1: Create database and schemas
-- Execute: scripts/init_database.sql

-- Step 2: Create Bronze tables
-- Execute all scripts in: scripts/bronze/ddl_bronze_*.sql

-- Step 3: Load raw data into Bronze
-- Execute: scripts/bronze/proc_load_bronze_clean.sql
EXEC bronze.load_bronze_clean;

-- Step 4: Validate Bronze layer
-- Execute: scripts/tests/quality_checks_bronze.sql

-- Step 5: Create Silver tables
-- Execute all scripts in: scripts/silver/ddl_silver_*.sql

-- Step 6: Transform and load Silver
-- Execute: scripts/silver/proc_load_silver.sql
EXEC silver.load_silver;

-- Step 7: Validate Silver layer
-- Execute: scripts/tests/quality_checks_silver.sql

-- Step 8: Create Gold views
-- Execute (in order):
--   scripts/gold/ddl_gold_dimensions.sql
--   scripts/gold/ddl_gold_facts.sql
--   scripts/gold/ddl_gold_reports.sql

-- Step 9: Validate Gold layer
-- Execute: scripts/gold/validation_gold.sql
-- Execute: scripts/tests/quality_checks_gold.sql

-- Step 10: Run analytics queries
-- Execute any script in: analytics/
```

### Rendering Mermaid Diagrams

Mermaid diagrams (`.mmd` files) in `docs/diagrams/` can be rendered:

- **GitHub**: Automatically rendered in `.md` files using ```mermaid code blocks
- **VS Code**: Install the [Mermaid Preview](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid) extension
- **Online**: Paste into [Mermaid Live Editor](https://mermaid.live)
- **CLI**: Use `mmdc` (Mermaid CLI) to export PNG/SVG: `npx @mermaid-js/mermaid-cli mmdc -i input.mmd -o output.png`

---

## 🎤 Interview Talking Points

<details>
<summary><b>Click to expand — Key points for interviews and resume discussions</b></summary>

### "Tell me about this project"
> *"I built an enterprise-grade data warehouse on SQL Server using the Medallion Architecture pattern. The project processes 60M+ records from the Home Credit Default Risk dataset through three layers — Bronze for raw ingestion, Silver for cleaning and enrichment, and Gold for star schema analytics. The Gold layer powers risk segmentation that classifies customers into High, Medium, and Low risk categories based on default history, payment behavior, and bureau credit data."*

### "Why Medallion Architecture?"
> *"Medallion Architecture provides clear separation of concerns — each layer has a distinct responsibility. Bronze preserves raw data for auditability, Silver handles data quality and transformations, and Gold serves optimized analytics. This pattern is widely adopted in modern data platforms including Databricks and Microsoft Fabric."*

### "How does the risk segmentation work?"
> *"The risk model combines three data sources: default history from loan applications, payment behavior from installment records, and bureau credit history. A customer is classified as High Risk if they have a default event, 3+ late payments, 3+ underpayments, or 2+ overdue bureau credits. Medium Risk captures customers with high credit-to-income ratios or excessive active credits."*

### "What data quality measures did you implement?"
> *"I built a three-layer validation framework covering row count validation, NULL key checks, duplicate detection, referential integrity between facts and dimensions, financial sanity checks for derived ratios, and risk segment distribution analysis."*

### "What would you improve?"
> *"Immediate priorities would be incremental loading to replace full truncate-and-load, adding SCD Type 2 for customer dimension history, implementing proper ETL logging to an audit table, and deploying the Power BI dashboard. Long-term, I'd consider migrating to dbt for transformation management and deploying on Azure SQL Database."*

</details>

> 📋 Full interview prep with 70 Q&As: [`docs/interview_questions.md`](docs/interview_questions.md)

---

## 🚀 Future Improvements

| Priority | Enhancement | Complexity |
|----------|-------------|-----------|
| 🔴 Must-Have | Incremental / Delta Loading | Medium |
| 🔴 Must-Have | ETL Logging & Audit Table | Low |
| 🔴 Must-Have | Error Handling Framework | Low |
| 🟡 Nice-to-Have | Power BI Dashboard Deployment | Medium |
| 🟡 Nice-to-Have | SCD Type 2 Dimensions | Medium |
| 🟡 Nice-to-Have | CI/CD with GitHub Actions | Medium |
| 🟢 Advanced | dbt Migration | High |
| 🟢 Advanced | Azure SQL Deployment | High |
| 🟢 Advanced | Airflow Orchestration | High |
| 🟢 Advanced | ML Model Integration | High |

> 📄 Full roadmap: [`docs/future_improvements.md`](docs/future_improvements.md)

---

## 👤 Author

**Anumodit Shukla**

📚 B.Tech in Biotechnology & Biochemical Engineering — NIT Agartala

💼 Interests: Data Analytics · Data Engineering · Machine Learning · Data Architecture

<a href="https://github.com/anumodit740" target="_blank">
  <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub">
</a>
<a href="https://www.linkedin.com/in/anumodit-shukla-59aa18288" target="_blank">
  <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
</a>

---

<div align="center">

**⭐ If this project helped you, please consider giving it a star!**

*Built with SQL Server · Medallion Architecture · Star Schema · T-SQL*

</div>
