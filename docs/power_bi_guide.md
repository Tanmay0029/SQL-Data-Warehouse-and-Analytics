# 📊 Power BI Dashboard Implementation Guide

This guide provides end-to-end instructions for connecting Power BI Desktop to your **Gold Layer Data Warehouse views**, creating DAX measures, establishing star schema relationships, and designing the **3 Core Business Dashboards**: Executive, Customer, and Product Analytics.

---

## 1. 🔌 Data Connection & Model Setup

### Step 1: Connect to SQL Server
1. Open **Power BI Desktop**.
2. Click **Get Data** ➔ **SQL Server Database**.
3. Enter your Connection Credentials:
   - **Server**: `localhost` (or your SQL Server instance name, e.g., `.\SQLEXPRESS`).
   - **Database**: `DataWarehouse`.
   - **Data Connectivity mode**: **Import** (Recommended for performance and full DAX capability).
4. Select the following **Gold Layer Views**:
   - `gold.fact_sales`
   - `gold.dim_customers`
   - `gold.dim_products`
5. Click **Load**.

---

## 2. 🔗 Data Model & Star Schema Relationships

In the **Model View**, verify and configure the Star Schema relationships:

| From Table | From Column | To Table | To Column | Cardinality | Cross Filter Direction |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `gold.fact_sales` | `customer_key` | `gold.dim_customers` | `customer_key` | Many to One (*:1) | Single (`dim_customers` filters `fact_sales`) |
| `gold.fact_sales` | `product_key` | `gold.dim_products` | `product_key` | Many to One (*:1) | Single (`dim_products` filters `fact_sales`) |
| `gold.fact_sales` | `order_date` | `DateTable` | `Date` | Many to One (*:1) | Single (`DateTable` filters `fact_sales`) |

> 💡 **Tip:** Always create a dedicated DAX Date Table (`DateTable`) for accurate time-intelligence calculations (YoY Growth, MoM Growth, Cumulative Sales).

---

## 3. 📐 DAX Measures Setup

Create a new table named `_Measures` to store all calculated metrics cleanly. You can copy measures from [`scripts/power_bi_dax_measures.dax`](../scripts/power_bi_dax_measures.dax).

### Core DAX Measures Overview:
* **Total Revenue**: `SUM(fact_sales[sales_amount])`
* **Total Profit**: `[Total Revenue] - SUMX(fact_sales, fact_sales[quantity] * RELATED(dim_products[cost]))`
* **Profit Margin %**: `DIVIDE([Total Profit], [Total Revenue], 0)`
* **Total Orders**: `DISTINCTCOUNT(fact_sales[order_number])`
* **Total Customers**: `DISTINCTCOUNT(fact_sales[customer_key])`
* **YoY Sales Growth %**: `DIVIDE([Total Revenue] - CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DateTable[Date])), CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DateTable[Date])), 0)`

---

## 4. 🖼️ Dashboard Specifications & Visual Layouts

---

### 👑 Dashboard 1: Executive Dashboard (Strategic Overview)
**Target Audience:** C-Suite, VPs, Operations Managers  
**Objective:** High-level overview of revenue performance, profitability, order volumes, customer growth, and year-over-year trends.

```
+-----------------------------------------------------------------------------------+
|                            EXECUTIVE DASHBOARD                                    |
+-----------------------------------------------------------------------------------+
|  [ KPI 1: Revenue ]  [ KPI 2: Profit ]  [ KPI 3: Orders ]  [ KPI 4: YoY Growth % ]  |
+------------------------------------------+----------------------------------------+
| Area Chart:                              | Bar Chart:                             |
| Revenue & Profit Trend over Time (Monthly| Sales Revenue by Product Category      |
| with YoY comparison)                     |                                        |
+------------------------------------------+----------------------------------------+
| Donut Chart:                             | Matrix Table:                          |
| Revenue Share by Region / Country        | Monthly Financial Breakdown & Margin % |
+------------------------------------------+----------------------------------------+
```

#### Visual Configurations:
1. **KPI Cards (Top Banner)**:
   - **Total Revenue**: Card Visual | Display formatted as Currency (`$`).
   - **Total Profit & Margin %**: Multi-row Card | Metric + Percentage.
   - **Total Orders**: Card Visual | Integer formatting.
   - **YoY Growth %**: Card Visual with conditional formatting (Green = Positive, Red = Negative).
2. **Monthly Sales & Profit Trend**:
   - **Visual Type**: Line and Clustered Column Chart.
   - **X-Axis**: `DateTable[Month Year]`.
   - **Y-Axis (Column)**: `[Total Revenue]`.
   - **Y-Axis (Line)**: `[Profit Margin %]`.
3. **Category Revenue Breakdown**:
   - **Visual Type**: Clustered Horizontal Bar Chart.
   - **Y-Axis**: `dim_products[category]`.
   - **X-Axis**: `[Total Revenue]`.
