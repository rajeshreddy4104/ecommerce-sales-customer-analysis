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
