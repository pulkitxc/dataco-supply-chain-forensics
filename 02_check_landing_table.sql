-- Verify landing table loaded from Python/to_sql

SELECT COUNT(*) AS total_rows
FROM analytics.orders_clean;

SELECT *
FROM analytics.orders_clean
LIMIT 10;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'analytics'
AND table_name = 'orders_clean'
ORDER BY ordinal_position;