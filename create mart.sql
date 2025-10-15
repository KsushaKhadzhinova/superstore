-- Удаляем все старые таблицы (public + mart), если они остались
DO $$
DECLARE
    tbl RECORD;
BEGIN
    -- Удаляем таблицы из public
    FOR tbl IN 
        SELECT table_schema, table_name 
        FROM information_schema.tables 
        WHERE table_schema IN ('public', 'mart')
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS %I.%I CASCADE;', tbl.table_schema, tbl.table_name);
        RAISE NOTICE '🗑️ Dropped table: %.%', tbl.table_schema, tbl.table_name;
    END LOOP;
END $$;

-- Создаём схему, если её нет
CREATE SCHEMA IF NOT EXISTS mart;

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

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'mart'
ORDER BY table_name;
