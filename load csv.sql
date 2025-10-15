-- Пример команды для pgAdmin Query Tool (клиентская загрузка)
\copy stage.orders_raw(row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment, country, city, state, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit) 
FROM 'E:/intern/etl + power bi/initial_load_superstore.csv' CSV HEADER DELIMITER ',';

\copy stage.orders_raw(row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment, country, city, state, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit) 
FROM 'E:/intern/etl + power bi/secondary_load_superstore.csv' CSV HEADER DELIMITER ',';


--Правильный вариант
\copy stage.orders_raw(row_number, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment, country, city, state, postal_code, region, product_id, category, sub_category, product_name, sales, quantity, discount, profit) 
FROM 'E:/intern/etl + power bi/initial_load_superstore.csv' CSV HEADER DELIMITER ',';

