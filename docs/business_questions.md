# 💡 Executive Business Questions & Data Insights Guide

This document presents **15 Strategic Business Questions** designed to extract actionable insights from the **Gold Layer Data Warehouse**. Each question features the business objective, SQL query implementation on Gold views ([`gold.fact_sales`](../scripts/gold/ddl_gold.sql:79), [`gold.dim_customers`](../scripts/gold/ddl_gold.sql:24), [`gold.dim_products`](../scripts/gold/ddl_gold.sql:53)), and executive takeaways.

---

## 🎯 Question 1: Which products contribute to 80% of total revenue (Pareto 80/20 Rule)?
**Business Objective:** Identify the vital few products driving the vast majority of sales revenue to optimize inventory allocation and marketing spend.

```sql
WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.product_name
),
ranked_revenue AS (
    SELECT
        product_name,
        total_revenue,
        SUM(total_revenue) OVER () AS grand_total,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
    FROM product_revenue
)
SELECT
    product_name,
    total_revenue,
    ROUND((running_revenue / grand_total) * 100, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN (running_revenue / grand_total) <= 0.80 THEN 'Top 80% Revenue Driver (Core Product)'
        ELSE 'Remaining 20% (Tail Product)'
    END AS pareto_classification
FROM ranked_revenue
ORDER BY total_revenue DESC;
```
**Executive Takeaway:** Focus retention and stock availability on the top 20% tier to protect 80% of company cash flow.

---

## 🌎 Question 2: Which customer regions or countries are underperforming?
**Business Objective:** Identify geographic markets where sales volume falls significantly below average to adjust regional marketing strategy.

```sql
WITH regional_sales AS (
    SELECT
        c.country,
        COUNT(DISTINCT f.order_number) AS total_orders,
        COUNT(DISTINCT f.customer_key) AS total_customers,
        SUM(f.sales_amount) AS total_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.country
),
avg_sales AS (
    SELECT AVG(total_revenue) AS global_avg_country_revenue FROM regional_sales
)
SELECT
    r.country,
    r.total_orders,
    r.total_customers,
    r.total_revenue,
    ROUND(a.global_avg_country_revenue, 2) AS avg_country_revenue,
    CASE 
        WHEN r.total_revenue < a.global_avg_country_revenue THEN 'Underperforming Market'
        ELSE 'High-Performing Market'
    END AS performance_status
FROM regional_sales r
CROSS JOIN avg_sales a
ORDER BY r.total_revenue ASC;
```

---

## 💎 Question 3: Who are the top 10 highest-value VIP customers and their revenue share?
**Business Objective:** Identify key high-net-worth accounts for targeted VIP loyalty programs.

```sql
WITH customer_spending AS (
    SELECT
        c.customer_key,
        c.first_name + ' ' + c.last_name AS customer_name,
        c.country,
        SUM(f.sales_amount) AS total_spent,
        COUNT(DISTINCT f.order_number) AS total_orders
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name, c.country
)
SELECT TOP 10
    customer_key,
    customer_name,
    country,
    total_spent,
    total_orders,
    ROUND((total_spent / SUM(total_spent) OVER ()) * 100, 2) AS top_10_revenue_share_pct
FROM customer_spending
ORDER BY total_spent DESC;
```

---

## 📈 Question 4: What is the Month-over-Month (MoM) revenue growth rate?
**Business Objective:** Measure velocity of monthly revenue expansion and detect seasonal slowdowns.

```sql
WITH monthly_sales AS (
    SELECT
        DATETRUNC(month, order_date) AS sales_month,
        SUM(sales_amount) AS current_month_revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)
SELECT
    FORMAT(sales_month, 'yyyy-MM') AS year_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY sales_month) AS prior_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month)) 
        / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0)) * 100, 
    2) AS mom_growth_pct
FROM monthly_sales
ORDER BY sales_month;
```

---

## 📊 Question 5: What is the revenue contribution % of each product category?
**Business Objective:** Evaluate category mix and dependency on core categories.

```sql
WITH category_totals AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS category_revenue,
        SUM(f.quantity) AS category_quantity
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    category_revenue,
    category_quantity,
    SUM(category_revenue) OVER () AS total_company_revenue,
    ROUND((category_revenue / SUM(category_revenue) OVER ()) * 100, 2) AS revenue_contribution_pct
FROM category_totals
ORDER BY category_revenue DESC;
```

---

## 🔁 Question 6: What is the Repeat Customer Rate and Order Frequency?
**Business Objective:** Assess customer loyalty and repeat purchasing habits.

```sql
WITH customer_orders AS (
    SELECT
        customer_key,
        COUNT(DISTINCT order_number) AS order_count
    FROM gold.fact_sales
    GROUP BY customer_key
)
SELECT
    COUNT(customer_key) AS total_purchasing_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND((CAST(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(customer_key)) * 100, 2) AS repeat_customer_rate_pct,
    ROUND(AVG(CAST(order_count AS FLOAT)), 2) AS avg_orders_per_customer
FROM customer_orders;
```

---

## 🚀 Question 7: What are the top 5 product categories by profit margin?
**Business Objective:** Identify the most profitable product lines rather than just revenue volume.

