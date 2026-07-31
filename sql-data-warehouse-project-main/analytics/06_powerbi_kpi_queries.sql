/*
==========================================================================
  FILE:    06_powerbi_kpi_queries.sql
  PURPOSE: Power BI dashboard KPI queries — executive summary metrics,
           risk segment cards, trend data, riskiest profiles, and
           filter dimension queries for slicers.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries are designed to feed Power BI visuals directly.
           Each query maps to a specific dashboard component.
==========================================================================
*/


-- ============================================
-- Q26: Executive KPI Summary
--      (Total customers, default count, default rate, avg income,
--       avg credit, total credit portfolio)
-- ============================================
SELECT
    COUNT(DISTINCT r.customer_id)                       AS total_customers,
    SUM(CAST(r.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(r.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct,
    AVG(r.income_total)                                 AS avg_income,
    AVG(r.credit_amount)                                AS avg_credit_amount,
    SUM(r.credit_amount)                                AS total_credit_portfolio,
    AVG(r.annuity_amount)                               AS avg_annuity_amount,
    AVG(r.age_years)                                    AS avg_customer_age
FROM gold.report_customer_risk_summary r;
-- Explanation: Single-row executive summary designed for Power BI card
-- visuals. Provides the key portfolio-level KPIs at a glance.


-- ============================================
-- Q27: Risk segment summary for dashboard cards
-- ============================================
SELECT
    risk_segment,
    COUNT(*)                                            AS customer_count,
    CAST(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)
    )                                                   AS segment_pct,
    SUM(CAST(default_flag AS INT))                      AS default_count,
    CAST(
        SUM(CAST(default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS segment_default_rate,
    AVG(income_total)                                   AS avg_income,
    AVG(credit_amount)                                  AS avg_credit_amount,
    SUM(credit_amount)                                  AS total_credit_exposure,
    AVG(credit_income_ratio)                            AS avg_credit_income_ratio
FROM gold.report_customer_risk_summary
GROUP BY risk_segment
ORDER BY
    CASE risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Provides per-segment KPIs for Power BI card/table visuals.
-- Each row represents one risk segment with its key metrics.


-- ============================================
-- Q28: Periodic trend data using DWH load dates
--      (for time-series charts in Power BI)
-- ============================================
SELECT
    CAST(r.report_generated_date AS DATE)               AS report_date,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(r.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(r.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct,
    AVG(r.credit_amount)                                AS avg_credit_amount,
    AVG(r.income_total)                                 AS avg_income,
    SUM(r.credit_amount)                                AS total_credit_exposure,
    SUM(CASE WHEN r.risk_segment = 'High Risk' THEN 1 ELSE 0 END)
                                                        AS high_risk_count,
    SUM(CASE WHEN r.risk_segment = 'Medium Risk' THEN 1 ELSE 0 END)
                                                        AS medium_risk_count,
    SUM(CASE WHEN r.risk_segment = 'Low Risk' THEN 1 ELSE 0 END)
                                                        AS low_risk_count
FROM gold.report_customer_risk_summary r
GROUP BY CAST(r.report_generated_date AS DATE)
ORDER BY report_date;
-- Explanation: Aggregates key metrics by report generation date to enable
-- time-series trend analysis in Power BI. If only one load date exists,
-- this serves as a baseline for future incremental loads.


-- ============================================
-- Q29: Top 10 riskiest customer profiles
--      (combined risk indicators from all fact tables)
-- ============================================
SELECT TOP 10
    r.customer_id,
    r.gender,
    r.age_years,
    r.education_type,
    r.occupation_type,
    r.income_type,
    r.income_total,
    r.credit_amount,
    r.credit_income_ratio,
    r.annuity_income_ratio,
    r.default_flag,
    r.risk_segment,
    p.late_payment_count,
    p.avg_payment_delay_days,
    p.payment_completion_ratio,
    h.overdue_credit_count,
    h.total_credit_overdue,
    h.avg_credit_debt_ratio
FROM gold.report_customer_risk_summary r
LEFT JOIN gold.fact_payment_behavior p
    ON r.customer_id = p.customer_id
LEFT JOIN gold.fact_credit_history h
    ON r.customer_id = h.customer_id
WHERE r.risk_segment = 'High Risk'
ORDER BY
    ISNULL(p.avg_payment_delay_days, 0) DESC,
    ISNULL(h.overdue_credit_count, 0) DESC,
    r.credit_income_ratio DESC;
-- Explanation: Identifies the 10 riskiest customers by combining signals
-- from payment delays, bureau overdue counts, and credit-income ratios.
-- Designed for a Power BI detailed table or drill-through page.


-- ============================================
-- Q30: Dashboard filter dimensions
--      (distinct values for Power BI slicers)
-- ============================================

-- Gender slicer values
SELECT DISTINCT gender AS filter_value, 'Gender' AS filter_type
FROM gold.dim_customer
WHERE gender IS NOT NULL

UNION ALL

-- Education type slicer values
SELECT DISTINCT education_type, 'Education Type'
FROM gold.dim_customer
WHERE education_type IS NOT NULL

UNION ALL

-- Occupation type slicer values
SELECT DISTINCT occupation_type, 'Occupation Type'
FROM gold.dim_customer
WHERE occupation_type IS NOT NULL

UNION ALL

-- Income type slicer values
SELECT DISTINCT income_type, 'Income Type'
FROM gold.dim_customer
WHERE income_type IS NOT NULL

UNION ALL

-- Housing type slicer values
SELECT DISTINCT housing_type, 'Housing Type'
FROM gold.dim_customer
WHERE housing_type IS NOT NULL

ORDER BY filter_type, filter_value;
-- Explanation: Retrieves all distinct dimension values for Power BI slicer
-- filters. This single query provides values for gender, education,
-- occupation, income type, and housing type dropdowns. Useful for
-- dynamically populating filter lists without hardcoding values.
