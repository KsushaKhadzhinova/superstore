-- Количество строк в Stage
SELECT COUNT(*) FROM stage.orders_raw;

-- Количество уникальных строк (по всем столбцам, кроме row_id)
SELECT COUNT(*) FROM (
  SELECT DISTINCT 
    row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
    segment, country, city, state, postal_code, region, product_id, category, sub_category, product_name,
    sales, quantity, discount, profit
  FROM stage.orders_raw
) AS unique_rows;

