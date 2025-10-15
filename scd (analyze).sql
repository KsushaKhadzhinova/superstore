-- SCD Type 1: обновление текущих записей, если изменились поля (кроме version, valid_from, valid_to, is_current)

UPDATE mart.sales_report m
SET
  order_date = s.order_date,
  ship_date = s.ship_date,
  ship_mode = s.ship_mode,
  customer_name = s.customer_name,
  segment = s.segment,
  city = s.city,
  state = s.state,
  postal_code = s.postal_code,
  country = s.country,
  region = s.region,
  product_name = s.product_name,
  category = s.category,
  sub_category = s.sub_category,
  sales = s.sales,
  quantity = s.quantity,
  discount = s.discount,
  profit = s.profit
FROM stage.orders_raw s
WHERE m.order_id = s.order_id
AND m.is_current = TRUE
AND (
    m.order_date IS DISTINCT FROM s.order_date OR
    m.ship_date IS DISTINCT FROM s.ship_date OR
    m.ship_mode IS DISTINCT FROM s.ship_mode OR
    m.customer_name IS DISTINCT FROM s.customer_name OR
    m.segment IS DISTINCT FROM s.segment OR
    m.city IS DISTINCT FROM s.city OR
    m.state IS DISTINCT FROM s.state OR
    m.postal_code IS DISTINCT FROM s.postal_code OR
    m.country IS DISTINCT FROM s.country OR
    m.region IS DISTINCT FROM s.region OR
    m.product_name IS DISTINCT FROM s.product_name OR
    m.category IS DISTINCT FROM s.category OR
    m.sub_category IS DISTINCT FROM s.sub_category OR
    m.sales IS DISTINCT FROM s.sales OR
    m.quantity IS DISTINCT FROM s.quantity OR
    m.discount IS DISTINCT FROM s.discount OR
    m.profit IS DISTINCT FROM s.profit
);

-- SCD Type 2: выделяем "новые версии" записей (например, order_id с суффиксом '_ver2')

WITH scd2_rows AS (
  SELECT s.*
  FROM stage.orders_raw s
  JOIN mart.sales_report m ON
    m.order_id = REGEXP_REPLACE(s.order_id, '_ver2$', '') AND m.is_current = TRUE 
  WHERE s.order_id LIKE '%_ver2'
)
-- Обновляем прежнюю запись (делаем не текущей)
UPDATE mart.sales_report m
SET valid_to = CURRENT_DATE,
    is_current = FALSE
FROM scd2_rows s
WHERE m.order_id = REGEXP_REPLACE(s.order_id, '_ver2$', '')
AND m.is_current = TRUE;

-- Вставляем новые версии
INSERT INTO mart.sales_report (
    order_id, version, order_date, ship_date, ship_mode, customer_id, customer_name, segment, city, state, postal_code, country, region,
    product_id, product_name, category, sub_category, sales, quantity, discount, profit, valid_from, valid_to, is_current
)
SELECT
    s.order_id,
    COALESCE(mr.version, 1) + 1,
    s.order_date,
    s.ship_date,
    s.ship_mode,
    s.customer_id,
    s.customer_name,
    s.segment,
    s.city,
    s.state,
    s.postal_code,
    s.country,
    s.region,
    s.product_id,
    s.product_name,
    s.category,
    s.sub_category,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    CURRENT_DATE,
    NULL,
    TRUE
FROM stage.orders_raw s
LEFT JOIN mart.sales_report mr ON mr.order_id = REGEXP_REPLACE(s.order_id, '_ver2$', '')
WHERE s.order_id LIKE '%_ver2';
