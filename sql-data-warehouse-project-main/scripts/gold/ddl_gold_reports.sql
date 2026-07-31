USE DataWarehouse;
GO

/*
===============================================================================
DDL Script: Gold Reports / Analytical Marts
===============================================================================
Purpose:
    Create Power BI-ready business reporting views.

Layer:
    Gold

Report Views:
    1. gold.report_customer_risk_summary

Design Notes:
    - Combines dimension and fact views
    - Provides customer-level risk summary
    - Ready for analytics and dashboarding
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_customer_risk_summary;
GO

/*
===============================================================================
Report: report_customer_risk_summary
===============================================================================

Purpose:
    Customer-level risk mart combining:
    - Customer profile
    - Loan application data
    - Payment behavior
    - Bureau credit history

Grain:
    1 row = 1 customer

Business Usage:
    - Power BI dashboard
    - Risk segmentation
    - Customer profiling
    - Default risk analysis

===============================================================================
*/

CREATE VIEW gold.report_customer_risk_summary AS

SELECT
    -- Customer Dimension
    c.customer_key,
    c.customer_id,

    c.gender,
    c.age_years,
    c.education_type,
    c.family_status,
    c.income_type,
    c.occupation_type,
    c.housing_type,
    c.owns_car,
    c.owns_realty,

    c.region_rating_client,
    c.region_rating_client_w_city,

    -- Loan Application Fact
    l.default_flag,
    l.contract_type,

    l.income_total,
    l.credit_amount,
    l.annuity_amount,
    l.goods_price,

    l.credit_income_ratio,
    l.annuity_income_ratio,
    l.goods_credit_ratio,

    -- Payment Behavior Fact
    ISNULL(p.total_installments, 0) AS total_installments,
    ISNULL(p.late_payment_count, 0) AS late_payment_count,
    ISNULL(p.underpaid_count, 0) AS underpaid_count,

    p.avg_payment_delay_days,
    p.avg_payment_difference,
    p.payment_completion_ratio,

    -- Bureau Credit History Fact
    ISNULL(b.total_bureau_records, 0) AS total_bureau_records,
    ISNULL(b.active_credit_count, 0) AS active_credit_count,
    ISNULL(b.overdue_credit_count, 0) AS overdue_credit_count,

    b.total_credit_sum,
    b.total_credit_debt,
    b.total_credit_overdue,
    b.avg_credit_debt_ratio,

    -- Business Risk Segmentation
    CASE
        WHEN l.default_flag = 1 THEN 'High Risk'
        WHEN ISNULL(p.late_payment_count, 0) >= 3 THEN 'High Risk'
        WHEN ISNULL(p.underpaid_count, 0) >= 3 THEN 'High Risk'
        WHEN ISNULL(b.overdue_credit_count, 0) >= 2 THEN 'High Risk'
        WHEN l.credit_income_ratio >= 5 THEN 'Medium Risk'
        WHEN l.annuity_income_ratio >= 0.4 THEN 'Medium Risk'
        WHEN ISNULL(b.active_credit_count, 0) >= 5 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment,

    -- Metadata
    GETDATE() AS report_generated_date

FROM gold.dim_customer c

LEFT JOIN gold.fact_loan_application l
    ON c.customer_id = l.customer_id

LEFT JOIN gold.fact_payment_behavior p
    ON c.customer_id = p.customer_id

LEFT JOIN gold.fact_credit_history b
    ON c.customer_id = b.customer_id;
GO