INSERT INTO analytics.dim_customer (
    customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude
)
SELECT DISTINCT
    customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude
FROM analytics.orders_clean
ON CONFLICT (customer_id) DO NOTHING;


INSERT INTO analytics.dim_product (
    product_card_id,
    product_name,
    product_price,
    product_status,
    category_id,
    category_name,
    department_id,
    department_name
)
SELECT DISTINCT
    product_card_id,
    product_name,
    product_price,
    product_status,
    category_id,
    category_name,
    department_id,
    department_name
FROM analytics.orders_clean
ON CONFLICT (product_card_id) DO NOTHING;


INSERT INTO analytics.dim_date (
    order_date_dateorders,
    order_year,
    order_month,
    order_quarter,
    order_weekday
)
SELECT DISTINCT
    order_date_dateorders,
    order_year,
    order_month,
    order_quarter,
    order_weekday
FROM analytics.orders_clean
ON CONFLICT (order_date_dateorders) DO NOTHING;