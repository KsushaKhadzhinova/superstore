-- ================================================================
-- 🧩 SUPERSTORE — FULL MART LAYER REFRESH SCRIPT
-- Author: Kseniya
-- Purpose: Create & Refresh mart layer from core and stage schemas
-- ================================================================

-- 1️⃣ Ensure mart schema exists
CREATE SCHEMA IF NOT EXISTS mart;

-- 2️⃣ DROP existing tables (optional, clean rebuild)
DROP TABLE IF EXISTS 
  mart.returns_mart, 
  mart.inventory_mart, 
  mart.sales_mart, 
  mart.date_mart, 
  mart.store_mart, 
  mart.customer_mart, 
  mart.product_mart 
CASCADE;

-- 3️⃣ CREATE mart tables
CREATE TABLE mart.product_mart (
  product_id SERIAL PRIMARY KEY, 
  product_name VARCHAR(255), 
  category VARCHAR(100), 
  sub_category VARCHAR(100), 
  price NUMERIC(12,2), 
  cost NUMERIC(12,2)
);

CREATE TABLE mart.customer_mart (
  customer_id SERIAL PRIMARY KEY, 
  customer_name VARCHAR(255), 
  segment VARCHAR(100), 
  region VARCHAR(100), 
  city VARCHAR(100)
);

CREATE TABLE mart.store_mart (
  store_id SERIAL PRIMARY KEY, 
  store_name VARCHAR(255), 
  city VARCHAR(100), 
  state VARCHAR(100), 
  region VARCHAR(100)
);

CREATE TABLE mart.date_mart (
  date_key INT PRIMARY KEY, 
  date DATE UNIQUE, 
  year INT, 
  quarter INT, 
  month INT, 
  day INT, 
  weekday VARCHAR(20)
);

CREATE TABLE mart.sales_mart (
  sales_id SERIAL PRIMARY KEY, 
  order_date_key INT REFERENCES mart.date_mart(date_key), 
  product_id INT REFERENCES mart.product_mart(product_id), 
  customer_id INT REFERENCES mart.customer_mart(customer_id), 
  store_id INT REFERENCES mart.store_mart(store_id), 
  sales_amount NUMERIC(14,2), 
  quantity INT, 
  profit NUMERIC(14,2)
);

CREATE TABLE mart.inventory_mart (
  inventory_id SERIAL PRIMARY KEY, 
  product_id INT REFERENCES mart.product_mart(product_id), 
  store_id INT REFERENCES mart.store_mart(store_id), 
  quantity INT, 
  inventory_date_key INT REFERENCES mart.date_mart(date_key)
);

CREATE TABLE mart.returns_mart (
  return_id SERIAL PRIMARY KEY, 
  sales_id INT REFERENCES mart.sales_mart(sales_id), 
  product_id INT REFERENCES mart.product_mart(product_id), 
  return_date_key INT REFERENCES mart.date_mart(date_key), 
  quantity_returned INT
);


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'core'
  AND table_name = 'products';


-- ================================================================
-- 4️⃣ POPULATE MART TABLES
-- ================================================================

-- 🔸 Product Mart
INSERT INTO mart.product_mart (product_name, category, sub_category, price, cost)
SELECT DISTINCT
    p.product_name,
    p.category,
    p.sub_category,
    0 AS price,
    0 AS cost
FROM core.products p;

-- 🔸 Customer Mart
INSERT INTO mart.customer_mart (customer_name, segment, region, city)
SELECT DISTINCT 
    c.customer_name,
    c.segment,
    c.region,
    c.city
FROM core.customers c;

-- 🔸 Store Mart
INSERT INTO mart.store_mart (store_name, city, state, region)
SELECT DISTINCT
    CONCAT(c.region, ' Store') AS store_name,
    c.city,
    c.state,
    c.region
FROM core.customers c;

-- 🔸 Date Mart (auto-generated)
WITH date_series AS (
    SELECT generate_series(
        (SELECT MIN(order_date) FROM core.orders),
        (SELECT MAX(order_date) FROM core.orders),
        interval '1 day'
    )::date AS date
)
INSERT INTO mart.date_mart (date_key, date, year, quarter, month, day, weekday)
SELECT
    EXTRACT(YEAR FROM date)::INT * 10000 +
    EXTRACT(MONTH FROM date)::INT * 100 +
    EXTRACT(DAY FROM date)::INT AS date_key,
    date,
    EXTRACT(YEAR FROM date)::INT,
    EXTRACT(QUARTER FROM date)::INT,
    EXTRACT(MONTH FROM date)::INT,
    EXTRACT(DAY FROM date)::INT,
    TO_CHAR(date, 'Day')
FROM date_series;

-- 🔸 Sales Mart
INSERT INTO mart.sales_mart (
    order_date_key, 
    product_id, 
    customer_id, 
    store_id, 
    sales_amount, 
    quantity, 
    profit
)
SELECT
    d.date_key,
    pm.product_id,
    cm.customer_id,
    sm.store_id,
    o.sales,
    o.quantity,
    o.profit
FROM core.orders o
JOIN core.products p ON o.product_id = p.product_id
JOIN core.customers c ON o.customer_id = c.customer_id
JOIN mart.product_mart pm 
    ON pm.product_name = p.product_name
JOIN mart.customer_mart cm 
    ON cm.customer_name = c.customer_name
JOIN mart.store_mart sm 
    ON sm.region = c.region  -- связываем по региону вместо store_id
JOIN mart.date_mart d 
    ON d.date = o.order_date;


-- 🔸 Inventory Mart (примерная структура)
INSERT INTO mart.inventory_mart (product_id, store_id, quantity, inventory_date_key)
SELECT
    pm.product_id,
    sm.store_id,
    -- допустим, средний запас = продажи за месяц * коэффициент 1.5
    ROUND(SUM(s.quantity) * 1.5) AS quantity,
    d.date_key
FROM mart.sales_mart s
JOIN mart.product_mart pm ON s.product_id = pm.product_id
JOIN mart.store_mart sm ON s.store_id = sm.store_id
JOIN mart.date_mart d ON s.order_date_key = d.date_key
GROUP BY pm.product_id, sm.store_id, d.date_key;

-- 🔸 Returns Mart
INSERT INTO mart.returns_mart (sales_id, product_id, return_date_key, quantity_returned)
SELECT
    s.sales_id,
    s.product_id,
    d.date_key,
    ROUND(s.quantity * 0.1) AS quantity_returned  -- допустим, 10% от проданного
FROM mart.sales_mart s
JOIN mart.date_mart d ON d.date_key = s.order_date_key
WHERE RANDOM() < 0.05  -- 5% возвратов
AND s.quantity > 0;

-- ================================================================
-- 5️⃣ CHECK RESULTS
-- ================================================================
SELECT 
    'product_mart' AS table_name, COUNT(*) AS rows_count FROM mart.product_mart
UNION ALL
SELECT 'customer_mart', COUNT(*) FROM mart.customer_mart
UNION ALL
SELECT 'store_mart', COUNT(*) FROM mart.store_mart
UNION ALL
SELECT 'date_mart', COUNT(*) FROM mart.date_mart
UNION ALL
SELECT 'sales_mart', COUNT(*) FROM mart.sales_mart
UNION ALL
SELECT 'inventory_mart', COUNT(*) FROM mart.inventory_mart
UNION ALL
SELECT 'returns_mart', COUNT(*) FROM mart.returns_mart;
