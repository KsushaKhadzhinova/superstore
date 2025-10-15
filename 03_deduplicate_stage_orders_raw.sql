-- ============================
-- Deduplication in stage.orders_raw
-- ============================

CREATE TABLE stage.orders_unique AS 
SELECT DISTINCT
  row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment, country, city, state, postal_code, region,
  product_id, category, sub_category, product_name, sales, quantity, discount, profit
FROM stage.orders_raw;

TRUNCATE TABLE stage.orders_raw;

INSERT INTO stage.orders_raw (row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment, country, city, state, postal_code, region,
                             product_id, category, sub_category, product_name, sales, quantity, discount, profit)
SELECT * FROM stage.orders_unique;
