/*
E-Commerce Sales & Customer Analytics

Assumptions:
- SQL dialect: MySQL 8+.
- Orders data is loaded into a table named orders.
- Returns data is loaded into a table named returns.
- People data is loaded into a table named people.

Recommended normalized column names:
row_id, order_id, order_date, ship_date, ship_mode, customer_id,
customer_name, segment, city, state, country, market, postal_code,
region, product_id, category, sub_category, product_name, sales,
quantity, discount, shipping_cost, profit, order_priority
*/

-- 1. Overall KPIs
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders;

-- 2. Yearly sales and profit trend
SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- 3. Monthly sales trend
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY order_year, order_month;

-- 4. Sales and profit by market
SELECT
    market,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY market
ORDER BY total_sales DESC;

-- 5. Top 10 countries by sales
SELECT
    country,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY country
ORDER BY total_sales DESC
LIMIT 10;

-- 6. Category and sub-category performance
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(discount), 4) AS avg_discount,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY category, sub_category
ORDER BY total_sales DESC;

-- 7. Customer segment performance
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

-- 8. Top customers by sales
SELECT
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;

-- 9. Shipping mode performance
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(shipping_cost) / NULLIF(SUM(sales), 0), 4) AS shipping_cost_ratio
FROM orders
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- 10. Discount impact on profitability
SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.10 THEN '0-10%'
        WHEN discount > 0.10 AND discount <= 0.20 THEN '10-20%'
        WHEN discount > 0.20 AND discount <= 0.30 THEN '20-30%'
        ELSE '30%+'
    END AS discount_band,
    COUNT(*) AS line_items,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0), 4) AS profit_margin
FROM orders
GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.10 THEN '0-10%'
        WHEN discount > 0.10 AND discount <= 0.20 THEN '10-20%'
        WHEN discount > 0.20 AND discount <= 0.30 THEN '20-30%'
        ELSE '30%+'
    END
ORDER BY discount_band;

-- 11. Loss-making products
SELECT
    product_id,
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(discount), 4) AS avg_discount
FROM orders
GROUP BY product_id, product_name, category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 20;

-- 12. Returned order impact
SELECT
    o.market,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    ROUND(COUNT(DISTINCT r.order_id) * 1.0 / NULLIF(COUNT(DISTINCT o.order_id), 0), 4) AS return_rate,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sales ELSE 0 END), 2) AS returned_sales
FROM orders o
LEFT JOIN returns r
    ON o.order_id = r.order_id
GROUP BY o.market
ORDER BY return_rate DESC;

-- ============================================================================
-- Advanced Analytical SQL
-- These queries demonstrate CTEs, joins, subqueries, window functions, ranking,
-- contribution analysis, and regional business analysis.
-- ============================================================================

-- 13. Rank countries within each region by sales
WITH country_region_sales AS (
    SELECT
        region,
        country,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY region, country
)
SELECT
    region,
    country,
    total_sales,
    total_profit,
    RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS sales_rank_in_region
FROM country_region_sales
ORDER BY region, sales_rank_in_region;

-- 14. Top product in each region by sales
WITH product_region_sales AS (
    SELECT
        region,
        product_id,
        product_name,
        category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY region, product_id, product_name, category
),
ranked_products AS (
    SELECT
        product_region_sales.*,
        RANK() OVER(PARTITION BY region ORDER BY total_sales DESC) AS product_rank
    FROM product_region_sales
)
SELECT
    region,
    product_id,
    product_name,
    category,
    total_sales,
    total_profit
FROM ranked_products
WHERE product_rank = 1
ORDER BY total_sales DESC;

-- 15. Profit contribution by category and sub-category
WITH subcategory_profit AS (
    SELECT
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY category, sub_category
),
total_profit AS (
    SELECT SUM(profit) AS company_profit
    FROM orders
)
SELECT
    sp.category,
    sp.sub_category,
    sp.total_sales,
    sp.total_profit,
    ROUND(sp.total_profit / NULLIF(tp.company_profit, 0), 4) AS profit_contribution_pct,
    DENSE_RANK() OVER(ORDER BY sp.total_profit DESC) AS profit_rank
