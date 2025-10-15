-- Клиенты
INSERT INTO core.customers (customer_id, customer_name, segment, city, state, postal_code, country, region)
SELECT DISTINCT customer_id, customer_name, segment, city, state, postal_code, country, region
FROM stage.orders_raw
ON CONFLICT (customer_id) DO NOTHING;

-- Продукты
INSERT INTO core.products (product_id, product_name, category, sub_category)
SELECT DISTINCT product_id, product_name, category, sub_category
FROM stage.orders_raw
ON CONFLICT (product_id) DO NOTHING;

-- Заказы
INSERT INTO core.orders (order_id, order_date, ship_date, ship_mode, customer_id, product_id, sales, quantity, discount, profit)
SELECT DISTINCT order_id, order_date, ship_date, ship_mode, customer_id, product_id, sales, quantity, discount, profit
FROM stage.orders_raw
ON CONFLICT (order_id) DO NOTHING;
