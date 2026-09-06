# 🏛️ End-to-End Medallion Data Architecture & BI Ecosystem

This document details the enterprise data architecture implemented in this project, following the **Medallion Architecture Pattern** (Bronze ➔ Silver ➔ Gold) integrated with **Power BI Business Intelligence Dashboards**.

---

## 📐 Architecture Diagram

```
+---------------------------------------------------------------------------------------+
|                                  SOURCE DATA SYSTEMS                                  |
|   +------------------------------------+     +------------------------------------+   |
|   |         CRM Source System          |     |         ERP Source System          |   |
|   | (cust_info, prd_info, sales_dtls) |     |  (CUST_AZ12, LOC_A101, PX_CAT_G1)  |   |
|   +------------------------------------+     +------------------------------------+   |
+-----------------------------------+---------------------------------------------------+
                                    | Bulk Insert / Staging ETL
                                    v
+---------------------------------------------------------------------------------------+
|                               BRONZE LAYER (RAW DATA)                                 |
|   - Ingests raw data as-is from CSV source systems into SQL Server                    |
|   - Tables: bronze.crm_cust_info, bronze.crm_prd_info, bronze.crm_sales_details,      |
|             bronze.erp_cust_az12, bronze.erp_loc_a101, bronze.erp_px_cat_g1v2        |
+-----------------------------------+---------------------------------------------------+
                                    | Cleansing, Standardizing, Deduplication
                                    v
+---------------------------------------------------------------------------------------+
|                             SILVER LAYER (CLEANSED DATA)                              |
|   - Standardizes data types, removes whitespace, handles NULLs, formats keys          |
|   - Tables: silver.crm_cust_info, silver.crm_prd_info, silver.crm_sales_details,      |
|             silver.erp_cust_az12, silver.erp_loc_a101, silver.erp_px_cat_g1v2        |
+-----------------------------------+---------------------------------------------------+
                                    | Data Modeling & Star Schema Modeling
                                    v
+---------------------------------------------------------------------------------------+
|                        GOLD LAYER (BUSINESS-READY STAR SCHEMA)                        |
|   - Business-ready analytical views optimized for BI consumption                      |
|   - Views:                                                                            |
|     * gold.dim_customers (Surrogate keys, combined CRM + ERP customer profiles)       |
|     * gold.dim_products  (Product attributes, cost, category hierarchies)             |
|     * gold.fact_sales    (Transactional sales metrics linked to dimensions)           |
|     * gold.report_customers & gold.report_products (Pre-aggregated analytical views)  |
+-----------------------------------+---------------------------------------------------+
                                    | Direct Import via Star Schema
                                    v
+---------------------------------------------------------------------------------------+
|                         POWER BI BUSINESS INTELLIGENCE LAYER                          |
|   - Interactive Executive, Customer, and Product Analytics Dashboards                 |
|   - Features DAX Time Intelligence, YoY Growth %, Customer Decile Segmentation        |
|   - Dashboards:                                                                       |
|     1. Executive Dashboard (Revenue, Profit, Orders, Customers, YoY Growth)           |
|     2. Customer Dashboard  (Top Customers, VIP Segments, Repeat Rate)                 |
|     3. Product Dashboard   (Hero Products, Laggards, Category Margins)              |
+---------------------------------------------------------------------------------------+
```

---

## 🔬 Data Pipeline Layers Explained

### 1. Source Systems
* **CRM System**: Contains transactional sales logs, product catalogs, and core customer profile details.
* **ERP System**: Contains supplemental demographic data, geographic location master tables, and product category mappings.

### 2. Bronze Layer (Raw Staging)
* **Goal**: High-speed ingestion of raw source data into SQL Server.
* **Characteristics**: Unaltered schema, all data stored as `NVARCHAR` / raw types to prevent load failures. No business logic applied.

### 3. Silver Layer (Cleaned & Standardized)
* **Goal**: Establish a single source of truth with clean data quality standards.
* **Transformations**:
  * Trimming leading/trailing whitespace.
  * Standardizing gender codes (`M` ➔ `Male`, `F` ➔ `Female`, invalid codes replaced with default fallbacks).
  * Data type conversions (Strings ➔ `DATE`, `DECIMAL`, `INT`).
  * Deduplication and structural validation.

### 4. Gold Layer (Dimensional Star Schema)
* **Goal**: Fast, intuitive business reporting and self-service BI analytics.
* **Design Pattern**: Star Schema comprising 1 Fact Table ([`gold.fact_sales`](../scripts/gold/ddl_gold.sql:79)) and 2 Dimension Tables ([`gold.dim_customers`](../scripts/gold/ddl_gold.sql:24), [`gold.dim_products`](../scripts/gold/ddl_gold.sql:53)).
* **Features**:
  * Surrogate key generation using `ROW_NUMBER()`.
  * Cross-system record linkage between CRM and ERP entities.
  * Reporting views ([`gold.report_customers`](../scripts/12_report_customers.sql:31), [`gold.report_products`](../scripts/13_report_products.sql:30)) aggregating RFM metrics and product performance tiers.

### 5. Power BI Layer (Business Intelligence)
* **Goal**: Deliver interactive decision-making dashboards for executive leadership and operational teams.
* **Architecture**: Direct Star Schema import connecting to Gold views, backed by custom DAX measure tables and time-intelligence engines.