FROM subcategory_profit sp
CROSS JOIN total_profit tp
ORDER BY profit_rank;

-- 16. Running monthly sales and profit by year
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        ROUND(SUM(sales), 2) AS monthly_sales,
        ROUND(SUM(profit), 2) AS monthly_profit
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    order_year,
    order_month,
    monthly_sales,
    monthly_profit,
    ROUND(
        SUM(monthly_sales) OVER(
            PARTITION BY order_year
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_sales,
    ROUND(
        SUM(monthly_profit) OVER(
            PARTITION BY order_year
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS running_profit
FROM monthly_sales
ORDER BY order_year, order_month;

-- 17. Year-over-year sales growth
WITH yearly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        ROUND(SUM(sales), 2) AS total_sales
    FROM orders
    GROUP BY YEAR(order_date)
),
sales_with_previous_year AS (
    SELECT
        order_year,
        total_sales,
        LAG(total_sales) OVER(ORDER BY order_year) AS previous_year_sales
    FROM yearly_sales
)
SELECT
    order_year,
    total_sales,
    previous_year_sales,
    ROUND(
        (total_sales - previous_year_sales) / NULLIF(previous_year_sales, 0),
        4
    ) AS yoy_sales_growth
FROM sales_with_previous_year
ORDER BY order_year;

-- 18. Customers above average revenue using a subquery
SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS customer_sales,
    ROUND(SUM(profit), 2) AS customer_profit
FROM orders
GROUP BY customer_id, customer_name, segment
HAVING SUM(sales) > (
    SELECT AVG(customer_sales)
    FROM (
        SELECT SUM(sales) AS customer_sales
        FROM orders
        GROUP BY customer_id
    ) customer_totals
)
ORDER BY customer_sales DESC;

-- 19. Regional manager performance using joins
SELECT
    p.person AS regional_manager,
    o.region,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.sales), 0), 4) AS profit_margin
FROM orders o
LEFT JOIN people p
    ON o.region = p.region
GROUP BY p.person, o.region
ORDER BY total_sales DESC;

-- 20. Return rate by category and market using joins
SELECT
    o.market,
    o.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS returned_orders,
    ROUND(COUNT(DISTINCT r.order_id) / NULLIF(COUNT(DISTINCT o.order_id), 0), 4) AS return_rate,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(CASE WHEN r.order_id IS NOT NULL THEN o.sales ELSE 0 END), 2) AS returned_sales
FROM orders o
LEFT JOIN returns r
    ON o.order_id = r.order_id
GROUP BY o.market, o.category
ORDER BY return_rate DESC, returned_sales DESC;

-- 21. Market sales contribution to company total
WITH market_sales AS (
    SELECT
        market,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY market
)
SELECT
    market,
    total_sales,
    total_profit,
    ROUND(total_sales / NULLIF(SUM(total_sales) OVER(), 0), 4) AS sales_contribution_pct,
    ROUND(total_profit / NULLIF(SUM(total_profit) OVER(), 0), 4) AS profit_contribution_pct
FROM market_sales
ORDER BY sales_contribution_pct DESC;

-- 22. Discount risk analysis by category
WITH category_discount AS (
    SELECT
        category,
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount > 0 AND discount <= 0.10 THEN '0-10%'
            WHEN discount > 0.10 AND discount <= 0.20 THEN '10-20%'
            WHEN discount > 0.20 AND discount <= 0.30 THEN '20-30%'
            ELSE '30%+'
        END AS discount_band,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        COUNT(*) AS line_items
    FROM orders
    GROUP BY
        category,
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount > 0 AND discount <= 0.10 THEN '0-10%'
            WHEN discount > 0.10 AND discount <= 0.20 THEN '10-20%'
            WHEN discount > 0.20 AND discount <= 0.30 THEN '20-30%'
            ELSE '30%+'
        END
)
SELECT
    category,
    discount_band,
    line_items,
    total_sales,
    total_profit,
    ROUND(total_profit / NULLIF(total_sales, 0), 4) AS profit_margin,
    RANK() OVER(PARTITION BY category ORDER BY total_profit ASC) AS profit_risk_rank
FROM category_discount
ORDER BY category, profit_risk_rank;
