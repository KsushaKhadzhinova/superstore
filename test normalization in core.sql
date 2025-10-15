SELECT customer_id, COUNT(*) 
FROM core.customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1;
