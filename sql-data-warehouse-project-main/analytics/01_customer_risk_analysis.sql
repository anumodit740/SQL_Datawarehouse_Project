/*
==========================================================================
  FILE:    01_customer_risk_analysis.sql
  PURPOSE: Customer risk analysis — default rates across demographic 
           dimensions and risk segment distribution.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries power customer risk dashboards and support
           credit risk segmentation analysis.
==========================================================================
*/


-- ============================================
-- Q1: What is the overall default rate across all loan applications?
-- ============================================
SELECT
    COUNT(*)                                            AS total_applications,
    SUM(CAST(default_flag AS INT))                      AS total_defaults,
    CAST(
        SUM(CAST(default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application;
-- Explanation: Calculates the portfolio-wide default rate as a percentage.
-- This is the single most important KPI for credit risk monitoring.


-- ============================================
-- Q2: How does the default rate vary by gender?
-- ============================================
SELECT
    c.gender,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.gender
ORDER BY default_rate_pct DESC;
-- Explanation: Breaks down default rate by gender to identify if any
-- gender segment carries disproportionately higher risk.


-- ============================================
-- Q3: What is the default rate by education type?
-- ============================================
SELECT
    c.education_type,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.education_type
ORDER BY default_rate_pct DESC;
-- Explanation: Analyzes default rates across education levels.
-- Higher education may correlate with lower default risk.


-- ============================================
-- Q4: What is the default rate by income type?
-- ============================================
SELECT
    c.income_type,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.income_type
ORDER BY default_rate_pct DESC;
-- Explanation: Identifies which income source categories are associated
-- with higher default risk (e.g., unemployed vs salaried).


-- ============================================
-- Q5: What is the distribution of customers across risk segments?
-- ============================================
SELECT
    risk_segment,
    COUNT(*)                                            AS customer_count,
    CAST(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)
    )                                                   AS segment_pct,
    AVG(income_total)                                   AS avg_income,
    AVG(credit_amount)                                  AS avg_credit_amount,
    AVG(CAST(default_flag AS DECIMAL(5,2)))             AS avg_default_rate
FROM gold.report_customer_risk_summary
GROUP BY risk_segment
ORDER BY 
    CASE risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Shows how customers are distributed across High / Medium / Low
-- risk segments, with average financial metrics per segment.
-- Useful for portfolio composition reporting.
