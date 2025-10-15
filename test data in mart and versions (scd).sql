SELECT order_id, COUNT(*) AS versions_count, SUM(CASE WHEN is_current THEN 1 ELSE 0 END) AS current_versions
FROM mart.sales_report
GROUP BY order_id
HAVING COUNT(*) > 1 OR SUM(CASE WHEN is_current THEN 1 ELSE 0 END) != 1;
