/*
===============================================================================
Advanced Analytics SQL Queries
===============================================================================
Purpose:
    This script contains production-grade SQL analytical queries using 
    advanced window functions:
        - LAG() & LEAD()
        - RANK() & DENSE_RANK()
        - NTILE()
        - SUM() OVER() (Running Totals & Part-to-Whole)

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products
===============================================================================
*/


-- ============================================================================
-- 1. LAG() & LEAD() WINDOW FUNCTIONS
-- ============================================================================

-- 1.1 Month-over-Month (MoM) Revenue Growth Rate using LAG()
WITH monthly_revenue AS (
    SELECT
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS total_revenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)
SELECT
    order_month,
    total_revenue AS current_month_revenue,
    LAG(total_revenue, 1) OVER (ORDER BY order_month) AS previous_month_revenue,
    total_revenue - LAG(total_revenue, 1) OVER (ORDER BY order_month) AS mom_revenue_change,
    ROUND(
        ((total_revenue - LAG(total_revenue, 1) OVER (ORDER BY order_month)) 
        / NULLIF(CAST(LAG(total_revenue, 1) OVER (ORDER BY order_month) AS FLOAT), 0)) * 100, 
    2) AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_month;


-- 1.2 Customer Purchase Interval & Days Between Orders using LEAD()
WITH customer_order_dates AS (
    SELECT DISTINCT
        customer_key,
        order_number,
        order_date
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
)
SELECT
    customer_key,
    order_number,
    order_date AS current_order_date,
    LEAD(order_date, 1) OVER (PARTITION BY customer_key ORDER BY order_date) AS next_order_date,
    DATEDIFF(
        day, 
        order_date, 
        LEAD(order_date, 1) OVER (PARTITION BY customer_key ORDER BY order_date)
    ) AS days_until_next_order
FROM customer_order_dates
ORDER BY customer_key, order_date;


-- ============================================================================
-- 2. RANK() & DENSE_RANK() WINDOW FUNCTIONS
-- ============================================================================

-- 2.1 Top Product Ranking Globally and Per Category using RANK() vs DENSE_RANK()
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS global_rank,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_dense_rank
FROM product_sales
ORDER BY category, category_dense_rank;


-- 2.2 Top 3 Spenders Per Country using DENSE_RANK()
WITH customer_country_spending AS (
    SELECT
        c.country,
        c.customer_key,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(f.sales_amount) AS total_spent
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.country, c.customer_key, c.first_name, c.last_name
)
SELECT
    country,
    customer_key,
    customer_name,
    total_spent,
    country_rank
FROM (
    SELECT
        country,
        customer_key,
        customer_name,
        total_spent,
        DENSE_RANK() OVER (PARTITION BY country ORDER BY total_spent DESC) AS country_rank
    FROM customer_country_spending
) ranked_customers
WHERE country_rank <= 3
ORDER BY country, country_rank;


-- ============================================================================
-- 3. NTILE() WINDOW FUNCTION (Segmentation & Decile Analysis)
-- ============================================================================

-- 3.1 Customer Wealth / Spending Deciles (NTILE 10)
WITH customer_total_spend AS (
    SELECT
        c.customer_key,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(f.sales_amount) AS total_spending
    FROM gold.fact_sales f
    JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
)
SELECT
    customer_key,
    customer_name,
    total_spending,
    NTILE(10) OVER (ORDER BY total_spending DESC) AS spending_decile,
    CASE 
        WHEN NTILE(10) OVER (ORDER BY total_spending DESC) = 1 THEN 'Top 10% VIP Spenders'
        WHEN NTILE(10) OVER (ORDER BY total_spending DESC) BETWEEN 2 AND 4 THEN 'High Value'
        WHEN NTILE(10) OVER (ORDER BY total_spending DESC) BETWEEN 5 AND 8 THEN 'Mid Tier'
        ELSE 'Low Volume'
    END AS decile_tier
FROM customer_total_spend
ORDER BY spending_decile, total_spending DESC;


-- 3.2 Product Performance Quartiles (NTILE 4)
WITH product_performance AS (
    SELECT
        p.product_name,
        p.category,
        SUM(f.sales_amount) AS total_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.product_name, p.category
)
SELECT
    product_name,
    category,
    total_revenue,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS performance_quartile,
    CASE NTILE(4) OVER (ORDER BY total_revenue DESC)
        WHEN 1 THEN 'Q1 - Top Performers'
        WHEN 2 THEN 'Q2 - Above Average'
        WHEN 3 THEN 'Q3 - Below Average'
        WHEN 4 THEN 'Q4 - Underperforming'
    END AS quartile_label
FROM product_performance
ORDER BY performance_quartile, total_revenue DESC;


-- ============================================================================
-- 4. CUMULATIVE & PART-TO-WHOLE ANALYTICS
-- ============================================================================

-- 4.1 Running Total Revenue & Moving Average
WITH daily_revenue AS (
    SELECT
        order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_date
)
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue,
    AVG(total_sales) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS [moving_avg_7_day_revenue]
FROM daily_revenue
ORDER BY order_date;


-- 4.2 Revenue Share % and Cumulative Contribution % (Pareto)
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS category_revenue
    FROM gold.fact_sales f
    JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    category_revenue,
    SUM(category_revenue) OVER () AS total_company_revenue,
    ROUND((category_revenue / SUM(category_revenue) OVER ()) * 100, 2) AS category_revenue_share_pct
FROM category_sales
ORDER BY category_revenue DESC;
