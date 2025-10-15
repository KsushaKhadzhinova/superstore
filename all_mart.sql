CREATE TABLE product_mart (
  product_id SERIAL PRIMARY KEY, 
  product_name VARCHAR(255), 
  category VARCHAR(100), 
  sub_category VARCHAR(100), 
  price NUMERIC(12,2), 
  cost NUMERIC(12,2)
);

CREATE TABLE customer_mart (
  customer_id SERIAL PRIMARY KEY, 
  customer_name VARCHAR(255), 
  segment VARCHAR(100), 
  region VARCHAR(100), 
  city VARCHAR(100)
);

CREATE TABLE store_mart (
  store_id SERIAL PRIMARY KEY, 
  store_name VARCHAR(255), 
  city VARCHAR(100), 
  state VARCHAR(100), 
  region VARCHAR(100)
);

CREATE TABLE date_mart (
  date_key INT PRIMARY KEY, 
  date DATE UNIQUE, 
  year INT, 
  quarter INT, 
  month INT, 
  day INT, 
  weekday VARCHAR(20)
);

CREATE TABLE sales_mart (
  sales_id SERIAL PRIMARY KEY, 
  order_date_key INT REFERENCES date_mart(date_key), 
  product_id INT REFERENCES product_mart(product_id), 
  customer_id INT REFERENCES customer_mart(customer_id), 
  store_id INT REFERENCES store_mart(store_id), 
  sales_amount NUMERIC(14,2), 
  quantity INT, 
  profit NUMERIC(14,2)
);

CREATE TABLE inventory_mart (
  inventory_id SERIAL PRIMARY KEY, 
  product_id INT REFERENCES product_mart(product_id), 
  store_id INT REFERENCES store_mart(store_id), 
  quantity INT, 
  inventory_date_key INT REFERENCES date_mart(date_key)
);

CREATE TABLE returns_mart (
  return_id SERIAL PRIMARY KEY, 
  sales_id INT REFERENCES sales_mart(sales_id), 
  product_id INT REFERENCES product_mart(product_id), 
  return_date_key INT REFERENCES date_mart(date_key), 
  quantity_returned INT
);

