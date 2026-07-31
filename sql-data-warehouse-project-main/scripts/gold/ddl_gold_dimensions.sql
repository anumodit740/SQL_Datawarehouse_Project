USE DataWarehouse;
GO

/*
===============================================================================
DDL Script: Gold Dimensions
===============================================================================
Purpose:
    Create business-ready dimension views for Gold Layer.

Layer:
    Gold

Design Notes:
    - Gold layer contains analytics-ready business views
    - Uses cleaned Silver layer as source
    - Follows star schema design
===============================================================================
*/

-- ============================================================================
-- Create Gold Schema
-- ============================================================================

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO

-- ============================================================================
-- Drop Existing View
-- ============================================================================

DROP VIEW IF EXISTS gold.dim_customer;
GO

/*
===============================================================================
Dimension: dim_customer
===============================================================================

Purpose:
    Stores customer demographic and profile information.

Grain:
    1 row = 1 customer / applicant

Source:
    silver.application_train

Business Usage:
    - Customer segmentation
    - Risk profiling
    - Power BI slicers
    - Customer analytics

===============================================================================
*/

CREATE VIEW gold.dim_customer AS

SELECT

    -- Surrogate Key
    ROW_NUMBER() OVER (
        ORDER BY sk_id_curr
    ) AS customer_key,

    -- Business Key
    sk_id_curr AS customer_id,

    -- Demographics
    gender,
    age_years,

    -- Family Information
    family_status,
    children_count,
    family_members_count,

    -- Education & Profession
    education_type,
    occupation_type,
    income_type,
    organization_type,

    -- Housing & Assets
    housing_type,
    owns_car,
    owns_realty,

    -- Regional Information
    region_rating_client,
    region_rating_client_w_city,

    -- External Risk Scores
    ext_source_1,
    ext_source_2,
    ext_source_3,

    -- Metadata
    dwh_load_date

FROM silver.application_train;
GO