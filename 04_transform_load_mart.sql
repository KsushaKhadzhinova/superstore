-- ============================
-- Transform and load mart.sales_report from core tables
-- ============================

INSERT INTO mart.sales_report (
    order_id, version, order_date, ship_date, ship_mode, customer_id, customer_name, segment, city, state, postal_code, country, region,
    product_id, product_name, category, sub_category, sales, quantity, discount, profit, valid_from, valid_to, is_current
)
SELECT
    o.order_id,
    1 AS version,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    c.customer_id,
    c.customer_name,
    c.segment,
    c.city,
    c.state,
    c.postal_code,
    c.country,
    c.region,
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    o.sales,
    o.quantity,
    o.discount,
    o.profit,
    CURRENT_DATE,
    NULL,
    TRUE
FROM core.orders o
JOIN core.customers c ON o.customer_id = c.customer_id
JOIN core.products p ON o.product_id = p.product_id
ON CONFLICT (order_id) DO NOTHING;
