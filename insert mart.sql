-- ===========================================
-- 🧹 1. Очистка и пересоздание схемы MART
-- ===========================================
DO $$
DECLARE
    tbl RECORD;
BEGIN
    FOR tbl IN 
        SELECT table_schema, table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'mart'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS %I.%I CASCADE;', tbl.table_schema, tbl.table_name);
        RAISE NOTICE '🗑️ Dropped table: %.%', tbl.table_schema, tbl.table_name;
    END LOOP;
END $$;

CREATE SCHEMA IF NOT EXISTS mart;

-- ===========================================
-- 🧱 2. Создание таблиц MART
-- ===========================================

-- 📅 Dimension: Date
CREATE TABLE mart.date (
    date_key SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday VARCHAR(20)
);

-- 📦 Dimension: Product
CREATE TABLE mart.product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    price NUMERIC(12,2),
    cost NUMERIC(12,2)
);

-- 👥 Dimension: Customer
CREATE TABLE mart.customer (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    segment VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100)
);

-- 🏬 Dimension: Store
CREATE TABLE mart.store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(100)
);

-- 💰 Fact: Sales
CREATE TABLE mart.sales (
    sales_id SERIAL PRIMARY KEY,
    order_date_key INT REFERENCES mart.date(date_key),
    product_id INT REFERENCES mart.product(product_id),
    customer_id INT REFERENCES mart.customer(customer_id),
    store_id INT REFERENCES mart.store(store_id),
    sales_amount NUMERIC(14,2),
    quantity INT,
    profit NUMERIC(14,2)
);

-- 📦 Fact: Inventory
CREATE TABLE mart.inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES mart.product(product_id),
    store_id INT REFERENCES mart.store(store_id),
    quantity INT,
    inventory_date_key INT REFERENCES mart.date(date_key)
);

-- 🔁 Fact: Returns
CREATE TABLE mart.returns (
    return_id SERIAL PRIMARY KEY,
    sales_id INT REFERENCES mart.sales(sales_id),
    product_id INT REFERENCES mart.product(product_id),
    return_date_key INT REFERENCES mart.date(date_key),
    quantity_returned INT
);

-- 📅 Date dimension (1 год)
INSERT INTO mart.date (date, year, quarter, month, day, weekday)
SELECT 
    d::DATE,
    EXTRACT(YEAR FROM d)::INT,
    EXTRACT(QUARTER FROM d)::INT,
    EXTRACT(MONTH FROM d)::INT,
    EXTRACT(DAY FROM d)::INT,
    TO_CHAR(d, 'Day')
FROM generate_series('2024-01-01'::DATE, '2024-12-31'::DATE, INTERVAL '1 day') d;

RAISE NOTICE '✅ date table filled';


-- 📦 Product dimension
INSERT INTO mart.product (product_name, category, sub_category, price, cost)
SELECT 
    'Product ' || g::TEXT AS product_name,
    CASE WHEN g % 3 = 0 THEN 'Office Supplies'
         WHEN g % 3 = 1 THEN 'Technology'
         ELSE 'Furniture' END AS category,
    CASE WHEN g % 2 = 0 THEN 'Subcat A' ELSE 'Subcat B' END AS sub_category,
    (100 + random() * 400)::NUMERIC(12,2) AS price,
    (50 + random() * 200)::NUMERIC(12,2) AS cost
FROM generate_series(1, 50) g;

RAISE NOTICE '✅ product table filled';


-- 👥 Customer dimension
INSERT INTO mart.customer (customer_name, segment, region, city)
SELECT 
    'Customer ' || g::TEXT,
    CASE WHEN g % 3 = 0 THEN 'Consumer'
         WHEN g % 3 = 1 THEN 'Corporate'
         ELSE 'Home Office' END,
    CASE WHEN g % 4 = 0 THEN 'West'
         WHEN g % 4 = 1 THEN 'East'
         WHEN g % 4 = 2 THEN 'Central'
         ELSE 'South' END,
    'City ' || g::TEXT
FROM generate_series(1, 100) g;

RAISE NOTICE '✅ customer table filled';


-- 🏬 Store dimension
INSERT INTO mart.store (store_name, city, state, region)
SELECT 
    'Store ' || g::TEXT,
    'City ' || g::TEXT,
    'State ' || g::TEXT,
    CASE WHEN g % 2 = 0 THEN 'West' ELSE 'East' END
FROM generate_series(1, 10) g;

RAISE NOTICE '✅ store table filled';


-- =====================================================
-- 💰 ЗАПОЛНЕНИЕ ФАКТОВ (FACTS)
-- =====================================================

-- 💵 Sales
INSERT INTO mart.sales (order_date_key, product_id, customer_id, store_id, sales_amount, quantity, profit)
SELECT 
    d.date_key,
    p.product_id,
    c.customer_id,
    s.store_id,
    (p.price * (0.9 + random() * 0.3))::NUMERIC(14,2),
    (1 + (random() * 10)::INT),
    ((p.price - p.cost) * (0.8 + random() * 0.4))::NUMERIC(14,2)
FROM mart.product p
CROSS JOIN LATERAL (SELECT customer_id FROM mart.customer ORDER BY random() LIMIT 1) c
CROSS JOIN LATERAL (SELECT store_id FROM mart.store ORDER BY random() LIMIT 1) s
CROSS JOIN LATERAL (SELECT date_key FROM mart.date ORDER BY random() LIMIT 1) d
LIMIT 1000;

RAISE NOTICE '✅ sales table filled';


-- 📦 Inventory
INSERT INTO mart.inventory (product_id, store_id, quantity, inventory_date_key)
SELECT 
    p.product_id,
    s.store_id,
    (10 + random() * 200)::INT,
    d.date_key
FROM mart.product p
JOIN mart.store s ON true
JOIN mart.date d ON d.date = '2024-12-31'
LIMIT 200;

RAISE NOTICE '✅ inventory table filled';


-- 🔁 Returns
INSERT INTO mart.returns (sales_id, product_id, return_date_key, quantity_returned)
SELECT 
    s.sales_id,
    s.product_id,
    d.date_key,
    (CASE WHEN random() < 0.1 THEN 1 ELSE 0 END)::INT
FROM mart.sales s
JOIN mart.date d ON d.date = '2024-12-31';

RAISE NOTICE '✅ returns table filled';


-- =====================================================
-- ✅ Проверка итогов
-- =====================================================
SELECT 'mart.product' AS table, COUNT(*) AS rows FROM mart.product UNION ALL
SELECT 'mart.customer', COUNT(*) FROM mart.customer UNION ALL
SELECT 'mart.store', COUNT(*) FROM mart.store UNION ALL
SELECT 'mart.date', COUNT(*) FROM mart.date UNION ALL
SELECT 'mart.sales', COUNT(*) FROM mart.sales UNION ALL
SELECT 'mart.inventory', COUNT(*) FROM mart.inventory UNION ALL
SELECT 'mart.returns', COUNT(*) FROM mart.returns;
