/*
==========================================================================
  FILE:    04_payment_behavior_analysis.sql
  PURPOSE: Payment behavior analysis — examining installment payment
           patterns, late payments, and their correlation with default.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries reveal behavioral signals from payment history
           that are strong predictors of future default.
==========================================================================
*/


-- ============================================
-- Q16: What are the average payment metrics by risk segment?
-- ============================================
SELECT
    r.risk_segment,
    COUNT(*)                                            AS customer_count,
    AVG(p.total_installments)                           AS avg_total_installments,
    AVG(p.late_payment_count)                           AS avg_late_payments,
    AVG(p.underpaid_count)                              AS avg_underpaid_count,
    AVG(p.avg_payment_delay_days)                       AS avg_delay_days,
    AVG(p.payment_completion_ratio)                     AS avg_completion_ratio,
    AVG(p.total_payment_amount)                         AS avg_total_paid
FROM gold.fact_payment_behavior p
INNER JOIN gold.report_customer_risk_summary r
    ON p.customer_id = r.customer_id
GROUP BY r.risk_segment
ORDER BY
    CASE r.risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Compares payment behavior metrics across risk segments.
-- High-risk customers are expected to show more late payments, higher
-- delays, and lower completion ratios.


-- ============================================
-- Q17: How do late payment patterns differ between
--      defaulters and non-defaulters?
-- ============================================
SELECT
    CASE f.default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_customers,
    AVG(p.late_payment_count)                           AS avg_late_payments,
    AVG(p.underpaid_count)                              AS avg_underpaid_count,
    AVG(p.avg_payment_delay_days)                       AS avg_delay_days,
    SUM(p.late_payment_count)                           AS total_late_payments,
    CAST(
        AVG(CASE 
            WHEN p.total_installments > 0 
            THEN p.late_payment_count * 100.0 / p.total_installments 
            ELSE 0 
        END) AS DECIMAL(5,2)
    )                                                   AS avg_late_payment_pct
FROM gold.fact_payment_behavior p
INNER JOIN gold.fact_loan_application f
    ON p.customer_id = f.customer_id
GROUP BY f.default_flag
ORDER BY f.default_flag;
-- Explanation: Quantifies the gap in late payment behavior between
-- defaulters and non-defaulters. This validates late payments as a
-- leading indicator of default.


-- ============================================
-- Q18: What is the distribution of payment completion ratios?
-- ============================================
SELECT
    CASE
        WHEN p.payment_completion_ratio >= 1.00 THEN '1. Fully Paid (100%+)'
        WHEN p.payment_completion_ratio >= 0.90 THEN '2. Near Complete (90-99%)'
        WHEN p.payment_completion_ratio >= 0.75 THEN '3. Mostly Paid (75-89%)'
        WHEN p.payment_completion_ratio >= 0.50 THEN '4. Partial (50-74%)'
        WHEN p.payment_completion_ratio > 0     THEN '5. Low (<50%)'
        ELSE '6. No Payments'
    END                                                 AS completion_band,
    COUNT(*)                                            AS customer_count,
    CAST(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)
    )                                                   AS pct_of_total,
    AVG(p.avg_payment_delay_days)                       AS avg_delay_days
FROM gold.fact_payment_behavior p
GROUP BY
    CASE
        WHEN p.payment_completion_ratio >= 1.00 THEN '1. Fully Paid (100%+)'
        WHEN p.payment_completion_ratio >= 0.90 THEN '2. Near Complete (90-99%)'
        WHEN p.payment_completion_ratio >= 0.75 THEN '3. Mostly Paid (75-89%)'
        WHEN p.payment_completion_ratio >= 0.50 THEN '4. Partial (50-74%)'
        WHEN p.payment_completion_ratio > 0     THEN '5. Low (<50%)'
        ELSE '6. No Payments'
    END
ORDER BY completion_band;
-- Explanation: Buckets customers by how much of their total installment
-- amount they have actually paid. Helps identify the proportion of
-- borrowers with significant payment shortfalls.


-- ============================================
-- Q19: Who are the top 20 customers with the highest payment delays?
-- ============================================
SELECT TOP 20
    p.customer_id,
    c.gender,
    c.age_years,
    c.occupation_type,
    p.avg_payment_delay_days,
    p.late_payment_count,
    p.total_installments,
    p.payment_completion_ratio,
    f.credit_amount,
    f.income_total,
    f.default_flag
FROM gold.fact_payment_behavior p
INNER JOIN gold.dim_customer c
    ON p.customer_id = c.customer_id
INNER JOIN gold.fact_loan_application f
    ON p.customer_id = f.customer_id
ORDER BY p.avg_payment_delay_days DESC;
-- Explanation: Lists the 20 customers with the longest average payment
-- delays along with their demographic and loan details. Useful for
-- collections prioritization and case-level investigation.


-- ============================================
-- Q20: What is the correlation between payment behavior metrics
--      and default status?
-- ============================================
SELECT
    CASE f.default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_customers,
    AVG(p.total_installments)                           AS avg_total_installments,
    AVG(p.late_payment_count)                           AS avg_late_payments,
    AVG(p.underpaid_count)                              AS avg_underpaid_count,
    AVG(p.avg_payment_delay_days)                       AS avg_delay_days,
    AVG(p.avg_payment_difference)                       AS avg_payment_difference,
    AVG(p.total_payment_amount)                         AS avg_total_paid,
    AVG(p.total_instalment_amount)                      AS avg_total_due,
    AVG(p.payment_completion_ratio)                     AS avg_completion_ratio
FROM gold.fact_payment_behavior p
INNER JOIN gold.fact_loan_application f
    ON p.customer_id = f.customer_id
GROUP BY f.default_flag
ORDER BY f.default_flag;
-- Explanation: Comprehensive side-by-side comparison of ALL payment
-- behavior metrics grouped by default status. This query is the
-- foundation for understanding which payment signals best discriminate
-- between good and bad borrowers.
