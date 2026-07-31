/*
==========================================================================
  FILE:    03_income_credit_analysis.sql
  PURPOSE: Income and credit analysis — exploring the relationship between
           income levels, credit amounts, financial ratios, and default risk.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries support affordability analysis and help calibrate
           credit-to-income based lending policies.
==========================================================================
*/


-- ============================================
-- Q11: What is the income distribution by risk segment?
--      (avg, min, max, and median)
-- ============================================
SELECT
    risk_segment,
    COUNT(*)                                            AS customer_count,
    AVG(income_total)                                   AS avg_income,
    MIN(income_total)                                   AS min_income,
    MAX(income_total)                                   AS max_income,
    PERCENTILE_CONT(0.5) WITHIN GROUP 
        (ORDER BY income_total) OVER (PARTITION BY risk_segment)
                                                        AS median_income
FROM gold.report_customer_risk_summary
GROUP BY risk_segment
ORDER BY
    CASE risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Provides a full statistical distribution of income for each
-- risk segment. Median is included because income distributions are often
-- right-skewed, making the mean misleading.
-- NOTE: PERCENTILE_CONT is a window function in T-SQL; if this causes
-- issues, wrap the query in a CTE or use an approximate approach.


-- ============================================
-- Q12: How does the credit-to-income ratio differ between
--      defaulters and non-defaulters?
-- ============================================
SELECT
    CASE default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_customers,
    AVG(credit_income_ratio)                            AS avg_credit_income_ratio,
    MIN(credit_income_ratio)                            AS min_credit_income_ratio,
    MAX(credit_income_ratio)                            AS max_credit_income_ratio,
    AVG(credit_amount)                                  AS avg_credit_amount,
    AVG(income_total)                                   AS avg_income
FROM gold.fact_loan_application
GROUP BY default_flag
ORDER BY default_flag;
-- Explanation: Compares credit-to-income ratios between defaulters and
-- non-defaulters. A higher ratio suggests over-leveraging and is a
-- key predictor of repayment difficulty.


-- ============================================
-- Q13: What is the annuity burden analysis by default status?
-- ============================================
SELECT
    CASE default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_customers,
    AVG(annuity_income_ratio)                           AS avg_annuity_income_ratio,
    AVG(annuity_amount)                                 AS avg_annuity_amount,
    AVG(income_total)                                   AS avg_income,
    AVG(goods_credit_ratio)                             AS avg_goods_credit_ratio
FROM gold.fact_loan_application
GROUP BY default_flag
ORDER BY default_flag;
-- Explanation: Measures annuity burden (monthly payment as % of income)
-- by default status. Customers with high annuity-to-income ratios are
-- more likely to struggle with repayments.


-- ============================================
-- Q14: What is the credit amount distribution by education type?
-- ============================================
SELECT
    c.education_type,
    COUNT(*)                                            AS total_applications,
    AVG(f.credit_amount)                                AS avg_credit_amount,
    MIN(f.credit_amount)                                AS min_credit_amount,
    MAX(f.credit_amount)                                AS max_credit_amount,
    AVG(f.income_total)                                 AS avg_income,
    AVG(f.credit_income_ratio)                          AS avg_credit_income_ratio,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.education_type
ORDER BY avg_credit_amount DESC;
-- Explanation: Analyzes how credit amounts and income vary by education
-- level. Higher education typically correlates with higher income and
-- larger loan amounts, but also potentially lower default rates.


-- ============================================
-- Q15: What are the default rates across income bands?
--      (0-50k, 50k-100k, 100k-200k, 200k-500k, 500k+)
-- ============================================
SELECT
    CASE
        WHEN f.income_total <= 50000                  THEN '1. 0 - 50K'
        WHEN f.income_total BETWEEN 50001 AND 100000  THEN '2. 50K - 100K'
        WHEN f.income_total BETWEEN 100001 AND 200000 THEN '3. 100K - 200K'
        WHEN f.income_total BETWEEN 200001 AND 500000 THEN '4. 200K - 500K'
        WHEN f.income_total > 500000                  THEN '5. 500K+'
        ELSE '6. Unknown'
    END                                                 AS income_band,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct,
    AVG(f.credit_amount)                                AS avg_credit_amount,
    AVG(f.credit_income_ratio)                          AS avg_credit_income_ratio
FROM gold.fact_loan_application f
GROUP BY
    CASE
        WHEN f.income_total <= 50000                  THEN '1. 0 - 50K'
        WHEN f.income_total BETWEEN 50001 AND 100000  THEN '2. 50K - 100K'
        WHEN f.income_total BETWEEN 100001 AND 200000 THEN '3. 100K - 200K'
        WHEN f.income_total BETWEEN 200001 AND 500000 THEN '4. 200K - 500K'
        WHEN f.income_total > 500000                  THEN '5. 500K+'
        ELSE '6. Unknown'
    END
ORDER BY income_band;
-- Explanation: Groups customers into income bands and calculates default
-- rates for each. This reveals whether lower-income borrowers face
-- disproportionately higher default risk — a critical input for
-- income-based credit policy thresholds.
