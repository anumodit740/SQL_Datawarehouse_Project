/*
==========================================================================
  FILE:    05_bureau_credit_history_analysis.sql
  PURPOSE: Bureau credit history analysis — external credit data patterns,
           overdue trends, and their relationship with default risk.
  AUTHOR:  Anumodit Shukla
  DATE:    2026-06-09
  USAGE:   Run against the Gold layer views in SQL Server.
           These queries leverage credit bureau data to assess how
           external credit behavior predicts default on current loans.
==========================================================================
*/


-- ============================================
-- Q21: What does the bureau credit history look like by risk segment?
-- ============================================
SELECT
    r.risk_segment,
    COUNT(*)                                            AS customer_count,
    AVG(h.total_bureau_records)                         AS avg_bureau_records,
    AVG(h.active_credit_count)                          AS avg_active_credits,
    AVG(h.overdue_credit_count)                         AS avg_overdue_credits,
    AVG(h.total_credit_sum)                             AS avg_total_credit_sum,
    AVG(h.total_credit_debt)                            AS avg_total_credit_debt,
    AVG(h.total_credit_overdue)                         AS avg_total_overdue_amt
FROM gold.fact_credit_history h
INNER JOIN gold.report_customer_risk_summary r
    ON h.customer_id = r.customer_id
GROUP BY r.risk_segment
ORDER BY
    CASE r.risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Summarizes bureau credit data by risk segment to reveal
-- how external credit exposure and overdue patterns vary across
-- risk tiers. High-risk customers typically have more overdue credits.


-- ============================================
-- Q22: How do active and overdue credit counts compare
--      between defaulters and non-defaulters?
-- ============================================
SELECT
    CASE f.default_flag
        WHEN 1 THEN 'Defaulted'
        WHEN 0 THEN 'Non-Defaulted'
    END                                                 AS default_status,
    COUNT(*)                                            AS total_customers,
    AVG(h.active_credit_count)                          AS avg_active_credits,
    AVG(h.overdue_credit_count)                         AS avg_overdue_credits,
    SUM(h.overdue_credit_count)                         AS total_overdue_credits,
    CAST(
        AVG(CASE 
            WHEN h.active_credit_count > 0 
            THEN h.overdue_credit_count * 100.0 / h.active_credit_count 
            ELSE 0 
        END) AS DECIMAL(5,2)
    )                                                   AS avg_overdue_pct_of_active
FROM gold.fact_credit_history h
INNER JOIN gold.fact_loan_application f
    ON h.customer_id = f.customer_id
GROUP BY f.default_flag
ORDER BY f.default_flag;
-- Explanation: Compares the volume of active and overdue bureau credits
-- between defaulters and non-defaulters. A higher proportion of overdue
-- credits signals elevated risk of current loan default.


-- ============================================
-- Q23: What is the credit debt ratio analysis by risk segment?
-- ============================================
SELECT
    r.risk_segment,
    COUNT(*)                                            AS customer_count,
    AVG(h.avg_credit_debt_ratio)                        AS avg_debt_ratio,
    MIN(h.avg_credit_debt_ratio)                        AS min_debt_ratio,
    MAX(h.avg_credit_debt_ratio)                        AS max_debt_ratio,
    AVG(h.total_credit_debt)                            AS avg_total_debt,
    AVG(h.total_credit_sum)                             AS avg_total_credit_sum
FROM gold.fact_credit_history h
INNER JOIN gold.report_customer_risk_summary r
    ON h.customer_id = r.customer_id
GROUP BY r.risk_segment
ORDER BY
    CASE r.risk_segment
        WHEN 'High Risk'   THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk'    THEN 3
    END;
-- Explanation: Analyzes the debt-to-credit ratio from bureau data across
-- risk segments. A high ratio means borrowers are utilizing a large
-- share of their available credit — a classic risk signal.


-- ============================================
-- Q24: How do customers with NO bureau history compare to those
--      WITH bureau history in terms of default rate?
-- ============================================
SELECT
    CASE
        WHEN h.customer_id IS NULL THEN 'No Bureau History'
        ELSE 'Has Bureau History'
    END                                                 AS bureau_status,
    COUNT(*)                                            AS total_customers,
    SUM(CAST(f.default_flag AS INT))                    AS total_defaults,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct,
    AVG(f.credit_amount)                                AS avg_credit_amount,
    AVG(f.income_total)                                 AS avg_income
FROM gold.fact_loan_application f
LEFT JOIN gold.fact_credit_history h
    ON f.customer_id = h.customer_id
GROUP BY
    CASE
        WHEN h.customer_id IS NULL THEN 'No Bureau History'
        ELSE 'Has Bureau History'
    END
ORDER BY default_rate_pct DESC;
-- Explanation: Compares default rates between customers who have external
-- credit history and those who are "thin-file" (no bureau records).
-- Thin-file customers often present higher uncertainty and risk.


-- ============================================
-- Q25: What are the top credit exposure and overdue patterns
--      across different bureau record volume tiers?
-- ============================================
SELECT
    CASE
        WHEN h.total_bureau_records = 0  THEN '1. No Records'
        WHEN h.total_bureau_records <= 3 THEN '2. 1-3 Records'
        WHEN h.total_bureau_records <= 7 THEN '3. 4-7 Records'
        WHEN h.total_bureau_records <= 15 THEN '4. 8-15 Records'
        ELSE '5. 15+ Records'
    END                                                 AS bureau_record_tier,
    COUNT(*)                                            AS customer_count,
    AVG(h.overdue_credit_count)                         AS avg_overdue_credits,
    AVG(h.total_credit_overdue)                         AS avg_overdue_amount,
    AVG(h.total_credit_sum)                             AS avg_credit_exposure,
    AVG(h.avg_credit_debt_ratio)                        AS avg_debt_ratio,
    CAST(
        SUM(CAST(f.default_flag AS INT)) * 100.0 
        / COUNT(*) AS DECIMAL(5,2)
    )                                                   AS default_rate_pct
FROM gold.fact_credit_history h
INNER JOIN gold.fact_loan_application f
    ON h.customer_id = f.customer_id
GROUP BY
    CASE
        WHEN h.total_bureau_records = 0  THEN '1. No Records'
        WHEN h.total_bureau_records <= 3 THEN '2. 1-3 Records'
        WHEN h.total_bureau_records <= 7 THEN '3. 4-7 Records'
        WHEN h.total_bureau_records <= 15 THEN '4. 8-15 Records'
        ELSE '5. 15+ Records'
    END
ORDER BY bureau_record_tier;
-- Explanation: Segments customers by how many bureau records they have
-- and examines overdue patterns and default rates per tier. Customers
-- with many records but high overdue counts are a concern; those with
-- few records may represent thin-file risk.
