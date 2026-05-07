-- ============================================================
-- SALES DASHBOARD - Sample Data
-- Run AFTER 01_create_tables.sql
-- ============================================================

-- CUSTOMERS
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Acme Corp',       'acme@example.com',    'New York',   'USA',     'Enterprise');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Globex Ltd',      'globex@example.com',  'London',     'UK',      'Enterprise');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Initech',         'info@initech.com',    'Berlin',     'Germany', 'SMB');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Umbrella Inc',    'u@umbrella.com',      'Paris',      'France',  'Enterprise');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Wonka Industries','wonka@factory.com',   'Stockholm',  'Sweden',  'SMB');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Stark Tech',      'tony@stark.com',      'Chicago',    'USA',     'SMB');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Wayne Enterprises','bruce@wayne.com',    'Gotham',     'USA',     'Enterprise');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Dunder Mifflin',  'michael@dm.com',      'Scranton',   'USA',     'SMB');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Pied Piper',      'richard@pp.com',      'San Jose',   'USA',     'Consumer');
INSERT INTO sd_customers (customer_name, email, city, country, segment) VALUES ('Hooli Corp',      'gavin@hooli.com',     'San Jose',   'USA',     'Enterprise');

-- PRODUCTS
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Laptop Pro 15',       'Electronics',  1299.00, 750.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Wireless Headphones',  'Electronics',   149.99,  45.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Standing Desk',        'Furniture',     499.00, 200.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Ergonomic Chair',      'Furniture',     349.00, 140.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('4K Monitor',           'Electronics',   599.00, 250.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Mechanical Keyboard',  'Electronics',    89.99,  30.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('USB-C Hub',            'Electronics',    49.99,  12.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Notebook Pack (10)',   'Stationery',     12.99,   3.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Office Chair Mat',     'Furniture',      59.99,  20.00);
INSERT INTO sd_products (product_name, category, unit_price, cost_price) VALUES ('Webcam HD 1080p',      'Electronics',    79.99,  25.00);

-- ORDERS & ORDER ITEMS (18 months of randomised data)
BEGIN
    FOR i IN 1..200 LOOP
        DECLARE
            v_order_id   NUMBER;
            v_cust_id    NUMBER := TRUNC(DBMS_RANDOM.VALUE(1,11));
            v_days_back  NUMBER := TRUNC(DBMS_RANDOM.VALUE(0,540));
            v_order_date DATE   := TRUNC(SYSDATE) - v_days_back;
            v_status     VARCHAR2(20);
            v_region     VARCHAR2(50);
            v_num_items  NUMBER := TRUNC(DBMS_RANDOM.VALUE(1,5));
        BEGIN
            CASE
                WHEN DBMS_RANDOM.VALUE < 0.80 THEN v_status := 'Completed';
                WHEN DBMS_RANDOM.VALUE < 0.90 THEN v_status := 'Pending';
                ELSE                                v_status := 'Cancelled';
            END CASE;

            CASE TRUNC(DBMS_RANDOM.VALUE(1,5))
                WHEN 1 THEN v_region := 'North America';
                WHEN 2 THEN v_region := 'Europe';
                WHEN 3 THEN v_region := 'Asia Pacific';
                ELSE        v_region := 'Middle East';
            END CASE;

            INSERT INTO sd_orders (customer_id, order_date, status, region)
            VALUES (v_cust_id, v_order_date, v_status, v_region)
            RETURNING order_id INTO v_order_id;

            FOR j IN 1..v_num_items LOOP
                INSERT INTO sd_order_items (order_id, product_id, quantity, unit_price, discount_pct)
                SELECT v_order_id,
                       product_id,
                       TRUNC(DBMS_RANDOM.VALUE(1,10)),
                       unit_price,
                       CASE WHEN DBMS_RANDOM.VALUE < 0.3
                            THEN ROUND(DBMS_RANDOM.VALUE(5,20))
                            ELSE 0 END
                FROM   sd_products
                WHERE  product_id = TRUNC(DBMS_RANDOM.VALUE(1,11));
            END LOOP;
        END;
    END LOOP;
    COMMIT;
END;
/

SELECT 'Customers'   AS tbl, COUNT(*) AS cnt FROM sd_customers  UNION ALL
SELECT 'Products',          COUNT(*)          FROM sd_products   UNION ALL
SELECT 'Orders',            COUNT(*)          FROM sd_orders     UNION ALL
SELECT 'Order Items',       COUNT(*)          FROM sd_order_items;
