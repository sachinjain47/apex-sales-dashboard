-- ============================================================
-- SALES DASHBOARD - Table Creation
-- Run in: APEX > SQL Workshop > SQL Commands
-- ============================================================

-- 1. CUSTOMERS
CREATE TABLE sd_customers (
    customer_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email         VARCHAR2(150),
    city          VARCHAR2(100),
    country       VARCHAR2(100),
    segment       VARCHAR2(50)   -- 'Enterprise', 'SMB', 'Consumer'
);

-- 2. PRODUCTS
CREATE TABLE sd_products (
    product_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name  VARCHAR2(150) NOT NULL,
    category      VARCHAR2(100),  -- 'Electronics', 'Clothing', 'Food', etc.
    unit_price    NUMBER(10,2)   NOT NULL,
    cost_price    NUMBER(10,2)   NOT NULL
);

-- 3. ORDERS
CREATE TABLE sd_orders (
    order_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   NUMBER         NOT NULL REFERENCES sd_customers(customer_id),
    order_date    DATE           NOT NULL,
    status        VARCHAR2(50)   NOT NULL,  -- 'Completed', 'Pending', 'Cancelled'
    region        VARCHAR2(100)
);

-- 4. ORDER LINE ITEMS
CREATE TABLE sd_order_items (
    item_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id      NUMBER         NOT NULL REFERENCES sd_orders(order_id),
    product_id    NUMBER         NOT NULL REFERENCES sd_products(product_id),
    quantity      NUMBER         NOT NULL,
    unit_price    NUMBER(10,2)   NOT NULL,  -- price at time of sale
    discount_pct  NUMBER(5,2)    DEFAULT 0
);

-- ============================================================
-- VIEWS used by APEX pages
-- ============================================================

-- Monthly Revenue View
CREATE OR REPLACE VIEW sd_monthly_revenue AS
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')           AS sale_month,
    TO_CHAR(o.order_date, 'Mon YYYY')          AS month_label,
    TRUNC(o.order_date, 'MM')                  AS month_start,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))     AS revenue,
    SUM(i.quantity * p.cost_price)             AS total_cost,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))
    - SUM(i.quantity * p.cost_price)           AS gross_profit,
    COUNT(DISTINCT o.order_id)                 AS order_count
FROM   sd_orders o
JOIN   sd_order_items i ON i.order_id   = o.order_id
JOIN   sd_products    p ON p.product_id = i.product_id
WHERE  o.status = 'Completed'
GROUP  BY TO_CHAR(o.order_date,'YYYY-MM'),
          TO_CHAR(o.order_date,'Mon YYYY'),
          TRUNC(o.order_date,'MM');

-- Top Products View
CREATE OR REPLACE VIEW sd_top_products AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(i.quantity)                                       AS units_sold,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))               AS revenue,
    RANK() OVER (ORDER BY
        SUM(i.quantity * i.unit_price
            * (1 - NVL(i.discount_pct,0)/100)) DESC)     AS revenue_rank
FROM   sd_products    p
JOIN   sd_order_items i ON i.product_id = p.product_id
JOIN   sd_orders      o ON o.order_id   = i.order_id
WHERE  o.status = 'Completed'
GROUP  BY p.product_id, p.product_name, p.category;

-- KPI Summary View
CREATE OR REPLACE VIEW sd_kpi_summary AS
SELECT
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))          AS total_revenue,
    COUNT(DISTINCT o.order_id)                       AS total_orders,
    COUNT(DISTINCT o.customer_id)                    AS total_customers,
    ROUND(
        SUM(i.quantity * i.unit_price
            * (1 - NVL(i.discount_pct,0)/100))
        / NULLIF(COUNT(DISTINCT o.order_id),0), 2)  AS avg_order_value,
    SUM(CASE WHEN TRUNC(o.order_date,'MM') = TRUNC(SYSDATE,'MM')
             THEN i.quantity * i.unit_price * (1 - NVL(i.discount_pct,0)/100)
             ELSE 0 END)                             AS current_month_revenue,
    SUM(CASE WHEN TRUNC(o.order_date,'MM') = ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)
             THEN i.quantity * i.unit_price * (1 - NVL(i.discount_pct,0)/100)
             ELSE 0 END)                             AS prev_month_revenue
FROM  sd_orders o
JOIN  sd_order_items i ON i.order_id = o.order_id
WHERE o.status = 'Completed';

-- Revenue by Region View
CREATE OR REPLACE VIEW sd_revenue_by_region AS
SELECT
    NVL(o.region, 'Unknown')                          AS region,
    SUM(i.quantity * i.unit_price
        * (1 - NVL(i.discount_pct,0)/100))            AS revenue,
    COUNT(DISTINCT o.order_id)                        AS order_count
FROM  sd_orders o
JOIN  sd_order_items i ON i.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY o.region;
