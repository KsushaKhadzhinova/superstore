CREATE TABLE dim_date(date_key DATE PRIMARY KEY, year INT NOT NULL, quarter INT NOT NULL, month INT NOT NULL, day INT NOT NULL, weekday INT NOT NULL);
CREATE TABLE dim_product(product_id SERIAL PRIMARY KEY, product_name VARCHAR(255), category VARCHAR(100), sub_category VARCHAR(100), price NUMERIC(12,2), cost NUMERIC(12,2));
CREATE TABLE dim_customer(customer_id SERIAL PRIMARY KEY, customer_name VARCHAR(255), segment VARCHAR(100), region VARCHAR(100), city VARCHAR(100));
CREATE TABLE dim_store(store_id SERIAL PRIMARY KEY, store_name VARCHAR(255), city VARCHAR(100), state VARCHAR(100), region VARCHAR(100));
CREATE TABLE fact_sales(sales_id SERIAL PRIMARY KEY, order_date DATE NOT NULL, product_id INT NOT NULL REFERENCES dim_product(product_id), customer_id INT NOT NULL REFERENCES dim_customer(customer_id), store_id INT NOT NULL REFERENCES dim_store(store_id), sales_amount NUMERIC(14,2), quantity INT, profit NUMERIC(14,2));
CREATE TABLE fact_inventory(inventory_id SERIAL PRIMARY KEY, product_id INT NOT NULL REFERENCES dim_product(product_id), store_id INT NOT NULL REFERENCES dim_store(store_id), quantity INT, date_key DATE NOT NULL REFERENCES dim_date(date_key));
CREATE TABLE fact_returns(return_id SERIAL PRIMARY KEY, sales_id INT NOT NULL REFERENCES fact_sales(sales_id), product_id INT NOT NULL REFERENCES dim_product(product_id), return_date DATE NOT NULL, quantity_returned INT);