```sql
SELECT TOP 5
    p.category,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity * p.cost) AS total_cogs,
    SUM(f.sales_amount) - SUM(f.quantity * p.cost) AS total_profit,
    ROUND(((SUM(f.sales_amount) - SUM(f.quantity * p.cost)) / NULLIF(SUM(f.sales_amount), 0)) * 100, 2) AS profit_margin_pct
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY profit_margin_pct DESC;
```

---

## 📉 Question 8: Which products are laggards with zero or low revenue?
**Business Objective:** Identify candidates for discounting, clearance, or product line discontinuation.

```sql
SELECT TOP 10
    p.product_name,
    p.category,
    COALESCE(SUM(f.sales_amount), 0) AS total_revenue,
    COALESCE(SUM(f.quantity), 0) AS total_units_sold
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f ON p.product_key = f.product_key
GROUP BY p.product_name, p.category
ORDER BY total_revenue ASC;
```

---

## 🎂 Question 9: Which customer age groups generate the highest sales spend?
**Business Objective:** Refine target demographic profiles for advertising campaigns.

```sql
WITH customer_age_sales AS (
    SELECT
        CASE 
            WHEN DATEDIFF(year, c.birthdate, GETDATE()) < 25 THEN 'Under 25'
            WHEN DATEDIFF(year, c.birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
            WHEN DATEDIFF(year, c.birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
            WHEN DATEDIFF(year, c.birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55 and Above'
        END AS age_group,
        f.sales_amount
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE c.birthdate IS NOT NULL
)
SELECT
    age_group,
    COUNT(*) AS transaction_count,
    SUM(sales_amount) AS total_revenue,
    ROUND(AVG(sales_amount), 2) AS avg_transaction_value
FROM customer_age_sales
GROUP BY age_group
ORDER BY total_revenue DESC;
```

---

## 🏃 Question 10: What is the cumulative running total of sales over time?
**Business Objective:** Track revenue compounding across the business lifecycle.

```sql
WITH daily_sales AS (
    SELECT
        order_date,
        SUM(sales_amount) AS daily_revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_date
)
SELECT
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_running_revenue
FROM daily_sales
ORDER BY order_date;
```

---

## ⏳ Question 11: What is the average order turnaround / shipping lead time?
**Business Objective:** Monitor logistics performance and fulfillment speed.

```sql
SELECT
    p.category,
    COUNT(f.order_number) AS total_orders,
    AVG(DATEDIFF(day, f.order_date, f.shipping_date)) AS avg_shipping_days,
    MAX(DATEDIFF(day, f.order_date, f.shipping_date)) AS max_shipping_days
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL AND f.shipping_date IS NOT NULL
GROUP BY p.category
ORDER BY avg_shipping_days DESC;
```

---

## 🥇 Question 12: What are the top 3 selling products per category?
**Business Objective:** Rank top performers within specific merchandising categories.

```sql
WITH product_ranks AS (
    SELECT
        p.category,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.sales_amount) DESC) AS rank_in_category
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    total_revenue,
    rank_in_category
FROM product_ranks
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;
```

---

## 👥 Question 13: How are customers distributed across VIP, Regular, and New segments?
**Business Objective:** Evaluate customer base maturity and high-value customer retention.

```sql
WITH customer_lifespan AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segments AS (
    SELECT
        customer_key,
        CASE 
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS segment
    FROM customer_lifespan
)
SELECT
    segment,
    COUNT(customer_key) AS customer_count,
    ROUND((CAST(COUNT(customer_key) AS FLOAT) / SUM(COUNT(customer_key)) OVER ()) * 100, 2) AS pct_of_customer_base
FROM customer_segments
GROUP BY segment
ORDER BY customer_count DESC;
```

---

## 💰 Question 14: What is the Average Order Value (AOV) trend by gender?
**Business Objective:** Determine purchasing basket sizes between male and female customer demographics.

```sql
SELECT
    c.gender,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    ROUND(SUM(f.sales_amount) / NULLIF(COUNT(DISTINCT f.order_number), 0), 2) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.gender IN ('M', 'F', 'Male', 'Female')
GROUP BY c.gender;
```

---

## 🏆 Question 15: Which products have Year-over-Year (YoY) revenue growth vs decline?
**Business Objective:** Uncover trending vs fading product lines over annual cycles.

```sql
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS sales_year,
        p.product_name,
        SUM(f.sales_amount) AS annual_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    sales_year,
    product_name,
    annual_revenue,
    LAG(annual_revenue) OVER (PARTITION BY product_name ORDER BY sales_year) AS prior_year_revenue,
    annual_revenue - LAG(annual_revenue) OVER (PARTITION BY product_name ORDER BY sales_year) AS yoy_diff,
    CASE 
        WHEN annual_revenue > LAG(annual_revenue) OVER (PARTITION BY product_name ORDER BY sales_year) THEN 'Growing (+)'
        WHEN annual_revenue < LAG(annual_revenue) OVER (PARTITION BY product_name ORDER BY sales_year) THEN 'Declining (-)'
        ELSE 'New / Stable'
    END AS growth_status
FROM yearly_product_sales
ORDER BY product_name, sales_year;
```
