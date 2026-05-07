-- ============================================================
-- SALES DASHBOARD - SQL Queries for every APEX page & chart
-- ============================================================

-- PAGE 1: KPI Cards
SELECT
    TO_CHAR(total_revenue,      'FM$999,999,990.00')    AS total_revenue,
    TO_CHAR(total_orders,       'FM999,990')             AS total_orders,
    TO_CHAR(total_customers,    'FM999,990')             AS total_customers,
    TO_CHAR(avg_order_value,    'FM$999,990.00')         AS avg_order_value,
    TO_CHAR(current_month_revenue,'FM$999,999,990.00')   AS current_month_revenue,
    ROUND(
        (current_month_revenue - prev_month_revenue)
        / NULLIF(prev_month_revenue, 0) * 100, 1
    ) AS mom_growth_pct
FROM sd_kpi_summary;


-- PAGE 1: Revenue Trend (JET Line Chart)
-- Label column: LABEL   Value columns: "Revenue", "Cost", "Gross Profit"
SELECT
    month_label   AS label,
    revenue       AS "Revenue",
    total_cost    AS "Cost",
    gross_profit  AS "Gross Profit"
FROM   sd_monthly_revenue
ORDER  BY month_start;


-- PAGE 1: Top 10 Products (JET Bar Horizontal)
-- Label: LABEL   Value: VALUE   Series: SERIES
SELECT
    product_id,
    product_name  AS label,
    revenue       AS value,
    category      AS series
FROM   sd_top_products
WHERE  revenue_rank <= 10
ORDER  BY revenue DESC;


-- PAGE 1: Revenue by Region (JET Pie)
SELECT
    region   AS label,
    revenue  AS value
FROM   sd_revenue_by_region
ORDER  BY revenue DESC;


-- PAGE 1: Orders by Status (JET Donut)
SELECT
    status   AS label,
    COUNT(*) AS value
FROM   sd_orders
GROUP  BY status;


-- PAGE 2: Order List (Interactive Report)
-- Page items: :P2_STATUS  :P2_REGION  :P2_MONTH
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.segment,
    o.status,
    o.region,
    COUNT(i.item_id)                                      AS line_items,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))               AS order_total
FROM   sd_orders       o
JOIN   sd_customers    c ON c.customer_id = o.customer_id
JOIN   sd_order_items  i ON i.order_id    = o.order_id
WHERE  ( :P2_STATUS IS NULL OR o.status  = :P2_STATUS )
AND    ( :P2_REGION IS NULL OR o.region  = :P2_REGION )
AND    ( :P2_MONTH  IS NULL OR TO_CHAR(o.order_date,'YYYY-MM') = :P2_MONTH )
GROUP  BY o.order_id, o.order_date, c.customer_name,
          c.segment, o.status, o.region
ORDER  BY o.order_date DESC;


-- PAGE 3: Order Line Detail
-- Page item: :P3_ORDER_ID
SELECT
    p.product_name,
    p.category,
    i.quantity,
    i.unit_price,
    i.discount_pct,
    ROUND(i.quantity * i.unit_price
          * (1 - NVL(i.discount_pct,0)/100), 2)   AS line_total,
    ROUND(p.cost_price * i.quantity, 2)            AS line_cost,
    ROUND(
        (i.unit_price * (1 - NVL(i.discount_pct,0)/100) - p.cost_price)
        * i.quantity, 2)                           AS line_profit
FROM   sd_order_items i
JOIN   sd_products    p ON p.product_id = i.product_id
WHERE  i.order_id = :P3_ORDER_ID;


-- PAGE 4: Product Monthly Trend (JET Bar)
-- Page item: :P4_PRODUCT_ID
SELECT
    TO_CHAR(o.order_date,'Mon YYYY')              AS sale_month,
    TRUNC(o.order_date,'MM')                      AS month_start,
    SUM(i.quantity)                               AS units_sold,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))        AS revenue
FROM   sd_order_items i
JOIN   sd_orders      o ON o.order_id   = i.order_id
WHERE  i.product_id = :P4_PRODUCT_ID
AND    o.status     = 'Completed'
GROUP  BY TO_CHAR(o.order_date,'Mon YYYY'),
          TRUNC(o.order_date,'MM')
ORDER  BY month_start;
