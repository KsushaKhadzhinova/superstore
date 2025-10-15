-- 1️⃣ Копируем таблицу продуктов
INSERT INTO mart.product_mart
SELECT * FROM public.product_mart;

-- 2️⃣ Копируем таблицу клиентов
INSERT INTO mart.customer_mart
SELECT * FROM public.customer_mart;

-- 3️⃣ Копируем таблицу магазинов
INSERT INTO mart.store_mart
SELECT * FROM public.store_mart;

-- 4️⃣ Копируем календарь
INSERT INTO mart.date_mart
SELECT * FROM public.date_mart;

-- 5️⃣ Копируем продажи
INSERT INTO mart.sales_mart
SELECT * FROM public.sales_mart;

-- 6️⃣ Копируем запасы
INSERT INTO mart.inventory_mart
SELECT * FROM public.inventory_mart;

-- 7️⃣ Копируем возвраты
INSERT INTO mart.returns_mart
SELECT * FROM public.returns_mart;


SELECT 
    'product_mart' AS table_name, COUNT(*) AS rows_count FROM mart.product_mart
UNION ALL
SELECT 'customer_mart', COUNT(*) FROM mart.customer_mart
UNION ALL
SELECT 'store_mart', COUNT(*) FROM mart.store_mart
UNION ALL
SELECT 'date_mart', COUNT(*) FROM mart.date_mart
UNION ALL
SELECT 'sales_mart', COUNT(*) FROM mart.sales_mart
UNION ALL
SELECT 'inventory_mart', COUNT(*) FROM mart.inventory_mart
UNION ALL
SELECT 'returns_mart', COUNT(*) FROM mart.returns_mart;


