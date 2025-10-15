-- Проверка новых order_id в Stage
SELECT DISTINCT order_id FROM stage.orders_raw WHERE order_id LIKE 'NEW-%';

-- Проверка наличия этих order_id в Mart
SELECT order_id, is_current FROM mart.sales_report WHERE order_id LIKE 'NEW-%';

-- Проверка изменений SCD Type 1
SELECT order_id, segment FROM mart.sales_report WHERE order_id IN (SELECT order_id FROM stage.orders_raw WHERE order_id LIKE 'SCD1-%');

-- Проверка версий SCD Type 2 для order_id с суффиксом _ver2
SELECT order_id, version, valid_from, valid_to, is_current 
FROM mart.sales_report 
WHERE order_id LIKE '%_ver2';
