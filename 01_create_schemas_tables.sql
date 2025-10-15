-- ============================
-- Stage, Core, and Mart Schemas
-- ============================

-- Stage schema for raw data storage
CREATE SCHEMA IF NOT EXISTS stage;

CREATE TABLE stage.orders_raw (
    row_id SERIAL PRIMARY KEY,
    row_number INTEGER,
    order_id VARCHAR,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    segment VARCHAR,
    country VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    region VARCHAR,
    product_id VARCHAR,
    category VARCHAR,
    sub_category VARCHAR,
    product_name VARCHAR,
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC
);

-- Core schema for normalized data
CREATE SCHEMA IF NOT EXISTS core;

CREATE TABLE core.customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_name VARCHAR,
    segment VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    region VARCHAR
);

CREATE TABLE core.products (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    category VARCHAR,
    sub_category VARCHAR
);

CREATE TABLE core.orders (
    order_id VARCHAR PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR,
    customer_id VARCHAR REFERENCES core.customers(customer_id),
    product_id VARCHAR REFERENCES core.products(product_id),
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC
);

-- Mart schema for denormalized reporting with versioning support
CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE mart.sales_report (
    surrogate_key SERIAL PRIMARY KEY,
    order_id VARCHAR,
    version INTEGER DEFAULT 1,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    segment VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    region VARCHAR,
    product_id VARCHAR,
    product_name VARCHAR,
    category VARCHAR,
    sub_category VARCHAR,
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_current BOOLEAN DEFAULT TRUE
);

ALTER TABLE mart.sales_report ADD CONSTRAINT uq_order_id UNIQUE (order_id);
