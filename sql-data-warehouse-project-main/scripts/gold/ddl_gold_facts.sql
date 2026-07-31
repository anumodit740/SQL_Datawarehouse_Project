USE DataWarehouse;
GO

/*
===============================================================================
DDL Script: Gold Facts
===============================================================================
Purpose:
    Create business-ready fact views for Gold Layer.

Layer:
    Gold

Fact Views:
    1. gold.fact_loan_application
    2. gold.fact_payment_behavior
    3. gold.fact_credit_history

Design Notes:
    - Facts contain measurable business events / metrics
    - Uses cleaned Silver tables
    - Optimized for analytics and Power BI
===============================================================================
*/

-- ============================================================================
-- Drop Existing Fact Views
-- ============================================================================

DROP VIEW IF EXISTS gold.fact_credit_history;
DROP VIEW IF EXISTS gold.fact_payment_behavior;
DROP VIEW IF EXISTS gold.fact_loan_application;
GO

/*
===============================================================================
Fact: fact_loan_application
===============================================================================

Purpose:
    Stores loan application level financial and risk information.

Grain:
    1 row = 1 loan application / customer application

Source:
    silver.application_train

===============================================================================
*/

CREATE VIEW gold.fact_loan_application AS

SELECT
    sk_id_curr AS customer_id,

    target AS default_flag,

    contract_type,

    income_total,
    credit_amount,
    annuity_amount,
    goods_price,

    credit_income_ratio,
    annuity_income_ratio,
    goods_credit_ratio,

    req_credit_bureau_hour,
    req_credit_bureau_day,
    req_credit_bureau_week,
    req_credit_bureau_month,
    req_credit_bureau_quarter,
    req_credit_bureau_year,

    dwh_load_date

FROM silver.application_train;
GO

/*
===============================================================================
Fact: fact_payment_behavior
===============================================================================

Purpose:
    Aggregates customer repayment behavior from installment payments.

Grain:
    1 row = 1 customer

Source:
    silver.installments_payments

===============================================================================
*/

CREATE VIEW gold.fact_payment_behavior AS

SELECT
    sk_id_curr AS customer_id,

    COUNT(*) AS total_installments,

    SUM(CASE WHEN late_payment_flag = 1 THEN 1 ELSE 0 END) AS late_payment_count,
    SUM(CASE WHEN underpaid_flag = 1 THEN 1 ELSE 0 END) AS underpaid_count,

    AVG(payment_delay_days) AS avg_payment_delay_days,
    AVG(payment_difference) AS avg_payment_difference,

    SUM(payment_amount) AS total_payment_amount,
    SUM(instalment_amount) AS total_instalment_amount,

    CASE
        WHEN SUM(instalment_amount) > 0
            THEN SUM(payment_amount) / SUM(instalment_amount)
        ELSE NULL
    END AS payment_completion_ratio,

    MAX(dwh_load_date) AS dwh_load_date

FROM silver.installments_payments
GROUP BY sk_id_curr;
GO

/*
===============================================================================
Fact: fact_credit_history
===============================================================================

Purpose:
    Aggregates customer credit bureau history.

Grain:
    1 row = 1 customer

Source:
    silver.bureau

===============================================================================
*/

CREATE VIEW gold.fact_credit_history AS

SELECT
    sk_id_curr AS customer_id,

    COUNT(*) AS total_bureau_records,

    SUM(CASE WHEN credit_active = 'Active' THEN 1 ELSE 0 END) AS active_credit_count,
    SUM(CASE WHEN overdue_flag = 1 THEN 1 ELSE 0 END) AS overdue_credit_count,

    SUM(credit_sum) AS total_credit_sum,
    SUM(credit_sum_debt) AS total_credit_debt,
    SUM(credit_sum_overdue) AS total_credit_overdue,

    AVG(credit_debt_ratio) AS avg_credit_debt_ratio,

    MAX(dwh_load_date) AS dwh_load_date

FROM silver.bureau
GROUP BY sk_id_curr;
GO