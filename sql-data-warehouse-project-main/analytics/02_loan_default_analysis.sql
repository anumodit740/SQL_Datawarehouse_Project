/*
==========================================================================
  FILE:    02_loan_default_analysis.sql
  PURPOSE: Loan default analysis — examining default patterns across
           age groups, contract types, housing, and occupations.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries help identify which loan and demographic
           attributes are strongest predictors of default.
==========================================================================
*/


-- ============================================
-- Q6: What is the default rate by age group?
-- ============================================
SELECT
    CASE
        WHEN c.age_years BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age_years BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age_years BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age_years BETWEEN 46 AND 55 THEN '46-55'
        WHEN c.age_years > 55              THEN '55+'
        ELSE 'Unknown'
    END                                                 AS age_group,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    CASE
        WHEN c.age_years BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age_years BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age_years BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age_years BETWEEN 46 AND 55 THEN '46-55'
        WHEN c.age_years > 55              THEN '55+'
        ELSE 'Unknown'
    END
ORDER BY default_rate_pct DESC;
-- Explanation: Segments customers into age bands to reveal which
-- age cohorts carry the highest default risk. Younger borrowers
-- often have higher default rates due to thinner credit histories.


-- ============================================
-- Q7: What is the average credit amount for defaulters vs non-defaulters?
-- ============================================
SELECT
    CASE default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_applications,
    AVG(credit_amount)                                  AS avg_credit_amount,
    AVG(annuity_amount)                                 AS avg_annuity_amount,
    AVG(goods_price)                                    AS avg_goods_price,
    AVG(income_total)                                   AS avg_income
FROM gold.fact_loan_application
GROUP BY default_flag
ORDER BY default_flag;
-- Explanation: Compares average loan characteristics between defaulters
-- and non-defaulters. Higher credit amounts relative to income may
-- indicate over-leveraging.


-- ============================================
-- Q8: What is the default rate by contract type?
-- ============================================
SELECT
    contract_type,
    COUNT(*)                                            AS total_applications,
    SUM(CAST(default_flag AS INT))                      AS total_defaults,
    CAST(
        SUM(CAST(default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct,
    AVG(credit_amount)                                  AS avg_credit_amount,
    AVG(annuity_amount)                                 AS avg_annuity_amount
FROM gold.fact_loan_application
GROUP BY contract_type
ORDER BY default_rate_pct DESC;
-- Explanation: Identifies which loan contract types (e.g., Cash loans
-- vs Revolving loans) have higher default risk.


-- ============================================
-- Q9: What is the default rate by housing type?
-- ============================================
SELECT
    c.housing_type,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.housing_type
ORDER BY default_rate_pct DESC;
-- Explanation: Analyzes default rates across housing types. Customers
-- in rented or co-op apartments may behave differently from homeowners.


-- ============================================
-- Q10: Which are the top 10 occupation types with the highest default rate?
--      (minimum 100 customers to ensure statistical relevance)
-- ============================================
SELECT TOP 10
    c.occupation_type,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_loan_application f
INNER JOIN gold.dim_customer c
    ON f.customer_id = c.customer_id
WHERE c.occupation_type IS NOT NULL
GROUP BY c.occupation_type
HAVING COUNT(*) >= 100
ORDER BY default_rate_pct DESC;
-- Explanation: Identifies the riskiest occupations by default rate,
-- filtering for those with at least 100 customers to avoid noise
-- from small sample sizes. Useful for underwriting rule refinement.
