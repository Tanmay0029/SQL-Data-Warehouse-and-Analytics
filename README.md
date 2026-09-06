# 🏢 Enterprise Medallion Data Warehouse & Power BI Analytics Platform

[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server%202022-blue?style=for-the-badge&logo=microsoftsqlserver)](https://www.microsoft.com/en-us/sql-server/)
[![Power BI](https://img.shields.io/badge/BI-Power%20BI%20Desktop-yellow?style=for-the-badge&logo=powerbi)](https://powerbi.microsoft.com/)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-green?style=for-the-badge)](#-data-architecture)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

---

## 📌 Executive Summary

Designed and implemented an enterprise-grade **Medallion Architecture Data Warehouse (Bronze/Silver/Gold)** in SQL Server, processing 100K+ sales records and enabling business reporting through interactive **Power BI dashboards** and **advanced SQL analytics**.

This solution integrates disparate transactional data from ERP and CRM source systems into a unified Star Schema data model, resolving data quality issues, establishing automated transformations, and delivering key performance metrics across Executive, Customer, and Product domains.

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

Detailed architectural specifications are documented in [`docs/architecture.md`](docs/architecture.md).
---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

## 🚀 Quick Start & Installation

### 1. Database Setup
1. Open **SQL Server Management Studio (SSMS)**.
2. Execute [`scripts/init_database.sql`](scripts/init_database.sql) to set up the `DataWarehouse` database and schema layers.
3. Run [`scripts/bronze/proc_load_bronze.sql`](scripts/bronze/proc_load_bronze.sql) to bulk load raw source CSV files into the **Bronze Layer**.
4. Run [`scripts/silver/proc_load_silver.sql`](scripts/silver/proc_load_silver.sql) to execute data cleaning transformations into the **Silver Layer**.
5. Run [`scripts/gold/ddl_gold.sql`](scripts/gold/ddl_gold.sql) to build the Star Schema analytical views in the **Gold Layer**.

### 2. Analytics & Reporting
* Execute [`scripts/14_advanced_analytics.sql`](scripts/14_advanced_analytics.sql) for window function analytics.
* Connect **Power BI Desktop** to `gold.fact_sales`, `gold.dim_customers`, and `gold.dim_products` by following [`docs/power_bi_guide.md`](docs/power_bi_guide.md).

---

---
## 🌟 Key Upgrades & Project Highlights

### 1. 📊 Power BI Analytics Suite (3 Core Dashboards)
Built 3 specialized interactive dashboards on top of Gold Layer star schema views:
- 👑 **Executive Dashboard**: C-Suite metrics for Revenue, Profit, Order Volumes, Active Customers, and YoY Sales Growth %.
- 👥 **Customer Dashboard**: Customer Lifecycle Analysis, Top 10 High-Value Spenders, Customer Segmentation (VIP, Regular, New), and Repeat Purchase Rates.
- 📦 **Product Dashboard**: Merchandise analytics covering High-Performers, Product Laggards, Category Profit Margins, and Price vs Volume Scatter Trends.
> 📖 Step-by-step setup and visual layouts: [`docs/power_bi_guide.md`](docs/power_bi_guide.md)  
> 🔢 DAX measure calculations script: [`scripts/power_bi_dax_measures.dax`](scripts/power_bi_dax_measures.dax)

### 2. 💡 15 Strategic Business Questions & Data Insights
Formulated 15 production-grade SQL queries to resolve complex commercial inquiries:
- Pareto 80/20 Revenue Contribution Analysis
- Underperforming Geographic Markets
- VIP Customer Identification & Revenue Share
- Month-over-Month (MoM) Growth Velocity
- Customer Recency, Frequency, & Lifespan Segmentation
> 📖 Complete business query catalog & insights: [`docs/business_questions.md`](docs/business_questions.md)

### 3. ⚡ Advanced Analytics SQL Script
Leveraged complex T-SQL window functions to solve high-value analytical problems:
- **`LAG()` & `LEAD()`**: MoM/YoY growth velocity, previous purchase comparison, and next order gap analysis.
- **`RANK()` & `DENSE_RANK()`**: Global and categorical product/customer performance rankings without rank gaps.
- **`NTILE()`**: Customer spending decile segmentation (Top 10% VIPs) and product performance quartiles (Q1–Q4).
- **Cumulative Metrics**: 7-day moving averages and running total sales velocity over time.
> 💻 SQL Script: [`scripts/14_advanced_analytics.sql`](scripts/14_advanced_analytics.sql)

---
## 🛠️ Important Links & Tools:

Everything is for Free!
- **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting your SQL database.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Notion](https://www.notion.com/templates/sql-data-warehouse-project):** Get the Project Template from Notion
- **[Notion Project Steps](https://thankful-pangolin-2ca.notion.site/SQL-Data-Warehouse-Project-16ed041640ef80489667cfe2f380b269?pvs=4):** Access to All Project Phases and Tasks.

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.  

For more details, refer to [docs/requirements.md](docs/requirements.md).

## 📂 Repository Structure

```
.
├── datasets/                           # Raw ERP & CRM source data files (CSV)
│   ├── source_crm/                     # CRM: Customer Info, Product Info, Sales Details
│   └── source_erp/                     # ERP: Customer Demographics, Locations, Categories
├── docs/                               # Enterprise project documentation
│   ├── architecture.md                 # End-to-end Medallion Architecture documentation
│   ├── power_bi_guide.md               # Power BI dashboard setup & design specs
│   ├── business_questions.md           # 15 Strategic SQL business queries & insights
│   ├── data_catalog.md                 # Field data dictionary and schema definitions
│   └── naming_conventions.md           # SQL & Data Warehouse naming guidelines
├── scripts/                            # SQL ETL pipeline and analytical scripts
│   ├── init_database.sql               # Database & schema creation script (Bronze/Silver/Gold)
│   ├── bronze/                         # Bronze Layer DDL & Bulk Load stored procedures
│   ├── silver/                         # Silver Layer DDL & Data Cleaning procedures
│   ├── gold/                           # Gold Layer Star Schema dimensional views
│   ├── 01-13_analysis_scripts.sql      # Exploratory & reporting SQL scripts
│   ├── 14_advanced_analytics.sql       # Advanced SQL window functions (LAG, RANK, NTILE)
│   └── power_bi_dax_measures.dax       # DAX measure definitions for Power BI dashboards
├── tests/                              # Quality assurance & data sanity checks
├── README.md                           # Master project documentation
└── LICENSE                             # MIT License
```

---

## 🛠️ Technology Stack & Skills Demonstrated

* **Data Warehousing & Modeling**: SQL Server, Medallion Architecture (Bronze/Silver/Gold), Star Schema Modeling, Surrogate Keys, Data Cleansing.
* **Advanced SQL Analytics**: T-SQL, Window Functions (`LAG`, `LEAD`, `RANK`, `DENSE_RANK`, `NTILE`), CTEs, Aggregations, Subqueries.
* **Business Intelligence (BI)**: Power BI Desktop, DAX (Data Analysis Expressions), Time Intelligence, Data Visualization, Interactive Dashboard Design.
* **Data Engineering & ETL**: Stored Procedures, Bulk Ingestion, Data Transformation, Data Quality Control.

---


## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