4. **Geographic Distribution**:
   - **Visual Type**: Filled Map or Donut Chart.
   - **Legend/Location**: `dim_customers[country]`.
   - **Values**: `[Total Revenue]`.

---

### 👥 Dashboard 2: Customer Dashboard (Customer Analytics & Segmentation)
**Target Audience:** Marketing Team, Customer Success, Sales Leads  
**Objective:** Identify top-spending customers, evaluate repeat purchase behaviour, and analyze customer lifecycle segments.

```
+-----------------------------------------------------------------------------------+
|                            CUSTOMER DASHBOARD                                     |
+-----------------------------------------------------------------------------------+
|  [ KPI: Total Customers ]  [ KPI: Repeat Rate % ]  [ KPI: Avg Order Value (AOV) ]    |
+------------------------------------------+----------------------------------------+
| Bar Chart:                               | Donut Chart:                           |
| Top 10 High-Value Customers by Revenue   | Customer Segment Distribution          |
|                                          | (VIP vs Regular vs New)                |
+------------------------------------------+----------------------------------------+
| Stacked Column Chart:                    | Data Table:                            |
| Revenue Distribution by Age Group        | Customer Recency & Frequency Matrix    |
+------------------------------------------+----------------------------------------+
```

#### Visual Configurations:
1. **KPI Cards**:
   - **Total Purchasing Customers**: `[Total Purchasing Customers]`.
   - **Repeat Customer Rate %**: `[Repeat Customer Rate %]` (Target > 40%).
   - **Average Order Value (AOV)**: `[Average Order Value]`.
2. **Top 10 Customers**:
   - **Visual Type**: Horizontal Bar Chart.
   - **Y-Axis**: `dim_customers[first_name] & " " & dim_customers[last_name]`.
   - **X-Axis**: `[Total Revenue]`.
   - **Filter**: Top N = 10 by `[Total Revenue]`.
3. **Customer Segmentation Breakdown**:
   - **Visual Type**: Donut Chart.
   - **Legend**: Customer Segment (`VIP`, `Regular`, `New`).
   - **Values**: `[Total Purchasing Customers]`.
4. **Demographic Performance (Age & Gender)**:
   - **Visual Type**: Stacked Column Chart.
   - **X-Axis**: Age Group (`Under 20`, `20-29`, `30-39`, `40-49`, `50+`).
   - **Y-Axis**: `[Total Revenue]`.
   - **Legend**: `dim_customers[gender]`.

---

### 📦 Dashboard 3: Product Dashboard (Inventory & Merchandise Performance)
**Target Audience:** Product Managers, Merchandising, Supply Chain Analysts  
**Objective:** Pinpoint high-performing hero products, identify low-turnover laggards, and evaluate category profitability.

```
+-----------------------------------------------------------------------------------+
|                             PRODUCT DASHBOARD                                     |
+-----------------------------------------------------------------------------------+
|  [ KPI: Total Products ]  [ KPI: Top Category ]  [ KPI: Avg Selling Price (ASP) ] |
+------------------------------------------+----------------------------------------+
| Bar Chart:                               | Bar Chart:                             |
| Top 10 Best-Selling Products (Revenue)   | Bottom 10 Laggard Products (Revenue)   |
+------------------------------------------+----------------------------------------+
| Scatter Plot:                            | Matrix Visual:                         |
| Price vs Quantity Sold by Category       | Subcategory Performance & COGS Matrix  |
+------------------------------------------+----------------------------------------+
```

#### Visual Configurations:
1. **KPI Cards**:
   - **Active Product Portfolio**: `[Total Products]`.
   - **Top Category**: `[Top Product Name]`.
   - **Average Selling Price**: `[Average Selling Price]`.
2. **Top & Bottom Product Rankings**:
   - **Visual Type**: Clustered Bar Charts (Side-by-side or tabbed).
   - **Top 10 Products**: Top N Filter = 10 by `[Total Revenue]`.
   - **Bottom 10 Products**: Bottom N Filter = 10 by `[Total Revenue]`.
3. **Category & Subcategory Breakdown**:
   - **Visual Type**: Treemap or Matrix Visual.
   - **Category Hierarchy**: `dim_products[category]` ➔ `dim_products[subcategory]`.
   - **Values**: `[Total Revenue]`, `[Total Profit]`, `[Profit Margin %]`.
4. **Price vs Sales Volume Analysis**:
   - **Visual Type**: Scatter Chart.
   - **X-Axis**: `[Average Selling Price]`.
   - **Y-Axis**: `[Total Quantity Sold]`.
   - **Size**: `[Total Revenue]`.
   - **Details**: `dim_products[product_name]`.

---

## 5. 🚀 Publishing & Export Instructions

1. Save your Power BI file as `PowerBI_Sales_Analytics_Dashboard.pbix` in the project root directory.
2. Publish to Power BI Service:
   - Click **Publish** ➔ Select **My Workspace** or designated App Workspace.
   - Configure scheduled data refresh via Gateway (if connecting to local SQL Server).
